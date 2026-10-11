# 📱 آموزش کلاس اول — اپلیکیشن آموزش الفبا و اعداد (فارسی، آفلاین)

اپلیکیشن Flutter برای آموزش حروف الفبای فارسی به ترتیب کتاب درسی کلاس اول + اعداد ۰ تا ۱۰۰،
با صدای تلفظ انسانی، تصویر، تمرین نوشتن نقطه‌چین و ۴ نوع بازی — **کاملاً آفلاین**.

---

## ✨ امکانات

| بخش | توضیح |
|---|---|
| 🔤 ۳۳ حرف الفبا | به ترتیب استاندارد کتاب فارسی اول (آ تا ی) با کلمه شاهد و تصویر کارتونی |
| 🔊 صدای انسانی فارسی | تلفظ هر حرف (بَ، بِ، بُ)، هر کلمه، خوانش هجایی و اعداد ۰ تا ۱۰۰ — همه داخل اپ |
| 🔒 قفل مرحله‌ای | تا حرف قبلی کامل نشود (نوشتن + ۴ بازی) حرف بعدی باز نمی‌شود |
| ✏️ تمرین نوشتن | حرف به نقطه‌های قابل ردگیری تبدیل می‌شود؛ پوشش ۶۵٪ = قبولی |
| 🎮 ۴ بازی برای هر حرف | پیدا کن، جور کن، حافظه، بکش و بگذار |
| 🔢 اعداد ۰ تا ۱۰۰ | نمایش، تلفظ، شمارش تصویری و ۳ بازی عددی |
| 👨‍👩‍👧 داشبورد والدین | درصد پیشرفت، دقت، زمان بازی، وضعیت تک‌تک حروف |
| ⚙️ تنظیمات | قطع/وصل صدا، سرعت تلفظ (آهسته/معمولی/سریع)، ریست پیشرفت |
| 📴 کاملاً آفلاین | بدون مجوز اینترنت؛ هیچ داده‌ای ارسال نمی‌شود |

## 🎨 پالت رنگ و فونت

- بنفش ملایم `#9B7EBD` • مرجانی `#FF6B6B` • نعنایی `#4ECDC4`
- پس‌زمینه `#FDF6F0` • متن `#2C3E50`
- فونت **Vazirmatn** (Regular/Medium/SemiBold/Bold/Black) — از قبل در `assets/fonts` قرار دارد.

---

## 📁 ساختار پروژه

```
alefba_app/
├── .github/workflows/
│   └── build-apk.yml             # 🤖 ساخت خودکار APK در گیت‌هاب (هر پوش + هر تگ)
├── scripts/
│   ├── create_repo.sh            # ساخت ریپو در گیت‌هاب (بار اول)
│   ├── push_to_github.sh         # پوش خودکار با توکن
│   └── release_new_version.sh    # انتشار نسخه جدید (بامپ + تگ → APK در Releases)
├── pubspec.yaml                  # وابستگی‌ها + فونت + assets + آیکون لانچر
├── android_patch/                # فایل‌های اندروید (Manifest بدون اینترنت، امضا)
├── assets/
│   ├── audio/
│   │   ├── letters/              # ۱۶۲ فایل: صدای حرف، کلمه، معرفی، هجاها
│   │   ├── numbers/              # ۱۰۱ فایل: صفر تا صد
│   │   └── sfx/                  # جملات تشویقی و راهنما
│   ├── fonts/                    # Vazirmatn (۵ وزن)
│   └── images/
│       ├── letters/              # ۳۳ تصویر کارتونی l01.png … l33.png
│       └── mascot/               # روباهی (ماسکوت)
├── lib/
│   ├── main.dart                 # ورودی — RTL فارسی
│   ├── core/
│   │   ├── app_colors.dart       # پالت رنگ
│   │   ├── app_theme.dart        # تم Material 3
│   │   └── utils.dart            # ارقام فارسی + مسیر SFX
│   ├── data/
│   │   ├── models/               # LetterModel, NumberModel, ProgressModel
│   │   ├── letters_data.dart     # دیتای ۳۳ حرف (ترتیب کتاب درسی)
│   │   └── numbers_data.dart     # مولد اعداد ۰-۱۰۰ + نام فارسی
│   ├── services/
│   │   ├── storage_service.dart  # SharedPreferences (پیشرفت آفلاین)
│   │   └── audio_service.dart    # just_audio (دو پلیر: تلفظ + افکت)
│   ├── state/app_state.dart      # ChangeNotifier + منطق قفل مرحله‌ای
│   ├── features/writing/
│   │   └── writing_tracer.dart   # تمرین نوشتن نقطه‌چین با ردیابی انگشت
│   ├── games/
│   │   ├── game_scaffold.dart    # اسکلت مشترک بازی‌ها
│   │   ├── letter/               # find, match, memory, drag_drop
│   │   └── number/               # count, match, find
│   ├── screens/                  # ۸ صفحه اصلی
│   └── widgets/                  # دکمه فنری، هدر، جشن و…
└── tool/
    ├── apply_android_patch.sh    # اعمال پچ اندروید بعد از flutter create (در CI)
    ├── generate_audio.py         # بازتولید همه صداها (edge-tts فارسی)
    └── generate_images.py        # بازتولید تصاویر کارتونی
```

