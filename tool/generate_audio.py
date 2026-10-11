# -*- coding: utf-8 -*-
"""
تولید خودکار تمام فایل‌های صوتی اپ «آموزش کلاس اول»
با صدای عصبی بومی فارسی (fa-IR-DilaraNeural) از edge-tts.
خروجی‌ها داخل assets/audio بسته می‌شوند => اپ کاملاً آفلاین است.

اجرا:  python3 tool/generate_audio.py
اسکریپت idempotent است: فایل‌های موجود را دوباره نمی‌سازد.
"""
import asyncio
import pathlib
import sys

import edge_tts

ROOT = pathlib.Path(__file__).resolve().parent.parent
VOICE = "fa-IR-DilaraNeural"
RATE = "-5%"  # کمی آرام‌تر برای کودکان
CONCURRENCY = 3

# ────────────────────────────── داده حروف (به ترتیب کتاب فارسی اول) ─────────────
# (شناسه, حرف, متن صدای حرف با حرکت, کلمه)
LETTERS = [
    # (شناسه, حرف, متن صدای حرف با حرکت, کلمه, [هجاها])
    ("l01", "آ", "آ", "آشیانه", ["آ", "شیا", "نه"]),
    ("l02", "ا", "اَ، اِ، اُ", "اسب", ["اَسب"]),
    ("l03", "ب", "بَ، بِ، بُ", "بادبادک", ["با", "با", "دَک"]),
    ("l04", "پ", "پَ، پِ، پُ", "پرنده", ["پَ", "رن", "ده"]),
    ("l05", "ت", "تَ، تِ، تُ", "توپ", ["توپ"]),
    ("l06", "ث", "ثَ، ثِ، ثُ", "ثمر", ["ثَ", "مر"]),
    ("l07", "ج", "جَ، جِ، جُ", "جوجه", ["جو", "جه"]),
    ("l08", "چ", "چَ، چِ، چُ", "چتر", ["چَ", "تر"]),
    ("l09", "ح", "حَ، حِ، حُ", "حلزون", ["حَل", "زون"]),
    ("l10", "خ", "خَ، خِ، خُ", "خیار", ["خِ", "یار"]),
    ("l11", "د", "دَ، دِ، دُ", "دریا", ["دَر", "یا"]),
    ("l12", "ذ", "ذَ، ذِ، ذُ", "ذرت", ["ذُ", "رَت"]),
    ("l13", "ر", "رَ، رِ، رُ", "روباه", ["رو", "باه"]),
    ("l14", "ز", "زَ، زِ، زُ", "زرافه", ["زَ", "را", "فه"]),
    ("l15", "ژ", "ژَ، ژِ، ژُ", "ژاکت", ["ژا", "کت"]),
    ("l16", "س", "سَ، سِ، سُ", "سیب", ["سیب"]),
    ("l17", "ش", "شَ، شِ، شُ", "شیر", ["شیر"]),
    ("l18", "ص", "صَ، صِ، صُ", "صدف", ["صَ", "دَف"]),
    ("l19", "ض", "ضَ، ضِ، ضُ", "ضفدع", ["ضَف", "دَع"]),
    ("l20", "ط", "طَ، طِ، طُ", "طوطی", ["طو", "طی"]),
    ("l21", "ظ", "ظَ، ظِ، ظُ", "ظرف", ["ظَ", "رَف"]),
    ("l22", "ع", "عَ، عِ، عُ", "عسل", ["عَ", "سَل"]),
    ("l23", "غ", "غَ، غِ، غُ", "غاز", ["غاز"]),
    ("l24", "ف", "فَ، فِ، فُ", "فیل", ["فیل"]),
    ("l25", "ق", "قَ، قِ، قُ", "قارچ", ["قار", "چه"]),
    ("l26", "ک", "کَ، کِ، کُ", "کفش", ["کَ", "فِش"]),
    ("l27", "گ", "گَ، گِ، گُ", "گوسفند", ["گو", "سف", "ند"]),
    ("l28", "ل", "لَ، لِ، لُ", "لیمو", ["لی", "مو"]),
    ("l29", "م", "مَ، مِ، مُ", "ماهی", ["ما", "هی"]),
    ("l30", "ن", "نَ، نِ، نُ", "نهنگ", ["نَ", "هنگ"]),
    ("l31", "و", "وَ، وِ، وُ", "وان", ["وان"]),
    ("l32", "ه", "هَ، هِ، هُ", "هلو", ["هَ", "لو"]),
    ("l33", "ی", "یَ، یِ، یُ", "یخ", ["یخ"]),
]

