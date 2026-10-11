import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/utils.dart';
import '../state/app_state.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/common_widgets.dart';
import 'number_detail_screen.dart';

/// خانه اعداد: گرید کامل ۰ تا ۱۰۰ (مطابق موکاپ سوم)
class NumbersHomeScreen extends StatelessWidget {
  const NumbersHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final report = state.report();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          PageHeader(
            title: 'اعداد ۰ تا ۱۰۰',
            subtitle: 'بیا با هم اعداد رو یاد بگیریم!',
            stars: report.totalStars,
            headerColor: AppColors.coral,
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 82,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.05,
              ),
              itemCount: 101,
              itemBuilder: (context, i) => _NumberChip(value: i),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberChip extends StatelessWidget {
  const _NumberChip({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final unlocked = state.isNumberUnlocked(value);
    final progress = state.numberProgressOf(value);

    // رنگ چرخه‌ای ده‌تایی‌ها
    final colors = [AppColors.primary, AppColors.coral, AppColors.mint];
    final color = colors[(value ~/ 10) % 3];

    return BouncyButton(
      enabled: unlocked,
      color: unlocked ? Colors.white : AppColors.lockGrey.withValues(alpha: 0.22),
      borderRadius: 16,
      onTap: () {
        AudioService.instance.go();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NumberDetailScreen(initialValue: value),
          ),
        );
      },
      child: Stack(
        children: [
          Center(
            child: Text(
              unlocked ? Fa.num(value) : '🔒',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: unlocked ? color : AppColors.lockGrey,
              ),
            ),
          ),
          if (unlocked && progress.stars > 0)
            const Positioned(
              top: 3,
              left: 4,
              child: Icon(Icons.star_rounded,
                  size: 16, color: AppColors.gold),
            ),
        ],
      ),
    );
  }
}