---

## 🤖 اتوماسیون گیت‌هاب — پوش خودکار + ساخت خودکار APK

این پروژه طوری تنظیم شده که **هیچ‌وقت نیازی به کامپیوتر با Flutter نداشته باشید**:

### ⚙️ ورک‌فلو خودکار (`.github/workflows/build-apk.yml`)

| رویداد | نتیجه |
|---|---|
| هر پوش به `main` | APK ساخته و در تب **Actions → Artifacts** همان اجرا آپلود می‌شود |
| انتشار تگ نسخه (`v1.0.0`، `v1.0.1`، …) | APK ساخته و در بخش **Releases** ریپو منتشر می‌شود |
| اجرای دستی | از تب Actions → دکمه `Run workflow` |

مراحل خودکار ورک‌فلو: نصب Java 17 + Flutter → `flutter create` (ساخت پوشه اندروید) → اعمال پچ آفلاین/نام فارسی → `pub get` → ساخت آیکون لانچر از روباهی 🦊 → `flutter build apk --release` → آپلود.

### 🧰 اسکریپت‌های آماده (پوش و نسخه‌بندی)

```bash
cd alefba_app

# ۱) فقط بار اول — ساخت ریپو در گیت‌هاب:
./scripts/create_repo.sh <TOKEN> <USERNAME> alefba-app

# ۲) هر بار که تغییری داده شد — پوش به گیت‌هاب (APK در Actions ساخته می‌شود):
./scripts/push_to_github.sh <TOKEN> <USERNAME> alefba-app "پیام بروزرسانی"

# ۳) انتشار نسخه جدید — شماره نسخه خودکار زیاد می‌شود (1.0.0 → 1.0.1)
#    و تگ زده می‌شود؛ APK جدید در بخش Releases ظاهر می‌شود:
./scripts/release_new_version.sh <TOKEN> <USERNAME> alefba-app

#    یا با شماره نسخه دلخواه:
./scripts/release_new_version.sh <TOKEN> <USERNAME> alefba-app 1.1.0
```

### 🔑 توکن لازم

