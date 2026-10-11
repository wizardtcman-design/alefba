import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../data/letters_data.dart';
import '../features/writing/writing_tracer.dart';
import '../services/audio_service.dart';
import '../state/app_state.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/celebration.dart';
import '../widgets/common_widgets.dart';
import '../games/letter/find_game.dart';
import '../games/letter/drag_drop_game.dart';
import '../games/letter/match_game.dart';
import '../games/letter/memory_game.dart';
import 'home_screen.dart';
import 'letters_list_screen.dart';
import 'parents_dashboard_screen.dart';
import 'settings_screen.dart';

/// صفحه آموزش یک حرف: تصویر + صدا + نوشتن + ۴ بازی
class LetterDetailScreen extends StatefulWidget {
  const LetterDetailScreen({super.key, required this.letterId});

  final int letterId;

  @override
  State<LetterDetailScreen> createState() => _LetterDetailScreenState();
}

class _LetterDetailScreenState extends State<LetterDetailScreen> {
  bool _teaching = false;
  bool _celebrate = false;

  LetterModel get model => LettersData.byId(widget.letterId);

  @override
  void dispose() {
    AudioService.instance.stopVoice();
    super.dispose();
  }

  /// تدریس خودکار: معرفی → صدای حرف → صدای کلمه (پشت‌سرهم، آفلاین)
  Future<void> _autoTeach() async {
    if (_teaching) return;
    setState(() => _teaching = true);
    await AudioService.instance
        .speakQueue([model.introAudio, model.soundAudio, model.wordAudio]);
    if (mounted) setState(() => _teaching = false);
  }

  Future<void> _playWord() async =>
      AudioService.instance.speakQueue([model.wordAudio]);

  Future<void> _playSound() async =>
      AudioService.instance.speakQueue([model.soundAudio]);

  /// خوانش هجایی: هر هجا یک دکمه با صدای جداگانه (فایل‌های آفلاین)
  Future<void> _playSyllables() async {
    final paths = [for (var i = 0; i < model.syllables.length; i++) model.syllableAudio(i)];
    await AudioService.instance.speakQueue(paths);
  }

  void _onWritingDone() {
    final state = context.read<AppState>();
    state.completeLetterPart(widget.letterId, part: 'writing', stars: 1);
    _checkCompletion();
  }

  void _onGameDone(String part) {
    final state = context.read<AppState>();
    state.completeLetterPart(widget.letterId, part: part, stars: 1);
    state.flushAnswerStatsTo(widget.letterId);
    _checkCompletion();
  }

