import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/utils.dart';
import '../data/letters_data.dart';
import '../services/audio_service.dart';
import '../state/app_state.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/common_widgets.dart';
import 'letter_detail_screen.dart';

/// لیست ۳۳ حرف با قفل مرحله‌ای: تا حرف قبلی کامل نشود، بعدی باز نمی‌شود
class LettersListScreen extends StatelessWidget {
  const LettersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final report = state.report();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          PageHeader(
            title: 'حروف الفبا',
            subtitle: 'حرف‌ها را به ترتیب، یکی‌یکی کامل کن!',
            stars: report.totalStars,
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.88,
              ),
              itemCount: LettersData.all.length,
              itemBuilder: (context, index) =>
                  _LetterTile(model: LettersData.all[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({required this.model});

  final LetterModel model;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final progress = state.progressOf(model.id);
    final unlocked = state.isLetterUnlocked(model.id);

    final color = model.id % 3 == 0
        ? AppColors.mint
        : model.id % 3 == 1
            ? AppColors.primary
            : AppColors.coral;

    return BouncyButton(
      enabled: unlocked,
      borderRadius: 24,
      color: unlocked ? Colors.white : AppColors.lockGrey.withValues(alpha: 0.25),
      onTap: unlocked
          ? () {
              AudioService.instance.go();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LetterDetailScreen(letterId: model.id),
                ),
              );
            }
          : () {
              AudioService.instance.speakAsync(Sfx.lockHint);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.text,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  content: const Text(
                    'اول حرف قبلی را کامل کن تا این حرف باز شود! 🔒',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              );
            },
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // حلقه پیشرفت دور حرف
            SizedBox(
              width: 66,
              height: 66,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (unlocked)
                    SizedBox(
                      width: 66,
                      height: 66,
                      child: CircularProgressIndicator(
                        value: progress.completionRatio,
                        strokeWidth: 5,
                        backgroundColor: color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(color),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  Text(
                    unlocked ? model.char : '🔒',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: unlocked ? color : AppColors.lockGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              unlocked ? model.word : 'قفل است',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: unlocked ? AppColors.text : AppColors.lockGrey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return Icon(
                  Icons.star_rounded,
                  size: 15,
                  color: i < progress.stars
                      ? AppColors.gold
                      : AppColors.lockGrey.withValues(alpha: 0.35),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
