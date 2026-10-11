#!/usr/bin/env bash
# ============================================================
#  انتشار نسخه جدید (بستن تگ → ساخت خودکار APK در Releases)
#  استفاده:
#     ./scripts/release_new_version.sh <TOKEN> <USERNAME> <REPO>            # پچ خودکار (1.0.0 → 1.0.1)
#     ./scripts/release_new_version.sh <TOKEN> <USERNAME> <REPO> 1.2.0      # نسخه دلخواه
# ============================================================
set -euo pipefail

TOKEN="${1:?❌ استفاده: release_new_version.sh <TOKEN> <USERNAME> <REPO> [VERSION]}"
GUSER="${2:?❌ نام کاربری گیت‌هاب را وارد کنید}"
REPO="${3:?❌ نام ریپو را وارد کنید}"
WANT_VER="${4:-}"

cd "$(dirname "$0")/.."

if [ ! -d .git ]; then
  git init -q
  git branch -M main 2>/dev/null || true
fi
git config user.name  "${GIT_AUTHOR_NAME:-Alefba Bot}"
git config user.email "${GIT_AUTHOR_EMAIL:-bot@alefba.ir}"

# --- خواندن نسخه فعلی از pubspec.yaml ---
CUR_VER=$(sed -n 's/^version: \([0-9]*\.[0-9]*\.[0-9]*\)+[0-9]*/\1/p' pubspec.yaml | head -n1)
CUR_BUILD=$(sed -n 's/^version: [0-9]*\.[0-9]*\.[0-9]*+\([0-9]*\)/\1/p' pubspec.yaml | head -n1)
[ -z "$CUR_BUILD" ] && CUR_BUILD=0
NEW_BUILD=$((CUR_BUILD + 1))

if [ -z "$WANT_VER" ]; then
  # افزایش خودکار پچ:  1.0.3 → 1.0.4
  MAJ=$(echo "$CUR_VER" | cut -d. -f1)
  MIN=$(echo "$CUR_VER" | cut -d. -f2)
  PAT=$(echo "$CUR_VER" | cut -d. -f3)
  WANT_VER="${MAJ}.${MIN}.$((PAT + 1))"
fi

sed -i -E "s/^version: .+/version: ${WANT_VER}+${NEW_BUILD}/" pubspec.yaml
echo "🔖 نسخه: ${CUR_VER}+${CUR_BUILD}  →  ${WANT_VER}+${NEW_BUILD}"

# --- ثبت در CHANGELOG ---
{
  echo ""
  echo "## ${WANT_VER} ($(date +%Y-%m-%d))"
  echo "- انتشار نسخه جدید با ساخت خودکار APK در گیت‌هاب"
} >> CHANGELOG.md

git add -A
git commit -q -m "🔖 نسخه ${WANT_VER}" --allow-empty
git tag -f "v${WANT_VER}"

git remote remove origin 2>/dev/null || true
git remote add origin "https://x-access-token:${TOKEN}@github.com/${GUSER}/${REPO}.git"

git push -u origin main
git push -f origin "v${WANT_VER}"
git remote remove origin

echo ""
echo "🎉 تگ v${WANT_VER} منتشر شد!"
echo "   👉 گیت‌هاب الان خودکار APK را می‌سازد (۲ تا ۵ دقیقه)."
echo "   👉 بعد از اتمام، فایل APK در اینجا است:"
echo "      https://github.com/${GUSER}/${REPO}/releases/tag/v${WANT_VER}"
