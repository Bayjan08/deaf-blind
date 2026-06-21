import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_colors.dart';
import '../../../deaf_school/presentation/widgets/design_widgets.dart';
import '../providers/flashcards_provider.dart';
import '../widgets/flip_flashcard.dart';

class FlashcardsScreen extends ConsumerWidget {
  const FlashcardsScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(flashcardsProvider);
    final notifier = ref.read(flashcardsProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [DesignColors.purpleSoft, DesignColors.bg],
          stops: [0, 0.35],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DesignBackButton(onTap: onBack),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Карточки жестов',
                    style: AppTheme.baloo(fontSize: 20, fontWeight: FontWeight.w700, height: 1),
                  ),
                ),
                if (!state.isFinished)
                  GestureDetector(
                    onTap: () => notifier.restart(shuffleDeck: true),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: DesignColors.purple.withValues(alpha: 0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.shuffle_rounded, size: 18, color: DesignColors.purple),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            if (state.isFinished)
              _SummaryView(
                knownCount: state.knownIds.length,
                totalCount: state.deck.length,
                onRestart: () => notifier.restart(),
                onShuffleRestart: () => notifier.restart(shuffleDeck: true),
              )
            else
              _DeckView(state: state, notifier: notifier),
          ],
        ),
      ),
    );
  }
}

class _DeckView extends StatelessWidget {
  const _DeckView({required this.state, required this.notifier});

  final FlashcardsState state;
  final FlashcardsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final card = state.current!;
    final progress = state.index / state.deck.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: DesignColors.progressBg,
                  color: DesignColors.purple,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${state.index + 1}/${state.deck.length}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: DesignColors.purple),
            ),
          ],
        ),
        const SizedBox(height: 22),
        FlipFlashcard(
          key: ValueKey(card.id),
          card: card,
          flipped: state.flipped,
          onTap: notifier.flip,
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'Повторить',
                icon: Icons.refresh_rounded,
                color: DesignColors.orangeSoft,
                textColor: DesignColors.orange,
                onTap: notifier.markLearning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                label: 'Знаю',
                icon: Icons.check_rounded,
                color: DesignColors.green,
                textColor: Colors.white,
                onTap: notifier.markKnown,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.nunito(fontSize: 15, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({
    required this.knownCount,
    required this.totalCount,
    required this.onRestart,
    required this.onShuffleRestart,
  });

  final int knownCount;
  final int totalCount;
  final VoidCallback onRestart;
  final VoidCallback onShuffleRestart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: DesignColors.textDark.withValues(alpha: 0.12),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [DesignColors.purple, DesignColors.purpleLight],
              ),
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 46),
          ),
          const SizedBox(height: 18),
          Text(
            'Колода пройдена! 🎉',
            style: AppTheme.baloo(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Ты знаешь $knownCount из $totalCount жестов',
            style: TextStyle(fontSize: 15, color: DesignColors.textMuted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: onRestart,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [DesignColors.purple, DesignColors.purpleLight],
                ),
                boxShadow: [
                  BoxShadow(
                    color: DesignColors.purple.withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text('Пройти ещё раз', style: AppTheme.nunito(fontSize: 16, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onShuffleRestart,
            child: Text(
              'Перемешать и повторить →',
              style: AppTheme.nunito(fontSize: 14, color: DesignColors.purple),
            ),
          ),
        ],
      ),
    );
  }
}
