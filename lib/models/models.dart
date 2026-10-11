/// شناسه‌های بازی‌ها (برای ذخیره ستاره هر بازی)
class GameIds {
  GameIds._();

  static const String find = 'find';
  static const String puzzle = 'puzzle';
  static const String memory = 'memory';
  static const String drag = 'drag';
  static const String counting = 'counting';
  static const String numberMatch = 'nmatch';
}

/// مدل هر حرف الفبا
class LetterItem {
  const LetterItem({
    required this.id,
    required this.char,
    required this.letterName,
    required this.word,
    required this.plainWord,
    required this.emoji,
    required this.order,
  });

  final String id;
  final String char;
  final String letterName;
  final String word;
  final String plainWord;
  final String emoji;
  final int order;

  String get audioAsset => 'audio/letters/$id.wav';
  String get wordAudioAsset => 'audio/words/$id.wav';
}

/// مدل هر عدد
class NumberItem {
  const NumberItem(this.value, this.name);

  final int value;
  final String name;
}

/// پیشرفت یک حرف
class LetterProgress {
  LetterProgress({
    this.learned = false,
    this.practiced = false,
    Map<String, int>? games,
    this.updatedAt = 0,
  }) : games = games ?? <String, int>{};

  bool learned;
  bool practiced;
  Map<String, int> games;
  int updatedAt;

  /// میانگین ستاره‌های بازی‌های این حرف (۰ تا ۳)
  int get stars {
    if (games.isEmpty) return 0;
    final int sum = games.values.fold<int>(0, (int a, int b) => a + b);
    return (sum / games.length).round().clamp(0, 3).toInt();
  }

  /// حرف کامل شده = یادگرفته + نوشته + حداقل ۲ بازی + میانگین ۲ ستاره
  bool get completed =>
      learned && practiced && games.length >= 2 && stars >= 2;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'learned': learned,
        'practiced': practiced,
        'games': games,
        'updatedAt': updatedAt,
      };

  factory LetterProgress.fromJson(Map<String, dynamic> json) {
    final Object? gamesRaw = json['games'];
    final Map<String, int> games = <String, int>{};
    if (gamesRaw is Map) {
      gamesRaw.forEach((Object? key, Object? value) {
        if (key is String && value is num) games[key] = value.toInt();
      });
    }
    return LetterProgress(
      learned: json['learned'] == true,
      practiced: json['practiced'] == true,
      games: games,
      updatedAt: (json['updatedAt'] as num?)?.toInt() ?? 0,
    );
  }
}

/// کل پیشرفت برنامه
class AppProgress {
  AppProgress({
    Map<String, LetterProgress>? letters,
    Set<int>? knownNumbers,
    Set<int>? writtenNumbers,
    Map<String, int>? numberGames,
    this.totalGamePlays = 0,
  })  : letters = letters ?? <String, LetterProgress>{},
        knownNumbers = knownNumbers ?? <int>{},
        writtenNumbers = writtenNumbers ?? <int>{},
        numberGames = numberGames ?? <String, int>{};

  Map<String, LetterProgress> letters;
  Set<int> knownNumbers;
  Set<int> writtenNumbers;
  Map<String, int> numberGames;
  int totalGamePlays;

  static AppProgress empty() => AppProgress();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'letters': letters.map(
          (String k, LetterProgress v) => MapEntry(k, v.toJson()),
        ),
        'knownNumbers': knownNumbers.toList(),
        'writtenNumbers': writtenNumbers.toList(),
        'numberGames': numberGames,
        'totalGamePlays': totalGamePlays,
      };

  static Set<int> _toIntSet(Object? raw) {
    final Set<int> out = <int>{};
    if (raw is List) {
      for (final Object? v in raw) {
        if (v is num) out.add(v.toInt());
      }
    }
    return out;
  }

  factory AppProgress.fromJson(Map<String, dynamic> json) {
    final Object? lettersRaw = json['letters'];
    final Map<String, LetterProgress> letters = <String, LetterProgress>{};
    if (lettersRaw is Map) {
      lettersRaw.forEach((Object? key, Object? value) {
        if (key is String && value is Map) {
          letters[key] = LetterProgress.fromJson(
            value.cast<String, dynamic>(),
          );
        }
      });
    }

    final Object? numberGamesRaw = json['numberGames'];
    final Map<String, int> numberGames = <String, int>{};
    if (numberGamesRaw is Map) {
      numberGamesRaw.forEach((Object? key, Object? value) {
        if (key is String && value is num) numberGames[key] = value.toInt();
      });
    }

    return AppProgress(
      letters: letters,
      knownNumbers: _toIntSet(json['knownNumbers']),
      writtenNumbers: _toIntSet(json['writtenNumbers']),
      numberGames: numberGames,
      totalGamePlays: (json['totalGamePlays'] as num?)?.toInt() ?? 0,
    );
  }
}
