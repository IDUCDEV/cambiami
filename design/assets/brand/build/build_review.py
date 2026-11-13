#!/usr/bin/env python3
"""Compose a single review sheet for the brand assets (design review only)."""
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = "/home/iducdev/Escritorio/cambiami"
B = f"{ROOT}/design/assets/brand"
OUT = f"{B}/preview/00-review.png"
DARK = (0x29, 0x24, 0x3D)
CREAM = (0xFF, 0xF9, 0xF1)
WHITE = (0xFF, 0xFF, 0xFF)
MUTED = (0x6B, 0x66, 0x73)

FONT_DIR = "/usr/share/fonts/liberation-sans-fonts"
f_title = ImageFont.truetype(f"{FONT_DIR}/LiberationSans-Bold.ttf", 30)
f_h2 = ImageFont.truetype(f"{FONT_DIR}/LiberationSans-Bold.ttf", 17)
f_lbl = ImageFont.truetype(f"{FONT_DIR}/LiberationSans-Regular.ttf", 13)
f_small = ImageFont.truetype(f"{FONT_DIR}/LiberationSans-Regular.ttf", 12)

W = 1500
PAD = 44
canvas = Image.new("RGB", (W, 1500), CREAM)
d = ImageDraw.Draw(canvas)

y = PAD
d.text((PAD, y), "Cambiami · assets de marca", font=f_title, fill=DARK)
y += 40
d.text((PAD, y), "Emblema plano (A) · 3 colores del sistema · wordmark en curvas · iconos",
       font=f_lbl, fill=MUTED)
y += 46


def tile(img, x, y, box, bg, radius=18):
    t = Image.new("RGB", (box, box), bg)
    if img.mode == "RGBA":
        t.paste(img, ((box - img.width) // 2, (box - img.height) // 2), img)
    else:
        t.paste(img, ((box - img.width) // 2, (box - img.height) // 2))
    mask = Image.new("L", (box, box), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, box - 1, box - 1], radius, fill=255)
    canvas.paste(t, (x, y), mask)


def caption(text, x, y, w, font=f_small, fill=MUTED):
    tw = d.textlength(text, font=font)
    d.text((x + (w - tw) / 2, y), text, font=font, fill=fill)


# --- 1. icono de app -------------------------------------------------------
d.text((PAD, y), "Icono de app", font=f_h2, fill=DARK)
y += 30
dark = Image.open(f"{B}/app-icon-dark-1024.png").resize((240, 240), Image.LANCZOS)
cream = Image.open(f"{B}/app-icon-cream-1024.png").resize((240, 240), Image.LANCZOS)
fg = Image.open(f"{B}/android/ic_launcher_foreground-432.png").resize((240, 240), Image.LANCZOS)
mono = Image.open(f"{B}/android/ic_launcher_monochrome-432.png").resize((240, 240), Image.LANCZOS)
items = [
    (dark, DARK, "app-icon-dark-1024"),
    (cream, CREAM, "app-icon-cream-1024"),
    (fg, DARK, "adaptive foreground"),
    (mono, DARK, "monochrome (Android 13)"),
]
x = PAD
for img, bg, label in items:
    tile(img, x, y, 240, bg)
    caption(label, x, y + 250, 240)
    x += 260
y += 290

# --- 2. escalera de tamaño ------------------------------------------------
d.text((PAD, y), "Escalera de tamaño", font=f_h2, fill=DARK)
y += 30
for tone, bg, x0 in (("dark", DARK, PAD), ("cream", CREAM, PAD + 470)):
    for i, size in enumerate((96, 48, 24)):
        src = Image.open(f"{B}/preview/{tone}-{size}.png").convert("RGBA")
        tile(src, x0 + i * 150, y, 120, bg, radius=14)
        caption(f"{size} px", x0 + i * 150, y + 126, 120)
y += 170

# --- 3. wordmark -----------------------------------------------------------
d.text((PAD, y), "Wordmark (Nunito 800 · 32 px · tracking −0,5)", font=f_h2, fill=DARK)
y += 34
for tone, bg, x0 in (("dark", DARK, PAD), ("cream", CREAM, PAD + 470)):
    for i, size in enumerate((160, 64, 32)):
        src = Image.open(f"{B}/preview/wordmark-{tone}-{size}.png").convert("RGB")
        box_w = 420
        t = Image.new("RGB", (box_w, 70), bg)
        t.paste(src, (12, (70 - src.height) // 2))
        canvas.paste(t, (x0, y + i * 82))
        caption(f"{size} px", x0, y + i * 82 + 52, box_w, fill=(MUTED if bg == CREAM else (185, 174, 220)))
y += 3 * 82 + 20

# --- 4. notas --------------------------------------------------------------
d.text((PAD, y), "Comprobaciones", font=f_h2, fill=DARK)
y += 28
notes = [
    "Silueta del emblema: IoU 0,991 frente al PNG original · tintas 48,4 / 45,1 / 6,5 % (idénticas)",
    "Sin costuras interiores: 0,0004 % de huecos a más de 6 px del borde (silueta base violeta)",
    "Icono oscuro: contraste 3,12:1 (violeta), 7,05:1 (teal), 10,30:1 (ámbar) — WCAG 1.4.11",
    "Icono crema: el teal cae a 2,01:1 y el ámbar a 1,38:1 → no recomendado",
    "Wordmark: avance 141,01 px = nodo n4R8P del .pen (141 px) · 7 huecos en la misma posición",
    "Adaptive foreground: 243×250 px dentro de la zona segura de 288 px",
]
for n in notes:
    d.text((PAD + 8, y), f"· {n}", font=f_lbl, fill=DARK)
    y += 24

canvas = canvas.crop((0, 0, W, y + PAD))
canvas.save(OUT)
print("wrote", OUT, canvas.size)
