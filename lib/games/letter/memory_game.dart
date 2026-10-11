import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../data/letters_data.dart';
import '../../services/audio_service.dart';
import '../../state/app_state.dart';
import '../game_scaffold.dart';

/// بازی ۳ «حافظه»: کارت‌ها را برگردان و جفت حرف و تصویر را پیدا کن
class MemoryLetterGame extends GameScaffold {
  const MemoryLetterGame({super.key, required this.letterId});

  final int letterId;

  @override
  String get title => 'بازی حافظه';

  @override
  int get totalRounds => 1; // یک برد کامل کافی است

  @override
  GameScaffoldState<MemoryLetterGame> createState() =>
      _MemoryLetterGameState();
}

class _MemoryCard {
  _MemoryCard({required this.id, required this.face, required this.isLetter});

  final int id; // شناسه حرف — جفت‌ها id مشترک دارند
  final String face; // حرف یا ایموجی
  final bool isLetter;
  bool revealed = false;
  bool matched = false;
}

class _MemoryLetterGameState extends GameScaffoldState<MemoryLetterGame> {
  late List<_MemoryCard> cards;
  int? firstPick;
  bool busy = false;


  @override
  void initState() {
    super.initState();
    _newBoard();
  }

  void _newBoard() {
    final target = LettersData.byId(widget.letterId);
    final trio = pickLetters(3, include: target);
    cards = [];
    for (final l in trio) {
      cards.add(_MemoryCard(id: l.id, face: l.char, isLetter: true));
      cards.add(_MemoryCard(id: l.id, face: l.emoji, isLetter: false));
    }
    cards.shuffle(rnd);
    firstPick = null;
    busy = false;
  }

  void _onCardTap(int index) {
    if (busy) return;
    final card = cards[index];
    if (card.matched || card.revealed) return;

    AudioService.instance.speakAsync(
      card.isLetter
          ? LettersData.byId(card.id).soundAudio
          : LettersData.byId(card.id).wordAudio,
    );

    setState(() => card.revealed = true);

    if (firstPick == null) {
      firstPick = index;
      return;
    }

    final a = cards[firstPick!];
    final b = card;
    firstPick = null;

    context
        .read<AppState>()
        .recordAnswer(correct: a.id == b.id && a.isLetter != b.isLetter);

    if (a.id == b.id && a.isLetter != b.isLetter) {
      // جفت درست
      setState(() {
        a.matched = true;
        b.matched = true;
      });
      AudioService.instance.star();
      if (cards.every((c) => c.matched)) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) setState(() => finished = true);
        });
      }
    } else {
      // اشتباه — برگرداندن کارت‌ها
      busy = true;
      AudioService.instance.retry();
      Future.delayed(const Duration(milliseconds: 950), () {
        if (!mounted) return;
        setState(() {
          a.revealed = false;
          b.revealed = false;
          busy = false;
        });
      });
    }
  }

  @override
  Widget buildRound(BuildContext context) {
    return Column(
      children: [
        const Text(
          'جفتِ حرف و تصویرش را پیدا کن!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: cards.length,
            itemBuilder: (context, i) => _CardTile(
              card: cards[i],
              onTap: () => _onCardTap(i),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card, required this.onTap});

  final _MemoryCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final show = card.revealed || card.matched;
    final color = card.matched
        ? AppColors.mint
        : (card.isLetter ? AppColors.primary : AppColors.coral);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: anim,
          child: child,
        ),
        child: Container(
          key: ValueKey(show ? 'face${card.id}${card.isLetter}' : 'back'),
          decoration: BoxDecoration(
            color: show ? Colors.white : AppColors.primary.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: show ? color : AppColors.primaryDark,
              width: 2.5,
            ),
            boxShadow: AppColors.cardShadow(),
          ),
          child: Center(
            child: show
                ? card.isLetter
                    ? Text(card.face,
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: color))
                    : Text(card.face, style: const TextStyle(fontSize: 38))
                : const Icon(Icons.favorite_rounded,
                    color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }
}
