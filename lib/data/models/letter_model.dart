/// مدل هر حرف الفبا — به ترتیب کتاب فارسی کلاس اول
class LetterModel {
  const LetterModel({
    required this.id,
    required this.char,
    required this.sound,
    required this.word,
    required this.syllables,
    required this.emoji,
    this.funFact,
  });

  /// شماره ترتیب آموزش: 1 تا 33 (آ = 1)
  final int id;

  /// خودِ حرف: «ب»
  final String char;

  /// متن تلفظ حرف برای نمایش: «بَ، بِ، بُ»
  final String sound;

  /// کلمه شاهد: «بادبادک»
  final String word;

  /// بخش‌بندی هجایی برای خوانش پله‌ای: [با، با، دَک]
  final List<String> syllables;

  /// ایموجی جایگزین تصویر (اگر PNG نبود، همین نمایش داده می‌شود)
  final String emoji;

  /// نکته بامزه برای کودک
  final String? funFact;

  /// مسیر تصویر داخل asset (اگر موجود باشد)
  String get imagePath => 'assets/images/letters/l${id.toString().padLeft(2, '0')}.png';

  /// مسیر صدای حرف (بَ بِ بُ)
  String get soundAudio =>
      'assets/audio/letters/l${id.toString().padLeft(2, '0')}_sound.mp3';

  /// مسیر صدای کلمه
  String get wordAudio =>
      'assets/audio/letters/l${id.toString().padLeft(2, '0')}_word.mp3';

  /// مسیر جمله معرفی: «این حرف ب است؛ مثل بادبادک»
  String get introAudio =>
      'assets/audio/letters/l${id.toString().padLeft(2, '0')}_intro.mp3';

  /// مسیر صدای هجای i (برای خوانش پله‌ای) — تعداد فایل‌ها با syllables برابر است
  String syllableAudio(int index) =>
      'assets/audio/letters/l${id.toString().padLeft(2, '0')}_syl_$index.mp3';

  /// آیا حرف هجای دوم دارد؟
  bool get hasSyllables => syllables.length > 1;
}
