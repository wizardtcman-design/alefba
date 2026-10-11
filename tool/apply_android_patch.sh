#!/usr/bin/env bash
# ============================================================
#  اعمال پچ‌های اندروید بعد از «flutter create»
#  این اسکریپت در CI (GitHub Actions) و روی سیستم محلی یکسان کار می‌کند:
#   ۱) جایگزینی AndroidManifest با نسخه آفلاین (بدون مجوز اینترنت + نام فارسی)
#   ۲) جایگزینی MainActivity با پکیج ir.alefbaman.alefba
# ============================================================
set -euo pipefail
cd "$(dirname "$0")/.."

MANIFEST_SRC="android_patch/AndroidManifest.xml"
MANIFEST_DST="android/app/src/main/AndroidManifest.xml"
ACT_SRC="android_patch/MainActivity.kt"
ACT_DIR="android/app/src/main/kotlin/ir/alefbaman/alefba"

if [ ! -f "$MANIFEST_DST" ]; then
  echo "❌ خطا: $MANIFEST_DST پیدا نشد."
  echo "   اول «flutter create . --org ir.alefbaman --project-name alefba» را اجرا کنید."
  exit 1
fi

cp "$MANIFEST_SRC" "$MANIFEST_DST"
mkdir -p "$ACT_DIR"
cp "$ACT_SRC" "$ACT_DIR/MainActivity.kt"

echo "✅ پچ اندروید اعمال شد:"
echo "   - AndroidManifest.xml  → بدون مجوز اینترنت + نام فارسی «آموزش کلاس اول»"
echo "   - MainActivity.kt      → package ir.alefbaman.alefba"
