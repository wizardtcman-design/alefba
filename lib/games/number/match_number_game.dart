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

/// بازی جفت‌یابی عدد: عدد را به نامش وصل کن (۶ کارت = ۳ جفت)
class MatchNumberGame extends StatefulWidget {
  const MatchNumberGame({super.key, required this.number});

  final int number;

  @override
  State<MatchNumberGame> createState() => _MatchNumberGameState();
}

class _MatchNumberGameState extends State<MatchNumberGame> {
  late List<_Tile> tiles;
  int? firstPickIndex;
  bool busy = false;
  bool finished = false;

  final math.Random _rnd = math.Random();

  @override
  void initState() {
    super.initState();
    _newBoard();
  }

  void _newBoard() {
    // ۳ عدد نزدیک به عدد درس
    final base = widget.number;
    final picks = <int>{base};
    var guard = 0;
    while (picks.length < 3 && guard++ < 50) {
      final c = base + _rnd.nextInt(6) - 3;
      if (c >= 0 && c <= 100) picks.add(c);
    }
    tiles = [];
    for (final n in picks) {
      tiles.add(_Tile(n: n, isDigit: true));
      tiles.add(_Tile(n: n, isDigit: false));
    }
    tiles.shuffle(_rnd);
    firstPickIndex = null;
  }

  void _tap(int i) {
    if (busy) return;
    final t = tiles[i];
    if (t.matched || t.revealed) return;

    AudioService.instance
        .speakAsync(NumberModel(value: t.n).audio);
    setState(() => t.revealed = true);

    if (firstPickIndex == null) {
      firstPickIndex = i;
      return;
    }
    final a = tiles[firstPickIndex!];
    firstPickIndex = null;

    if (a.n == t.n && a.isDigit != t.isDigit) {
      setState(() {
        a.matched = true;
        t.matched = true;
      });
      context
          .read<AppState>()
          .completeNumberGame(widget.number, game: 'match', won: true);
      AudioService.instance.star();
      if (tiles.every((x) => x.matched)) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) setState(() => finished = true);
        });
      }
    } else {
      busy = true;
      context
          .read<AppState>()
          .completeNumberGame(widget.number, game: 'match', won: false);
      AudioService.instance.retry();
      Future.delayed(const Duration(milliseconds: 950), () {
        if (!mounted) return;
        setState(() {
          a.revealed = false;
          t.revealed = false;
          busy = false;
        });
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
                title: 'بازی جفت‌یابی',
                subtitle: 'عدد را به نامش برسان!',
                headerColor: AppColors.primary,
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(18),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: tiles.length,
                  itemBuilder: (context, i) {
                    final t = tiles[i];
                    final show = t.revealed || t.matched;
                    final color = t.isDigit ? AppColors.primary : AppColors.coral;
                    return GestureDetector(
                      onTap: () => _tap(i),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Container(
                          key: ValueKey(show ? 'f${t.n}${t.isDigit}' : 'b$i'),
                          decoration: BoxDecoration(
                            color: show
                                ? Colors.white
                                : AppColors.primary.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: show
                                  ? (t.matched ? AppColors.mint : color)
                                  : AppColors.primaryDark,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: show
                                ? (t.isDigit
                                    ? Text(Fa.num(t.n),
                                        style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w900,
                                            color: t.matched
                                                ? AppColors.mintDark
                                                : color))
                                    : Text(NumberModel(value: t.n).name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: t.matched
                                                ? AppColors.mintDark
                                                : color)))
                                : const Icon(Icons.favorite_rounded,
                                    color: Colors.white, size: 30),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (finished) const ConfettiOverlay(play: true),
          if (finished)
            Center(
              child: CelebrationCard(
                title: 'همه جفت‌ها را پیدا کردی! 🎉',
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

class _Tile {
  _Tile({required this.n, required this.isDigit});

  final int n;
  final bool isDigit;
  bool revealed = false;
  bool matched = false;
}