# ────────────────────────────── نام اعداد ۰ تا ۱۰۰ ──────────────────────────────
ONES = ["صفر", "یک", "دو", "سه", "چهار", "پنج", "شش", "هفت", "هشت", "نه"]
TEENS = ["ده", "یازده", "دوازده", "سیزده", "چهارده", "پانزده", "شانزده",
         "هفده", "هجده", "نوزده"]
TENS = {2: "بیست", 3: "سی", 4: "چهل", 5: "پنجاه", 6: "شصت", 7: "هفتاد",
        8: "هشتاد", 9: "نود"}


def number_name(n: int) -> str:
    if n < 10:
        return ONES[n]
    if n < 20:
        return TEENS[n - 10]
    if n == 100:
        return "صد"
    tens_part = TENS[n // 10]
    rest = n % 10
    return f"{tens_part} و {ONES[rest]}" if rest else tens_part


# ────────────────────────────── افکت‌ها و جمله‌های صوتی ────────────────────────
SFX = {
    "praise_1": "آفرین!",
    "praise_2": "عالی بود!",
    "praise_3": "دمت گرم!",
    "praise_4": "چه خوب شد!",
    "praise_5": "درست بود!",
    "retry_1": "اشکالی نداره، یک بار دیگه!",
    "retry_2": "نزدیک بود، دوباره تلاش کن!",
    "retry_3": "یه بار دیگه امتحان کنیم!",
    "ui_go": "بزن بریم!",
    "ui_play": "بریم بازی کنیم!",
    "ui_star": "ستونده!",
    "hello": "سلام! من روباهی‌ام. بیا با هم الفبا یاد بگیریم!",
    "lock_hint": "برای باز شدن این حرف، اول حرف قبلی رو کامل کن!",
    "write_done": "چه خط قشنگی نوشتی!",
}


def build_tasks():
    """لیست کامل (مسیر خروجی، متن) برای همه صداها."""
    jobs = []

    out_letters = ROOT / "assets" / "audio" / "letters"
    out_numbers = ROOT / "assets" / "audio" / "numbers"
    out_sfx = ROOT / "assets" / "audio" / "sfx"

    for lid, _ch, sound, word, syls in LETTERS:
        # صدای حرف: بَ، بِ، بُ
        jobs.append((out_letters / f"{lid}_sound.mp3", sound))
        # صدای کلمه
        jobs.append((out_letters / f"{lid}_word.mp3", word))
        # جمله معرفی: «این حرف ب است؛ مثل بادبادک»
        jobs.append((out_letters / f"{lid}_intro.mp3", f"این حرف {_ch} است. مثل {word}!"))
        # صدای تک‌تک هجاها برای خوانش پله‌ای
        for si, syl in enumerate(syls):
            jobs.append((out_letters / f"{lid}_syl_{si}.mp3", syl))

    for n in range(0, 101):
        jobs.append((out_numbers / f"n{n:03d}.mp3", number_name(n)))

    for key, text in SFX.items():
        jobs.append((out_sfx / f"{key}.mp3", text))

    return jobs


async def gen_one(sem, text, out_path, retries=3):
    out_path.parent.mkdir(parents=True, exist_ok=True)
    if out_path.exists() and out_path.stat().st_size > 1024:
        return ("skip", out_path.name)
    for attempt in range(1, retries + 1):
        try:
            async with sem:
                comm = edge_tts.Communicate(text, VOICE, rate=RATE)
                await comm.save(str(out_path))
            await asyncio.sleep(0.25)
            if out_path.stat().st_size > 1024:
                return ("ok", out_path.name)
            raise RuntimeError("فایل خیلی کوچک است")
        except Exception as exc:  # noqa: BLE001
            if attempt == retries:
                return ("fail", f"{out_path.name}: {exc}")
            await asyncio.sleep(1.5 * attempt)
    return ("fail", out_path.name)


async def main():
    jobs = build_tasks()
    print(f"تعداد کل فایل‌های صوتی: {len(jobs)}")
    sem = asyncio.Semaphore(CONCURRENCY)
    results = await asyncio.gather(*(gen_one(sem, t, p) for p, t in jobs))

    ok = sum(1 for s, _ in results if s in ("ok", "skip"))
    fails = [m for s, m in results if s == "fail"]
    print(f"موفق: {ok} / {len(jobs)}")
    if fails:
        print("ناموفق:")
        for f in fails:
            print("  -", f)
        sys.exit(1)
    print("همه صداها ساخته شدند ✔")


if __name__ == "__main__":
    asyncio.run(main())
