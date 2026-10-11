import '../core/utils.dart';
import 'models/number_model.dart';

export 'models/number_model.dart';

/// مولد اعداد ۰ تا ۱۰۰ + نام فارسی + ایموجی شمارش
class NumbersData {
  NumbersData._();

  static const List<String> _ones = [
    'صفر', 'یک', 'دو', 'سه', 'چهار', 'پنج', 'شش', 'هفت', 'هشت', 'نه'
  ];

  static const List<String> _teens = [
    'ده', 'یازده', 'دوازده', 'سیزده', 'چهارده', 'پانزده', 'شانزده',
    'هفده', 'هجده', 'نوزده'
  ];

  static const List<String> _tens = [
    '', '', 'بیست', 'سی', 'چهل', 'پنجاه', 'شصت', 'هفتاد', 'هشتاد', 'نود'
  ];

  /// نام فارسی عدد
  static String nameOf(int n) {
    assert(n >= 0 && n <= 100);
    if (n < 10) return _ones[n];
    if (n < 20) return _teens[n - 10];
    if (n == 100) return 'صد';
    final t = _tens[n ~/ 10];
    final r = n % 10;
    return r == 0 ? t : '$t و ${_ones[r]}';
  }

  /// لیست ۱۰۱ عدد
  static List<NumberModel> get all =>
      List.generate(101, (i) => NumberModel(value: i));

  /// ایموجی‌های شمارش تصویری — الگوی متنوع برای جذابیت
  static const List<String> _countSet = [
    '🍎', '🍊', '🐤', '🦋', '⭐', '🍓', '🐠', '🌸', '🐞', '🎈'
  ];

  /// برای عدد n، ردیف ایموجی برای شمارش (در ویجت نمایش داده می‌شود)
  static String countEmoji(int n) {
    final e = _countSet[n % _countSet.length];
    return e * (n > 20 ? 20 : n); // حداکثر ۲۰ تا؛ بقیه با متن ×n
  }

  /// ده‌تایی که عدد به آن تعلق دارد: 42 → گروه ۴ (اعداد ۴۰ تا ۴۹)
  static int groupOf(int n) => n ~/ 10;

  /// متن گروه: «اعداد ۴۰ تا ۴۹»
  static String groupTitle(int group) => group == 0
      ? 'اعداد ۰ تا ۹'
      : 'اعداد ${Fa.num(group * 10)} تا ${Fa.num(group * 10 + 9)}';
}
