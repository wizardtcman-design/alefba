import '../models/models.dart';

/// ۳۲ حرف الفبا به ترتیب کتاب درسی پایه اول
class AlphabetData {
  AlphabetData._();

  static const List<LetterItem> letters = <LetterItem>[
    LetterItem(
      id: 'alef', char: 'ا', letterName: 'الف', word: 'اَبر',
      plainWord: 'ابر', emoji: '☁️', order: 0,
    ),
    LetterItem(
      id: 'be', char: 'ب', letterName: 'بِ', word: 'بادبادک',
      plainWord: 'بادبادک', emoji: '🪁', order: 1,
    ),
    LetterItem(
      id: 'pe', char: 'پ', letterName: 'پِ', word: 'پرنده',
      plainWord: 'پرنده', emoji: '🐦', order: 2,
    ),
    LetterItem(
      id: 'te', char: 'ت', letterName: 'تِ', word: 'توپ',
      plainWord: 'توپ', emoji: '⚽', order: 3,
    ),
    LetterItem(
      id: 'se', char: 'ث', letterName: 'ثِ', word: 'ثعلب',
      plainWord: 'ثعلب', emoji: '🦊', order: 4,
    ),
    LetterItem(
      id: 'jim', char: 'ج', letterName: 'جیم', word: 'جامدادی',
      plainWord: 'جامدادی', emoji: '✏️', order: 5,
    ),
    LetterItem(
      id: 'che', char: 'چ', letterName: 'چِ', word: 'چتر',
      plainWord: 'چتر', emoji: '☂️', order: 6,
    ),
    LetterItem(
      id: 'he', char: 'ح', letterName: 'حِ', word: 'حلزون',
      plainWord: 'حلزون', emoji: '🐌', order: 7,
    ),
    LetterItem(
      id: 'khe', char: 'خ', letterName: 'خِ', word: 'خرس',
      plainWord: 'خرس', emoji: '🐻', order: 8,
    ),
    LetterItem(
      id: 'dal', char: 'د', letterName: 'دال', word: 'درخت',
      plainWord: 'درخت', emoji: '🌳', order: 9,
    ),
    LetterItem(
      id: 'zal', char: 'ذ', letterName: 'ذال', word: 'ذرت',
      plainWord: 'ذرت', emoji: '🌽', order: 10,
    ),
    LetterItem(
      id: 're', char: 'ر', letterName: 'رِ', word: 'رنگین‌کمان',
      plainWord: 'رنگین‌کمان', emoji: '🌈', order: 11,
    ),
    LetterItem(
      id: 'ze', char: 'ز', letterName: 'زِ', word: 'زرافه',
      plainWord: 'زرافه', emoji: '🦒', order: 12,
    ),
    LetterItem(
      id: 'zhe', char: 'ژ', letterName: 'ژِ', word: 'ژاکت',
      plainWord: 'ژاکت', emoji: '🧥', order: 13,
    ),
    LetterItem(
      id: 'sin', char: 'س', letterName: 'سین', word: 'سیب',
      plainWord: 'سیب', emoji: '🍎', order: 14,
    ),
    LetterItem(
      id: 'shin', char: 'ش', letterName: 'شین', word: 'شیر',
      plainWord: 'شیر', emoji: '🦁', order: 15,
    ),
    LetterItem(
      id: 'sad', char: 'ص', letterName: 'صاد', word: 'صابون',
      plainWord: 'صابون', emoji: '🧼', order: 16,
    ),
    LetterItem(
      id: 'zad', char: 'ض', letterName: 'ضاد', word: 'ضفدع',
      plainWord: 'ضفدع', emoji: '🐸', order: 17,
    ),
    LetterItem(
      id: 'ta', char: 'ط', letterName: 'طا', word: 'طبل',
      plainWord: 'طبل', emoji: '🥁', order: 18,
    ),
    LetterItem(
      id: 'za', char: 'ظ', letterName: 'ظا', word: 'ظرف',
      plainWord: 'ظرف', emoji: '🍽️', order: 19,
    ),
    LetterItem(
      id: 'ein', char: 'ع', letterName: 'عین', word: 'عنکبوت',
      plainWord: 'عنکبوت', emoji: '🕷️', order: 20,
    ),
    LetterItem(
      id: 'ghein', char: 'غ', letterName: 'غین', word: 'غاز',
      plainWord: 'غاز', emoji: '🦆', order: 21,
    ),
    LetterItem(
      id: 'fe', char: 'ف', letterName: 'فِ', word: 'فیل',
      plainWord: 'فیل', emoji: '🐘', order: 22,
    ),
    LetterItem(
      id: 'ghaf', char: 'ق', letterName: 'قاف', word: 'قناری',
      plainWord: 'قناری', emoji: '🐤', order: 23,
    ),
    LetterItem(
      id: 'kaf', char: 'ک', letterName: 'کاف', word: 'کتاب',
      plainWord: 'کتاب', emoji: '📖', order: 24,
    ),
    LetterItem(
      id: 'gaf', char: 'گ', letterName: 'گاف', word: 'گل',
      plainWord: 'گل', emoji: '🌸', order: 25,
    ),
    LetterItem(
      id: 'lam', char: 'ل', letterName: 'لام', word: 'لیمو',
      plainWord: 'لیمو', emoji: '🍋', order: 26,
    ),
    LetterItem(
      id: 'mim', char: 'م', letterName: 'میم', word: 'موز',
      plainWord: 'موز', emoji: '🍌', order: 27,
    ),
    LetterItem(
      id: 'nun', char: 'ن', letterName: 'نون', word: 'نارنج',
      plainWord: 'نارنج', emoji: '🍊', order: 28,
    ),
    LetterItem(
      id: 'vav', char: 'و', letterName: 'واو', word: 'واگن',
      plainWord: 'واگن', emoji: '🚃', order: 29,
    ),
    LetterItem(
      id: 'heh', char: 'ه', letterName: 'هِ', word: 'هواپیما',
      plainWord: 'هواپیما', emoji: '✈️', order: 30,
    ),
    LetterItem(
      id: 'ye', char: 'ی', letterName: 'یِ', word: 'یخ',
      plainWord: 'یخ', emoji: '🧊', order: 31,
    ),
  ];
}
