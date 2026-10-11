import '../models/models.dart';

/// داده‌های اعداد ۰ تا ۱۰۰ با نام فارسی
class NumbersData {
  NumbersData._();

  static const List<String> _units = <String>[
    'صفر', 'یک', 'دو', 'سه', 'چهار', 'پنج', 'شش', 'هفت', 'هشت', 'نه',
  ];

  static const List<String> _teens = <String>[
    'ده', 'یازده', 'دوازده', 'سیزده', 'چهارده', 'پانزده', 'شانزده', 'هفده',
    'هجده', 'نوزده',
  ];

  static const List<String> _tens = <String>[
    '', '', 'بیست', 'سی', 'چهل', 'پنجاه', 'شصت', 'هفتاد', 'هشتاد', 'نود',
  ];

  /// نام فارسی عدد
  static String nameOf(int value) {
    if (value == 100) return 'صد';
    if (value < 0) return 'صفر';
    if (value < 10) return _units[value];
    if (value < 20) return _teens[value - 10];
    if (value > 100) return 'صد';
    final int t = value ~/ 10;
    final int u = value % 10;
    if (u == 0) return _tens[t];
    return '${_tens[t]} و ${_units[u]}';
  }

  /// صد فایل صوتی: audio/numbers/n0.wav ... n100.wav
  static String audioAssetFor(int value) => 'audio/numbers/n$value.wav';

  /// ایموجی شمارش هر گروه ده‌تایی
  static const List<String> countingEmojis = <String>[
    '🍎', '🐥', '🌸', '🐟', '🚗', '🎈', '🍓', '🐝', '⭐', '🍋', '🧸',
  ];

  static String emojiFor(int value) =>
      countingEmojis[(value ~/ 10) % countingEmojis.length];

  static NumberItem item(int value) => NumberItem(value, nameOf(value));

  static List<NumberItem> get all =>
      List<NumberItem>.generate(101, (int i) => item(i));

  /// شماره گروه ده‌تایی (۰ تا ۱۰)
  static int groupOf(int value) {
    if (value >= 100) return 10;
    return value ~/ 10;
  }
}
