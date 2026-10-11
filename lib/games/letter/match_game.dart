import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../data/letters_data.dart';
import '../../services/audio_service.dart';
import '../../state/app_state.dart';
import '../../widgets/bouncy_button.dart';
import '../game_scaffold.dart';

/// بازی ۲ «جور کن» (جورچین): حرف را به تصویر کلمه‌اش وصل کن
/// کودک اول حرف را می‌زند، بعد تصویر درست را انتخاب می‌کند
class MatchLetterGame extends GameScaffold {
  const MatchLetterGame({super.key, required this.letterId});

  final int letterId;

  @override
  String get title => 'بازی جور کن';

  @override
  int get totalRounds => 3;

  @override
  GameScaffoldState<MatchLetterGame> createState() => _MatchLetterGameState();
}

class _MatchLetterGameState extends GameScaffoldState<MatchLetterGame> {
  late List<LetterModel> current;
  int? selectedLetterId;

  /// مرحله فعلی؛ هر مرحله ۳ جفت

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    // ۳ حرف متفاوت برای این مرحله (حرف هدف همیشه هست)
    final target = LettersData.byId(widget.letterId);
    current = pickLetters(3, include: target);
    selectedLetterId = null;
  }

  void _onLetterTap(LetterModel l) {
    AudioService.instance.speakAsync(l.soundAudio);
    setState(() => selectedLetterId = l.id);
  }

  void _onImageTap(LetterModel l) {
    if (selectedLetterId == null) {
      AudioService.instance.speakAsync(l.wordAudio);
      return;
    }
    context
        .read<AppState>()
        .recordAnswer(correct: selectedLetterId == l.id);
    if (selectedLetterId == l.id) {
      // درست!
      AudioService.instance.praise();
      setState(() {
        current = current.where((c) => c.id != l.id).toList();
        selectedLetterId = null;
      });
      if (current.isEmpty) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          if (round >= widget.totalRounds) {
            setState(() => finished = true);
          } else {
            setState(() => round++);
            _newRound();
          }
        });
      }
    } else {
      AudioService.instance.retry();
      setState(() => selectedLetterId = null);
    }
  }

  @override
  Widget buildRound(BuildContext context) {
    final colors = [AppColors.primary, AppColors.coral, AppColors.mint];
    return Column(
      children: [
        const Text(
          'اول حرف را بزن، بعد تصویرش را!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text),
        ),
        const SizedBox(height: 16),
        // ردیف حروف
        Row(
          children: [
            for (var i = 0; i < current.length; i++) ...[
              if (i > 0) const Spacer(),
              _ChoiceBox(
                selected: selectedLetterId == current[i].id,
                color: colors[i],
                onTap: () => _onLetterTap(current[i]),
                child: Text(
                  current[i].char,
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: colors[i],
                  ),
                ),
              ),
            ],
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Icon(Icons.more_vert_rounded, color: AppColors.lockGrey, size: 30),
        ),
        // ردیف تصاویر (ترتیب مخلوط)
        Row(
          children: [
            for (var i = 0; i < current.length; i++) ...[
              if (i > 0) const Spacer(),
              _ChoiceBox(
                selected: false,
                color: colors[(i + 2) % 3],
                onTap: () => _onImageTap(current[i]),
                child: Image.asset(
                  current[i].imagePath,
                  width: 74,
                  height: 74,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(
                    current[i].emoji,
                    style: const TextStyle(fontSize: 52),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (selectedLetterId != null)
          Text(
            'حالا تصویر درست را بزن!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
            ),
          ),
      ],
    );
  }
}

/// قاب انتخاب با حالت انتخاب‌شده
class _ChoiceBox extends StatelessWidget {
  const _ChoiceBox({
    required this.selected,
    required this.color,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BouncyButton(
      onTap: onTap,
      color: selected ? color.withValues(alpha: 0.25) : Colors.white,
      borderRadius: 22,
      child: Container(
        width: 104,
        height: 104,
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.35),
            width: selected ? 4 : 2,
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(child: child),
      ),
    );
  }
}
