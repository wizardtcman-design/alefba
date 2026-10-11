import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../data/letters_data.dart';
import '../../services/audio_service.dart';
import '../../state/app_state.dart';
import '../game_scaffold.dart';

/// بازی ۴ «بکش و بگذار»: حرف‌ها را با انگشت روی تصویر درست بگذار
class DragDropLetterGame extends GameScaffold {
  const DragDropLetterGame({super.key, required this.letterId});

  final int letterId;

  @override
  String get title => 'بکش و بگذار';

  @override
  int get totalRounds => 2;

  @override
  GameScaffoldState<DragDropLetterGame> createState() =>
      _DragDropLetterGameState();
}

class _DragDropLetterGameState extends GameScaffoldState<DragDropLetterGame> {
  late List<LetterModel> targets;
  late List<LetterModel> letters;
  final Set<int> doneIds = {};


  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    final target = LettersData.byId(widget.letterId);
    targets = pickLetters(3, include: target);
    letters = List.of(targets)..shuffle(rnd);
    doneIds.clear();
  }

  void _onDrop(LetterModel target, LetterModel dropped) {
    context
        .read<AppState>()
        .recordAnswer(correct: dropped.id == target.id);
    if (dropped.id == target.id) {
      setState(() => doneIds.add(target.id));
      AudioService.instance.praise();
      if (doneIds.length == targets.length) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          if (round >= widget.totalRounds) {
            setState(() => finished = true);
          } else {
            setState(() => round++);
            _newRound();
          }
        });
      }
    } else {
      AudioService.instance.retry();
    }
  }

  @override
  Widget buildRound(BuildContext context) {
    return Column(
      children: [
        const Text(
          'حرف‌ها را روی تصویر خودشان بگذار!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text),
        ),
        const SizedBox(height: 18),
        // باکس‌های هدف: تصویر + جای خالی حرف
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final t in targets)
              _DropZone(
                model: t,
                done: doneIds.contains(t.id),
                onDrop: (dropped) => _onDrop(t, dropped),
              ),
          ],
        ),
        const Spacer(),
        const Text(
          'حرف‌ها 👇',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textLight),
        ),
        const SizedBox(height: 10),
        // حرف‌های قابل کشیدن
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final l in letters)
              if (!doneIds.contains(l.id))
                Draggable<LetterModel>(
                  data: l,
                  feedback: _LetterChip(model: l, dragging: true),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _LetterChip(model: l),
                  ),
                  child: _LetterChip(model: l),
                ),
          ],
        ),
        const SizedBox(height: 26),
      ],
    );
  }
}

/// باکس هدف: تصویر + جای حرف
class _DropZone extends StatelessWidget {
  const _DropZone({
    required this.model,
    required this.done,
    required this.onDrop,
  });

  final LetterModel model;
  final bool done;
  final void Function(LetterModel) onDrop;

  @override
  Widget build(BuildContext context) {
    return DragTarget<LetterModel>(
      builder: (context, candidate, rejected) {
        final hovering = candidate.isNotEmpty;
        return Container(
          width: 108,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: done
                ? AppColors.mintLight
                : hovering
                    ? AppColors.primaryLight
                    : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: done
                  ? AppColors.mint
                  : hovering
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.35),
              width: hovering || done ? 3.5 : 2,
            ),
          ),
          child: Column(
            children: [
              // جای حرف (خالی یا پرشده)
              Container(
                height: 56,
                width: 56,
                alignment: Alignment.center,
                child: done
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.mint, size: 44)
                    : DashedBox(width: 48, height: 48),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 64,
                child: Image.asset(
                  model.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      Text(model.emoji, style: const TextStyle(fontSize: 44)),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                model.word,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight),
              ),
            ],
          ),
        );
      },
      onAcceptWithDetails: (details) => onDrop(details.data),
    );
  }
}

/// مربع نقطه‌چین برای جای خالی حرف
class DashedBox extends StatelessWidget {
  const DashedBox({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _DashedBoxPainter(),
    );
  }
}

class _DashedBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    const dash = 6.0;
    const gap = 5.0;
    final path = Path()..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(12)));

    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        canvas.drawPath(metric.extractPath(dist, dist + dash), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// چیپ حرف قابل کشیدن
class _LetterChip extends StatelessWidget {
  const _LetterChip({required this.model, this.dragging = false});

  final LetterModel model;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: dragging
            ? AppColors.softShadow(AppColors.primaryDark)
            : AppColors.softShadow(AppColors.primary),
      ),
      child: Center(
        child: Text(
          model.char,
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
