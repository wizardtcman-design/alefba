import '../../core/utils.dart';
import '../numbers_data.dart';

/// مدل هر عدد از ۰ تا ۱۰۰
class NumberModel {
  const NumberModel({required this.value});

  /// مقدار عددی: 0..100
  final int value;

  /// نمایش با ارقام فارسی: «۴۲»
  String get faDigits => Fa.num(value);

  /// نام فارسی عدد: «چهل و دو»
  String get name => NumbersData.nameOf(value);

  /// مسیر صدای عدد: assets/audio/numbers/n042.mp3
  String get audio => 'assets/audio/numbers/n${value.toString().padLeft(3, '0')}.mp3';

  /// ایموجی‌های شمارش تصویری (حداکثر ۱۰ تا نمایش داده می‌شود؛ بقیه به‌صورت ×n)
  String get countingEmoji => NumbersData.countEmoji(value);

  /// آیا عدد ده‌گانه است (۰، ۱۰، ۲۰ ...)؟ برای جشن گروه‌ها
  bool get isRound => value % 10 == 0;

  /// آیا در بازه آزادشده است؟ (ده‌تا اول آزاد است؛ بقیه با تکمیل ده‌تای قبلی)
  bool isUnlocked(int highestCompletedGroup) =>
      value <= 10 || value <= highestCompletedGroup * 10 + 10;
}
