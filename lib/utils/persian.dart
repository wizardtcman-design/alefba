const List<String> _faDigits = <String>[
  '۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹',
];

/// تبدیل ارقام لاتین به ارقام فارسی برای نمایش در رابط کاربری
String toPersianDigits(Object? value) {
  final String source = value?.toString() ?? '';
  final StringBuffer out = StringBuffer();
  for (final int code in source.codeUnits) {
    if (code >= 0x30 && code <= 0x39) {
      out.write(_faDigits[code - 0x30]);
    } else {
      out.writeCharCode(code);
    }
  }
  return out.toString();
}
