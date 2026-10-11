/// ابزارهای مشترک — ارقام فارسی و مسیرهای asset
class Fa {
  Fa._();

  static const List<String> _digits = [
    '۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'
  ];

  /// تبدیل عدد به رشته با ارقام فارسی: 42 → «۴۲»
  static String num(int n) {
    if (n < 0) return '−${num(-n)}';
    final b = StringBuffer();
    do {
      b.write(_digits[n % 10]);
      n ~/= 10;
    } while (n > 0);
    return b.toString();
  }

  /// تبدیل ارقام لاتین داخل یک متن به فارسی
  static String text(String input) => input.replaceAllMapped(
        RegExp(r'[0-9]'),
        (m) => _digits[int.parse(m[0]!)],
      );
}

/// همه مسیرهای asset صوتی — نام‌گذاری ASCII برای سازگاری حداکثری
class Sfx {
  Sfx._();

  static const String praise1 = 'assets/audio/sfx/praise_1.mp3';
  static const String praise2 = 'assets/audio/sfx/praise_2.mp3';
  static const String praise3 = 'assets/audio/sfx/praise_3.mp3';
  static const String praise4 = 'assets/audio/sfx/praise_4.mp3';
  static const String praise5 = 'assets/audio/sfx/praise_5.mp3';
  static const String retry1 = 'assets/audio/sfx/retry_1.mp3';
  static const String retry2 = 'assets/audio/sfx/retry_2.mp3';
  static const String retry3 = 'assets/audio/sfx/retry_3.mp3';
  static const String uiGo = 'assets/audio/sfx/ui_go.mp3';
  static const String uiPlay = 'assets/audio/sfx/ui_play.mp3';
  static const String uiStar = 'assets/audio/sfx/ui_star.mp3';
  static const String hello = 'assets/audio/sfx/hello.mp3';
  static const String lockHint = 'assets/audio/sfx/lock_hint.mp3';
  static const String writeDone = 'assets/audio/sfx/write_done.mp3';

  static const List<String> praises = [
    praise1, praise2, praise3, praise4, praise5
  ];

  static const List<String> retries = [retry1, retry2, retry3];

  /// انتخاب تصادفی جمله تشویقی
  static String get randomPraise =>
      praises[DateTime.now().millisecond % praises.length];

  static String get randomRetry =>
      retries[DateTime.now().millisecond % retries.length];
}
