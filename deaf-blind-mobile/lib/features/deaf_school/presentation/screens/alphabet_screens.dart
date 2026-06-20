import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../app_screen.dart';
import '../widgets/design_widgets.dart';

// ─── ALPHABET INTRO ─────────────────────────────────────────────────────────

class AlphabetIntroScreen extends StatelessWidget {
  const AlphabetIntroScreen({
    super.key,
    required this.onBack,
    required this.onPractice,
  });

  final VoidCallback onBack;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 130),
      child: Column(
        children: [
          Row(
            children: [
              DesignBackButton(onTap: onBack),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 0.6,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE6E8F1),
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '3/5',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Аа',
            style: AppTextStyles.style(
              fontSize: 96,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              height: 1,
            ),
          ),
          Text(
            'Буква «А»',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.12),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: const Color(0xFFFDEBE2),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '[ изображение: арбуз ]',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: const Color(0xFFC99B83),
                        ),
                      ),
                      Text(
                        'Арбуз',
                        style: AppTextStyles.style(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE08A5C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                    children: const [
                      TextSpan(
                        text: 'А',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(text: 'рбуз начинается на букву А'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 88,
                  height: 88,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'анимация\nжеста',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: const Color(0xFF9AA3C0),
                            height: 1.3,
                          ),
                        ),
                      ),
                      const _RingBorder(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Жест буквы А',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Сожми кулак, большой палец сбоку. Смотри, как показывает аватар.',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF7A7F9A),
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Попробовать жест →',
            onTap: onPractice,
          ),
        ],
      ),
    );
  }
}

class _RingBorder extends StatefulWidget {
  const _RingBorder();

  @override
  State<_RingBorder> createState() => _RingBorderState();
}

class _RingBorderState extends State<_RingBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        return Transform.scale(
          scale: 0.4 + t * 1.1,
          child: Opacity(
            opacity: (1 - t) * 0.55,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.primary, width: 3),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── ALPHABET PRACTICE ───────────────────────────────────────────────────────

class AlphabetPracticeScreen extends StatelessWidget {
  const AlphabetPracticeScreen({
    super.key,
    required this.onBack,
    required this.practiceState,
    required this.onCheck,
    required this.onSuccess,
  });

  final VoidCallback onBack;
  final PracticeState practiceState;
  final VoidCallback onCheck;
  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.4),
              radius: 1.2,
              colors: [Color(0xFF2A2748), AppColors.textPrimary],
            ),
          ),
        ),
        Center(
          child: Text(
            '[ камера: ваше видео ]',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
        Positioned(
          top: 56,
          left: 20,
          right: 20,
          child: Row(
            children: [
              DesignBackButton(onTap: onBack, light: true),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Покажи букву жестом',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 120,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Аа',
                    style: AppTextStyles.style(
                      fontSize: 46,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ПОКАЖИ',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'букву А',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 220,
          right: 20,
          child: Container(
            width: 78,
            height: 104,
            decoration: BoxDecoration(
              color: const Color(0xFF221F3D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              'вы',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 9,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
        if (practiceState == PracticeState.ready)
          Positioned(
            bottom: 110,
            left: 20,
            right: 20,
            child: PrimaryButton(label: 'Проверить жест', onTap: onCheck),
          ),
        if (practiceState == PracticeState.checking)
          Positioned(
            bottom: 110,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _WaveBars(),
                  const SizedBox(width: 12),
                  const Text(
                    'Распознаём жест…',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (practiceState == PracticeState.success)
          Container(
            color: AppColors.success.withValues(alpha: 0.92),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.success,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Верно!',
                    style: AppTextStyles.style(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ты правильно показал букву А.\n+10 опыта для Лиса',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: onSuccess,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        'Дальше →',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _WaveBars extends StatefulWidget {
  const _WaveBars();

  @override
  State<_WaveBars> createState() => _WaveBarsState();
}

class _WaveBarsState extends State<_WaveBars> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(4, (i) {
          return AnimatedBuilder(
            animation: _c,
            builder: (context, child) {
              final phase = (_c.value + i * 0.15) % 1.0;
              final h = 0.35 + 0.65 * math.sin(phase * math.pi);
              return Container(
                width: 5,
                height: 24 * h,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// ─── ALPHABET SUCCESS ────────────────────────────────────────────────────────

class AlphabetSuccessScreen extends StatelessWidget {
  const AlphabetSuccessScreen({
    super.key,
    required this.onMap,
    required this.onNextLetter,
  });

  final VoidCallback onMap;
  final VoidCallback onNextLetter;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 40, 26, 130),
        child: Column(
          children: [
            _FloatingPetSuccess(),
            const SizedBox(height: 26),
            Text(
              'Буква выучена!',
              style: AppTextStyles.style(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Лис подрос, а его домик стал больше. Осталось 2 буквы до экзамена и нового уровня.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Уровень 1 · Буквы',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '3/5',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.6,
                      minHeight: 12,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            PrimaryButton(
              label: 'На карту уровней',
              onTap: onMap,
              color: Colors.white,
              textColor: AppColors.primary,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onNextLetter,
              child: const Text(
                'Следующая буква →',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingPetSuccess extends StatefulWidget {
  @override
  State<_FloatingPetSuccess> createState() => _FloatingPetSuccessState();
}

class _FloatingPetSuccessState extends State<_FloatingPetSuccess>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -7 * math.sin(_c.value * math.pi)),
        child: child,
      ),
      child: Container(
        width: 130,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 14),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              top: -22,
              child: CustomPaint(
                size: const Size(84, 30),
                painter: _TrianglePainter(Colors.white.withValues(alpha: 0.3)),
              ),
            ),
            Text(
              'питомец Лис\nстал круче',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