  void _checkCompletion() {
    final state = context.read<AppState>();
    if (state.progressOf(widget.letterId).isCompleted && !_celebrate) {
      setState(() => _celebrate = true);
      AudioService.instance.praise();
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => CelebrationCard(
              title: 'حرف ${model.char} را کامل یاد گرفتی! 🎉',
              stars: 3,
              continueLabel: widget.letterId < 33 ? 'حرف بعدی' : 'بازگشت',
              onContinue: () {
                Navigator.of(context).pop();
                if (widget.letterId < 33) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          LetterDetailScreen(letterId: widget.letterId + 1),
                    ),
                  );
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final progress = state.progressOf(widget.letterId);
    final palette = _paletteFor(widget.letterId);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AppBottomNav(
        current: 'lessons',
        onTap: _navTo,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              PageHeader(
                title: 'درس الفبا',
                subtitle: 'حرف ${model.char} را یاد بگیر و تمرین کن!',
                stars: state.totalStars,
                headerColor: palette,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── حرف بزرگ + حباب گفتار ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Center(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.elasticOut,
                                builder: (context, v, child) => Transform.scale(
                                  scale: v,
                                  child: child,
                                ),
                                child: Text(
                                  model.char,
                                  style: TextStyle(
                                    fontSize: 110,
                                    fontWeight: FontWeight.w900,
                                    color: palette,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _SpeechBubble(text: 'حرف ${model.char}', color: palette),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ── دکمه تدریس خودکار ──
                      BouncyButton(
                        onTap: _autoTeach,
                        enabled: !_teaching,
                        color: AppColors.primary,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_stories_rounded,
                                  color: Colors.white, size: 28),
                              const SizedBox(width: 10),
                              Text(
                                _teaching ? 'دارم یاد می‌دهم...' : 'تدریس خودکار',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── کارت تصویر و کلمه ──
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: palette.withValues(alpha: 0.4),
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignInside),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.asset(
                                model.imagePath,
                                height: 190,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => SizedBox(
                                  height: 190,
                                  child: Center(
                                    child: Text(model.emoji,
                                        style:
                                            const TextStyle(fontSize: 110)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            BouncyButton(
                              onTap: _playWord,
                              color: palette,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.volume_up_rounded,
                                        color: Colors.white, size: 26),
                                    const SizedBox(width: 8),
                                    Text(
                                      model.word,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // صدای حرف: بَ بِ بُ
                            BouncyButton(
                              onTap: _playSound,
                              color: palette.withValues(alpha: 0.15),
                              borderRadius: 16,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                child: Text(
                                  model.sound,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: palette,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // خوانش هجایی
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var i = 0; i < model.syllables.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: BouncyButton(
                                      onTap: () => AudioService.instance
                                          .speakAsync(model.syllableAudio(i)),
                                      color: AppColors.mintLight,
                                      borderRadius: 14,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        child: Text(
                                          model.syllables[i],
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.mintDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (model.funFact != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                '💡 ${model.funFact!}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── تمرین نوشتن ──
                      WritingTracer(
                        letter: model.char,
                        onComplete: _onWritingDone,
                      ),
                      if (progress.writingDone)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: AppColors.mint, size: 22),
                              SizedBox(width: 6),
                              Text(
                                'تمرین نوشتن انجام شد',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.mintDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 18),

                      // ── بازی‌ها ──
                      _GamesGrid(
                        letterId: widget.letterId,
                        gamesDone: progress.gamesDone,
                        onGameDone: _onGameDone,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ConfettiOverlay(play: _celebrate),
        ],
      ),
    );
  }

  void _navTo(String key) {
    Navigator.of(context).popUntil((r) => r.isFirst);
    if (key == 'lessons') {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const LettersListScreen()));
    } else if (key == 'progress') {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const ParentsDashboardScreen()));
    } else if (key == 'more') {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()));
    }
    // home → همان صفحه اول کافی است
  }

  Color _paletteFor(int id) {
    final colors = [AppColors.primary, AppColors.coral, AppColors.mint];
    return colors[id % 3];
  }
}

/// حباب گفتار کنار حرف
class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.coral,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(4),
          topLeft: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        boxShadow: AppColors.softShadow(AppColors.coral),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// شبکه ۴ بازی
class _GamesGrid extends StatelessWidget {
  const _GamesGrid({
    required this.letterId,
    required this.gamesDone,
    required this.onGameDone,
  });

  final int letterId;
  final List<String> gamesDone;
  final void Function(String) onGameDone;

  @override
  Widget build(BuildContext context) {
    final games = [
      (
        key: 'find',
        title: 'بازی پیدا کن',
        emoji: '🐢',
        color: AppColors.mint,
        builder: (int id) => FindLetterGame(letterId: id),
      ),
      (
        key: 'match',
        title: 'بازی جور کن',
        emoji: '🦁',
        color: AppColors.coral,
        builder: (int id) => MatchLetterGame(letterId: id),
      ),
      (
        key: 'memory',
        title: 'بازی تکرار کن',
        emoji: '🐰',
        color: AppColors.primary,
        builder: (int id) => MemoryLetterGame(letterId: id),
      ),
      (
        key: 'drag',
        title: 'بازی بکش و بگذار',
        emoji: '🐙',
        color: AppColors.gold,
        builder: (int id) => DragDropLetterGame(letterId: id),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text(
            'بازی‌های این حرف',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            for (final g in games)
              _GameTile(
                title: g.title,
                emoji: g.emoji,
                color: g.color,
                done: gamesDone.contains(g.key),
                onTap: () async {
                  AudioService.instance.go();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => g.builder(letterId)),
                  );
                  onGameDone(g.key);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({
    required this.title,
    required this.emoji,
    required this.color,
    required this.done,
    required this.onTap,
  });

  final String title;
  final String emoji;
  final Color color;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BouncyButton(
      onTap: onTap,
      color: color.withValues(alpha: 0.14),
      borderRadius: 20,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          if (done)
            const Positioned(
              top: 8,
              left: 8,
              child: Icon(Icons.check_circle_rounded,
                  color: AppColors.mint, size: 24),
            ),
        ],
      ),
    );
  }
}
