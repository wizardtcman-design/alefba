import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// تم سراسری اپ — فونت Vazirmatn، رنگ‌های پاستلی، گوشه‌های گرد
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const textTheme = TextTheme(
      displayLarge: TextStyle(
          fontFamily: 'Vazirmatn', fontWeight: FontWeight.w900, height: 1.25),
      displayMedium: TextStyle(
          fontFamily: 'Vazirmatn', fontWeight: FontWeight.w800, height: 1.25),
      headlineLarge: TextStyle(
          fontFamily: 'Vazirmatn', fontWeight: FontWeight.w800, height: 1.3),
      headlineMedium: TextStyle(
          fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700, height: 1.3),
      titleLarge: TextStyle(
          fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700, height: 1.4),
      titleMedium: TextStyle(
          fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600, height: 1.4),
      bodyLarge: TextStyle(
          fontFamily: 'Vazirmatn', fontWeight: FontWeight.w500, height: 1.6),
      bodyMedium: TextStyle(
          fontFamily: 'Vazirmatn', fontWeight: FontWeight.w400, height: 1.6),
      bodySmall: TextStyle(
          fontFamily: 'Vazirmatn', fontWeight: FontWeight.w400, height: 1.5),
      labelLarge: TextStyle(
          fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Vazirmatn',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.coral,
        tertiary: AppColors.mint,
        surface: AppColors.surface,
        error: AppColors.coralDark,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
        iconTheme: IconThemeData(color: AppColors.text),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 18,
              fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.white
                : AppColors.lockGrey),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.mint
                : AppColors.lockGrey.withValues(alpha: 0.4)),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.primaryLight.withValues(alpha: 0.6),
        thickness: 1.5,
      ),
    );
  }
}
