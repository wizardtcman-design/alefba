import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/utils.dart';
import '../data/numbers_data.dart';
import '../services/audio_service.dart';
import '../state/app_state.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/celebration.dart';
import '../widgets/common_widgets.dart';
import '../games/number/count_game.dart';
import '../games/number/find_number_game.dart';
import '../games/number/match_number_game.dart';
import 'home_screen.dart';
import 'numbers_home_screen.dart';
import 'parents_dashboard_screen.dart';
import 'settings_screen.dart';

/// صفحه یک عدد: نمایش بزرگ + بشنو + شمارش تصویری + بازی‌ها
class NumberDetailScreen extends StatefulWidget {
  const NumberDetailScreen({super.key, required this.initialValue});

  final int initialValue;

  @override
  State<NumberDetailScreen> createState() => _NumberDetailScreenState();
}

class _NumberDetailScreenState extends State<NumberDetailScreen> {
  late int value;
  bool _celebrate = false;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.instance.speakAsync(_model.audio);
      context.read<AppState>().completeNumberGame(value, game: 'view', won: false);
    });
  }

  NumberModel get _model => NumberModel(value: value);

  void _go(int delta) {
    final next = value + delta;
    if (next < 0 || next > 100) return;
    setState(() => value = next);
    AudioService.instance.speakAsync(_model.audio);
    context.read<AppState>().completeNumberGame(value, game: 'view', won: false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final unlocked = state.isNumberUnlocked(value);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AppBottomNav(
        current: 'home',
        onTap: _navTo,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              PageHeader(
                title: 'اعداد',
                subtitle: 'بیا با هم اعداد رو یاد بگیریم!',
                headerColor: AppColors.coral,
              ),
              Expanded(
                child: !unlocked
                    ? _LockedInfo(value: value)
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // ── ناوبری قبلی/بعدی + عدد بزرگ ──
                            Row(
                              children: [
                                BouncyButton(
                                  onTap: value < 100 ? () => _go(1) : () {},
                                  color: AppColors.mint,
                                  borderRadius: 18,
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Icon(Icons.add_rounded,
                                        color: Colors.white, size: 30),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      TweenAnimationBuilder<double>(
                                        key: ValueKey(value),
                                        tween: Tween(begin: 0.4, end: 1.0),
                                        duration:
                                            const Duration(milliseconds: 350),
                                        curve: Curves.easeOutBack,
                                        builder: (context, v, child) =>
                                            Transform.scale(
                                          scale: v,
                                          child: child,
                                        ),
                                        child: Text(
                                          _model.faDigits,
                                          style: const TextStyle(
                                            fontSize: 96,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primary,
                                            height: 1.0,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _model.name,
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                BouncyButton(
                                  onTap: value > 0 ? () => _go(-1) : () {},
                                  color: AppColors.coral,
                                  borderRadius: 18,
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Icon(Icons.remove_rounded,
                                        color: Colors.white, size: 30),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // ── بشنو ──
                            BouncyButton(
                              onTap: () => AudioService.instance
                                  .speakAsync(_model.audio),
                              color: AppColors.coral,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 34, vertical: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.volume_up_rounded,
                                        color: Colors.white, size: 28),
                                    SizedBox(width: 10),
                                    Text('بشنو',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── شمارش تصویری ──
                            _CountStrip(value: value),
                            const SizedBox(height: 18),

                            // ── بازی‌ها ──
                            _NumberGames(
                              value: value,
                              enabled: unlocked,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          ConfettiOverlay(play: _celebrate),
        ],
      ),
    );
  }

  void _navTo(String key) {
    Navigator.of(context).popUntil((r) => r.isFirst);
    if (key == 'home') {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const NumbersHomeScreen()));
    } else if (key == 'progress') {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const ParentsDashboardScreen()));
    } else if (key == 'more') {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()));
    } else {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }
}

/// کارت قفل برای اعداد هنوز آزاد نشده
class _LockedInfo extends StatelessWidget {
  const _LockedInfo({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔒', style: TextStyle(fontSize: 90)),
            const SizedBox(height: 16),
            Text(
              'این عدد هنوز قفل است!',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text),
            ),
            const SizedBox(height: 8),
            Text(
              'با بازی کردن اعداد قبلی، باز می‌شود.\nهر ۳ بازی درست در یک ده‌تا، ده‌تای بعدی را باز می‌کند!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}

/// نوار شمارش تصویری: نمایش آیتم‌ها برای شمردن با انگشت
class _CountStrip extends StatelessWidget {
  const _CountStrip({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final shown = value > 20 ? 20 : value;
    final emoji = value == 0 ? '⭕' : NumbersData.countEmoji(value).characters.first;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.cardShadow(),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🧮', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text(
                'شمارش کن با انگشت!',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (value == 0)
            const Text(
              'هیچی! صفر یعنی هیچ 😊',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.coral),
            )
          else
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < shown; i++)
                  Text(emoji, style: const TextStyle(fontSize: 26)),
              ],
            ),
          if (value > 20)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '... و ${Fa.num(value - 20)} تای دیگر!',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight),
              ),
            ),
        ],
      ),
    );
  }
}

/// دکمه‌های بازی‌های عدد
class _NumberGames extends StatelessWidget {
  const _NumberGames({required this.value, required this.enabled});

  final int value;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final games = [
      (
        title: 'بازی شمارش',
        color: AppColors.mint,
        builder: () => CountGame(number: value),
      ),
      (
        title: 'بازی جفت‌یابی',
        color: AppColors.primary,
        builder: () => MatchNumberGame(number: value),
      ),
      (
        title: 'بازی پیدا کن',
        color: AppColors.coral,
        builder: () => FindNumberGame(number: value),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text(
            'بازی‌های این عدد',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.text),
          ),
        ),
        const SizedBox(height: 10),
        ...games.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: BouncyButton(
                onTap: enabled
                    ? () {
                        AudioService.instance.go();
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => g.builder()));
                      }
                    : () {},
                color: enabled ? g.color.withValues(alpha: 0.15) : AppColors.lockGrey.withValues(alpha: 0.2),
                borderRadius: 20,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Text(enabled ? '🎮' : '🔒',
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          g.title,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: enabled ? AppColors.text : AppColors.lockGrey,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_back_rounded,
                          size: 26,
                          color: AppColors.textLight),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
