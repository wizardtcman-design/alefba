import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../games/games_page.dart';
import '../models/models.dart';
import '../providers/progress_provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/writing_pad.dart';

/// صفحه جزئیات هر حرف: صدا، واژه، نوشتن، بازی و یادگیری
class LetterDetailPage extends StatelessWidget {
  const LetterDetailPage({super.key, required this.letter});

  final LetterItem letter;

  Future<void> _celebrate(BuildContext context) async {
    final ProgressProvider provider = context.read<ProgressProvider>();
    provider.markLearned(letter.id);
    if (!context.mounted) return;
    await showCelebration(
      context,
      stars: provider.starsFor(letter.id),
      message: 'این حرف یاد گرفتی!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(letter.char)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _heroCard(),
              const SizedBox(height: 16),
              _wordCard(),
              const SizedBox(height: 24),
              const SectionTitle(
                text: 'بنویس!',
                icon: Icons.edit_rounded,
                color: AppColors.coral,
              ),
              const SizedBox(height: 12),
              WritingPad(
                character: letter.char,
                onComplete: () {
                  context.read<ProgressProvider>().markPracticed(letter.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('آفرین! خیلی خوب نوشتی 🎉'),
                      backgroundColor: AppColors.mint,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const SectionTitle(
                text: 'بازی کن!',
                icon: Icons.sports_esports_rounded,
              ),
              const SizedBox(height: 12),
              BigButton(
                label: 'برو بازی!',
                icon: Icons.play_arrow_rounded,
                color: AppColors.coral,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => GamesPage(initialLetterId: letter.id),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Consumer<ProgressProvider>(
                builder: (BuildContext context, ProgressProvider provider, _) {
                  final bool learned =
                      provider.letterProgressOf(letter.id)?.learned ?? false;
                  return BigButton(
                    label: learned ? 'یاد گرفتم ✓' : 'این حرف را یاد گرفتم!',
                    icon: Icons.school_rounded,
                    color: AppColors.mint,
                    onTap: () => _celebrate(context),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// کارت بزرگ حرف با دو دکمه صدا
  Widget _heroCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Text(
            letter.char,
            style: const TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w900,
              color: AppColors.purple,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _SoundButton(
                icon: Icons.record_voice_over_rounded,
                color: AppColors.mint,
                caption: 'صدای حرف',
                onTap: () => AudioService.instance.playLetter(letter),
              ),
              const SizedBox(width: 24),
              _SoundButton(
                icon: Icons.music_note_rounded,
                color: AppColors.coral,
                caption: 'صدای واژه',
                onTap: () => AudioService.instance.playLetterWord(letter),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// کارت واژه‌ی نمونه‌ی حرف
  Widget _wordCard() {
    return AppCard(
      child: Row(
        children: <Widget>[
          Text(letter.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  letter.word,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  letter.letterName,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// دکمه گرد ۵۶ پیکسلی با زیرنویس
class _SoundButton extends StatelessWidget {
  const _SoundButton({
    required this.icon,
    required this.color,
    required this.caption,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          caption,
          style: const TextStyle(fontSize: 13, color: AppColors.textLight),
        ),
      ],
    );
  }
}
