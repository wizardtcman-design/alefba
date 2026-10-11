import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_colors.dart';
import '../../services/audio_service.dart';
import '../../core/utils.dart';
import '../../widgets/bouncy_button.dart';

/// تمرین نوشتن حرف روی خطوط نقطه‌چین:
/// حرف به شبکه‌ای از نقطه تبدیل می‌شود و کودک با انگشت روی نقطه‌ها می‌کشد.
/// پوشش ≥ ۶۵٪ نقطه‌ها = قبولی و ستاره.
class WritingTracer extends StatefulWidget {
  const WritingTracer({
    super.key,
    required this.letter,
    required this.onComplete,
    this.rows = 3,
  });

  final String letter;
  final VoidCallback onComplete;
  final int rows;

  @override
  State<WritingTracer> createState() => _WritingTracerState();
}

class _WritingTracerState extends State<WritingTracer> {
  static const int _gridW = 18;
  static const int _gridH = 22;

  List<bool>? _mask;
  final Set<int> _traced = {};
  bool _done = false;

  // برای خط‌کشی بین دو نقطه متوالی انگشت
  Offset? _lastPoint;

  @override
  void initState() {
    super.initState();
    _buildMask();
  }

  @override
  void didUpdateWidget(WritingTracer old) {
    super.didUpdateWidget(old);
    if (old.letter != widget.letter) {
      _traced.clear();
      _done = false;
      _mask = null;
      _buildMask();
    }
  }

