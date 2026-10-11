import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../state/app_state.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/common_widgets.dart';

/// تنظیمات: صدا، افکت‌ها، سرعت تلفظ + کارت آفلاین
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          PageHeader(
            title: 'تنظیمات',
            subtitle: 'اپ را برای کودک خودتان تنظیم کنید',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                // ── صدا ──
                _SettingTile(
                  emoji: '🔊',
                  title: 'صدای آموزش',
                  desc: 'تلفظ حروف و اعداد',
                  value: s.soundOn,
                  onChanged: state.setSoundOn,
                ),
                _SettingTile(
                  emoji: '🎵',
                  title: 'صداهای تشویقی',
                  desc: 'آفرین و تشویق بعد از بازی',
                  value: s.sfxOn,
                  onChanged: state.setSfxOn,
                ),

                // ── سرعت تلفظ ──
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: AppColors.cardShadow(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('🐢', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 10),
                          Text(
                            'سرعت تلفظ',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _SpeedChip(
                            label: 'آهسته',
                            emoji: '🐢',
                            selected: s.speechSpeed < 0.95,
                            onTap: () => state.setSpeechSpeed(0.85),
                          ),
                          const SizedBox(width: 10),
                          _SpeedChip(
                            label: 'معمولی',
                            emoji: '🙂',
                            selected:
                                s.speechSpeed >= 0.95 && s.speechSpeed <= 1.05,
                            onTap: () => state.setSpeechSpeed(1.0),
                          ),
                          const SizedBox(width: 10),
                          _SpeedChip(
                            label: 'سریع',
                            emoji: '🐇',
                            selected: s.speechSpeed > 1.05,
                            onTap: () => state.setSpeechSpeed(1.2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── حالت آفلاین ──
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.mintLight,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.mint,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.wifi_off_rounded,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'کاملاً آفلاین 🔒',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.mintDark),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'همه صداها، تصاویر و بازی‌ها داخل خود اپ هستند. هیچ اینترنتی لازم نیست و هیچ داده‌ای جایی فرستاده نمی‌شود.',
                              style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── درباره ──
                const Center(
                  child: Text(
                    'آموزش کلاس اول • نسخه ۱٫۱٫۰',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.value,
    required this.onChanged,
  });

  final String emoji;
  final String title;
  final String desc;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.cardShadow(),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text)),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textLight)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SpeedChip extends StatelessWidget {
  const _SpeedChip({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BouncyButton(
        onTap: onTap,
        color: selected ? AppColors.primary : AppColors.background,
        borderRadius: 16,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : AppColors.textLight)),
            ],
          ),
        ),
      ),
    );
  }
}
