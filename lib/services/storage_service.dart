import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/progress_model.dart';

/// ذخیره‌سازی محلی با SharedPreferences — کاملاً آفلاین
/// ساختار ذخیره:
///   letters:   { "1": {u,w,g,s,c,t}, ... }
///   numbers:   { "42": {s,c,t}, ... }
///   settings:  { soundOn, sfxOn, speed }
///   stats:     { totalSeconds, todaySeconds, lastDay, maxNumberPlayed }
class StorageService {
  StorageService._();
  static StorageService? _instance;

  static StorageService get instance => _instance ??= StorageService._();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── حروف ─────────────────────────────────────────────────────
  Map<int, LetterProgress> loadLetters() {
    final raw = _prefs.getString('letters');
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map(
        (k, v) => MapEntry(int.parse(k), LetterProgress.fromJson(v)),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> saveLetters(Map<int, LetterProgress> letters) async {
    final map = letters.map((k, v) => MapEntry(k.toString(), v.toJson()));
    await _prefs.setString('letters', jsonEncode(map));
  }

  // ── اعداد ─────────────────────────────────────────────────────
  Map<int, NumberProgress> loadNumbers() {
    final raw = _prefs.getString('numbers');
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map(
        (k, v) => MapEntry(int.parse(k), NumberProgress.fromJson(v)),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> saveNumbers(Map<int, NumberProgress> numbers) async {
    final map = numbers.map((k, v) => MapEntry(k.toString(), v.toJson()));
    await _prefs.setString('numbers', jsonEncode(map));
  }

  // ── تنظیمات ───────────────────────────────────────────────────
  AppSettings loadSettings() {
    final raw = _prefs.getString('settings');
    if (raw == null) return AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings s) async =>
      _prefs.setString('settings', jsonEncode(s.toJson()));

  // ── آمار زمان بازی ────────────────────────────────────────────
  ({int totalSeconds, int todaySeconds, String lastDay, int maxNumberPlayed})
      loadStats() {
    return (
      totalSeconds: _prefs.getInt('totalSeconds') ?? 0,
      todaySeconds: _prefs.getInt('todaySeconds') ?? 0,
      lastDay: _prefs.getString('lastDay') ?? '',
      maxNumberPlayed: _prefs.getInt('maxNumberPlayed') ?? 0,
    );
  }

  Future<void> saveTime({
    required int totalSeconds,
    required int todaySeconds,
    required String lastDay,
  }) async {
    await _prefs.setInt('totalSeconds', totalSeconds);
    await _prefs.setInt('todaySeconds', todaySeconds);
    await _prefs.setString('lastDay', lastDay);
  }

  Future<void> saveMaxNumberPlayed(int n) =>
      _prefs.setInt('maxNumberPlayed', n);

  // ── پاک کردن همه پیشرفت‌ها ────────────────────────────────────
  Future<void> resetAll() async {
    await _prefs.remove('letters');
    await _prefs.remove('numbers');
    await _prefs.remove('totalSeconds');
    await _prefs.remove('todaySeconds');
    await _prefs.remove('lastDay');
    await _prefs.remove('maxNumberPlayed');
  }
}
