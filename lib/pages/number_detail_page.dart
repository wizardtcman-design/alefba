import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/numbers_data.dart';
import '../games/games_page.dart';
import '../providers/progress_provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../utils/persian.dart';
import '../widgets/common.dart';
import '../widgets/writing_pad.dart';

/// صفحه جزئیات هر عدد: بزرگ‌نمایی، شمارش، نوشتن، یادگیری و بازی
class NumberDetailPage extends StatelessWidget {
  const NumberDetailPage({super.key, required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(NumbersData.nameOf(value))),
      body: Consumer<ProgressProvider>(
        builder: (BuildContext context, ProgressProvider provider, _) {
          final bool known = provider.isNumberKnown(value);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _heroCard(),
                const SizedBox(height: 16),
                _countingCard(),
                const SizedBox(height: 16),
                _writingCard(context, provider),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: BigButton(
                    label: known ? 'بلدم ✓' : 'این عدد را یاد گرفتم!',
                    icon: Icons.school_rounded,
                    color: AppColors.mint,
                    onTap: () {
                      provider.toggleNumberKnown(value);
                      if (!known) {
                        AudioService.instance.playNumberName(value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: BigButton(
                    label: 'بازی با این عدد',
                    icon: Icons.play_arrow_rounded,
                    color: AppColors.purple,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              GamesPage(initialNumber: value),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  /// کارت قهرمان: عدد بزرگ + نام + دکمه پخش صدا
  Widget _heroCard() {
    return AppCard(
      child: Column(
        children: <Widget>[
          Text(
            toPersianDigits(value),
            style: const TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w900,
              color: AppColors.coral,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            NumbersData.nameOf(value),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: AppColors.mint,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => AudioService.instance.playNumberName(value),
              child: const SizedBox(
                width: 64,
                height: 64,
                child: Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// کارت شمارش: ایموجی (تا ۲۰) یا نقطه‌های ده‌تایی (بیشتر از ۲۰)
  Widget _countingCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SectionTitle(
            text: 'بشمار!',
            icon: Icons.calculate_rounded,
            color: AppColors.mint,
          ),
          const SizedBox(height: 16),
          if (value == 0)
            const Text(
              'صفر یعنی هیچ‌کدام! 🌟',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textLight,
              ),
            )
          else if (value <= 20)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: List<Widget>.generate(
                value,
                (int i) => Text(
                  NumbersData.emojiFor(value),
                  style: const TextStyle(fontSize: 34),
                ),
              ),
            )
          else ...<Widget>[
            Center(
              child: TenFrameDots(
                count: value,
                dotSize: 14,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'هر ردیف ۱۰ تا — ${toPersianDigits(value)} تا ${NumbersData.emojiFor(value)}!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
          ],
        ],
      ),
    );
  }

  /// کارت تمرین نوشتن عدد با ارقام فارسی
  Widget _writingCard(BuildContext context, ProgressProvider provider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionTitle(
            text: 'بنویس!',
            icon: Icons.edit_rounded,
            color: AppColors.coral,
          ),
          const SizedBox(height: 12),
          WritingPad(
            character: toPersianDigits(value),
            onComplete: () {
              provider.markNumberWritten(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'آفرین! عدد ${toPersianDigits(value)} را نوشتی 🎉',
                  ),
                  backgroundColor: AppColors.mint,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
