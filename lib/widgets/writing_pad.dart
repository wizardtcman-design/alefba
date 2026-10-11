import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// تمرین نوشتن با نقطه‌چین:
/// کاراکتر به صورت نقطه‌ای رندر می‌شود و کودک با انگشت روی آن می‌کشد.
class WritingPad extends StatefulWidget {
  const WritingPad({
    super.key,
    required this.character,
    this.height = 260,
    this.onComplete,
    this.dotColor = const Color(0xFFB9A7D0),
    this.strokeColor = AppColors.mint,
  });

  final String character;
  final double height;
  final VoidCallback? onComplete;
  final Color dotColor;
  final Color strokeColor;

  @override
  State<WritingPad> createState() => _WritingPadState();
}

class _WritingPadState extends State<WritingPad> {
  final List<List<Offset>> _strokes = <List<Offset>>[];
  List<Offset>? _currentStroke;
  List<Offset> _dots = const <Offset>[];
  Size? _dotsSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureDots();
  }

  Future<void> _ensureDots() async {
    final double w = MediaQuery.of(context).size.width - 72;
    final Size size = Size(w.clamp(180.0, 380.0), widget.height - 24);
    if (_dotsSize == size) return;
    final List<Offset> dots = await _computeDots(widget.character, size);
    if (!mounted) return;
    setState(() {
      _dots = dots;
      _dotsSize = size;
    });
  }

  /// رندر کاراکتر روی بوم نامرئی و نمونه‌برداری از پیکسل‌ها برای ساختن نقاط
  static Future<List<Offset>> _computeDots(String character, Size size) async {
    try {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final double fontSize =
          size.height * (character.length > 1 ? 0.45 : 0.8);
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: character,
          style: TextStyle(
            fontSize: fontSize,
            color: const Color(0xFF000000),
            height: 1.0,
          ),
        ),
        textDirection: TextDirection.rtl,
      );
      tp.layout(maxWidth: size.width);
      tp.paint(
        canvas,
        Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
      );
      final ui.Picture picture = recorder.endRecording();

      final int w = size.width.floor().clamp(1, 800);
      final int h = size.height.floor().clamp(1, 800);
      final ui.Image image = await picture.toImage(w, h);
      final ByteData? data =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) return const <Offset>[];

      final Uint8List bytes = data.buffer.asUint8List();
      final List<Offset> dots = <Offset>[];
      const int step = 7;
      for (int y = 0; y < h; y += step) {
        for (int x = 0; x < w; x += step) {
          final int idx = (y * w + x) * 4;
          if (idx + 3 < bytes.length && bytes[idx + 3] > 130) {
            dots.add(Offset(x.toDouble(), y.toDouble()));
          }
        }
      }
      return dots;
    } catch (_) {
      return const <Offset>[];
    }
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = null;
    });
  }

  void _done() {
    if (_strokes.isEmpty) return;
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.disabled, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: GestureDetector(
              onPanStart: (DragStartDetails d) {
                setState(() {
                  _currentStroke = <Offset>[d.localPosition];
                  _strokes.add(_currentStroke!);
                });
              },
              onPanUpdate: (DragUpdateDetails d) {
                setState(() {
                  _currentStroke?.add(d.localPosition);
                });
              },
              onPanEnd: (DragEndDetails d) {
                setState(() {
                  _currentStroke = null;
                });
              },
              child: CustomPaint(
                painter: _DotsPainter(_dots, widget.dotColor),
                foregroundPainter: _StrokesPainter(
                  _strokes,
                  widget.strokeColor,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.cleaning_services_rounded, size: 20),
              label: const Text('پاک کن'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.coral,
                side: const BorderSide(color: AppColors.coral, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                minimumSize: const Size(64, 48),
                textStyle: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _strokes.isEmpty ? null : _done,
              icon: const Icon(Icons.check_circle_rounded, size: 22),
              label: const Text('تمام شد!'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.mint,
                disabledBackgroundColor: AppColors.disabled,
                minimumSize: const Size(64, 48),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter(this.dots, this.color);

  final List<Offset> dots;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (final Offset o in dots) {
      canvas.drawCircle(o, 2.4, p);
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter oldDelegate) =>
      oldDelegate.dots != dots;
}

class _StrokesPainter extends CustomPainter {
  _StrokesPainter(this.strokes, this.color);

  final List<List<Offset>> strokes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 10;
    final Paint dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (final List<Offset> s in strokes) {
      if (s.isEmpty) continue;
      if (s.length == 1) {
        canvas.drawCircle(s.first, 5, dotPaint);
        continue;
      }
      final Path path = Path()
        ..moveTo(s.first.dx, s.first.dy);
      for (final Offset o in s.skip(1)) {
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _StrokesPainter oldDelegate) => true;
}
