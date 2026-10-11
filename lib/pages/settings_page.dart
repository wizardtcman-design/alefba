import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// تنظیمات: صدا، راهنما، درباره برنامه و پاک کردن پیشرفت
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _confirmAndReset(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('🤔', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              const Text(
                'مطمئنی؟',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'همه‌ی ستاره‌ها و پیشرفت پاک می‌شود.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textLight,
                        side: const BorderSide(
                          color: AppColors.disabled,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        minimumSize: const Size(64, 50),
                      ),
                      child: const Text(
                        'نه',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.coral,
                      ),
                      child: const Text(
                        'بله، پاک کن',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<ProgressProvider>().resetAll();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('پیشرفت پاک شد')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Consumer<ProgressProvider>(
              builder: (BuildContext context, ProgressProvider provider, _) {
                return AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: SwitchListTile(
                    value: provider.soundOn,
                    onChanged: provider.setSound,
                    activeColor: AppColors.mint,
                    title: const Text(
                      'صداها',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    subtitle: const Text(
                      'پخش تلفظ حروف و اعداد',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                    secondary: const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.purple,
                      size: 30,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SectionTitle(
                    text: 'راهنما',
                    icon: Icons.lightbulb_rounded,
                    color: AppColors.star,
                  ),
                  const SizedBox(height: 12),
                  _bullet('هر حرف بعد از کامل کردن حرف قبلی باز می‌شود'),
                  _bullet('برای کامل شدن هر حرف: یادگیری + نوشتن + ۲ بازی با ۲ ستاره'),
                  _bullet('هر گروه اعداد بعد از یادگیری ۶ عدد از گروه قبل باز می‌شود'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SectionTitle(
                    text: 'درباره برنامه',
                    icon: Icons.favorite_rounded,
                    color: AppColors.coral,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'نسخه: ۱٫۰٫۰',
                    style: TextStyle(fontSize: 15, color: AppColors.text),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'ساخته‌شده با 💜 برای کلاس اولی‌ها',
                    style: TextStyle(fontSize: 15, color: AppColors.text),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'کاملاً آفلاین — بدون نیاز به اینترنت',
                    style: TextStyle(fontSize: 15, color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'این عمل قابل بازگشت نیست!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _confirmAndReset(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.coral,
                      side: const BorderSide(color: AppColors.coral, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      minimumSize: const Size(64, 50),
                    ),
                    child: const Text(
                      'پاک کردن همه پیشرفت',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '•',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.star,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.7,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
