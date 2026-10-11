import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/alphabet_data.dart';
import '../data/numbers_data.dart';
import '../models/models.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import '../utils/persian.dart';
import '../widgets/common.dart';
import 'drag_drop_game.dart';
import 'find_letter_game.dart';
import 'memory_game.dart';
import 'number_games.dart';
import 'puzzle_game.dart';

/// مرکز بازی‌ها: تب حروف و تب اعداد
class GamesPage extends StatefulWidget {
  const GamesPage({super.key, this.initialLetterId, this.initialNumber});

  final String? initialLetterId;
  final int? initialNumber;

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialLetterId != null) {
        _openLetterGames(widget.initialLetterId!);
      } else if (widget.initialNumber != null) {
        _openNumberGames(widget.initialNumber!);
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _openLetterGames(String letterId) {
    final LetterItem letter =
        AlphabetData.letters.firstWhere((LetterItem l) => l.id == letterId);
    final ProgressProvider provider = context.read<ProgressProvider>();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (BuildContext sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'بازی با حرف ${letter.char}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 16),
              _GameTile(
                emoji: '🔍',
                title: 'حرف را پیدا کن',
                color: AppColors.purple,
                stars: provider.letterProgressOf(letter.id)?.games[GameIds.find] ?? 0,
                onTap: () => _startGame(
                  sheetCtx,
                  FindLetterGame(
                    letter: letter,
                    onFinish: (int s) =>
                        provider.recordGame(letter.id, GameIds.find, s),
                  ),
                ),
              ),
              _GameTile(
                emoji: '🧩',
                title: 'پازل حرف',
                color: AppColors.coral,
                stars: provider.letterProgressOf(letter.id)?.games[GameIds.puzzle] ?? 0,
                onTap: () => _startGame(
                  sheetCtx,
                  PuzzleGame(
                    letter: letter,
                    onFinish: (int s) =>
                        provider.recordGame(letter.id, GameIds.puzzle, s),
                  ),
                ),
              ),
              _GameTile(
                emoji: '🧠',
                title: 'جفت‌های حافظه',
                color: AppColors.mint,
                stars: provider.letterProgressOf(letter.id)?.games[GameIds.memory] ?? 0,
                onTap: () => _startGame(
                  sheetCtx,
                  MemoryGame(
                    letter: letter,
                    onFinish: (int s) =>
                        provider.recordGame(letter.id, GameIds.memory, s),
                  ),
                ),
              ),
              _GameTile(
                emoji: '✋',
                title: 'بکش و بگذار',
                color: AppColors.star,
                stars: provider.letterProgressOf(letter.id)?.games[GameIds.drag] ?? 0,
                onTap: () => _startGame(
                  sheetCtx,
                  DragDropGame(
                    letter: letter,
                    onFinish: (int s) =>
                        provider.recordGame(letter.id, GameIds.drag, s),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openNumberGames(int value) {
    final ProgressProvider provider = context.read<ProgressProvider>();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (BuildContext sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'بازی با عدد ${toPersianDigits(value)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 16),
              _GameTile(
                emoji: '🍎',
                title: 'بشمار و انتخاب کن',
                color: AppColors.coral,
                stars: provider.numberGameStars(value, GameIds.counting),
                onTap: () => _startGame(
                  sheetCtx,
                  CountingDragGame(
                    value: value,
                    onFinish: (int s) =>
                        provider.recordNumberGame(value, GameIds.counting, s),
                  ),
                ),
              ),
              _GameTile(
                emoji: '🃏',
                title: 'جفت عدد',
                color: AppColors.purple,
                stars: provider.numberGameStars(value, GameIds.numberMatch),
                onTap: () => _startGame(
                  sheetCtx,
                  NumberMatchGame(
                    value: value,
                    onFinish: (int s) => provider.recordNumberGame(
                        value, GameIds.numberMatch, s),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext sheetCtx, Widget game) {
    Navigator.of(sheetCtx).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => game),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بازی‌ها'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.purple,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.purple,
          labelStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          tabs: const <Widget>[
            Tab(text: 'حروف'),
            Tab(text: 'اعداد'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: <Widget>[_lettersTab(), _numbersTab()],
      ),
    );
  }

  Widget _lettersTab() {
    return Consumer<ProgressProvider>(
      builder: (BuildContext context, ProgressProvider p, _) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: AlphabetData.letters.length,
          itemBuilder: (BuildContext context, int index) {
            final LetterItem letter = AlphabetData.letters[index];
            final bool unlocked = p.isLetterUnlocked(index);
            return _GridTile(
              label: letter.char,
              color: unlocked
                  ? AppColors.playful[index % AppColors.playful.length]
                  : AppColors.disabled,
              locked: !unlocked,
              onTap: () {
                if (unlocked) {
                  _openLetterGames(letter.id);
                } else {
                  showLockedDialog(context);
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _numbersTab() {
    return Consumer<ProgressProvider>(
      builder: (BuildContext context, ProgressProvider p, _) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: 101,
          itemBuilder: (BuildContext context, int index) {
            final int value = index;
            final int group = NumbersData.groupOf(value);
            final bool unlocked = p.isNumberGroupUnlocked(group);
            return _GridTile(
              label: toPersianDigits(value),
              color: unlocked
                  ? AppColors.playful[group % AppColors.playful.length]
                  : AppColors.disabled,
              locked: !unlocked,
              onTap: () {
                if (unlocked) {
                  _openNumberGames(value);
                } else {
                  showLockedDialog(context);
                }
              },
            );
          },
        );
      },
    );
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({
    required this.emoji,
    required this.title,
    required this.color,
    required this.stars,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final Color color;
  final int stars;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: color.withOpacity(0.4), width: 2),
            ),
            child: Row(
              children: <Widget>[
                Text(emoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                ),
                StarRow(stars: stars, size: 18),
                const SizedBox(width: 8),
                Icon(Icons.chevron_left_rounded, color: color, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile({
    required this.label,
    required this.color,
    required this.locked,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
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
          child: Center(
            child: locked
                ? const Icon(Icons.lock_rounded, color: Colors.white54, size: 26)
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: label.length > 2 ? 18 : 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
