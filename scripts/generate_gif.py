#!/usr/bin/env python3
"""
Generates a looping GIF for the README at docs/gifs/stitching-3d.gif
Simple animated stitching unit scene using Pillow (no external assets).
"""

from PIL import Image, ImageDraw
from math import sin
from pathlib import Path

WIDTH = 960
HEIGHT = 320
FPS = 24
DURATION_S = 6
FRAMES = FPS * DURATION_S


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def lerp_color(c1: tuple[int, int, int], c2: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return (
        int(lerp(c1[0], c2[0], t)),
        int(lerp(c1[1], c2[1], t)),
        int(lerp(c1[2], c2[2], t)),
    )


def draw_background(draw: ImageDraw.ImageDraw, t: float) -> None:
    # diagonal gradient bg
    top_left = (15, 23, 42)   # #0F172A
    bottom_right = (30, 41, 59)  # #1E293B
    steps = 80
    for i in range(steps):
        c = lerp_color(top_left, bottom_right, i / (steps - 1))
        y0 = int(i * HEIGHT / steps)
        y1 = int((i + 1) * HEIGHT / steps)
        draw.rectangle((0, y0, WIDTH, y1), fill=c)

    # flowing threads
    threads = [(108, 99, 255, 230), (0, 194, 255, 153)]  # (r,g,b,a)
    for idx, (r, g, b, a) in enumerate(threads):
        points = []
        for x in range(0, WIDTH + 1, 8):
            y = int(HEIGHT * 0.76 + sin(x * 0.02 + t * 2 + idx) * 12 + idx * 6)
            points.append((x, y))
        for i in range(len(points) - 1):
            draw.line((points[i], points[i + 1]), fill=(r, g, b, a), width=3)


def round_rect(draw: ImageDraw.ImageDraw, bbox: tuple[int, int, int, int], radius: int, fill: tuple[int, int, int]):
    x0, y0, x1, y1 = bbox
    draw.rounded_rectangle(bbox, radius=radius, fill=fill)


def circle(draw: ImageDraw.ImageDraw, cx: int, cy: int, r: int, fill: tuple[int, int, int]):
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=fill)


def draw_station(draw: ImageDraw.ImageDraw, cx: int, cy: int, t: float, hue_shift: float = 0.0):
    # desk
    round_rect(draw, (cx - 120, cy + 40, cx + 120, cy + 52), radius=6, fill=(31, 41, 55))  # #1F2937
    # machine
    round_rect(draw, (cx - 40, cy, cx + 80, cy + 30), radius=6, fill=(148, 163, 184))  # #94A3B8
    round_rect(draw, (cx + 60, cy + 5, cx + 74, cy + 21), radius=3, fill=(148, 163, 184))
    circle(draw, cx - 16, cy + 15, 6, (203, 213, 225))  # wheel #CBD5E1
    # worker
    circle(draw, cx + 110, int(cy - 8 + sin(t * 2) * 2), 18, (226, 232, 240))  # head #E2E8F0
    round_rect(draw, (cx + 92, cy + 10, cx + 128, cy + 36), radius=8, fill=(100, 116, 139))  # torso #64748B
    # thread (quadratic bezier approximated with segments)
    p0 = (cx + 10, cy + 10)
    p1 = (cx + 40, int(cy - 20 + sin(t * 2 + hue_shift) * 10))
    p2 = (cx + 80, cy + 6)
    def q(tq):
        # Quadratic Bezier interpolation
        x = int((1 - tq) ** 2 * p0[0] + 2 * (1 - tq) * tq * p1[0] + tq ** 2 * p2[0])
        y = int((1 - tq) ** 2 * p0[1] + 2 * (1 - tq) * tq * p1[1] + tq ** 2 * p2[1])
        return (x, y)
    # color lerp between #6C63FF and #00C2FF
    def lerp_hex(a, b, tval):
        ar, ag, ab = a
        br, bg, bb = b
        return (
            int(lerp(ar, br, tval)),
            int(lerp(ag, bg, tval)),
            int(lerp(ab, bb, tval)),
        )
    col = lerp_hex((108, 99, 255), (0, 194, 255), (sin(t + hue_shift) + 1) / 2)
    prev = q(0.0)
    for j in range(1, 21):
        cur = q(j / 20.0)
        draw.line((prev, cur), fill=col, width=3)
        prev = cur


def main():
    out_dir = Path(__file__).resolve().parents[1] / 'docs' / 'gifs'
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / 'stitching-3d.gif'

    frames = []
    for i in range(FRAMES):
        t = i / FPS
        img = Image.new('RGBA', (WIDTH, HEIGHT), (15, 23, 42, 255))
        draw = ImageDraw.Draw(img, 'RGBA')
        draw_background(draw, t)
        draw_station(draw, int(WIDTH * 0.2), int(HEIGHT * 0.45), t + 0.0, 0.0)
        draw_station(draw, int(WIDTH * 0.5), int(HEIGHT * 0.45), t + 0.4, 0.2)
        draw_station(draw, int(WIDTH * 0.8), int(HEIGHT * 0.45), t + 0.8, 0.4)
        frames.append(img.convert('P', palette=Image.ADAPTIVE))

    # Save as GIF
    frames[0].save(
        out_path,
        save_all=True,
        append_images=frames[1:],
        duration=int(1000 / FPS),
        loop=0,
        optimize=True,
        disposal=2,
    )
    print(f"Wrote {out_path}")


if __name__ == '__main__':
    main()


