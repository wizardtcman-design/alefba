import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/utils.dart';
import '../../data/numbers_data.dart';
import '../../services/audio_service.dart';
import '../../state/app_state.dart';
import '../../widgets/celebration.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bouncy_button.dart';

/// بازی شمارش: چند شکل می‌بینی؟ عدد درست را انتخاب کن
class CountGame extends StatefulWidget {
  const CountGame({super.key, required this.number});

  final int number;

  @override
  State<CountGame> createState() => _CountGameState();
}

class _CountGameState extends State<CountGame> {
  late int target;
  List<int> options = [];
  bool locked = false;
  bool correct = false;
  int? wrongPick;
  bool finished = false;

  final math.Random _rnd = math.Random();

  @override
  void initState() {
    super.initState();
    // هدف بین ۱ تا ۲۰ (شمارش دست‌کم ۲۰ تا منطقی است)
    target = _rnd.nextInt(10) + 3;
    _makeOptions();
    AudioService.instance.speakAsync(NumberModel(value: target).audio);
  }

  void _makeOptions() {
    final set = <int>{target};
    while (set.length < 4) {
      final c = target + _rnd.nextInt(7) - 3;
      if (c > 0 && c != target) set.add(c);
    }
    options = set.toList()..shuffle(_rnd);
  }

  void _pick(int n) {
    if (locked) return;
    final state = context.read<AppState>();
    if (n == target) {
      setState(() {
        locked = true;
        correct = true;
      });
      state.completeNumberGame(widget.number, game: 'count', won: true);
      AudioService.instance.praise();
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => finished = true);
      });
    } else {
      setState(() => wrongPick = n);
      state.completeNumberGame(widget.number, game: 'count', won: false);
      AudioService.instance.retry();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => wrongPick = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final emoji = NumbersData.countEmoji(target).characters.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              PageHeader(
                title: 'بازی شمارش',
                subtitle: 'بشمار و عدد درست را بزن!',
                headerColor: AppColors.mint,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const Text(
                        'چند تا می‌بینی؟ 🤔',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text),
                      ),
                      const SizedBox(height: 12),
                      // اشکال قابل شمارش
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: AppColors.cardShadow(),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            runAlignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (var i = 0; i < target; i++)
                                Text(emoji,
                                    style: const TextStyle(fontSize: 34)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // گزینه‌ها
                      Row(
                        children: [
                          for (var i = 0; i < options.length; i++) ...[
                            if (i > 0) const SizedBox(width: 10),
                            Expanded(
                              child: BouncyButton(
                                onTap: () => _pick(options[i]),
                                enabled: !locked,
                                color: correct && options[i] == target
                                    ? AppColors.mint
                                    : (wrongPick == options[i]
                                        ? AppColors.coralLight
                                        : Colors.white),
                                borderRadius: 20,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: correct && options[i] == target
                                          ? AppColors.mintDark
                                          : (wrongPick == options[i]
                                              ? AppColors.coral
                                              : AppColors.mint
                                                  .withValues(alpha: 0.4)),
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      Fa.num(options[i]),
                                      style: TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                        color: correct && options[i] == target
                                            ? Colors.white
                                            : (wrongPick == options[i]
                                                ? AppColors.coral
                                                : AppColors.mintDark),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (finished) const ConfettiOverlay(play: true),
          if (finished)
            Center(
              child: CelebrationCard(
                title: 'شمارنده‌ی قهارتی! 🎉',
                stars: 3,
                continueLabel: 'پایان بازی',
                onContinue: () => Navigator.of(context).pop(),
              ),
            ),
        ],
      ),
    );
  }
}
