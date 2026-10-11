import 'package:just_audio/just_audio.dart';

import '../core/utils.dart';

/// مدیریت صدا با just_audio — پخش فایل‌های mp3 داخل asset (آفلاین)
/// دو پلیر مجزا: یکی برای تلفظ‌ها، یکی برای افکت‌های تشویقی
class AudioService {
  AudioService._();
  static AudioService? _instance;

  static AudioService get instance => _instance ??= AudioService._();

  late final AudioPlayer _voicePlayer;
  late final AudioPlayer _sfxPlayer;

  bool soundOn = true;
  bool sfxOn = true;
  double speed = 1.0;

  /// برای تشخیص «بشنو» فعال
  bool isSpeaking = false;

  Future<void> init() async {
    _voicePlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    await _voicePlayer.setVolume(1.0);
    await _sfxPlayer.setVolume(0.9);
  }

  /// اعمال تنظیمات کاربر
  void updateSettings({required bool soundOn, required bool sfxOn, required double speed}) {
    this.soundOn = soundOn;
    this.sfxOn = sfxOn;
    this.speed = speed;
    _voicePlayer.setSpeed(speed);
    _sfxPlayer.setSpeed(1.0);
  }

  Future<void> dispose() async {
    await _voicePlayer.dispose();
    await _sfxPlayer.dispose();
  }

  // ── تلفظ‌های آموزشی ───────────────────────────────────────────
  Future<void> speak(String assetPath) async {
    if (!soundOn) return;
    try {
      isSpeaking = true;
      await _voicePlayer.stop();
      await _voicePlayer.setAsset(assetPath);
      await _voicePlayer.setSpeed(speed);
      await _voicePlayer.play();
      // صبر تا پایان پخش (برای صف آموزش خودکار)
      await _voicePlayer.playerStateStream
          .firstWhere((s) => s.processingState == ProcessingState.completed);
      isSpeaking = false;
    } catch (_) {
      isSpeaking = false;
    }
  }

  /// پخش بدون صبر تا پایان (برای دکمه‌های سریع)
  Future<void> speakAsync(String assetPath) async {
    if (!soundOn) return;
    try {
      await _voicePlayer.stop();
      await _voicePlayer.setAsset(assetPath);
      await _voicePlayer.setSpeed(speed);
      await _voicePlayer.play();
    } catch (_) {}
  }

  /// صف آموزش خودکار: چند صدا پشت‌سرهم
  Future<void> speakQueue(List<String> paths) async {
    if (!soundOn) return;
    for (final p in paths) {
      if (!soundOn) break; // وسط کار خاموش شد
      await speak(p);
    }
  }

  Future<void> stopVoice() async {
    try {
      await _voicePlayer.stop();
    } catch (_) {}
    isSpeaking = false;
  }

  // ── افکت‌های صوتی ─────────────────────────────────────────────
  Future<void> sfx(String assetPath) async {
    if (!sfxOn) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setAsset(assetPath);
      await _sfxPlayer.setSpeed(1.0);
      await _sfxPlayer.play();
    } catch (_) {}
  }

  Future<void> praise() => sfx(Sfx.randomPraise);

  Future<void> retry() => sfx(Sfx.randomRetry);

  Future<void> star() => sfx(Sfx.uiStar);

  Future<void> go() => sfx(Sfx.uiGo);
}
