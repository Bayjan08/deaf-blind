import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_colors.dart';
import '../../domain/models/gesture_card.dart';

/// A tappable card that flips from the gesture's picture to its meaning.
class FlipFlashcard extends StatelessWidget {
  const FlipFlashcard({
    super.key,
    required this.card,
    required this.flipped,
    required this.onTap,
  });

  final GestureCard card;
  final bool flipped;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: flipped ? 1 : 0),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        builder: (context, t, child) {
          final showBack = t > 0.5;
          final angle = t * pi;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(angle),
            child: showBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _CardFace.back(card: card),
                  )
                : _CardFace.front(card: card),
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace.front({required this.card}) : isFront = true;
  const _CardFace.back({required this.card}) : isFront = false;

  final GestureCard card;
  final bool isFront;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 380,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isFront ? DesignColors.purpleSoft : DesignColors.greenSoft,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignColors.textDark.withValues(alpha: 0.14),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isFront ? _buildFront() : _buildBack(),
    );
  }

  Widget _buildFront() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: DesignColors.purpleSoft,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(12),
            child: Image.asset(card.imageAsset, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Как переводится этот жест?',
          textAlign: TextAlign.center,
          style: AppTheme.nunito(fontSize: 14, color: DesignColors.textMuted),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.touch_app_rounded, size: 14, color: DesignColors.purple),
            const SizedBox(width: 4),
            Text(
              'Нажми, чтобы узнать ответ',
              style: AppTheme.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: DesignColors.purple),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBack() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: DesignColors.greenSoft,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(16),
            child: Image.asset(card.imageAsset, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          card.meaning,
          textAlign: TextAlign.center,
          style: AppTheme.baloo(fontSize: 28, fontWeight: FontWeight.w700, color: DesignColors.green),
        ),
      ],
    );
  }
}
