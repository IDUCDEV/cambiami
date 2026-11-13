#!/usr/bin/env python3
"""Build the Cambiami wordmark as vector outlines.

Source of truth: DESIGN_SYSTEM type/h2 — Nunito 800, 32 px, tracking -0.5.
The .pen node `n4R8P` measures 141 px wide at that setting; this script must
produce the same advance width.

Requires: fonttools (pip install fonttools)
"""
import os
import subprocess

from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

ROOT = "/home/iducdev/Escritorio/cambiami"
FONT = f"{ROOT}/design/assets/fonts/Nunito-VariableFont_wght.ttf"
OUT = f"{ROOT}/design/assets/brand"
TEXT = "cambiami"
SIZE = 32.0
TRACKING = -0.5
WEIGHT = 800
REFERENCE_WIDTH = 141.0  # .pen node n4R8P


def build(fill):
    font = instantiateVariableFont(
        TTFont(FONT), {"wght": WEIGHT}, inplace=True, updateFontNames=False
    )
    upm = font["head"].unitsPerEm
    glyphset = font.getGlyphSet()
    cmap = font.getBestCmap()
    hmtx = font["hmtx"]
    scale = SIZE / upm

    pen = SVGPathPen(glyphset)
    bounds = BoundsPen(glyphset)
    x = 0.0
    for ch in TEXT:
        gname = cmap[ord(ch)]
        glyphset[gname].draw(TransformPen(pen, (scale, 0, 0, -scale, x, 0)))
        glyphset[gname].draw(TransformPen(bounds, (scale, 0, 0, -scale, x, 0)))
        x += hmtx[gname][0] * scale + TRACKING
    advance = x - TRACKING  # last gap is not part of the word

    xmin, ymin, xmax, ymax = bounds.bounds
    w, h = xmax - xmin, ymax - ymin
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{w:.2f}" height="{h:.2f}" '
        f'viewBox="0 0 {w:.2f} {h:.2f}">\n'
        f'  <path fill="{fill}" d="{pen.getCommands()}" '
        f'transform="translate({-xmin:.2f},{-ymin:.2f})"/>\n</svg>\n'
    ), advance, (w, h)


variants = {
    "wordmark.svg": "#FFF9F1",        # sobre bg/inverse
    "wordmark-purple.svg": "#9944EE",  # sobre bg/canvas
    "wordmark-mono.svg": "currentColor",
}
os.makedirs(OUT, exist_ok=True)
for name, fill in variants.items():
    svg, advance, size = build(fill)
    open(f"{OUT}/{name}", "w").write(svg)
    print(f"{name}: advance {advance:.2f} px (ref {REFERENCE_WIDTH}), "
          f"ink {size[0]:.2f}x{size[1]:.2f}, {len(svg)} B")

# previews: same sizes as the .pen (32) plus 64 and 160 for review
os.makedirs(f"{OUT}/preview", exist_ok=True)
for bg, tone, src in (
    ("#29243D", "dark", f"{OUT}/wordmark.svg"),
    ("#FFF9F1", "cream", f"{OUT}/wordmark-purple.svg"),
):
    for size in (160, 64, 32):
        subprocess.run([
            "magick", "-background", bg, src,
            "-resize", f"x{size}", "-bordercolor", bg, "-border", "12",
            "-depth", "8", f"{OUT}/preview/wordmark-{tone}-{size}.png"
        ], check=True)
print("wordmark previews written")
