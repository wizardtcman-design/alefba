import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

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

/// بازی «پازل حرف»: حرف بزرگ به ۴ قطعه تقسیم شده؛ کودک قطعه‌ها را سر جای‌شان می‌گذارد.
class PuzzleGame extends StatefulWidget {
  const PuzzleGame({
    super.key,
    required this.letter,
    required this.onFinish,
  });

  final LetterItem letter;
  final ValueChanged<int> onFinish;

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  final math.Random _random = math.Random();

  late List<int> _trayOrder;
  List<bool> _placed = <bool>[false, false, false, false];
  int _mistakes = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _trayOrder = <int>[0, 1, 2, 3]..shuffle(_random);
  }

  /// قطعه‌های باقی‌مانده در سینی (شاخص‌های بر زده‌شده منهای گذاشته‌شده‌ها)
  List<int> get _trayItems =>
      _trayOrder.where((int i) => !_placed[i]).toList(growable: false);

  void _onDrop(int dragged, int slot) {
    if (_finished || _placed[slot]) return;
    if (dragged != slot) {
      setState(() => _mistakes++);
      return;
    }
    setState(() => _placed[slot] = true);
    if (_placed.every((bool p) => p)) {
      unawaited(_finish());
    }
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    unawaited(AudioService.instance.playLetter(widget.letter));
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    await endGame(
      context,
      onFinish: widget.onFinish,
      stars: _starsFor(_mistakes),
      message: 'پازل حرف ${widget.letter.char} کامل شد!',
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
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double boardSize = math.min(constraints.maxWidth, 280.0);
                  return SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 8),
                        _board(boardSize),
                        const SizedBox(height: 24),
                        _tray(boardSize),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'پازل حرف ${widget.letter.char}',
              style: const TextStyle(
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

  /// تخته پازل: حرف کامل کم‌رنگ پشت ۴ خانه خالی
  Widget _board(double boardSize) {
    return Center(
      child: SizedBox(
        width: boardSize,
        height: boardSize,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Opacity(
                opacity: 0.12,
                child: Center(
                  child: Text(
                    widget.letter.char,
                    style: TextStyle(
                      fontSize: boardSize * 0.85,
                      fontWeight: FontWeight.w900,
                      color: AppColors.purple,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _slot(0, 0, boardSize),
                    _slot(0, 1, boardSize),
                  ],
                ),
                Row(
                  children: <Widget>[
                    _slot(1, 0, boardSize),
                    _slot(1, 1, boardSize),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// خانه رهاکردن قطعه (اندازه نصف تخته)
  Widget _slot(int row, int col, double boardSize) {
    final int index = row * 2 + col;
    final double half = boardSize / 2;
    return DragTarget<int>(
      onAccept: (int data) => _onDrop(data, index),
      builder: (
        BuildContext context,
        List<int?> candidates,
        List<dynamic> rejected,
      ) {
        if (_placed[index]) return _tile(row, col, boardSize);
        final bool hovered = candidates.isNotEmpty;
        return SizedBox(
          width: half,
          height: half,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hovered ? AppColors.mint : AppColors.disabled,
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// قطعه پازل: ربعی از حرف بزرگ با برش ClipRect
  Widget _tile(int row, int col, double boardSize) {
    final double half = boardSize / 2;
    return ClipRect(
      child: SizedBox(
        width: half,
        height: half,
        child: OverflowBox(
          maxWidth: boardSize,
          maxHeight: boardSize,
          alignment: Alignment(-1 + 2 * col, -1 + 2 * row),
          child: SizedBox(
            width: boardSize,
            height: boardSize,
            child: Center(
              child: Text(
                widget.letter.char,
                style: TextStyle(
                  fontSize: boardSize * 0.85,
                  fontWeight: FontWeight.w900,
                  color: AppColors.purple,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tray(double boardSize) {
    final List<int> items = _trayItems;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: List<Widget>.generate(
          items.length,
          (int i) => _trayTile(items[i], boardSize),
        ),
      ),
    );
  }

  Widget _trayTile(int index, double boardSize) {
    final int row = index ~/ 2;
    final int col = index % 2;
    return Draggable<int>(
      data: index,
      feedback: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Transform.scale(scale: 1.1, child: _tile(row, col, boardSize)),
      ),
      childWhenDragging: Opacity(
        opacity: 0.25,
        child: _tile(row, col, boardSize),
      ),
      child: _tile(row, col, boardSize),
    );
  }
}
