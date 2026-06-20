import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_colors.dart';
import '../widgets/design_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onProfile,
    required this.onAlphabetMap,
    required this.onSubjects,
  });

  final VoidCallback onProfile;
  final VoidCallback onAlphabetMap;
  final VoidCallback onSubjects;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'С возвращением',
                      style: TextStyle(
                        fontSize: 14,
                        color: DesignColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Привет, Артём!',
                      style: AppTheme.baloo(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const StreakBadge(),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onProfile,
                child: const AvatarImage(size: 46),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _AiRecommendationCard(onTap: onAlphabetMap),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Продолжить',
                style: AppTheme.baloo(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              GestureDetector(
                onTap: onSubjects,
                child: const Text(
                  'Все предметы',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: DesignColors.purple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onAlphabetMap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: DesignColors.textDark.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: DesignColors.purpleSoft,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Аа',
                      style: AppTheme.baloo(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: DesignColors.purple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Алфавит жестами',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: DesignColors.textDark,
                          ),
                        ),
                        Text(
                          'Уровень 1 · Буквы',
                          style: TextStyle(
                            fontSize: 13,
                            color: DesignColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: 0.6,
                            minHeight: 8,
                            backgroundColor: DesignColors.progressBg,
                            color: DesignColors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '3/5',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: DesignColors.purple,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _StatCard(value: '+18%', label: 'Прогресс за неделю', color: DesignColors.green)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(value: '47', label: 'Выучено жестов', color: DesignColors.purple)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiRecommendationCard extends StatelessWidget {
  const _AiRecommendationCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DesignColors.purple, DesignColors.purpleLight],
        ),
        boxShadow: [
          BoxShadow(
            color: DesignColors.purple.withValues(alpha: 0.7),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ИИ-помощник',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.35,
                  ),
                  children: [
                    const TextSpan(text: 'Буквы '),
                    TextSpan(
                      text: 'Д',
                      style: AppTheme.baloo(fontSize: 17, color: Colors.white),
                    ),
                    const TextSpan(text: ' и '),
                    TextSpan(
                      text: 'П',
                      style: AppTheme.baloo(fontSize: 17, color: Colors.white),
                    ),
                    const TextSpan(text: ' даются трудно. Давай быстро повторим их?'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Повторить →',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: DesignColors.purple,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: DesignColors.textDark.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTheme.baloo(fontSize: 26, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: DesignColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SUBJECTS ────────────────────────────────────────────────────────────────

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({
    super.key,
    required this.onAlphabetMap,
    required this.onMusicNotes,
    required this.onPronunciation,
  });

  final VoidCallback onAlphabetMap;
  final VoidCallback onMusicNotes;
  final VoidCallback onPronunciation;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 64, 20, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Предметы',
            style: AppTheme.baloo(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          Text(
            'Выбери, чем хочешь заняться',
            style: TextStyle(
              fontSize: 14,
              color: DesignColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          _SubjectCard(
            onTap: onAlphabetMap,
            icon: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: DesignColors.purple,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                'Аа',
                style: AppTheme.baloo(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
            title: 'Алфавит жестами',
            subtitle: 'Игра с питомцем · 4 уровня',
            badge: 'Уровень 1 · 3/5',
            badgeBg: DesignColors.greenSoft,
            badgeColor: DesignColors.green,
          ),
          const SizedBox(height: 14),
          _SubjectCard(
            onTap: onMusicNotes,
            icon: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: DesignColors.purpleSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/music_disc.png',
                fit: BoxFit.contain,
              ),
            ),
            title: 'Музыка через вибрацию',
            subtitle: 'Ноты через цвет и вибрацию',
            badge: '7 нот',
            badgeBg: const Color(0xFFF0F6FF),
            badgeColor: const Color(0xFF4D8BFF),
          ),
          const SizedBox(height: 26),
          Text(
            'ДОПОЛНИТЕЛЬНО · ПО ЖЕЛАНИЮ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: DesignColors.textDim,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          _SubjectCard(
            onTap: onPronunciation,
            icon: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded, color: DesignColors.orange, size: 30),
            ),
            title: 'Произношение',
            subtitle: 'Артикуляция звуков · необязательно',
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Основной язык обучения — жесты. Этот курс можно проходить дополнительно, он не влияет на твой прогресс.',
              style: TextStyle(
                fontSize: 12,
                color: DesignColors.textDim,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeBg,
    this.badgeColor,
  });

  final VoidCallback onTap;
  final Widget icon;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeBg;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: DesignColors.textDark.withValues(alpha: 0.15),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: DesignColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: DesignColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ALPHABET MAP ────────────────────────────────────────────────────────────

class AlphabetMapScreen extends StatelessWidget {
  const AlphabetMapScreen({
    super.key,
    required this.onBack,
    required this.onIntro,
  });

  final VoidCallback onBack;
  final VoidCallback onIntro;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [DesignColors.purpleMap, DesignColors.bg],
          stops: [0, 0.4],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 130),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 14),
              child: Row(
                children: [
                  DesignBackButton(onTap: onBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Алфавит жестами',
                      style: AppTheme.baloo(fontSize: 20, fontWeight: FontWeight.w700, height: 1),
                    ),
                  ),
                  const StreakBadge(compact: true),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: DesignColors.textDark.withValues(alpha: 0.15),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _FloatingPet(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Лис растёт вместе с тобой',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: DesignColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 7),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: 0.35,
                              minHeight: 9,
                              backgroundColor: DesignColors.progressBg,
                              color: DesignColors.purple,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Ещё 2 буквы до нового уровня',
                            style: TextStyle(
                              fontSize: 12,
                              color: DesignColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 580,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(double.infinity, 580),
                    painter: _MapPathPainter(),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 70,
                    child: Center(
                      child: LockedLevelNode(
                        label: 'Замок · Предложения',
                        large: true,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 235,
                    top: 225,
                    child: LockedLevelNode(label: 'Слова'),
                  ),
                  const Positioned(
                    left: 95,
                    top: 350,
                    child: LockedLevelNode(label: 'Слоги'),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 470,
                    child: Column(
                      children: [
                        _ContinueBubble(),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: onIntro,
                          child: Container(
                            width: 96,
                            height: 84,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              gradient: const LinearGradient(
                                colors: [DesignColors.purple, DesignColors.purpleLight],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: DesignColors.purple.withValues(alpha: 0.7),
                                  blurRadius: 28,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Positioned(
                                  top: -16,
                                  child: CustomPaint(
                                    size: const Size(60, 22),
                                    painter: _TrianglePainter(const Color(0xFF7B6BF0)),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 26),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Уровень 1 · Буквы',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: DesignColors.purple,
                          ),
                        ),
                      ],
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
}

class _FloatingPet extends StatefulWidget {
  @override
  State<_FloatingPet> createState() => _FloatingPetState();
}

class _FloatingPetState extends State<_FloatingPet>
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
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFFEAF0FF),
        ),
        alignment: Alignment.center,
        child: Text(
          'питомец\nЛис',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            color: const Color(0xFF9AA3C0),
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class _ContinueBubble extends StatefulWidget {
  @override
  State<_ContinueBubble> createState() => _ContinueBubbleState();
}

class _ContinueBubbleState extends State<_ContinueBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: DesignColors.textDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'ПРОДОЛЖИТЬ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 10,
              height: 10,
              color: DesignColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD8D5F0)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.897)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.784, size.width * 0.27, size.height * 0.655)
      ..quadraticBezierTo(size.width * 0.33, size.height * 0.517, size.width * 0.67, size.height * 0.431)
      ..quadraticBezierTo(size.width * 0.71, size.height * 0.302, size.width * 0.43, size.height * 0.19);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
