import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';

/// دکمه فنری با افکت لمس — همه دکمه‌های اپ از این استفاده می‌کنند
/// حداقل ۵۶ پیکسل برای دست‌های کوچک
class BouncyButton extends StatefulWidget {
  const BouncyButton({
    super.key,
    required this.onTap,
    required this.child,
    this.color,
    this.borderRadius = 22,
    this.haptic = true,
    this.enabled = true,
  });

  final VoidCallback onTap;
  final Widget child;
  final Color? color;
  final double borderRadius;
  final bool haptic;
  final bool enabled;

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
    _scale = Tween(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOut),
    );
  }

  void _down(TapDownDetails d) {
    if (!widget.enabled) return;
    _c.forward();
  }

  void _up(TapUpDetails d) async {
    if (!widget.enabled) return;
    _c.reverse();
    if (widget.haptic) HapticFeedback.lightImpact();
    widget.onTap();
  }

  void _cancel() => _c.reverse();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: _cancel,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.color == null
                ? AppColors.cardShadow()
                : AppColors.softShadow(widget.color!),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
