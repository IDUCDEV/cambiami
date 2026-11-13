#!/usr/bin/env python3
"""Build the Cambiami brand assets from design/assets/emblem.png.

Outputs (design/assets/brand/):
  emblem.svg                    3 flat colours, cropped to content
  emblem-mono.svg               single colour silhouette (currentColor)
  app-icon-dark-1024.png        emblem on bg/inverse
  app-icon-cream-1024.png       emblem on bg/canvas
  android/ic_launcher_foreground-432.png
  android/ic_launcher_monochrome-432.png
  android/ic_notification-96.png
  preview/*.png                 size ladder for review
"""
import os
import cv2
import numpy as np

ROOT = "/home/iducdev/Escritorio/cambiami"
SRC = f"{ROOT}/design/assets/emblem.png"
OUT = f"{ROOT}/design/assets/brand"
DARK = "#29243D"
CREAM = "#FFF9F1"
PALETTE = {"W": "#FFD166", "V": "#9944EE", "C": "#20C6C8"}

os.makedirs(f"{OUT}/android", exist_ok=True)
os.makedirs(f"{OUT}/preview", exist_ok=True)

im = cv2.imread(SRC, cv2.IMREAD_UNCHANGED)
alpha = (im[:, :, 3] > 110).astype(np.uint8)
H, S, V = cv2.split(cv2.cvtColor(im[:, :, :3], cv2.COLOR_BGR2HSV))

raw = {
    "C": (H >= 76) & (H <= 119),
    "V": (H > 119) & (H <= 154),
    "W": (H < 40) | (H > 165),
}
masks = {k: (m & (alpha > 0)).astype(np.uint8) for k, m in raw.items()}
leftover = ((alpha > 0) & (sum(masks.values()) == 0)).astype(np.uint8)
if leftover.any():
    dist = np.stack([cv2.distanceTransform(1 - masks[k], cv2.DIST_L2, 5) for k in masks])
    winner = np.argmin(dist, axis=0)
    for i, k in enumerate(masks):
        masks[k] = masks[k] | (leftover & (winner == i)).astype(np.uint8)


def clean(m):
    m = cv2.GaussianBlur(m.astype(np.float32), (9, 9), 0)
    m = (m > 0.5).astype(np.uint8)
    return cv2.morphologyEx(m, cv2.MORPH_CLOSE, np.ones((7, 7), np.uint8))


def catmull(pts):
    n = len(pts)
    d = [f"M{pts[0][0]:.1f},{pts[0][1]:.1f}"]
    for i in range(n):
        p0, p1 = pts[(i - 1) % n], pts[i]
        p2, p3 = pts[(i + 1) % n], pts[(i + 2) % n]
        c1 = (p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6)
        c2 = (p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6)
        d.append(f"C{c1[0]:.1f},{c1[1]:.1f} {c2[0]:.1f},{c2[1]:.1f} {p2[0]:.1f},{p2[1]:.1f}")
    d.append("Z")
    return "".join(d)


def to_path(mask, eps=2.2, min_area=200):
    cnts, _ = cv2.findContours(mask, cv2.RETR_CCOMP, cv2.CHAIN_APPROX_SIMPLE)
    parts = []
    for c in cnts:
        if cv2.contourArea(c) < min_area:
            continue
        ap = cv2.approxPolyDP(c, eps, True).reshape(-1, 2)
        if len(ap) >= 4:
            parts.append(catmull([tuple(p) for p in ap]))
    return "".join(parts)


cleaned = {k: clean(m) for k, m in masks.items()}
ys, xs = np.where(alpha > 0)
x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
PAD_PX = 2
x0, y0, x1, y1 = x0 - PAD_PX, y0 - PAD_PX, x1 + PAD_PX, y1 + PAD_PX
W, Hh = x1 - x0, y1 - y0

# --- emblem.svg (3 colours, cropped) ---------------------------------------
# A base silhouette in the violet tone fills any hairline between regions;
# the three colour paths are then painted on top.
base = to_path(clean(alpha))
paths = f'  <path fill="{PALETTE["V"]}" fill-rule="evenodd" d="{base}"/>'
paths += "\n" + "\n".join(
    f'  <path fill="{PALETTE[k]}" fill-rule="evenodd" d="{to_path(cleaned[k])}"/>'
    for k in ("C", "V", "W")
)
open(f"{OUT}/emblem.svg", "w").write(
    f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{Hh}" '
    f'viewBox="{x0} {y0} {W} {Hh}">\n{paths}\n</svg>\n'
)

# --- emblem-mono.svg (silhouette, inherits colour) -------------------------
mono = to_path(clean(alpha))
open(f"{OUT}/emblem-mono.svg", "w").write(
    f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{Hh}" '
    f'viewBox="{x0} {y0} {W} {Hh}">\n  <path fill="currentColor" '
    f'fill-rule="evenodd" d="{mono}"/>\n</svg>\n'
)

print(f"emblem {W}x{Hh}  emblem.svg {os.path.getsize(f'{OUT}/emblem.svg')} B  "
      f"mono {os.path.getsize(f'{OUT}/emblem-mono.svg')} B")

# --- raster helpers --------------------------------------------------------
import subprocess


def render(svg, size, out, bg=None):
    cmd = ["magick", "-background", bg or "none", svg,
           "-resize", f"{size}x{size}", "-depth", "8", out]
    subprocess.run(cmd, check=True)


def compose(emblem_png, canvas, bg, coverage, out, fg=None):
    """Centre emblem_png on a square canvas at the given coverage."""
    target = int(canvas * coverage)
    tmp = "/tmp/opencode/_emblem_tmp.png"
    render(emblem_png, target, tmp)
    subprocess.run([
        "magick", "-size", f"{canvas}x{canvas}", f"xc:{bg}", tmp,
        "-gravity", "center", "-composite", "-depth", "8", out
    ], check=True)


# --- app icons -------------------------------------------------------------
compose(f"{OUT}/emblem.svg", 1024, DARK, 0.64, f"{OUT}/app-icon-dark-1024.png")
compose(f"{OUT}/emblem.svg", 1024, CREAM, 0.64, f"{OUT}/app-icon-cream-1024.png")

# --- android layers --------------------------------------------------------
render(f"{OUT}/emblem.svg", int(432 * 0.58), f"{OUT}/android/ic_launcher_foreground-432.png")
render(f"{OUT}/emblem-mono.svg", int(432 * 0.58), f"{OUT}/android/ic_launcher_monochrome-432.png")
# pad layers to 432 so the safe zone is explicit
for f in ("ic_launcher_foreground-432.png", "ic_launcher_monochrome-432.png"):
    p = f"{OUT}/android/{f}"
    subprocess.run(["magick", p, "-gravity", "center", "-background", "none",
                    "-extent", "432x432", "-depth", "8", p], check=True)

# notification icon: white silhouette on transparent, 96 px (24dp @4x)
subprocess.run([
    "magick", "-background", "none", f"{OUT}/emblem-mono.svg",
    "-resize", "72x72", "-fill", "white", "-colorize", "100",
    "-gravity", "center", "-background", "none", "-extent", "96x96",
    "-depth", "8", f"{OUT}/android/ic_notification-96.png"
], check=True)

# --- preview ladder --------------------------------------------------------
for name, bg in (("dark", DARK), ("cream", CREAM)):
    for size in (1024, 96, 48, 24):
        compose(f"{OUT}/emblem.svg", size, bg, 0.82,
                f"{OUT}/preview/{name}-{size}.png")

print("built:", sorted(os.listdir(OUT)))
