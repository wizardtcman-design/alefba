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

/// بازی «عدد را پیدا کن»: اسم عدد گفته می‌شود، کودک از بین ۴ گزینه درست را می‌زند
class FindNumberGame extends StatefulWidget {
  const FindNumberGame({super.key, required this.number});

  final int number;

  @override
  State<FindNumberGame> createState() => _FindNumberGameState();
}

class _FindNumberGameState extends State<FindNumberGame> {
  late int target;
  late List<int> options;
  bool locked = false;
  bool correct = false;
  int? wrongPick;
  bool finished = false;

  final math.Random _rnd = math.Random();

  @override
  void initState() {
    super.initState();
    target = widget.number;
    _makeOptions();
    AudioService.instance.speakAsync(NumberModel(value: target).audio);
  }

  void _makeOptions() {
    final set = <int>{target};
    var guard = 0;
    while (set.length < 4 && guard++ < 60) {
      final c = target + _rnd.nextInt(11) - 5;
      if (c >= 0 && c <= 100 && c != target) set.add(c);
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
      state.completeNumberGame(widget.number, game: 'find', won: true);
      AudioService.instance.praise();
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => finished = true);
      });
    } else {
      setState(() => wrongPick = n);
      state.completeNumberGame(widget.number, game: 'find', won: false);
      AudioService.instance.retry();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => wrongPick = null);
      });
    }
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
                title: 'عدد را پیدا کن',
                subtitle: 'گوش کن و عدد درست را بزن!',
                headerColor: AppColors.coral,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'کدام عدد است؟',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text),
                      ),
                      const SizedBox(height: 18),
                      BouncyButton(
                        onTap: () => AudioService.instance
                            .speakAsync(NumberModel(value: target).audio),
                        color: AppColors.coral,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.volume_up_rounded,
                                  color: Colors.white, size: 30),
                              SizedBox(width: 8),
                              Text('بشنو دوباره',
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.6,
                        children: [
                          for (final o in options)
                            BouncyButton(
                              onTap: () => _pick(o),
                              enabled: !locked,
                              color: correct && o == target
                                  ? AppColors.mint
                                  : (wrongPick == o
                                      ? AppColors.coralLight
                                      : Colors.white),
                              borderRadius: 22,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: correct && o == target
                                        ? AppColors.mintDark
                                        : (wrongPick == o
                                            ? AppColors.coral
                                            : AppColors.coral
                                                .withValues(alpha: 0.35)),
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Center(
                                  child: Text(
                                    Fa.num(o),
                                    style: TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      color: correct && o == target
                                          ? Colors.white
                                          : (wrongPick == o
                                              ? AppColors.coral
                                              : AppColors.text),
                                    ),
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
            ],
          ),
          if (finished) const ConfettiOverlay(play: true),
          if (finished)
            Center(
              child: CelebrationCard(
                title: 'چشم تیزبینی داری! 🎉',
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
