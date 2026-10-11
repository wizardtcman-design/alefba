import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ذخیره‌سازی محلی: Hive برای پیشرفت، SharedPreferences برای تنظیمات
class StorageService {
  static const String _boxName = 'alefba';
  static const String _progressKey = 'progress_v1';
  static const String _soundKey = 'sound_on';

  Box<dynamic>? _box;
  SharedPreferences? _prefs;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(_boxName);
    _prefs = await SharedPreferences.getInstance();
  }

  String? get progressJson => _box?.get(_progressKey) as String?;

  Future<void> saveProgressJson(String json) async {
    final Box<dynamic>? box = _box;
    if (box != null) {
      await box.put(_progressKey, json);
    }
  }

  bool get soundOn => _prefs?.getBool(_soundKey) ?? true;

  Future<void> setSoundOn(bool value) async {
    await _prefs?.setBool(_soundKey, value);
  }
}
