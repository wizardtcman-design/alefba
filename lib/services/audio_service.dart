import 'package:just_audio/just_audio.dart';

import '../models/models.dart';

/// پخش صداهای آفلاین از داخل assets
class AudioService {
  AudioService._internal();

  static final AudioService instance = AudioService._internal();

  factory AudioService() => instance;

  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;

  set soundEnabled(bool value) {
    _soundEnabled = value;
    if (!value) {
      _player.stop();
    }
  }

  /// پخش یک فایل صوتی از assets؛ اگر فایل موجود نباشد بی‌صدا رد می‌شود
  Future<void> playAsset(String assetPath) async {
    if (!_soundEnabled) return;
    try {
      await _player.setAsset(assetPath);
      await _player.play();
    } catch (_) {
      // اگر فایل صوتی موجود نبود، برنامه هرگز کرش نمی‌کند
    }
  }

  Future<void> playLetter(LetterItem letter) => playAsset(letter.audioAsset);

  Future<void> playLetterWord(LetterItem letter) =>
      playAsset(letter.wordAudioAsset);

  Future<void> playNumberName(int value) => playAsset('audio/numbers/n$value.wav');
}
