import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/number_model.dart';
import '../data/models/progress_model.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

/// مدیریت کل state اپ: پیشرفت، قفل مرحله‌ای، تنظیمات و آمار
///
/// قاعده قفل مرحله‌ای:
///   حرف ۱ همیشه باز است.
///   حرف n+1 وقتی باز می‌شود که حرف n «کامل» شده باشد
///   (تمرین نوشتن + هر ۴ بازی).
class AppState extends ChangeNotifier {
  AppState() {
    settings = StorageService.instance.loadSettings();
    _letters = StorageService.instance.loadLetters();
    _numbers = StorageService.instance.loadNumbers();
    _stats = StorageService.instance.loadStats();
    _today = _todayKey();
    if (_stats.lastDay != _today) _stats = (
      totalSeconds: _stats.totalSeconds,
      todaySeconds: 0,
      lastDay: _today,
      maxNumberPlayed: _stats.maxNumberPlayed,
    );
    _ensureFirstLetterUnlocked();
    _startSessionTimer();
  }

  AppSettings settings = AppSettings();
  Map<int, LetterProgress> _letters = {};
  Map<int, NumberProgress> _numbers = {};
  ({int totalSeconds, int todaySeconds, String lastDay, int maxNumberPlayed})
      _stats = (
    totalSeconds: 0,
    todaySeconds: 0,
    lastDay: '',
    maxNumberPlayed: 0,
  );
  String _today = '';

  Timer? _sessionTimer;

  // ────────────────────────── قفل مرحله‌ای حروف ──────────────────────────
  Map<int, LetterProgress> get letters => _letters;

  /// حرف باز است؟ (باز بودن زنجیره‌ای از اول)
  bool isLetterUnlocked(int id) {
    if (id <= 1) return true;
    return progressOf(id - 1).isCompleted && (progressOf(id).unlocked);
  }

  LetterProgress progressOf(int id) =>
      _letters[id] ?? LetterProgress(unlocked: id == 1);

  /// اولین حرفِ ناتمام — برای دکمه «ادامه بده»
  int get nextLetterId {
    for (final l in _letters.values) {
      if (!l.isCompleted && l.unlocked) {
        return _letters.entries
            .firstWhere((e) => e.value == l)
            .key;
      }
    }
    return 1;
  }

  void _ensureFirstLetterUnlocked() {
    final p = _letters[1] ?? LetterProgress();
    if (!p.unlocked) {
      p.unlocked = true;
      _letters[1] = p;
      StorageService.instance.saveLetters(_letters);
    }
  }

  /// ثبت اتمام یک بخش از حرف؛ در صورت کامل شدن، حرف بعدی باز می‌شود
  void completeLetterPart(int id, {required String part, required int stars}) {
    final p = progressOf(id);
    var newStar = false;

    if (part == 'writing') {
      if (!p.writingDone) {
        p.writingDone = true;
        newStar = true;
      }
    } else {
      if (!p.gamesDone.contains(part)) {
        p.gamesDone.add(part);
        newStar = true;
      }
    }
    p.stars = (p.stars + (newStar ? stars : 0)).clamp(0, 5);

    // باز کردن حرف بعدی
    if (p.isCompleted) {
      final next = progressOf(id + 1);
      if (id + 1 <= 33 && !next.unlocked) {
        next.unlocked = true;
        _letters[id + 1] = next;
      }
    }
    _letters[id] = p;
    StorageService.instance.saveLetters(_letters);
    notifyListeners();
  }

  void recordAnswer({required bool correct}) {
    // برای حروف در بازی‌های مستقل؛ دقت کل
    _lastCorrect = correct ? _lastCorrect + 1 : _lastCorrect;
    _lastTries += 1;
  }

  int _lastCorrect = 0;
  int _lastTries = 0;

  void flushAnswerStatsTo(int letterId) {
    final p = progressOf(letterId);
    p.correct += _lastCorrect;
    p.tries += _lastTries;
    _lastCorrect = 0;
    _lastTries = 0;
    _letters[letterId] = p;
    StorageService.instance.saveLetters(_letters);
  }

  // ────────────────────────── اعداد ──────────────────────────
  Map<int, NumberProgress> get numbers => _numbers;

  NumberProgress numberProgressOf(int n) =>
      _numbers[n] ?? NumberProgress();

