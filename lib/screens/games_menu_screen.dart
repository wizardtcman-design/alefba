import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/utils.dart';
import '../services/audio_service.dart';
import '../state/app_state.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/common_widgets.dart';
import '../games/letter/drag_drop_game.dart';
import '../games/letter/find_game.dart';
import '../games/letter/match_game.dart';
import '../games/letter/memory_game.dart';

/// منوی بازی‌های مستقل — با هر حرفی که باز کرده، بازی کن
class GamesMenuScreen extends StatelessWidget {
  const GamesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // حرف تصادفی از بین حروف باز شده برای شروع بازی
    final unlockedIds = <int>[
      for (var i = 1; i <= 33; i++)
        if (state.isLetterUnlocked(i)) i
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          PageHeader(
            title: 'بازی‌های بامزه',
            subtitle: 'هر وقت بخواهی، با حرف‌هایی که یاد گرفتی بازی کن!',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _GameCard(
                  emoji: '🔍',
                  color: AppColors.mint,
                  title: 'بازی پیدا کن',
                  desc: 'حرف درست را بین گزینه‌ها پیدا کن',
                  onTap: unlockedIds.isEmpty
                      ? null
                      : () => _start(
                          context, FindLetterGame(letterId: _random(unlockedIds))),
                ),
                _GameCard(
                  emoji: '🧩',
                  color: AppColors.coral,
                  title: 'بازی جور کن',
                  desc: 'هر حرف را به تصویر خودش برسان',
                  onTap: unlockedIds.isEmpty
                      ? null
                      : () => _start(
                          context, MatchLetterGame(letterId: _random(unlockedIds))),
                ),
                _GameCard(
                  emoji: '🃏',
                  color: AppColors.primary,
                  title: 'بازی حافظه',
                  desc: 'کارت‌ها را برگردان و جفت‌ها را پیدا کن',
                  onTap: unlockedIds.isEmpty
                      ? null
                      : () => _start(
                          context, MemoryLetterGame(letterId: _random(unlockedIds))),
                ),
                _GameCard(
                  emoji: '🖐️',
                  color: AppColors.gold,
                  title: 'بکش و بگذار',
                  desc: 'حرف‌ها را روی تصویر خودشان بگذار',
                  onTap: unlockedIds.isEmpty
                      ? null
                      : () => _start(
                          context, DragDropLetterGame(letterId: _random(unlockedIds))),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mintLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Text('🦊', style: TextStyle(fontSize: 36)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          unlockedIds.isEmpty
                              ? 'اول در درس‌ها حرف «آ» را کامل کن تا بازی‌ها باز شوند!'
                              : 'با ${Fa.num(unlockedIds.length)} حرفی که یاد گرفتی می‌توانی بازی کنی!',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mintDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _random(List<int> ids) =>
      ids[math.Random().nextInt(ids.length)];

  void _start(BuildContext context, Widget game) {
    AudioService.instance.go();
    Navigator.push(context, MaterialPageRoute(builder: (_) => game));
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.emoji,
    required this.color,
    required this.title,
    required this.desc,
    required this.onTap,
  });

  final String emoji;
  final Color color;
  final String title;
  final String desc;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: BouncyButton(
        onTap: onTap ?? () {},
        enabled: !disabled,
        color: disabled ? AppColors.lockGrey.withValues(alpha: 0.2) : Colors.white,
        borderRadius: 24,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: disabled
                      ? AppColors.lockGrey.withValues(alpha: 0.2)
                      : color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                    child: Text(disabled ? '🔒' : emoji,
                        style: const TextStyle(fontSize: 34))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: disabled ? AppColors.lockGrey : AppColors.text)),
                    const SizedBox(height: 2),
                    Text(desc,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: disabled
                                ? AppColors.lockGrey
                                : AppColors.textLight)),
                  ],
                ),
              ),
              Icon(Icons.arrow_back_rounded,
                  color: disabled ? AppColors.lockGrey : color, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
