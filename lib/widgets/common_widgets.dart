import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/utils.dart';
import 'bouncy_button.dart';

/// نوار پایین مشترک (مطابق موکاپ): خانه | درس‌ها | پیشرفت | بیشتر
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.current,
    required this.onTap,
  });

  /// home | lessons | progress | more
  final String current;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    Widget item(String key, IconData icon, IconData iconOff, String label,
        {Color color = AppColors.primary}) {
      final active = current == key;
      return Expanded(
        child: BouncyButton(
          onTap: () => onTap(key),
          color: Colors.transparent,
          borderRadius: 18,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: active
                      ? BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        )
                      : null,
                  child: Icon(active ? icon : iconOff,
                      size: 30,
                      color: active ? color : AppColors.textLight),
                ),
                const SizedBox(height: 2),
                Text(label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                      color: active ? color : AppColors.textLight,
                    )),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
          child: Row(
            children: [
              item('home', Icons.home_rounded, Icons.home_outlined, 'خانه'),
              item('lessons', Icons.menu_book_rounded, Icons.menu_book_outlined,
                  'درس‌ها'),
              item('progress', Icons.emoji_events_rounded,
                  Icons.emoji_events_outlined, 'پیشرفت'),
              item('more', Icons.tune_rounded, Icons.tune_outlined, 'بیشتر'),
            ],
          ),
        ),
      ),
    );
  }
}

/// هدر استاندارد صفحات داخلی: دکمه برگشت + عنوان + ستاره
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.stars,
    this.onBack,
    this.headerColor = AppColors.primary,
  });

  final String title;
  final String? subtitle;
  final int? stars;
  final VoidCallback? onBack;
  final Color headerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, MediaQuery.of(context).padding.top + 8, 12, 14),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: AppColors.softShadow(headerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              BouncyButton(
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: 16,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 30),
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              if (stars != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.gold, size: 26),
                      const SizedBox(width: 4),
                      Text(
                        '${Fa.num(stars!)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(width: 46),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ],
      ),
    );
  }
}
