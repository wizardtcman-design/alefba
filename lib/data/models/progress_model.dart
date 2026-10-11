/// مدل پیشرفت هر حرف برای ذخیره‌سازی محلی
class LetterProgress {
  LetterProgress({
    this.unlocked = false,
    this.writingDone = false,
    List<String>? gamesDone,
    this.stars = 0,
    this.correct = 0,
    this.tries = 0,
  }) : gamesDone = gamesDone ?? [];

  /// آیا این حرف باز شده؟
  bool unlocked;

  /// آیا تمرین نوشتن انجام شده؟
  bool writingDone;

  /// بازی‌های تمام‌شده: find | match | memory | drag
  List<String> gamesDone;

  /// ستاره‌های جمع‌شده (حداکثر ۵: چهار بازی + نوشتن)
  int stars;

  /// آمار دقت برای والدین
  int correct;
  int tries;

  /// آیا حرف کاملاً تمام شده؟ (شرط باز شدن حرف بعدی)
  bool get isCompleted => writingDone && gamesDone.length >= 4;

  double get completionRatio {
    var parts = 0.0;
    if (writingDone) parts += 1;
    parts += gamesDone.length;
    return parts / 5;
  }

  Map<String, dynamic> toJson() => {
        'u': unlocked ? 1 : 0,
        'w': writingDone ? 1 : 0,
        'g': gamesDone,
        's': stars,
        'c': correct,
        't': tries,
      };

  factory LetterProgress.fromJson(Map<String, dynamic> json) => LetterProgress(
        unlocked: json['u'] == 1,
        writingDone: json['w'] == 1,
        gamesDone: (json['g'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        stars: (json['s'] as num?)?.toInt() ?? 0,
        correct: (json['c'] as num?)?.toInt() ?? 0,
        tries: (json['t'] as num?)?.toInt() ?? 0,
      );
}

/// مدل پیشرفت هر عدد (برای بازی‌های عددی)
class NumberProgress {
  NumberProgress({this.stars = 0, this.correct = 0, this.tries = 0});

  int stars;
  int correct;
  int tries;

  Map<String, dynamic> toJson() =>
      {'s': stars, 'c': correct, 't': tries};

  factory NumberProgress.fromJson(Map<String, dynamic> json) => NumberProgress(
        stars: (json['s'] as num?)?.toInt() ?? 0,
        correct: (json['c'] as num?)?.toInt() ?? 0,
        tries: (json['t'] as num?)?.toInt() ?? 0,
      );
}

/// تنظیمات اپ (صدا، سرعت تلفظ، ...)
class AppSettings {
  AppSettings({
    this.soundOn = true,
    this.sfxOn = true,
    this.speechSpeed = 1.0,
  });

  /// روشن بودن صداهای آموزشی (تلفظ)
  bool soundOn;

  /// روشن بودن افکت‌های صوتی (تشویق و ...)
  bool sfxOn;

  /// سرعت پخش تلفظ: 0.85 آهسته | 1.0 معمولی | 1.2 سریع
  double speechSpeed;

  Map<String, dynamic> toJson() => {
        'soundOn': soundOn,
        'sfxOn': sfxOn,
        'speed': speechSpeed,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        soundOn: json['soundOn'] != false,
        sfxOn: json['sfxOn'] != false,
        speechSpeed:
            (json['speed'] as num?)?.toDouble() ?? 1.0,
      );
}

/// گزارش کلی برای داشبورد والدین
class OverallReport {
  OverallReport({
    required this.completedLetters,
    required this.startedLetters,
    required this.totalLetters,
    required this.totalStars,
    required this.maxStars,
    required this.correct,
    required this.tries,
    required this.totalSeconds,
    required this.todaySeconds,
    required this.maxNumberPlayed,
  });

  final int completedLetters;
  final int startedLetters;
  final int totalLetters;
  final int totalStars;
  final int maxStars;
  final int correct;
  final int tries;
  final int totalSeconds;
  final int todaySeconds;
  final int maxNumberPlayed;

  double get accuracy => tries == 0 ? 0 : correct / tries;

  double get overallPercent =>
      totalLetters == 0 ? 0 : completedLetters / totalLetters;
}
