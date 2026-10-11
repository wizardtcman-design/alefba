import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/numbers_data.dart';
import '../providers/progress_provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../utils/persian.dart';
import '../widgets/common.dart';
import 'number_detail_page.dart';

/// صفحه اعداد: ۱۱ گروه ده‌تایی از ۰ تا ۱۰۰
class NumbersPage extends StatelessWidget {
  const NumbersPage({super.key});

  static const int _groupCount = 11;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اعداد')),
      body: Consumer<ProgressProvider>(
        builder: (BuildContext context, ProgressProvider provider, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _groupCount,
            itemBuilder: (BuildContext context, int group) {
              return _GroupSection(group: group, provider: provider);
            },
          );
        },
      ),
    );
  }
}

/// یک گروه ده‌تایی: هدر رنگی + شبکه کارت‌های عدد
class _GroupSection extends StatelessWidget {
  const _GroupSection({required this.group, required this.provider});

  final int group;
  final ProgressProvider provider;

  List<int> get _values {
    if (group == 10) return const <int>[100];
    return List<int>.generate(10, (int i) => group * 10 + i);
  }

  String get _title {
    if (group == 0) return '۰ تا ۹';
    if (group == 10) return '۱۰۰';
    return '${toPersianDigits(group * 10)} تا ${toPersianDigits(group * 10 + 9)}';
  }

  @override
  Widget build(BuildContext context) {
    final bool unlocked = provider.isNumberGroupUnlocked(group);
    final Color accent = AppColors.playful[group % AppColors.playful.length];

    int knownCount = 0;
    for (final int v in _values) {
      if (provider.isNumberKnown(v)) knownCount++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              if (!unlocked)
                const Icon(Icons.lock_rounded, color: Colors.white, size: 22)
              else
                Text(
                  '${toPersianDigits(knownCount)} بلد است',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 5,
          childAspectRatio: 0.95,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          children: _values
              .map(
                (int v) => _buildCard(context, v, unlocked, accent),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    int value,
    bool unlocked,
    Color accent,
  ) {
    final bool known = provider.isNumberKnown(value);
    return _NumberCard(
      value: value,
      accent: accent,
      known: known,
      locked: !unlocked,
      onTap: () {
        if (!unlocked) {
          showLockedDialog(context);
          return;
        }
        AudioService.instance.playNumberName(value);
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => NumberDetailPage(value: value),
          ),
        );
      },
    );
  }
}

/// کارت هر عدد در شبکه گروه
class _NumberCard extends StatelessWidget {
  const _NumberCard({
    required this.value,
    required this.accent,
    required this.known,
    required this.locked,
    required this.onTap,
  });

  final int value;
  final Color accent;
  final bool known;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fill;
    final Color numberColor;
    final Color nameColor;
    final Border? border;

    if (locked) {
      fill = AppColors.disabled;
      numberColor = Colors.white;
      nameColor = Colors.white;
      border = null;
    } else if (known) {
      fill = AppColors.mint;
      numberColor = Colors.white;
      nameColor = Colors.white;
      border = null;
    } else {
      fill = Colors.white;
      numberColor = accent;
      nameColor = AppColors.textLight;
      border = Border.all(color: accent, width: 2);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(20),
            border: border,
            boxShadow: locked
                ? null
                : const <BoxShadow>[
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                toPersianDigits(value),
                style: TextStyle(
                  fontSize: value >= 100 ? 22 : 26,
                  fontWeight: FontWeight.w900,
                  color: numberColor,
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  NumbersData.nameOf(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: nameColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