  /// ساخت ماسک نقطه‌ای حرف با رستر کردن گلیف در حافظه
  Future<void> _buildMask() async {
    final tp = TextPainter(
      text: TextSpan(
        text: widget.letter,
        style: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 240,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();

    final w = tp.width.ceil().clamp(80, 600);
    final h = tp.height.ceil().clamp(80, 600);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    tp.paint(canvas, Offset.zero);
    final picture = recorder.endRecording();
    final image = await picture.toImage(w, h);
    final bytes =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    picture.dispose();
    image.dispose();

    if (bytes == null || !mounted) return;
    final pixels = bytes.buffer.asUint32List();

    final cellW = w / _gridW;
    final cellH = h / _gridH;
    final mask = List<bool>.filled(_gridW * _gridH, false);

    for (var gy = 0; gy < _gridH; gy++) {
      for (var gx = 0; gx < _gridW; gx++) {
        var opaque = 0;
        var total = 0;
        final x0 = (gx * cellW).floor();
        final y0 = (gy * cellH).floor();
        final x1 = ((gx + 1) * cellW).floor();
        final y1 = ((gy + 1) * cellH).floor();
        for (var y = y0; y < y1; y++) {
          for (var x = x0; x < x1; x++) {
            final a = (pixels[y * w + x] >> 24) & 0xFF;
            total++;
            if (a > 64) opaque++;
          }
        }
        if (total > 0 && opaque / total > 0.18) {
          mask[gy * _gridW + gx] = true;
        }
      }
    }

    setState(() => _mask = mask);
  }

  void _onPan(DragUpdateDetails d, Size boxSize) {
    if (_mask == null || _done) return;
    final cw = boxSize.width / _gridW;
    final ch = boxSize.height / _gridH;

    void mark(Offset p) {
      final gx = (p.dx / cw).floor().clamp(0, _gridW - 1);
      final gy = (p.dy / ch).floor().clamp(0, _gridH - 1);
      _traced.add(gy * _gridW + gx);
    }

    mark(d.localPosition);
    // پر کردن فاصله تا نقطه قبلی (حالت کشیدن سریع)
    if (_lastPoint != null) {
      final dist = (d.localPosition - _lastPoint!).distance;
      final steps = (dist / (cw * 0.5)).ceil().clamp(1, 24);
      for (var i = 1; i < steps; i++) {
        mark(Offset.lerp(_lastPoint!, d.localPosition, i / steps)!);
      }
    }
    _lastPoint = d.localPosition;
    setState(() {});
    _checkDone();
  }

  void _checkDone() {
    if (_done || _mask == null) return;
    var need = 0;
    var got = 0;
    for (var i = 0; i < _mask!.length; i++) {
      if (_mask![i]) {
        need++;
        if (_traced.contains(i)) got++;
      }
    }
    if (need > 0 && got / need >= 0.65) {
      _done = true;
      HapticFeedback.mediumImpact();
      AudioService.instance.speakAsync(Sfx.writeDone);
      widget.onComplete();
      setState(() {});
    }
  }

  void _reset() {
    _traced.clear();
    _done = false;
    _lastPoint = null;
    setState(() {});
  }

  /// نمایش خودکار: نقطه‌ها به ترتیب روشن می‌شوند (نشان بده)
  Future<void> _demo() async {
    if (_mask == null) return;
    _reset();
    final order = <int>[];
    for (var i = 0; i < _mask!.length; i++) {
      if (_mask![i]) order.add(i);
    }
    // مرتب‌سازی: بالا به پایین، راست به چپ (مسیر طبیعی نوشتن فارسی)
    order.sort((a, b) {
      final ay = a ~/ _gridW, ax = a % _gridW;
      final by = b ~/ _gridW, bx = b % _gridW;
      final bandA = ay ~/ 4, bandB = by ~/ 4;
      if (bandA != bandB) return bandA.compareTo(bandB);
      return bx.compareTo(ax);
    });
    for (final i in order) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 22));
      setState(() => _traced.add(i));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.mintLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.mint.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('✏️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'تمرین بنویس',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.mintDark,
                  ),
                ),
              ),
              BouncyButton(
                onTap: _demo,
                color: AppColors.mint.withValues(alpha: 0.2),
                borderRadius: 14,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Text('نشان بده',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mintDark)),
                ),
              ),
              const SizedBox(width: 8),
              BouncyButton(
                onTap: _reset,
                color: AppColors.coral.withValues(alpha: 0.15),
                borderRadius: 14,
                child: const Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(Icons.refresh_rounded,
                      size: 22, color: AppColors.coralDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // صفحه نوشتن
          LayoutBuilder(builder: (context, cons) {
            final size = Size(
                cons.maxWidth, math.max(200.0, cons.maxWidth * 0.78));
            return GestureDetector(
              onPanUpdate: (d) => _onPan(d, size),
              onPanStart: (_) => _lastPoint = null,
              child: Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CustomPaint(
                  painter: _TracerPainter(
                    mask: _mask,
                    traced: _traced,
                    done: _done,
                    rows: widget.rows,
                  ),
                  size: size,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TracerPainter extends CustomPainter {
  _TracerPainter({
    required this.mask,
    required this.traced,
    required this.done,
    required this.rows,
  });

  final List<bool>? mask;
  final Set<int> traced;
  final bool done;
  final int rows;

  @override
  void paint(Canvas canvas, Size size) {
    // خطوط راهنمای افقی (خط بالایی، میانی خط‌چین، پایینی)
    final solid = Paint()
      ..color = AppColors.lockGrey.withValues(alpha: 0.45)
      ..strokeWidth = 1.5;
    final dashed = Paint()
      ..color = AppColors.lockGrey.withValues(alpha: 0.55)
      ..strokeWidth = 1.5;

    canvas.drawLine(Offset(8, 8), Offset(size.width - 8, 8), solid);
    canvas.drawLine(
        Offset(8, size.height / 2), Offset(size.width - 8, size.height / 2), dashed);
    canvas.drawLine(
        Offset(8, size.height - 8), Offset(size.width - 8, size.height - 8), solid);

    // فلش‌های جهت نوشتن (راست به چپ)
    final arrow = Paint()
      ..color = AppColors.lockGrey.withValues(alpha: 0.4)
      ..strokeWidth = 2;
    final ay = size.height * 0.28;
    canvas.drawLine(Offset(size.width * 0.62, ay),
        Offset(size.width * 0.38, ay), arrow);
    final head = Path()
      ..moveTo(size.width * 0.38, ay)
      ..lineTo(size.width * 0.43, ay - 5)
      ..lineTo(size.width * 0.43, ay + 5)
      ..close();
    canvas.drawPath(head, arrow..style = PaintingStyle.fill);

    if (mask == null) {
      // در حال آماده‌سازی
      return;
    }

    final cw = size.width / 18;
    final ch = size.height / 22;

    for (var i = 0; i < mask!.length; i++) {
      if (!mask![i]) continue;
      final gx = i % 18;
      final gy = i ~/ 18;
      final center = Offset(gx * cw + cw / 2, gy * ch + ch / 2);
      final isTraced = traced.contains(i);
      final paint = Paint()
        ..color = isTraced
            ? (done ? AppColors.mint : AppColors.primary)
            : AppColors.lockGrey.withValues(alpha: 0.5);
      canvas.drawCircle(center, isTraced ? cw * 0.42 : cw * 0.28, paint);
    }
  }

  @override
  bool shouldRepaint(_TracerPainter old) =>
      old.done != done || old.traced.length != traced.length || old.mask != mask;
}
