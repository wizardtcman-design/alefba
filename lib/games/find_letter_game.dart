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

/// بازی «حرف را پیدا کن»: از میان ۴ حرف، حرف درست را پیدا کن (۳ دور)
class FindLetterGame extends StatefulWidget {
  const FindLetterGame({
    super.key,
    required this.letter,
    required this.onFinish,
  });

  final LetterItem letter;
  final ValueChanged<int> onFinish;

  @override
  State<FindLetterGame> createState() => _FindLetterGameState();
}

class _FindLetterGameState extends State<FindLetterGame> {
  static const int _totalRounds = 3;
  static const int _optionCount = 4;

  final math.Random _random = math.Random();

  int _round = 0;
  int _mistakes = 0;
  bool _busy = false;
  bool _finished = false;

  List<LetterItem> _options = <LetterItem>[];
  int _correctIndex = 0;
  int? _correctTapped;
  int? _wrongTapped;

  @override
  void initState() {
    super.initState();
    _startRound();
    unawaited(AudioService.instance.playLetter(widget.letter));
  }

  /// ساخت ۴ گزینه: حرف درست + ۳ حرف مزاحم، بر زده‌شده
  void _startRound() {
    final List<LetterItem> pool = AlphabetData.letters
        .where((LetterItem l) => l.char != widget.letter.char)
        .toList()
      ..shuffle(_random);
    _options = <LetterItem>[
      widget.letter,
      ...pool.take(_optionCount - 1),
    ]..shuffle(_random);
    _correctIndex =
        _options.indexWhere((LetterItem l) => l.id == widget.letter.id);
    _correctTapped = null;
    _wrongTapped = null;
    _busy = false;
  }

  void _onTap(int index) {
    if (_busy || _finished) return;
    if (_correctTapped != null) return;

    if (index == _correctIndex) {
      setState(() {
        _correctTapped = index;
        _busy = true;
      });
      unawaited(_advanceAfterDelay());
    } else {
      // تا پایان فلش قرمز، کلیک تکراری روی گزینه‌های نادرست شمرده نمی‌شود
      if (_wrongTapped != null) return;
      setState(() {
        _wrongTapped = index;
        _mistakes++;
      });
      unawaited(_clearWrongFlash());
    }
  }

  Future<void> _clearWrongFlash() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() => _wrongTapped = null);
  }

  Future<void> _advanceAfterDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    if (_round + 1 >= _totalRounds) {
      await _finish();
      return;
    }
    setState(() {
      _round++;
      _startRound();
    });
    unawaited(AudioService.instance.playLetter(widget.letter));
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    await endGame(
      context,
      onFinish: widget.onFinish,
      stars: _starsFor(_mistakes),
      message: 'همه حرف‌ها را پیدا کردی!',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'حرف «${widget.letter.letterName}» را پیدا کن!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _audioButton(),
            const SizedBox(height: 6),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    children: List<Widget>.generate(
                      _optionCount,
                      (int i) => _optionCard(i),
                    ),
                  ),
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
          Expanded(
            child: Text(
              'سؤال ${toPersianDigits(_round + 1)} از ${toPersianDigits(_totalRounds)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.purple,
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

  /// دکمه گرد پخش صدا (۶۴ پیکسل، رنگ نعنایی)
  Widget _audioButton() {
    return Center(
      child: Material(
        color: AppColors.mint,
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: AppColors.shadow,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () =>
              unawaited(AudioService.instance.playLetter(widget.letter)),
          child: const SizedBox(
            width: 64,
            height: 64,
            child: Center(
              child: Icon(
                Icons.volume_up_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionCard(int index) {
    final LetterItem option = _options[index];
    final bool isCorrect = _correctTapped == index;
    final bool isWrong = _wrongTapped == index;
    final Color color = isCorrect
        ? AppColors.mint
        : isWrong
            ? AppColors.coral
            : AppColors.playful[index % AppColors.playful.length];

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(40),
      elevation: 2,
      shadowColor: AppColors.shadow,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () => _onTap(index),
        child: SizedBox.expand(
          child: Stack(
            children: <Widget>[
              Center(
                child: Text(
                  option.char,
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isCorrect)
                const Align(
                  alignment: Alignment(-0.5, -0.5),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
