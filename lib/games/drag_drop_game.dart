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

/// بازی «بکش و بگذار»: حرف اول واژه را در جای خالی بگذار (۳ دور)
class DragDropGame extends StatefulWidget {
  const DragDropGame({
    super.key,
    required this.letter,
    required this.onFinish,
  });

  final LetterItem letter;
  final ValueChanged<int> onFinish;

  @override
  State<DragDropGame> createState() => _DragDropGameState();
}

class _DragDropGameState extends State<DragDropGame> {
  static const int _totalRounds = 3;

  final math.Random _random = math.Random();

  late final List<LetterItem> _targets;
  late List<String> _chips;

  int _round = 0;
  int _mistakes = 0;
  String? _dropped;
  bool _boxError = false;
  bool _busy = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    // دور ۰ حرف هدف؛ دورهای ۱ و ۲ دو حرف تصادفی دیگر
    final List<LetterItem> others = AlphabetData.letters
        .where((LetterItem l) => l.id != widget.letter.id)
        .toList()
      ..shuffle(_random);
    _targets = <LetterItem>[widget.letter, others[0], others[1]];
    _prepareRound();
    unawaited(AudioService.instance.playLetterWord(_targets[0]));
  }

  LetterItem get _current => _targets[_round];

  /// حرف درست + ۲ حرف مزاحم، بر زده‌شده
  void _prepareRound() {
    final LetterItem target = _current;
    final List<LetterItem> pool = AlphabetData.letters
        .where((LetterItem l) => l.char != target.char)
        .toList()
      ..shuffle(_random);
    _chips = <String>[target.char, pool[0].char, pool[1].char]
      ..shuffle(_random);
    _dropped = null;
    _boxError = false;
    _busy = false;
  }

  void _onDrop(String char) {
    if (_busy || _finished) return;
    if (char != _current.char) {
      setState(() {
        _mistakes++;
        _boxError = true;
      });
      unawaited(_clearErrorFlash());
      return;
    }
    setState(() {
      _dropped = char;
      _busy = true;
    });
    unawaited(AudioService.instance.playLetter(_current));
    unawaited(_nextAfterDelay());
  }

  Future<void> _clearErrorFlash() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _boxError = false);
  }

  Future<void> _nextAfterDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    if (_round + 1 >= _totalRounds) {
      await _finish();
      return;
    }
    setState(() {
      _round++;
      _prepareRound();
    });
    unawaited(AudioService.instance.playLetterWord(_current));
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    await endGame(
      context,
      onFinish: widget.onFinish,
      stars: _starsFor(_mistakes),
      message: 'همه واژه‌ها کامل شد!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final LetterItem target = _current;
    final String rest = target.plainWord.substring(1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: <Widget>[
              _header(),
              const SizedBox(height: 16),
              Text(target.emoji, style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 20),
              // در RTL: خانه خالی سمت راست و بقیه واژه سمت چپ آن
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textDirection: TextDirection.rtl,
                children: <Widget>[
                  _dropBox(),
                  const SizedBox(width: 8),
                  Text(
                    rest,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'حرف «${target.letterName}» کجاست؟',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 28),
              _tray(),
              const SizedBox(height: 16),
            ],
          ),
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
              'بکش و بگذار — سؤال ${toPersianDigits(_round + 1)} از ${toPersianDigits(_totalRounds)}',
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

  /// خانه خالی ۷۲×۷۲ برای رهاکردن حرف درست
  Widget _dropBox() {
    return DragTarget<String>(
      onAccept: (String data) => _onDrop(data),
      builder: (
        BuildContext context,
        List<String?> candidates,
        List<dynamic> rejected,
      ) {
        final bool hovered = candidates.isNotEmpty;
        final Color borderColor =
            hovered && !_boxError ? AppColors.mint : AppColors.coral;
        return Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _boxError
                ? AppColors.coral.withOpacity(0.12)
                : hovered
                    ? AppColors.mint.withOpacity(0.12)
                    : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2.5),
          ),
          child: Center(
            child: _dropped != null
                ? Text(
                    _dropped!,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.mint,
                    ),
                  )
                : Text(
                    '؟',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: _boxError ? AppColors.coral : AppColors.textLight,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _tray() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 14,
        children: List<Widget>.generate(
          _chips.length,
          (int i) => _chip(i),
        ),
      ),
    );
  }

  Widget _chip(int i) {
    final String char = _chips[i];
    final Color color = AppColors.playful[i % AppColors.playful.length];
    return Draggable<String>(
      data: char,
      feedback: Transform.scale(
        scale: 1.1,
        child: _chipFace(char, color, withShadow: true),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _chipFace(char, color)),
      child: _chipFace(char, color),
    );
  }

  Widget _chipFace(String char, Color color, {bool withShadow = false}) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: withShadow
            ? const <BoxShadow>[
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          char,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
