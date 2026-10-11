import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'bouncy_button.dart';

/// بارش ستاره و قلب هنگام جشن موفقیت — بدون پکیج خارجی
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({
    super.key,
    required this.play,
    this.duration = const Duration(milliseconds: 1800),
  });

  /// هر بار true شود، جشن پخش می‌شود
  final bool play;
  final Duration duration;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  final List<_Particle> _particles = [];
  final math.Random _rnd = math.Random();

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    // اگر از ابتدا play=true بود، همان موقع جشن بگیر
    if (widget.play) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _celebrate());
    }
  }

  @override
  void didUpdateWidget(ConfettiOverlay old) {
    super.didUpdateWidget(old);
    if (widget.play && !old.play) _celebrate();
  }

  void _celebrate() {
    _particles.clear();
    final symbols = ['⭐', '🌟', '💜', '❤️', '✨', '🎉'];
    for (var i = 0; i < 26; i++) {
      _particles.add(_Particle(
        x: _rnd.nextDouble(),
        symbol: symbols[_rnd.nextInt(symbols.length)],
        size: 16 + _rnd.nextDouble() * 18,
        delay: _rnd.nextDouble() * 0.3,
        swing: 20 + _rnd.nextDouble() * 40,
      ));
    }
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          if (!_c.isAnimating) return const SizedBox.shrink();
          return CustomPaint(
            painter: _ConfettiPainter(
              progress: _c.value,
              particles: _particles,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.symbol,
    required this.size,
    required this.delay,
    required this.swing,
  });

  final double x;
  final String symbol;
  final double size;
  final double delay;
  final double swing;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.particles});

  final double progress;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final y = -40 + t * (size.height + 80);
      final x = p.x * size.width +
          math.sin(t * math.pi * 2) * p.swing;
      final tp = TextPainter(
        text: TextSpan(text: p.symbol, style: TextStyle(fontSize: p.size)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

/// کارت جشن پایان مرحله با ستاره و دکمه ادامه
class CelebrationCard extends StatelessWidget {
  const CelebrationCard({
    super.key,
    required this.title,
    this.stars = 3,
    required this.onContinue,
    this.continueLabel = 'ادامه',
  });

  final String title;
  final int stars;
  final VoidCallback onContinue;
  final String continueLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 40),
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppColors.softShadow(AppColors.primary),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final active = i < stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.star_rounded,
                        size: 52,
                        color: active ? AppColors.gold : AppColors.lockGrey,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 22),
                BouncyButton(
                  onTap: onContinue,
                  color: AppColors.mint,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    child: Text(continueLabel,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            top: -6,
            child: Text('🦊', style: TextStyle(fontSize: 84)),
          ),
        ],
      ),
    );
  }
}
