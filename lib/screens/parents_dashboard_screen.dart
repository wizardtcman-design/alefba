import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/utils.dart';
import '../data/letters_data.dart';
import '../state/app_state.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/common_widgets.dart';

/// داشبورد والدین: گزارش پیشرفت، دقت، زمان بازی و مدیریت پیشرفت
class ParentsDashboardScreen extends StatelessWidget {
  const ParentsDashboardScreen({super.key});

  String _duration(int seconds) {
    final m = seconds ~/ 60;
    if (m < 60) return '${Fa.num(m)} دقیقه';
    return '${Fa.num(m ~/ 60)} ساعت و ${Fa.num(m % 60)} دقیقه';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final report = state.report();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          PageHeader(
            title: 'پیشرفت کودک',
            subtitle: 'گزارش ویژه والدین عزیز',
            headerColor: AppColors.primary,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                // ── کارت‌های خلاصه ──
                Row(
                  children: [
                    _StatCard(
                      label: 'حروف کامل‌شده',
                      value:
                          '${Fa.num(report.completedLetters)} از ${Fa.num(report.totalLetters)}',
                      emoji: '📚',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'ستاره‌ها',
                      value: Fa.num(report.totalStars),
                      emoji: '⭐',
                      color: AppColors.gold,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatCard(
                      label: 'دقت در بازی‌ها',
                      value: '%${Fa.num((report.accuracy * 100).round())}',
                      emoji: '🎯',
                      color: AppColors.mint,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'زمان امروز',
                      value: _duration(report.todaySeconds),
                      emoji: '⏰',
                      color: AppColors.coral,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── پیشرفت کلی ──
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: AppColors.cardShadow(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'پیشرفت کل دوره الفبا',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: report.overallPercent,
                          minHeight: 16,
                          backgroundColor: AppColors.primaryLight,
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '%${Fa.num((report.overallPercent * 100).round())} کامل شده',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ── جدول حروف ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: AppColors.cardShadow(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'وضعیت تک‌تک حروف',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text),
                      ),
                      const SizedBox(height: 12),
                      ...LettersData.all.map((l) {
                        final p = state.progressOf(l.id);
                        final unlocked = state.isLetterUnlocked(l.id);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: unlocked
                                      ? AppColors.primaryLight
                                      : AppColors.lockGrey.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  unlocked ? l.char : '🔒',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: unlocked
                                        ? AppColors.primaryDark
                                        : AppColors.lockGrey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  unlocked ? l.word : 'قفل',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text),
                                ),
                              ),
                              SizedBox(
                                width: 110,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: p.completionRatio,
                                    minHeight: 8,
                                    backgroundColor:
                                        AppColors.lockGrey.withValues(alpha: 0.25),
                                    valueColor:
                                        const AlwaysStoppedAnimation(
                                            AppColors.mint),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 52,
                                child: Text(
                                  p.isCompleted
                                      ? 'کامل ✅'
                                      : '${Fa.num((p.completionRatio * 100).round())}٪',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: p.isCompleted
                                        ? AppColors.mintDark
                                        : AppColors.textLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ── ریست پیشرفت ──
                BouncyButton(
                  onTap: () => _confirmReset(context),
                  color: AppColors.coralLight,
                  borderRadius: 20,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restart_alt_rounded,
                            color: AppColors.coralDark, size: 26),
                        SizedBox(width: 8),
                        Text(
                          'شروع مجدد پیشرفت',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.coralDark),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('شروع مجدد؟',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
          'همه ستاره‌ها و پیشرفت پاک می‌شود و دوره از حرف «آ» شروع می‌شود.',
          style: TextStyle(height: 1.7),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('نه، بی‌خیال',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            onPressed: () {
              context.read<AppState>().resetProgress();
              Navigator.pop(ctx);
            },
            child: const Text('بله، پاک کن'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
  });

  final String label;
  final String value;
  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppColors.cardShadow(),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}
