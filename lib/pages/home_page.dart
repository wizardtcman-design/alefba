import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../games/games_page.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import '../utils/persian.dart';
import '../widgets/common.dart';
import 'dashboard_page.dart';
import 'letters_page.dart';
import 'numbers_page.dart';
import 'settings_page.dart';

/// صفحه اصلی: خوش‌آمد، پیشرفت کلی و منوی بزرگ
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفبای من'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            color: AppColors.purple,
            tooltip: 'تنظیمات',
            onPressed: () => _open(context, const SettingsPage()),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<ProgressProvider>(
          builder: (BuildContext context, ProgressProvider provider, _) {
            final int percent = provider.overallPercent.round();
            // ارتفاع ثابت ~۱۵۰ برای کارت‌های منو در هر اندازه صفحه
            final double cellWidth =
                (MediaQuery.of(context).size.width - 40 - 14) / 2;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _WelcomeCard(percent: percent),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: cellWidth / 150,
                    children: <Widget>[
                      _MenuCard(
                        emoji: '📚',
                        title: 'حروف الفبا',
                        subtitle:
                            '${toPersianDigits(provider.completedLetters)} از ۳۲',
                        color: AppColors.purple,
                        onTap: () => _open(context, const LettersPage()),
                      ),
                      _MenuCard(
                        emoji: '🔢',
                        title: 'اعداد',
                        subtitle:
                            '${toPersianDigits(provider.knownNumbersCount)} از ۱۰۱',
                        color: AppColors.mint,
                        onTap: () => _open(context, const NumbersPage()),
                      ),
                      _MenuCard(
                        emoji: '🎮',
                        title: 'بازی‌ها',
                        subtitle: '${toPersianDigits(provider.totalGamePlays)} بازی',
                        color: AppColors.coral,
                        onTap: () => _open(context, const GamesPage()),
                      ),
                      _MenuCard(
                        emoji: '📊',
                        title: 'داشبورد والدین',
                        subtitle: 'گزارش پیشرفت',
                        color: AppColors.star,
                        onTap: () => _open(context, const DashboardPage()),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// کارت خوش‌آمد با نشانگر پیشرفت کلی
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: <Widget>[
          const Text('🦉', style: TextStyle(fontSize: 64)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'سلام! آماده‌ای یاد بگیریم؟',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    minHeight: 14,
                    backgroundColor: AppColors.disabled,
                    color: AppColors.mint,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'پیشرفت کلی: ${toPersianDigits(percent)}٪',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// کارت بزرگ منو با نوار رنگی بالای کارت
class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color.withOpacity(0.10),
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            emoji,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 44),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: const TextStyle(fontSize: 14, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