- **Classic Token**: با دسترسی‌های `repo` و `workflow` ([اینجا بسازید](https://github.com/settings/tokens/new?scopes=repo,workflow&description=Alefba+Bot))
- یا **Fine-grained Token**: دسترسی `Contents: Read/Write` + `Workflows: Read/Write` روی همان ریپو
- 🔒 امنیت: توکن فقط هنگام اجرای دستور استفاده می‌شود، در هیچ فایلی ذخیره نمی‌شود؛ بعد از کار می‌توانید آن را از تنظیمات گیت‌هاب لغو (Revoke) کنید.

### 🔁 گردش کار نسخه‌های بعدی

1. تغییرات را بخواهید → کد آپدیت می‌شود.
2. «پوش کن» بگویید → `push_to_github.sh` اجرا می‌شود → APK در Artifacts آماده است.
3. «نسخه جدید بده» بگویید → `release_new_version.sh` اجرا می‌شود → نسخه + تگ جدید → APK رسمی در **Releases**.
4. برای کافه‌بازار همیشه آخرین فایل بخش Releases را بردارید.

---

## 🚀 اجرا و ساخت APK — قدم‌به‌قدم (روش محلی، اختیاری)

### قدم ۰: نصب Flutter
[Flutter SDK](https://docs.flutter.dev/get-started/install) (۳٫۲۴ به بالا) + Android SDK را نصب کنید:

```bash
flutter doctor   # باید همه ✅ باشند
```

### قدم ۱: تولید پوشه‌های پلتفرم
پوشه‌های `android/` و… نسخه‌بندی‌شده با Flutter شما ساخته می‌شود:

```bash
cd alefba_app
flutter create . --org ir.persiankids --project-name first_grade_persian
```

### قدم ۲: اعظم فایل‌های اندروید (آفلاین + نام فارسی)

1. محتوای `android_patch/AndroidManifest.xml` را روی
   `android/app/src/main/AndroidManifest.xml` بگذارید
   (فقط مطمئن شوید مسیر `.MainActivity` با پکیج شما یکی است).
2. `android_patch/MainActivity.kt` را در
   `android/app/src/main/kotlin/ir/persiankids/firstgradepersian/` قرار دهید.

### قدم ۳: اجرا

```bash
flutter pub get
flutter run
```

### قدم ۴: آیکون اپ (اختیاری ولی توصیه‌شده)
از `assets/images/maskot/fox.png` به‌عنوان آیکون استفاده کنید:

```bash
flutter pub add dev:flutter_launcher_icons
```
و در `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  image_path: "assets/images/mascot/fox.png"
  adaptive_icon_background: "#FDF6F0"
  adaptive_icon_foreground: "assets/images/mascot/fox.png"
```
سپس:
```bash
flutter pub run flutter_launcher_icons
```

### قدم ۵: ساخت APK خروجی

```bash
# APK مستقیم برای تست:
flutter build apk --release --split-per-abi

# خروجی نهایی برای کافه‌بازار (App Bundle):
flutter build appbundle --release
```
فایل‌ها در `build/app/outputs/` قرار می‌گیرند.

---

## 🏪 انتشار در کافه‌بازار

1. **امضای Release** — طبق `android_patch/key.properties.example` کلید بسازید و
   `build.gradle` را ویرایش کنید.
2. **فایل خروجی** — کافه‌بازار فایل `.aab` یا `.apk` امضاشده می‌پذیرد.
3. **مدارک** — مجوز نشر اپ کودک را از پنل کافه‌بازار تکمیل کنید
   (اپ فاقد اینترنت، فاقد تبلیغ، فاقد خرید درون‌برنامه‌ای است).
4. **متن معرفی پیشنهادی**:
   > آموزش الفبا و اعداد برای کلاس اولی‌ها — با صدای فارسی، تصویر، تمرین نوشتن و بازی.
   > کاملاً آفلاین، بدون تبلیغ، بدون اینترنت. حرف‌ها به ترتیب کتاب درسی، یکی‌یکی باز می‌شوند.
5. **اسکرین‌شات** — از صفحات خانه، درس حرف، تمرین نوشتن، بازی‌ها و اعداد بگیرید.
6. **طبقه‌بندی** — آموزش کودکان / پیش‌دبستانی و اول ابتدایی.
7. **رتبه‌بندی سنی** — «همه سنین» / زیر ۵ سال.

---

## 🔧 بازتولید Assetها (اختیاری)

همه صداها و تصاویر از قبل ساخته و داخل پروژه هستند. برای تغییر یا بازسازی:

```bash
# صداها (به اینترنت نیاز دارد؛ خروجی آفلاین داخل اپ استفاده می‌شود)
pip install edge-tts
python3 tool/generate_audio.py

# تصاویر کارتونی
python3 tool/generate_images.py
```

- صدای فارسی: `fa-IR-DilaraNeural` (صدای عصبی مایکروسافت)
- اگر خواستید تصویر یک حرف را عوض کنید، فقط `assets/images/letters/lXX.png`
  را با همان نام جایگزین کنید — اپ خودکار از آن استفاده می‌کند.
- اگر تصویری موجود نباشد، اپ به‌صورت خودکار از ایموجی همان حرف استفاده می‌کند.

## 🧠 نکات فنی

- **ذخیره‌سازی**: `SharedPreferences` با JSON — سبک، سریع و بدون وابستگی اضافه.
  اگر بعداً به مدل داده پیچیده‌تر نیاز داشتید، جای `StorageService` با Hive به‌راحتی عوض می‌شود
  (کل رابط در یک فایل است).
- **صدا**: `just_audio` با دو پلیر مجزا (تلفظ/افکت) تا تشویق‌ها روی درس جایگزین نشوند.
  سرعت پخش با `setSpeed` از تنظیمات اعمال می‌شود.
- **قفل مرحله‌ای**: منطق در `AppState.completeLetterPart` — اتمام ۵ بخش حرف = باز شدن حرف بعدی.
- **تمرین نوشتن**: گلیف حرف با `TextPainter` رستر و به شبکه ۱۸×۲۲ نقطه تبدیل می‌شود؛
  پوشش ۶۵٪ نقطه‌ها با انگشت = قبولی.
