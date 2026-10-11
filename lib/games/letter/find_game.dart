import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../data/letters_data.dart';
import '../../services/audio_service.dart';
import '../../state/app_state.dart';
import '../game_scaffold.dart';

/// بازی ۱ «پیدا کن»: تصویر کلمه نشان داده می‌شود و کودک باید
/// حرفِ آغازین درست را بین ۴ گزینه پیدا کند
class FindLetterGame extends GameScaffold {
  const FindLetterGame({super.key, required this.letterId});

  final int letterId;

  @override
  String get title => 'بازی پیدا کن';

  @override
  int get totalRounds => 5;

  @override
  GameScaffoldState<FindLetterGame> createState() => _FindLetterGameState();
}

class _FindLetterGameState extends GameScaffoldState<FindLetterGame> {
  late LetterModel target;
  List<LetterModel> options = [];

  /// وضعیت پاسخ: null | correct | شناسه حرف اشتباه
  bool locked = false;
  bool answeredCorrect = false;
  int? wrongId;


  @override
  void initState() {
    super.initState();
    target = LettersData.byId(widget.letterId);
    _newQuestion();
  }

  void _newQuestion() {
    options = pickLetters(4, include: target);
    locked = false;
    answeredCorrect = false;
    wrongId = null;
    AudioService.instance.speakAsync(target.wordAudio);
  }

  void _onTap(LetterModel l) {
    if (locked) return;
    context.read<AppState>().recordAnswer(correct: l.id == target.id);
    if (l.id == target.id) {
      locked = true;
      answeredCorrect = true;
      setState(() {});
      AudioService.instance.praise();
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        if (round >= widget.totalRounds) {
          setState(() => finished = true);
        } else {
          setState(() => round++);
          _newQuestion();
        }
      });
    } else {
      setState(() => wrongId = l.id);
      AudioService.instance.retry();
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => wrongId = null);
      });
    }
  }

  @override
  Widget buildRound(BuildContext context) {
    return Column(
      children: [
        Text(
          'حرفِ «${target.word}» کدام است؟',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Image.asset(
            target.imagePath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Center(
                child: Text(target.emoji, style: const TextStyle(fontSize: 110))),
          ),
        ),
        _RepeatPill(onTap: () => AudioService.instance.speakAsync(target.wordAudio)),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 0.85,
                  child: LetterTile(
                    letter: options[i].char,
                    color: i % 2 == 0 ? AppColors.primary : AppColors.coral,
                    state: answeredCorrect && options[i].id == target.id
                        ? 'correct'
                        : (wrongId == options[i].id ? 'wrong' : null),
                    onTap: () => _onTap(options[i]),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _RepeatPill extends StatelessWidget {
  const _RepeatPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.mint,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.softShadow(AppColors.mint),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volume_up_rounded, color: Colors.white, size: 24),
            SizedBox(width: 6),
            Text('بشنو',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
