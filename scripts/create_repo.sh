#!/usr/bin/env bash
# ============================================================
#  ساخت ریپو در گیت‌هاب (فقط بار اول لازم است)
#  استفاده:  ./scripts/create_repo.sh <TOKEN> <USERNAME> [REPO_NAME]
# ============================================================
set -euo pipefail

TOKEN="${1:?❌ استفاده: create_repo.sh <TOKEN> <USERNAME> [REPO_NAME]}"
GUSER="${2:?❌ نام کاربری گیت‌هاب را وارد کنید}"
REPO="${3:-alefba-app}"

echo "🌐 در حال ساخت ریپو $GUSER/$REPO ..."

CODE=$(curl -s -o /tmp/gh_create_resp.json -w "%{http_code}" -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d "{\"name\":\"$REPO\",\"description\":\"اپلیکیشن آموزش الفبا و اعداد کلاس اول — فارسی و کاملاً آفلاین\",\"private\":false,\"has_wiki\":false,\"auto_init\":false}")

if [ "$CODE" = "201" ]; then
  echo "✅ ریپو ساخته شد: https://github.com/$GUSER/$REPO"
elif [ "$CODE" = "422" ]; then
  echo "ℹ️  این ریپو از قبل موجود است — ادامه می‌دهیم."
else
  echo "❌ خطا (کد $CODE):"
  cat /tmp/gh_create_resp.json
  exit 1
fi
