import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/alphabet_data.dart';
import '../models/models.dart';
import '../providers/progress_provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../utils/persian.dart';
import '../widgets/common.dart';
import 'letter_detail_page.dart';

/// شبکه ۳۲ حرف الفبا با قفل مرحله‌ای
class LettersPage extends StatelessWidget {
  const LettersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حروف الفبا')),
      body: SafeArea(
        child: Consumer<ProgressProvider>(
          builder: (BuildContext context, ProgressProvider provider, _) {
            final int total = AlphabetData.letters.length;
            final int completed = provider.completedLetters;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: LinearProgressIndicator(
                      value: completed / total,
                      minHeight: 14,
                      backgroundColor: AppColors.disabled,
                      color: AppColors.mint,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Text(
                    '${toPersianDigits(completed)} از ${toPersianDigits(total)} حرف کامل شد',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: total,
                    itemBuilder: (BuildContext context, int index) {
                      final LetterItem letter = AlphabetData.letters[index];
                      final bool unlocked = provider.isLetterUnlocked(index);
                      return _LetterCard(
                        letter: letter,
                        index: index,
                        unlocked: unlocked,
                        onTap: () {
                          if (unlocked) {
                            AudioService.instance.playLetter(letter);
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    LetterDetailPage(letter: letter),
                              ),
                            );
                          } else {
                            showLockedDialog(context);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// کارت یک حرف (باز یا قفل) با بازخورد لمسی ملایم
class _LetterCard extends StatelessWidget {
  const _LetterCard({
    required this.letter,
    required this.index,
    required this.unlocked,
    required this.onTap,
  });

  final LetterItem letter;
  final int index;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = AppColors.playful[index % AppColors.playful.length];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: unlocked
            ? const <BoxShadow>[
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: unlocked ? AppColors.card : AppColors.disabled,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          splashColor: color.withOpacity(0.15),
          highlightColor: color.withOpacity(0.08),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: <Widget>[
                    const Spacer(),
                    Text(
                      letter.char,
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: unlocked ? color : Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            letter.word,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: unlocked ? AppColors.text : Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          letter.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: unlocked
                    ? Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          toPersianDigits(index + 1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.lock_rounded,
                          color: Colors.white54,
                          size: 22,
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
