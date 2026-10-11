import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// عنوان بخش با آیکن
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.text,
    this.icon,
    this.color,
  });

  final String text;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, color: color ?? AppColors.purple, size: 26),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

/// کارت سفید گرد با سایه ملایم
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.color,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final Color? color;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final Widget body = Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: body,
      ),
    );
  }
}

/// ردیف ستاره‌ها
class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.stars, this.size = 18, this.max = 3});

  final int stars;
  final double size;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(
        max,
        (int i) => Icon(
          i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
          color: AppColors.star,
          size: size,
        ),
      ),
    );
  }
}

/// دکمه بزرگ و رنگی مناسب کودکان
class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.label,
    this.onTap,
    this.color,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.purple,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// دیالوگ قفل بودن مرحله
Future<void> showLockedDialog(
  BuildContext context, {
  String? message,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext ctx) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('🔒', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            const Text(
              'هنوز قفل است!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'اول مرحله‌ی قبل را کامل کن تا این بخش باز شود.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            BigButton(
              label: 'باشه!',
              color: AppColors.coral,
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    ),
  );
}

/// جشن پایان بازی با ستاره‌ها
Future<void> showCelebration(
  BuildContext context, {
  required int stars,
  String message = 'آفرین! عالی بود',
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (BuildContext context, double v, Widget? child) =>
                  Transform.scale(scale: v, child: child),
              child: const Text('🎉', style: TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            StarRow(stars: stars, size: 40),
            const SizedBox(height: 20),
            BigButton(
              label: 'برگردیم!',
              color: AppColors.mint,
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    ),
  );
}

/// پایان بازی: ثبت نتیجه + نمایش جشن + خروج از صفحه بازی
Future<void> endGame(
  BuildContext context, {
  required void Function(int stars) onFinish,
  required int stars,
  String message = 'آفرین! عالی بود',
}) async {
  onFinish(stars);
  await showCelebration(context, stars: stars, message: message);
  if (context.mounted) {
    Navigator.of(context).pop();
  }
}

/// نمایش گروه نقطه‌های شمارش (ردیف هر ۱۰ تا)
class TenFrameDots extends StatelessWidget {
  const TenFrameDots({
    super.key,
    required this.count,
    this.dotSize = 14,
    this.color,
  });

  final int count;
  final double dotSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? AppColors.coral;
    final double gap = dotSize * 0.45;
    final double rowWidth = 10 * dotSize + 9 * gap;
    return SizedBox(
      width: rowWidth,
      child: Wrap(
        spacing: gap,
        runSpacing: gap,
        children: List<Widget>.generate(
          count,
          (int i) => Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
