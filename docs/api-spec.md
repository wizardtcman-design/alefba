# مستندات API هسته پروژه «الفبای من»

این سند قراردادهای بین ماژول‌های هسته و صفحات/بازی‌ها را توضیح می‌دهد.
هسته (theme / models / data / services / provider / widgets / games_page) توسط عامل اصلی نوشته شده است.

## پالت رنگ — lib/theme/app_theme.dart
- `AppColors.purple` = `#9B7EBD` (اصلی)
- `AppColors.coral` = `#FF6B6B`
- `AppColors.mint` = `#4ECDC4`
- `AppColors.background` = `#FDF6F0`
- `AppColors.text` = `#2C3E50`
- `AppColors.textLight`, `AppColors.star`, `AppColors.disabled`, `AppColors.shadow`
- `AppColors.playful` = [purple, coral, mint, star] برای چرخش رنگ کارت‌ها
- `AppTheme.light` تم اصلی؛ `AppTheme.fontFamily` = 'Vazirmatn'

## مدل‌ها — lib/models/models.dart
- `GameIds.find / puzzle / memory / drag / counting / numberMatch` (string constants)
- `LetterItem`: `id, char, letterName, word, plainWord, emoji, order`
  - getters: `audioAsset` (audio/letters/{id}.mp3), `wordAudioAsset` (audio/words/{id}.mp3)
- `NumberItem(value, name)`
- `LetterProgress`: `learned, practiced, games: Map<String,int>, updatedAt`
  - `stars` (0..3 میانگین بازی‌ها), `completed` = learned && practiced && games.length>=2 && stars>=2
- `AppProgress`: `letters: Map<String,LetterProgress>, knownNumbers: Set<int>, writtenNumbers: Set<int>, numberGames: Map<String,int>, totalGamePlays`

## داده‌ها
- `AlphabetData.letters` → `List<LetterItem>` (۳۲ حرف به ترتیب کتاب درسی)
- `NumbersData`: `nameOf(int)`, `audioAssetFor(int)`, `emojiFor(int)`, `item(int)`, `all`, `groupOf(int)` (گروه ده‌تایی ۰..۱۰), `countingEmojis`

## صدا — lib/services/audio_service.dart
- `AudioService.instance` (singleton) — متدها:
  - `playAsset(String)`, `playLetter(LetterItem)`, `playLetterWord(LetterItem)`, `playNumberName(int)`
  - اگر فایل نبود بی‌صدا رد می‌شود؛ هرگز خطا نمی‌دهد.

## پیشرفت — lib/providers/progress_provider.dart
دسترسی: `context.watch<ProgressProvider>()` یا `context.read<ProgressProvider>()`
- `progress: AppProgress`, `soundOn: bool`
- `markLearned(letterId)`, `markPracticed(letterId)`
- `recordGame(letterId, gameId, stars1..3)`, `recordNumberGame(value, gameId, stars1..3)`
- `starsFor(letterId)`, `numberGameStars(value, gameId)`
- `letterProgressOf(letterId) → LetterProgress?`
- `isLetterCompleted(index)`, `isLetterUnlocked(index)` — حرف i فقط بعد از اتمام حرف i-1
- `isNumberKnown(value)`, `isNumberWritten(value)`, `isNumberGroupUnlocked(group)` — گروه g بعد از ۶ عدد از گروه g-1
- `toggleNumberKnown(value)`, `markNumberWritten(value)`
- `setSound(bool)`, `resetAll()`
- آمار: `completedLetters, learnedLetters, totalStars, knownNumbersCount, totalGamePlays, overallPercent (0..100 double)`

## ویجت‌های مشترک — lib/widgets/common.dart
- `SectionTitle(text, icon?, color?)`
- `AppCard(child, color?, onTap?, padding?)`
- `StarRow(stars, size?, max=3)`
- `BigButton(label, onTap?, color?, icon?)` — دکمه ۵۶px
- `showLockedDialog(context, {message})`
- `showCelebration(context, {stars, message})`
- `endGame(context, {onFinish, stars, message})` → ثبت + جشن + خروج از صفحه بازی (بازی‌ها این را صدا می‌زنند)
- `TenFrameDots(count, dotSize?, color?)` — نقطه‌های شمارش، هر ردیف ۱۰ تا

## تمرین نوشتن — lib/widgets/writing_pad.dart
- `WritingPad(character: 'ب' یا '۴۵', height?, onComplete?, dotColor?, strokeColor?)`
- حرف نقطه‌چین رسم می‌شود؛ کودک با انگشت می‌کشد؛ «تمام شد» → onComplete

## مرکز بازی‌ها — lib/games/games_page.dart
- `GamesPage({initialLetterId?, initialNumber?})` — تب حروف/اعداد؛ انتخاب حرف/عدد → شیت بازی‌ها
- سازنده‌های بازی‌ها (قرارداد ثابت):
  - `FindLetterGame({required LetterItem letter, required ValueChanged<int> onFinish})`
  - `PuzzleGame({required LetterItem letter, required ValueChanged<int> onFinish})`
  - `MemoryGame({required LetterItem letter, required ValueChanged<int> onFinish})`
  - `DragDropGame({required LetterItem letter, required ValueChanged<int> onFinish})`
  - `CountingDragGame({required int value, required ValueChanged<int> onFinish})`
  - `NumberMatchGame({required int value, required ValueChanged<int> onFinish})`

## قواعد ستاره‌دهی بازی‌ها
- ۳ ستاره: بدون اشتباه | ۲ ستاره: حداکثر ۲ اشتباه | ۱ ستاره: بیشتر
- پایان بازی: `await endGame(context, onFinish: widget.onFinish, stars: s);`
- صداها: `AudioService.instance.playLetter(...)` و ...

## ابزارها
- `toPersianDigits(Object?)` — lib/utils/persian.dart — برای همه اعداد UI

## ناوبری
- همه صفحات با `Navigator.push(MaterialPageRoute(builder: (_) => const XPage()))`
