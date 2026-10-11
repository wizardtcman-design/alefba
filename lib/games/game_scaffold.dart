import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/utils.dart';
import '../data/letters_data.dart';
import '../services/audio_service.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/celebration.dart';
import '../widgets/common_widgets.dart';

/// اسکلت مشترک همه بازی‌ها: هدر با شماره مرحله + جشن پایان
abstract class GameScaffold extends StatefulWidget {
  const GameScaffold({super.key});

  /// عنوان بازی — هر زیرکلاس جداگانه تعیین می‌کند
  String get title;

  /// تعداد مراحل (پیش‌فرض ۵؛ زیرکلاس می‌تواند تغییر دهد)
  int get totalRounds => 5;
}

abstract class GameScaffoldState<T extends GameScaffold> extends State<T> {
  int round = 1;
  bool finished = false;
  final math.Random rnd = math.Random();

  /// ساخت سؤال مرحله فعلی
  Widget buildRound(BuildContext context);

  /// بعد از هر پاسخ درست صدا زده می‌شود
  void nextRound() {
    if (round >= widget.totalRounds) {
      setState(() => finished = true);
      AudioService.instance.praise();
      return;
    }
    setState(() => round++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              PageHeader(
                title: widget.title,
                subtitle: 'مرحله ${Fa.num(round)} از ${Fa.num(widget.totalRounds)}',
              ),
              Expanded(
                child: finished
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.all(18),
                        child: buildRound(context),
                      ),
              ),
            ],
          ),
          if (finished)
            ConfettiOverlay(play: true)
          else
            const SizedBox.shrink(),
          if (finished)
            Center(
              child: CelebrationCard(
                title: 'آفرین! بازی را بردی! 🎉',
                stars: 3,
                continueLabel: 'پایان بازی',
                onContinue: () => Navigator.of(context).pop(),
              ),
            ),
        ],
      ),
    );
  }

  /// انتخاب n گزینه متمایز تصادفی از حروف
  List<LetterModel> pickLetters(int n, {LetterModel? include}) {
    final pool = LettersData.all.where((l) => l.id != include?.id).toList()
      ..shuffle(rnd);
    final result = pool.take(math.max(0, n - (include != null ? 1 : 0))).toList();
    if (include != null) result.add(include);
    result.shuffle(rnd);
    return result;
  }
}

/// کاشی بزرگ حرف برای بازی‌ها
class LetterTile extends StatelessWidget {
  const LetterTile({
    super.key,
    required this.letter,
    required this.color,
    required this.onTap,
    this.state,
  });

  final String letter;
  final Color color;
  final VoidCallback onTap;

  /// normal | correct | wrong
  final String? state;

  @override
  Widget build(BuildContext context) {
    Color bg = color.withValues(alpha: 0.14);
    var borderColor = color;
    if (state == 'correct') {
      bg = AppColors.mint;
      borderColor = AppColors.mintDark;
    } else if (state == 'wrong') {
      bg = AppColors.coralLight;
      borderColor = AppColors.coral;
    }
    return BouncyButton(
      onTap: onTap,
      enabled: state == null,
      color: bg,
      borderRadius: 24,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(letter,
                  style: TextStyle(
                    fontSize: 58,
                    fontWeight: FontWeight.w900,
                    color: state == 'wrong' ? AppColors.coral : color,
                  )),
              if (state == 'correct')
                Positioned(
                  bottom: 6,
                  left: 8,
                  child: Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 30),
                ),
              if (state == 'wrong')
                Positioned(
                  bottom: 6,
                  left: 8,
                  child: Icon(Icons.cancel_rounded,
                      color: AppColors.coral, size: 30),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
