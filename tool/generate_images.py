# -*- coding: utf-8 -*-
"""
تولید تصاویر کارتونی ۳۳ حرف + ماسکوت روباه + آیکون اپ
با z-ai image (CLI) در استایل موکاپ‌های کاربر: کاوایی/استیکری پاستلی.

اجرا:  bash tool/generate_images.sh   (idempotent - موجودها را رد می‌کند)
"""
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "images" / "letters"

STYLE = ("cute kawaii cartoon sticker illustration for kids, "
         "soft pastel colors, light purple #9B7EBD coral #FF6B6B mint #4ECDC4 palette, "
         "cream background #FDF6F0, thick white sticker outline, flat vector style, "
         "adorable big sparkling eyes, centered single subject, "
         "children picture book style, high quality, no text, no letters, no words")

# (شناسه فایل، توضیح صحنه)
SCENES = [
    ("l01", "a cozy bird nest on a tree branch with a happy yellow baby chick inside"),
    ("l02", "a cute friendly horse standing and smiling"),
    ("l03", "a colorful diamond-shaped kite flying with a curly tail ribbon"),
    ("l04", "a small cheerful singing bird with open wings"),
    ("l05", "a classic round soccer ball toy with patches"),
    ("l06", "a wicker basket full of mixed colorful fruits"),
    ("l07", "a tiny fluffy yellow baby chick chick hatching from eggshell"),
    ("l08", "an open pastel umbrella with raindrops around"),
    ("l09", "a cute snail with a spiral purple shell crawling slowly"),
    ("l10", "a fresh green cucumber slice and whole cucumber"),
    ("l11", "a calm sea shore with gentle blue-green waves and a little sailboat"),
    ("l12", "a golden corn cob with green husk leaves"),
    ("l13", "a clever cute orange fox with fluffy tail (mascot friend)"),
    ("l14", "a tall smiling giraffe with long neck"),
    ("l15", "a cozy warm winter jacket with zipper"),
    ("l16", "a shiny red apple with a green leaf"),
    ("l17", "a friendly lion cub with fluffy mane"),
    ("l18", "an open seashell with a small pearl inside"),
    ("l19", "a happy green frog sitting on a lily pad"),
    ("l20", "a colorful parrot with bright feathers on a branch"),
    ("l21", "a cute bowl dish plate stacked with a small cup"),
    ("l22", "a honey jar dripping golden honey with a dipper"),
    ("l23", "a white goose with orange beak standing proudly"),
    ("l24", "a big kind gray elephant raising trunk"),
    ("l25", "a red-capped mushroom with white spots"),
    ("l26", "a cute little sneaker shoe with laces"),
    ("l27", "a fluffy white sheep with curly wool"),
    ("l28", "a bright yellow lemon with a green leaf"),
    ("l29", "a cheerful tropical fish swimming with bubbles"),
    ("l30", "a big gentle blue whale spouting water"),
    ("l31", "a small bathtub filled with bubbles and a rubber duck"),
    ("l32", "a juicy peach fruit with a leaf"),
    ("l33", "a sparkling ice cube with snowflakes"),
]


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    failed = []
    for lid, scene in SCENES:
        path = OUT / f"{lid}.png"
        if path.exists() and path.stat().st_size > 30_000:
            print(f"skip {lid}")
            continue
        prompt = f"{scene}, {STYLE}"
        r = subprocess.run(
            ["z-ai", "image", "-p", prompt, "-o", str(path), "-s", "1024x1024"],
            capture_output=True, text=True, timeout=180,
        )
        if r.returncode == 0 and path.exists():
            print(f"ok   {lid}")
        else:
            print(f"FAIL {lid}: {r.stderr[-200:] if r.stderr else 'unknown'}")
            failed.append(lid)
    # ماسکوت روباه برای صفحه خانه
    mascot = ROOT / "assets" / "images" / "mascot" / "fox.png"
    mascot.parent.mkdir(parents=True, exist_ok=True)
    if not mascot.exists():
        prompt = ("a cute kawaii orange fox mascot wearing a small purple backpack, waving hello, "
                  f"{STYLE}")
        r = subprocess.run(["z-ai", "image", "-p", prompt, "-o", str(mascot), "-s", "1024x1024"],
                           capture_output=True, text=True, timeout=180)
        print("mascot ok" if r.returncode == 0 else f"mascot FAIL: {r.stderr[-200:]}")
        if r.returncode != 0:
            failed.append("mascot")
    if failed:
        print("FAILED LIST:", ",".join(failed))
        sys.exit(1)
    print("همه تصاویر ساخته شدند ✔")


if __name__ == "__main__":
    main()
