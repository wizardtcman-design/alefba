import 'package:flutter/material.dart';

/// پالت رنگ رسمی اپ — مطابق بریف طراحی
/// بنفش ملایم، مرجانی، نعنایی، کرم روشن و سرمه‌ای متن
class AppColors {
  AppColors._();

  // ── رنگ‌های اصلی ──────────────────────────────────────────────
  static const Color primary = Color(0xFF9B7EBD); // بنفش ملایم
  static const Color primaryDark = Color(0xFF7A5FA8);
  static const Color primaryLight = Color(0xFFE7DDF3);

  static const Color coral = Color(0xFFFF6B6B); // مرجانی
  static const Color coralDark = Color(0xFFE85555);
  static const Color coralLight = Color(0xFFFFE3E3);

  static const Color mint = Color(0xFF4ECDC4); // نعنایی
  static const Color mintDark = Color(0xFF35B8AF);
  static const Color mintLight = Color(0xFFDFF6F4);

  static const Color background = Color(0xFFFDF6F0); // کرم پس‌زمینه
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF2C3E50); // متن سرمه‌ای
  static const Color textLight = Color(0xFF8A9BAC);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color gold = Color(0xFFFFC93C); // ستاره
  static const Color lockGrey = Color(0xFFC4CDD5); // قفل

  // ── سایه نرم دکمه‌ها ─────────────────────────────────────────
  static List<BoxShadow> softShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.28),
          offset: const Offset(0, 4),
          blurRadius: 10,
        ),
      ];

  static List<BoxShadow> cardShadow() => [
        BoxShadow(
          color: const Color(0xFF9B7EBD).withValues(alpha: 0.10),
          offset: const Offset(0, 3),
          blurRadius: 8,
        ),
      ];
}
