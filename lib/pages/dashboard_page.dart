import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/alphabet_data.dart';
import '../models/models.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import '../utils/persian.dart';
import '../widgets/common.dart';

/// داشبورد والدین: آمار کلی، پیشرفت حروف و اعداد، تنظیم مجدد
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<void> _confirmAndReset(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('🤔', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              const Text(
                'مطمئنی؟',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'همه‌ی ستاره‌ها و پیشرفت پاک می‌شود.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textLight,
                        side: const BorderSide(
                          color: AppColors.disabled,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        minimumSize: const Size(64, 50),
                      ),
                      child: const Text(
                        'نه',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.coral,
                      ),
                      child: const Text(
                        'بله، پاک کن',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<ProgressProvider>().resetAll();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('پیشرفت پاک شد')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('داشبورد والدین')),
      body: SafeArea(
        child: Consumer<ProgressProvider>(
          builder: (BuildContext context, ProgressProvider provider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _statsGrid(provider),
                  const SizedBox(height: 16),
                  _lettersCard(provider),
                  const SizedBox(height: 16),
                  _numbersCard(provider),
                  const SizedBox(height: 16),
                  _resetCard(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// چهار آمار کلی در شبکه ۲×۲
  Widget _statsGrid(ProgressProvider provider) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: <Widget>[
        _StatCard(
          emoji: '📈',
          value: '${toPersianDigits(provider.overallPercent.round())}٪',
          label: 'درصد کل',
          color: AppColors.purple,
        ),
        _StatCard(
          emoji: '🔤',
          value:
              '${toPersianDigits(provider.completedLetters)} از ${toPersianDigits(32)}',
          label: 'حروف کامل‌شده',
          color: AppColors.mint,
        ),
        _StatCard(
          emoji: '⭐',
          value: toPersianDigits(provider.totalStars),
          label: 'ستاره‌ها',
          color: AppColors.star,
        ),
        _StatCard(
          emoji: '🎮',
          value: toPersianDigits(provider.totalGamePlays),
          label: 'بازی‌ها',
          color: AppColors.coral,
        ),
      ],
    );
  }

  /// شبکه کوچک ۳۲ حرف با رنگ وضعیت + راهنمای رنگ‌ها
  Widget _lettersCard(ProgressProvider provider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SectionTitle(
            text: 'پیشرفت حروف',
            icon: Icons.grid_view_rounded,
            color: AppColors.purple,
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1,
            ),
            itemCount: AlphabetData.letters.length,
            itemBuilder: (BuildContext context, int index) {
              final LetterItem letter = AlphabetData.letters[index];
              final bool completed = provider.isLetterCompleted(index);
              final bool learned =
                  provider.letterProgressOf(letter.id)?.learned ?? false;
              final Color bg = completed
                  ? AppColors.playful[index % AppColors.playful.length]
                  : learned
                      ? AppColors.purple.withOpacity(0.45)
                      : AppColors.disabled;
              return Tooltip(
                message: letter.letterName,
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter.char,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: <Widget>[
              const _LegendDot(color: AppColors.mint, label: 'کامل'),
              // همان رنگ کاشی «در حال یادگیری» (بنفش با شفافیت ۴۵٪)
              _LegendDot(
                color: AppColors.purple.withOpacity(0.45),
                label: 'در حال یادگیری',
              ),
              const _LegendDot(color: AppColors.disabled, label: 'شروع نشده'),
            ],
          ),
        ],
      ),
    );
  }

  /// پیشرفت ۱۱ گروه اعداد (۰ تا ۹، ۱۰ تا ۱۹، ...، ۱۰۰)
  Widget _numbersCard(ProgressProvider provider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SectionTitle(
            text: 'پیشرفت اعداد',
            icon: Icons.calculate_rounded,
            color: AppColors.mint,
          ),
          const SizedBox(height: 8),
          ...List<Widget>.generate(
            11,
            (int group) => _groupRow(provider, group),
          ),
        ],
      ),
    );
  }

  Widget _groupRow(ProgressProvider provider, int group) {
    final int total = group == 10 ? 1 : 10;
    final int known = _knownInGroup(provider, group);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 104,
            child: Text(
              'گروه ${_groupLabel(group)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: known / total,
                minHeight: 10,
                backgroundColor: AppColors.disabled,
                color: AppColors.mint,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 48,
            child: Text(
              '${toPersianDigits(known)}/${toPersianDigits(total)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _knownInGroup(ProgressProvider provider, int group) {
    if (group == 10) return provider.isNumberKnown(100) ? 1 : 0;
    int known = 0;
    for (int v = group * 10; v < group * 10 + 10; v++) {
      if (provider.isNumberKnown(v)) known++;
    }
    return known;
  }

  String _groupLabel(int group) {
    if (group == 10) return '۱۰۰';
    return '${toPersianDigits(group * 10)} تا ${toPersianDigits(group * 10 + 9)}';
  }

  /// کارت خطرناک: پاک کردن کل پیشرفت
  Widget _resetCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SectionTitle(
            text: 'تنظیم مجدد پیشرفت',
            icon: Icons.restart_alt_rounded,
            color: AppColors.coral,
          ),
          const SizedBox(height: 4),
          const Text(
            'همه‌ی ستاره‌ها و پیشرفت ذخیره‌شده پاک می‌شود.',
            style: TextStyle(fontSize: 14, color: AppColors.textLight),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _confirmAndReset(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.coral,
              side: const BorderSide(color: AppColors.coral, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              minimumSize: const Size(64, 50),
            ),
            child: const Text(
              'پاک کردن همه پیشرفت',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// کارت آمار: ایموجی، عدد بزرگ رنگی و برچسب
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  final String emoji;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            emoji,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: const TextStyle(fontSize: 14, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}

/// نقطه رنگی کوچک + برچسب برای راهنمای وضعیت
class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textLight),
        ),
      ],
    );
  }
}
