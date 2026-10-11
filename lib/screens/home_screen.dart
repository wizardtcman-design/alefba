import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/utils.dart';
import '../services/audio_service.dart';
import '../state/app_state.dart';
import '../widgets/bouncy_button.dart';
import 'games_menu_screen.dart';
import 'letters_list_screen.dart';
import 'numbers_home_screen.dart';
import 'parents_dashboard_screen.dart';
import 'settings_screen.dart';

/// صفحه خانه — مطابق طراحی: عنوان بزرگ، ماسکوت روباه، دو دکمه اصلی
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final List<AnimationController> _entrance;
  late final List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    // ورود پله‌ای عناصر
    _entrance = List.generate(4, (i) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 550),
      );
      Future.delayed(Duration(milliseconds: 120 * i), () {
        if (mounted) c.forward();
      });
      return c;
    });
    _slides = _entrance
        .map((c) => Tween(begin: const Offset(0, 0.25), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _entrance) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final report = state.report();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    // ── نوار بالا: والدین + تنظیمات ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CircleIcon(
                          icon: Icons.face_retouching_natural_rounded,
                          color: AppColors.primary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ParentsDashboardScreen()),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.mintLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppColors.gold, size: 26),
                              const SizedBox(width: 4),
                              Text(
                                Fa.num(report.totalStars),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.mintDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _CircleIcon(
                          icon: Icons.menu_rounded,
                          color: AppColors.primary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SettingsScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ── عنوان بزرگ ──
                    SlideTransition(
                      position: _slides[0],
                      child: Column(
                        children: const [
                          Text('آموزش',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                height: 1.1,
                              )),
                          Text('کلاس اول',
                              style: TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                                color: AppColors.coral,
                                height: 1.15,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // ── صحنه ماسکوت ──
                    SlideTransition(
                      position: _slides[1],
                      child: SizedBox(
                        height: 230,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              left: 0,
                              bottom: 8,
                              child: const Text('🍎',
                                  style: TextStyle(fontSize: 56)),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 8,
                              child: const Text('🍊',
                                  style: TextStyle(fontSize: 56)),
                            ),
                            Image.asset(
                              'assets/images/mascot/fox.png',
                              height: 210,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Text('🦊',
                                  style: TextStyle(fontSize: 120)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── دکمه حروف الفبا ──
                    SlideTransition(
                      position: _slides[2],
                      child: _MainCard(
                        color: AppColors.primary,
                        title: 'حروف الفبا',
                        badge: 'آپ',
                        trailingIcon: Icons.arrow_back_rounded,
                        progress:
                            report.completedLetters / report.totalLetters,
                        onTap: () {
                          AudioService.instance.go();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LettersListScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── دکمه اعداد ──
                    SlideTransition(
                      position: _slides[3],
                      child: _MainCard(
                        color: AppColors.coral,
                        title: 'اعداد ۰ تا ۱۰۰',
                        badge: '123',
                        isLatin: true,
                        trailingIcon: Icons.arrow_back_rounded,
                        progress: report.maxNumberPlayed / 100,
                        onTap: () {
                          AudioService.instance.go();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NumbersHomeScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── دکمه بازی‌ها ──
                    _MainCard(
                      color: AppColors.mint,
                      title: 'بازی‌های بامزه',
                      badge: '🎮',
                      trailingIcon: Icons.arrow_back_rounded,
                      onTap: () {
                        AudioService.instance.go();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const GamesMenuScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    // ── کارت شعار ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: AppColors.cardShadow(),
                      ),
                      child: Row(
                        children: [
                          const Text('💜', style: TextStyle(fontSize: 30)),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'هر روز یادگیری، هر روز لبخند',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          const Text('🌟', style: TextStyle(fontSize: 30)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// دکمه دایره‌ای بالای صفحه
class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.color, this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BouncyButton(
      onTap: onTap ?? () {},
      color: color.withValues(alpha: 0.18),
      borderRadius: 20,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}

/// کارت اصلی منو با نشان گرد و نوار پیشرفت
class _MainCard extends StatelessWidget {
  const _MainCard({
    required this.color,
    required this.title,
    required this.badge,
    required this.trailingIcon,
    required this.onTap,
    this.progress,
    this.isLatin = false,
  });

  final Color color;
  final String title;
  final String badge;
  final IconData trailingIcon;
  final VoidCallback onTap;
  final double? progress;
  final bool isLatin;

  @override
  Widget build(BuildContext context) {
    return BouncyButton(
      onTap: onTap,
      color: color,
      borderRadius: 26,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                // نشان گرد سمت راست (مطابق موکاپ)
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: badge.length > 2 ? 22 : 26,
                      fontWeight: FontWeight.w900,
                      color: color,
                      fontFamily: isLatin ? null : 'Vazirmatn',
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(trailingIcon, color: Colors.white, size: 32),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress!.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.35),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
