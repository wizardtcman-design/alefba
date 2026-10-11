import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/alphabet_data.dart';
import '../models/models.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

/// مدیریت کل پیشرفت کودک (قفل مراحل، ستاره‌ها، آمار)
class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._storage, this._audio) {
    _soundOn = _storage.soundOn;
    _load();
  }

  final StorageService _storage;
  final AudioService _audio;

  AppProgress _progress = AppProgress.empty();
  bool _soundOn = true;

  AppProgress get progress => _progress;
  bool get soundOn => _soundOn;

  void _load() {
    final String? raw = _storage.progressJson;
    if (raw == null) return;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _progress = AppProgress.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('load progress failed: $e');
    }
  }

  void _persist() {
    _storage.saveProgressJson(jsonEncode(_progress.toJson()));
    notifyListeners();
  }

  LetterProgress _letterProgress(String id) =>
      _progress.letters.putIfAbsent(id, () => LetterProgress());

  LetterProgress? letterProgressOf(String id) => _progress.letters[id];

  void markLearned(String letterId) {
    final LetterProgress lp = _letterProgress(letterId);
    lp.learned = true;
    lp.updatedAt = DateTime.now().millisecondsSinceEpoch;
    _persist();
  }

  void markPracticed(String letterId) {
    final LetterProgress lp = _letterProgress(letterId);
    lp.practiced = true;
    lp.updatedAt = DateTime.now().millisecondsSinceEpoch;
    _persist();
  }

  /// ثبت نتیجه یک بازی حروف (بهترین ستاره ذخیره می‌شود)
  void recordGame(String letterId, String gameId, int stars) {
    final int clamped = stars.clamp(1, 3).toInt();
    final LetterProgress lp = _letterProgress(letterId);
    final int best = lp.games[gameId] ?? 0;
    if (clamped > best) lp.games[gameId] = clamped;
    _progress.totalGamePlays += 1;
    lp.updatedAt = DateTime.now().millisecondsSinceEpoch;
    _persist();
  }

  /// ثبت نتیجه یک بازی اعداد
  void recordNumberGame(int value, String gameId, int stars) {
    final int clamped = stars.clamp(1, 3).toInt();
    final String key = 'n${value}_$gameId';
    final int best = _progress.numberGames[key] ?? 0;
    if (clamped > best) _progress.numberGames[key] = clamped;
    _progress.totalGamePlays += 1;
    _persist();
  }

  int starsFor(String letterId) => _progress.letters[letterId]?.stars ?? 0;

  int numberGameStars(int value, String gameId) =>
      _progress.numberGames['n${value}_$gameId'] ?? 0;

  bool isLetterCompleted(int index) {
    if (index < 0 || index >= AlphabetData.letters.length) return false;
    final String id = AlphabetData.letters[index].id;
    return _progress.letters[id]?.completed ?? false;
  }

  /// قانون قفل: حرف فقط وقتی باز می‌شود که حرف قبلی کامل شده باشد
  bool isLetterUnlocked(int index) =>
      index == 0 || isLetterCompleted(index - 1);

  bool isNumberKnown(int value) => _progress.knownNumbers.contains(value);

  bool isNumberWritten(int value) =>
      _progress.writtenNumbers.contains(value);

  /// هر گروه ده‌تایی بعد از یادگیری ۶ عدد از گروه قبل باز می‌شود
  bool isNumberGroupUnlocked(int group) {
    if (group <= 0) return true;
    final int start = (group - 1) * 10;
    final int end = group * 10;
    int known = 0;
    for (int v = start; v < end; v++) {
      if (_progress.knownNumbers.contains(v)) known++;
    }
    return known >= 6;
  }

  void toggleNumberKnown(int value) {
    if (_progress.knownNumbers.contains(value)) {
      _progress.knownNumbers.remove(value);
    } else {
      _progress.knownNumbers.add(value);
    }
    _persist();
  }

  void markNumberWritten(int value) {
    if (!_progress.writtenNumbers.contains(value)) {
      _progress.writtenNumbers.add(value);
      _persist();
    }
  }

  void setSound(bool enabled) {
    _soundOn = enabled;
    _audio.soundEnabled = enabled;
    _storage.setSoundOn(enabled);
    notifyListeners();
  }

  void resetAll() {
    _progress = AppProgress.empty();
    _persist();
  }

  // ---------- آمار برای داشبورد والدین ----------

  int get completedLetters =>
      _progress.letters.values.where((LetterProgress l) => l.completed).length;

  int get learnedLetters =>
      _progress.letters.values.where((LetterProgress l) => l.learned).length;

  int get totalStars =>
      _progress.letters.values.fold<int>(0, (int sum, LetterProgress l) => sum + l.stars);

  int get knownNumbersCount => _progress.knownNumbers.length;

  int get totalGamePlays => _progress.totalGamePlays;

  double get overallPercent {
    final double lettersPart =
        (completedLetters / AlphabetData.letters.length) * 70;
    final double numbersPart = (knownNumbersCount / 101) * 30;
    final double value = lettersPart + numbersPart;
    return value.clamp(0, 100).toDouble();
  }
}
