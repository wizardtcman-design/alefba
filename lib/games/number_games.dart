import 'dart:math';

import 'package:flutter/material.dart';

import '../data/numbers_data.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../utils/persian.dart';
import '../widgets/common.dart';

/// بازی «بشمار و انتخاب کن»:
/// کودک تعداد شکل‌ها را می‌شمارد و عدد درست را روی سبد می‌گذارد.
class CountingDragGame extends StatefulWidget {
  const CountingDragGame({
    super.key,
    required this.value,
    required this.onFinish,
  });

  final int value;
  final ValueChanged<int> onFinish;

  @override
  State<CountingDragGame> createState() => _CountingDragGameState();
}

class _CountingDragGameState extends State<CountingDragGame> {
  late final String _correct;
  late final List<String> _options;
  int _mistakes = 0;
  bool _wrong = false;
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    final Random rng = Random();
    final Set<int> decoys = <int>{};
    while (decoys.length < 2) {
      final int delta = rng.nextInt(6) - 3; // ۳- تا ۳+ بدون صفر
      if (delta == 0) continue;
      final int v = widget.value + delta;
      if (v < 0 || v > 100) continue;
      decoys.add(v);
    }
    _correct = toPersianDigits(widget.value);
    _options = <String>[_correct, ...decoys.map(toPersianDigits)]
      ..shuffle(rng);
  }

  /// ۰ اشتباه → ۳ ستاره | حداکثر ۲ اشتباه → ۲ ستاره | بیشتر → ۱ ستاره
  int get _stars => _mistakes == 0 ? 3 : (_mistakes <= 2 ? 2 : 1);

  Future<void> _onDrop(String data) async {
    if (_solved) return;
    if (data == _correct) {
      setState(() => _solved = true);
      AudioService.instance.playNumberName(widget.value);
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      await endGame(
        context,
        onFinish: widget.onFinish,
        stars: _stars,
        message: '${NumbersData.nameOf(widget.value)} را خوب شمردی!',
      );
      return;
    }
    // جواب نادرست: سبد گوشه‌ای قرمز می‌شود
    setState(() {
      _mistakes++;
      _wrong = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _wrong = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بشمار و انتخاب کن')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'چند تا است؟',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    'اشتباه‌ها: ${toPersianDigits(_mistakes)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(child: _itemsPreview()),
              const SizedBox(height: 24),
              _basket(),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  for (int i = 0; i < _options.length; i++) _draggableCard(i),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// نمایش شکل‌ها: ایموجی تا ۲۰، نقطه‌های ده‌تایی برای بزرگ‌ترها
  Widget _itemsPreview() {
    if (widget.value == 0) {
      return const Text(
        'هیچ‌کدام! صفر یعنی هیچ 🌟',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
        ),
      );
    }
    if (widget.value <= 20) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: List<Widget>.generate(
          widget.value,
          (int i) => Text(
            NumbersData.emojiFor(widget.value),
            style: const TextStyle(fontSize: 32),
          ),
        ),
      );
    }
    return TenFrameDots(
      count: widget.value,
      dotSize: 13,
      color: AppColors.coral,
    );
  }

  /// سبد هدف
  Widget _basket() {
    return DragTarget<String>(
      onWillAccept: (String? data) => !_solved,
      onAccept: (String data) => _onDrop(data),
      builder:
          (BuildContext context, List<String?> candidates, List<dynamic> _) {
        final bool hovering = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: _solved ? AppColors.mint.withOpacity(0.15) : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              width: 3,
              color: _wrong
                  ? AppColors.coral
                  : _solved
                      ? AppColors.mint
                      : hovering
                          ? AppColors.purple
                          : AppColors.disabled,
            ),
          ),
          child: Center(
            child: _solved
                ? Text(
                    toPersianDigits(widget.value),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.mint,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('🧺', style: TextStyle(fontSize: 44)),
                      const SizedBox(height: 2),
                      Text(
                        '؟',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: _wrong ? AppColors.coral : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _draggableCard(int index) {
    final String label = _options[index];
    final Color color = AppColors.playful[index % AppColors.playful.length];
    return Draggable<String>(
      data: label,
      feedback: Material(
        color: Colors.transparent,
        child: _optionCard(label, color),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _optionCard(label, color),
      ),
      child: _optionCard(label, color, withShadow: true),
    );
  }

  Widget _optionCard(String label, Color color, {bool withShadow = false}) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: withShadow
            ? const <BoxShadow>[
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// مدل یک کارت بازی جفت‌عدد: مقدار + شماره جفت + نوع کارت
class _MatchCard {
  const _MatchCard(this.pairValue, this.pairIndex, this.isNumeral);

  final int pairValue;
  final int pairIndex;
  final bool isNumeral;
}

/// بازی «جفت عدد»: هر عدد را با نقطه‌هایش جفت کن (سبک حافظه)
class NumberMatchGame extends StatefulWidget {
  const NumberMatchGame({
    super.key,
    required this.value,
    required this.onFinish,
  });

  final int value;
  final ValueChanged<int> onFinish;

  @override
  State<NumberMatchGame> createState() => _NumberMatchGameState();
}

class _NumberMatchGameState extends State<NumberMatchGame> {
  late final List<_MatchCard> _cards;
  late final List<bool> _matched;
  final Set<int> _revealed = <int>{};
  int? _firstPick;
  bool _busy = false;
  int _mistakes = 0;

  @override
  void initState() {
    super.initState();
    final Random rng = Random();
    final Set<int> others = <int>{};
    while (others.length < 2) {
      final int v = rng.nextInt(101); // ۰ تا ۱۰۰
      if (v != widget.value) others.add(v);
    }
    final List<int> pairValues = <int>[widget.value, ...others]..shuffle(rng);

    final List<_MatchCard> cards = <_MatchCard>[];
    for (int i = 0; i < pairValues.length; i++) {
      cards.add(_MatchCard(pairValues[i], i, true)); // کارت عدد
      cards.add(_MatchCard(pairValues[i], i, false)); // کارت نقطه‌ها
    }
    cards.shuffle(rng);
    _cards = cards;
    _matched = List<bool>.filled(cards.length, false);
  }

  int get _stars => _mistakes == 0 ? 3 : (_mistakes <= 2 ? 2 : 1);

  Future<void> _onCardTap(int index) async {
    if (_busy || _matched[index] || _revealed.contains(index)) return;

    // کارت اول
    if (_firstPick == null) {
      setState(() {
        _revealed.add(index);
        _firstPick = index;
      });
      return;
    }

    final int first = _firstPick!;
    final _MatchCard a = _cards[first];
    final _MatchCard b = _cards[index];

    if (a.pairIndex == b.pairIndex) {
      // جفت درست: باز می‌ماند
      setState(() {
        _matched[first] = true;
        _matched[index] = true;
        _revealed.remove(first);
        _revealed.remove(index);
        _firstPick = null;
      });
      AudioService.instance.playNumberName(a.pairValue);
      if (!_matched.contains(false)) {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;
        await endGame(
          context,
          onFinish: widget.onFinish,
          stars: _stars,
          message: 'همه جفت‌ها را پیدا کردی!',
        );
      }
      return;
    }

    // جفت نادرست: ۸۰۰ میلی‌ثانیه بعد برگردانده می‌شود
    setState(() {
      _revealed.add(index);
      _mistakes++;
      _busy = true;
      _firstPick = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _revealed.remove(index);
      _revealed.remove(first);
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جفت عدد')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'عددها را با هم جور کن!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    'اشتباه‌ها: ${toPersianDigits(_mistakes)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _cards.length,
                itemBuilder: (BuildContext context, int index) =>
                    _buildCard(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    final _MatchCard card = _cards[index];
    final Color color = AppColors.playful[card.pairIndex % 3];
    final bool faceUp = _matched[index] || _revealed.contains(index);

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color:
              faceUp ? (card.isNumeral ? color : Colors.white) : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: faceUp ? color : AppColors.disabled, width: 2),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: !faceUp
                ? const Text(
                    '؟',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textLight,
                    ),
                  )
                : card.isNumeral
                    ? Text(
                        toPersianDigits(card.pairValue),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: TenFrameDots(
                          count: card.pairValue,
                          dotSize: 8,
                          color: color,
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