  /// بالاترین ده‌گانه‌ای که دست‌کم ۳ عددش بازی شده → آزادسازی گروه‌ها
  int get highestCompletedGroup {
    var g = 0;
    for (var i = 0; i <= 9; i++) {
      var played = 0;
      for (var n = i * 10; n <= i * 10 + 9; n++) {
        if (_numbers[n] != null && _numbers[n]!.stars > 0) played++;
      }
      if (played >= 3) {
        g = i;
      } else {
        break;
      }
    }
    return g;
  }

  bool isNumberUnlocked(int n) =>
      n <= 10 || n <= highestCompletedGroup * 10 + 10;

  void completeNumberGame(int n, {required String game, required bool won}) {
    final p = numberProgressOf(n);
    if (won && p.stars == 0) p.stars = 1;
    // فقط بازی واقعی در آمار دقت حساب می‌شود (نه صرف تماشای عدد)
    if (game != 'view') {
      p.tries += 1;
      if (won) p.correct += 1;
    }
    _numbers[n] = p;
    StorageService.instance.saveNumbers(_numbers);
    if (n > _stats.maxNumberPlayed) {
      _stats = (
        totalSeconds: _stats.totalSeconds,
        todaySeconds: _stats.todaySeconds,
        lastDay: _stats.lastDay,
        maxNumberPlayed: n,
      );
      StorageService.instance.saveMaxNumberPlayed(n);
    }
    notifyListeners();
  }

  // ────────────────────────── تنظیمات ──────────────────────────
  void setSoundOn(bool v) {
    settings.soundOn = v;
    _applyAudioSettings();
    StorageService.instance.saveSettings(settings);
    notifyListeners();
  }

  void setSfxOn(bool v) {
    settings.sfxOn = v;
    _applyAudioSettings();
    StorageService.instance.saveSettings(settings);
    notifyListeners();
  }

  void setSpeechSpeed(double v) {
    settings.speechSpeed = v;
    _applyAudioSettings();
    StorageService.instance.saveSettings(settings);
    notifyListeners();
  }

  void _applyAudioSettings() {
    AudioService.instance.updateSettings(
      soundOn: settings.soundOn,
      sfxOn: settings.sfxOn,
      speed: settings.speechSpeed,
    );
  }

  // ────────────────────────── آمار زمان ──────────────────────────
  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      var today = _stats.todaySeconds + 15;
      if (_todayKey() != _today) {
        _today = _todayKey();
        today = 15;
      }
      _stats = (
        totalSeconds: _stats.totalSeconds + 15,
        todaySeconds: today,
        lastDay: _today,
        maxNumberPlayed: _stats.maxNumberPlayed,
      );
      await StorageService.instance.saveTime(
        totalSeconds: _stats.totalSeconds,
        todaySeconds: _stats.todaySeconds,
        lastDay: _stats.lastDay,
      );
      notifyListeners();
    });
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ────────────────────────── گزارش والدین ──────────────────────────
  OverallReport report() {
    var completed = 0;
    var started = 0;
    var stars = 0;
    var correct = 0;
    var tries = 0;
    for (final p in _letters.values) {
      if (p.isCompleted) completed++;
      if (p.completionRatio > 0) started++;
      stars += p.stars;
      correct += p.correct;
      tries += p.tries;
    }
    for (final p in _numbers.values) {
      stars += p.stars;
      correct += p.correct;
      tries += p.tries;
    }
    return OverallReport(
      completedLetters: completed,
      startedLetters: started,
      totalLetters: 33,
      totalStars: stars,
      maxStars: 33 * 5 + 101,
      correct: correct,
      tries: tries,
      totalSeconds: _stats.totalSeconds,
      todaySeconds: _stats.todaySeconds,
      maxNumberPlayed: _stats.maxNumberPlayed,
    );
  }

  /// مجموع ستاره‌ها برای هدر
  int get totalStars {
    var s = 0;
    for (final p in _letters.values) {
      s += p.stars;
    }
    for (final p in _numbers.values) {
      s += p.stars;
    }
    return s;
  }

  // ────────────────────────── ریست ──────────────────────────
  Future<void> resetProgress() async {
    await StorageService.instance.resetAll();
    _letters = {};
    _numbers = {};
    _stats = (
      totalSeconds: 0,
      todaySeconds: 0,
      lastDay: _today,
      maxNumberPlayed: 0,
    );
    _ensureFirstLetterUnlocked();
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
