import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/alphabet_data.dart';
import '../models/models.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../utils/persian.dart';
import '../widgets/common.dart';

/// قاعده ستاره: ۰ اشتباه → ۳ ستاره، حداکثر ۲ اشتباه → ۲ ستاره، بیشتر → ۱ ستاره
int _starsFor(int mistakes) {
  if (mistakes == 0) return 3;
  if (mistakes <= 2) return 2;
  return 1;
}

/// یک کارت حافظه
class _MemCard {
  _MemCard({required this.pairIndex, required this.isPicture});

  final int pairIndex;
  final bool isPicture;
  bool faceUp = false;
  bool matched = false;
}

/// بازی «جفت‌های حافظه»: جفت کردن حرف با تصویرش (۶ جفت = ۱۲ کارت)
class MemoryGame extends StatefulWidget {
  const MemoryGame({
    super.key,
    required this.letter,
    required this.onFinish,
  });

  final LetterItem letter;
  final ValueChanged<int> onFinish;

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final math.Random _random = math.Random();

  late final List<LetterItem> _pairLetters;
  late final List<_MemCard> _cards;

  final List<int> _open = <int>[];
  int _matchedPairs = 0;
  int _mistakes = 0;
  bool _busy = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    // جفت ۰ حرف هدف؛ جفت‌های ۱ تا ۵ پنج حرف تصادفی دیگر
    final List<LetterItem> others = AlphabetData.letters
        .where((LetterItem l) => l.id != widget.letter.id)
        .toList()
      ..shuffle(_random);
    _pairLetters = <LetterItem>[widget.letter, ...others.take(5)];
    _cards = <_MemCard>[
      for (int i = 0; i < _pairLetters.length; i++) ...<_MemCard>[
        _MemCard(pairIndex: i, isPicture: false),
        _MemCard(pairIndex: i, isPicture: true),
      ],
    ]..shuffle(_random);
  }

  void _onCardTap(int index) {
    if (_busy || _finished) return;
    final _MemCard card = _cards[index];
    if (card.matched || card.faceUp) return;

    setState(() {
      card.faceUp = true;
      _open.add(index);
    });
    if (_open.length < 2) return;

    final int a = _open[0];
    final int b = _open[1];
    final _MemCard first = _cards[a];
    final _MemCard second = _cards[b];

    if (first.pairIndex == second.pairIndex) {
      // جفت درست: باز می‌ماند
      setState(() {
        first.matched = true;
        second.matched = true;
        _matchedPairs++;
        _open.clear();
      });
      unawaited(AudioService.instance
          .playLetter(_pairLetters[first.pairIndex]));
      if (_matchedPairs == _pairLetters.length) {
        unawaited(_finish());
      }
    } else {
      // جفت نادرست: بعد از یک لحظه هر دو برمی‌گردند
      _busy = true;
      unawaited(_flipBack(a, b));
    }
  }

  Future<void> _flipBack(int a, int b) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _cards[a].faceUp = false;
      _cards[b].faceUp = false;
      _open.clear();
      _mistakes++;
      _busy = false;
    });
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    await endGame(
      context,
      onFinish: widget.onFinish,
      stars: _starsFor(_mistakes),
      message: 'همه جفت‌ها را پیدا کردی!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _header(),
            const SizedBox(height: 4),
            const Text(
              'حرف و عکسِ جفتش را پیدا کن!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: List<Widget>.generate(
                  _cards.length,
                  (int i) => _cardCell(i),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              'جفت‌های حافظه',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ),
          Text(
            'اشتباه: ${toPersianDigits(_mistakes)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardCell(int index) {
    final _MemCard card = _cards[index];
    final LetterItem pair = _pairLetters[card.pairIndex];
    final bool revealed = card.faceUp || card.matched;
    final Color color = revealed
        ? AppColors.card
        : AppColors.playful[card.pairIndex % AppColors.playful.length];

    Widget face;
    if (!revealed) {
      face = const Text(
        '؟',
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      );
    } else if (card.isPicture) {
      face = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(pair.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 4),
          Text(
            pair.plainWord,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
            ),
          ),
        ],
      );
    } else {
      face = Text(
        pair.char,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w900,
          color: AppColors.purple,
        ),
      );
    }

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      elevation: revealed ? 0 : 1,
      shadowColor: AppColors.shadow,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _onCardTap(index),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: card.matched ? AppColors.mint : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(child: face),
        ),
      ),
    );
  }
}
