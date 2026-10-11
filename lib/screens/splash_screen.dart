import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/utils.dart';
import '../services/audio_service.dart';
import 'home_screen.dart';

/// صفحه اسپلش: لوگو + ماسکوت روباه + انیمیشن ورود، سپس پرش به خانه
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _foxScale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _logoScale = Tween(begin: 0.3, end: 1.0).animate(curved);
    _foxScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 1.0, curve: Curves.elasticOut),
      ),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // صدای خوش‌آمد (آفلاین)
    Future.delayed(const Duration(milliseconds: 500), () {
      AudioService.instance.speakAsync(Sfx.hello);
    });

    Timer(const Duration(milliseconds: 2600), _goHome);
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(anim), child: child),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // لوگو حرف «آ» داخل دایره بنفش
            ScaleTransition(
              scale: _logoScale,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: AppColors.softShadow(AppColors.primary),
                ),
                child: const Center(
                  child: Text('آ', style: TextStyle(
                    fontSize: 64, fontWeight: FontWeight.w900,
                    color: Colors.white,
                  )),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fade,
              child: const Text(
                'آموزش کلاس اول',
                style: TextStyle(
                  fontSize: 40, fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _fade,
              child: const Text(
                'هر روز یادگیری، هر روز لبخند',
                style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
            ),
            const SizedBox(height: 36),
            // ماسکوت روباه (تصویر یا ایموجی جایگزین)
            ScaleTransition(
              scale: _foxScale,
              child: Image.asset(
                'assets/images/mascot/fox.png',
                width: 170, height: 170, fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Text('🦊',
                    style: TextStyle(fontSize: 110)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
