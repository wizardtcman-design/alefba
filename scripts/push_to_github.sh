#!/usr/bin/env bash
# ============================================================
#  پوش خودکل پروژه به گیت‌هاب
#  استفاده:  ./scripts/push_to_github.sh <TOKEN> <USERNAME> <REPO> [پیام کامیت]
#
#  نکته امنیتی: توکن فقط در همین دستور استفاده می‌شود و در .git/config ذخیره نمی‌شود.
# ============================================================
set -euo pipefail

TOKEN="${1:?❌ استفاده: push_to_github.sh <TOKEN> <USERNAME> <REPO> [MESSAGE]}"
GUSER="${2:?❌ نام کاربری گیت‌هاب را وارد کنید}"
REPO="${3:?❌ نام ریپو را وارد کنید}"
MSG="${4:-✨ بروزرسانی اپلیکیشن آموزش کلاس اول}"

cd "$(dirname "$0")/.."

# آماده‌سازی مخزن محلی
if [ ! -d .git ]; then
  git init -q
  git branch -M main 2>/dev/null || true
fi
git config user.name  "${GIT_AUTHOR_NAME:-Alefba Bot}"
git config user.email "${GIT_AUTHOR_EMAIL:-bot@alefba.ir}"

git add -A
if git diff --cached --quiet; then
  echo "ℹ️  تغییر جدیدی وجود ندارد — پوش خالی انجام می‌شود تا sync بماند."
fi
git commit -q -m "$MSG" --allow-empty
git branch -M main

# پوش با توکن (بدون ذخیره توکن در config)
git remote remove origin 2>/dev/null || true
git remote add origin "https://x-access-token:${TOKEN}@github.com/${GUSER}/${REPO}.git"

if git push -u origin main; then
  echo "✅ پوش شد: https://github.com/${GUSER}/${REPO}"
  echo "🛠 ساخت APK خودکار در تب Actions شروع شد؛ چند دقیقه صبر کنید."
else
  echo "⚠️  پوش معمولی رد شد (ریپو ممکن است کمیته اولیه داشته باشد) — force push می‌زنم..."
  git push -u origin main --force
  echo "✅ Force push انجام شد: https://github.com/${GUSER}/${REPO}"
fi

# پاک کردن ریموت برای حذف توکن از config
git remote remove origin
