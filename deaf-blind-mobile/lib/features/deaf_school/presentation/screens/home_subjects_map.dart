import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// ─── LEVEL MAP DATA ──────────────────────────────────────────────────────────

class LevelDef {
  final int num;
  final String name;
  final double cx, cy, w, ar;
  final String img;
  final bool active;
  const LevelDef(this.num, this.name, this.cx, this.cy, this.w, this.ar,
      this.img, this.active);
}

const double _kDesignW = 390;
const double _kCanvasH = 1160;

const List<LevelDef> _kLevels = [
  LevelDef(1, 'Letters', 196, 168, 154, 970 / 875, 'assets/level1_house.png', true),
  LevelDef(2, 'Syllables', 114, 448, 124, 475 / 526, 'assets/level2_house.png', false),
  LevelDef(3, 'Words', 276, 718, 106, 515 / 955, 'assets/level3_house.png', false),
  LevelDef(4, 'Sentences', 150, 1000, 152, 1199 / 1319, 'assets/level4_castle.png', false),
];

const ColorFilter _kGrayscale = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
]);

// ─── HOME SCREEN (level map) ─────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _bob;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400))
      ..repeat(reverse: true);
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bob.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: const Color(0xFF33485A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        duration: const Duration(milliseconds: 2300),
        margin: const EdgeInsets.fromLTRB(60, 0, 60, 28),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final s = screenW / _kDesignW;

    return Stack(
      children: [
        SingleChildScrollView(
          child: SizedBox(
            width: screenW,
            height: _kCanvasH * s,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.48, 1.0],
                        colors: [
                          Color(0xFFEAF7FC),
                          Color(0xFFD8EEF8),
                          Color(0xFFD6ECDA),
                        ],
                      ),
                    ),
                  ),
                ),
                _hill(s, left: -60, top: 430, size: 240, color: const Color(0xFFCFE9D3)),
                _hill(s, right: -80, top: 760, size: 280, color: const Color(0xFFC8E6CF)),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 200 * s,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00C8E6CD), Color(0xFFC2E3C6)],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(child: CustomPaint(painter: _LevelPathPainter(s))),
                for (final l in _kLevels) _buildNode(l, s),
              ],
            ),
          ),
        ),
        _buildHeader(s),
      ],
    );
  }

  Widget _hill(double s,
      {double? left, double? right, required double top, required double size, required Color color}) {
    return Positioned(
      left: left == null ? null : left * s,
      right: right == null ? null : right * s,
      top: top * s,
      child: Container(
        width: size * s,
        height: size * s,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildNode(LevelDef l, double s) {
    final bool isActive = l.active;
    final bool isLocked = !l.active;
    final double w = l.w * s;
    final double h = w / l.ar;
    const double slotExtraTop = 56;
    const double slotExtraBottom = 60;
    final double slotW = w * 1.4;
    final double slotH = h + slotExtraTop + slotExtraBottom;

    return Positioned(
      left: l.cx * s - slotW / 2,
      top: l.cy * s - (slotExtraTop + h / 2),
      width: slotW,
      height: slotH,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => isLocked
            ? _toast('Complete the previous level to unlock')
            : widget.onAlphabetMap(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: slotExtraTop),
            SizedBox(
              width: w,
              height: h,
              child: AnimatedBuilder(
                animation: Listenable.merge([_bob, _pulse]),
                builder: (_, _) {
                  final bob = isActive ? -8.0 * _wave(_bob.value) * s : 0.0;
                  return Transform.translate(
                    offset: Offset(0, bob),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        if (isActive)
                          Container(
                            width: w * 1.3,
                            height: w * 1.3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFF3933B).withValues(
                                      alpha: 0.55 - 0.43 * _wave(_pulse.value)),
                                  const Color(0x00F3933B),
                                ],
                                stops: const [0.0, 0.64],
                              ),
                            ),
                            transform: Matrix4.diagonal3Values(
                              1.0 + 0.22 * _wave(_pulse.value),
                              1.0 + 0.22 * _wave(_pulse.value),
                              1.0,
                            ),
                            transformAlignment: Alignment.center,
                          ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: w * 0.86,
                            height: w * 0.26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: const Alignment(0, -0.3),
                                colors: isLocked
                                    ? const [Color(0xFFCDD4DA), Color(0xFFAEB8C0)]
                                    : const [Color(0xFF9ED47A), Color(0xFF6FB24A)],
                              ),
                              boxShadow: isLocked
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: const Color(0xFF507832).withValues(alpha: 0.22),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: isLocked
                              ? Opacity(
                                  opacity: 0.52,
                                  child: ColorFiltered(
                                    colorFilter: _kGrayscale,
                                    child: Image.asset(
                                      l.img,
                                      fit: BoxFit.contain,
                                      alignment: Alignment.bottomCenter,
                                      errorBuilder: (_, _, _) => const SizedBox(),
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  l.img,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.bottomCenter,
                                  errorBuilder: (_, _, _) => const SizedBox(),
                                ),
                        ),
                        if (isLocked) ...[
                          Positioned(
                            top: -22,
                            child: CustomPaint(
                              size: const Size(42, 38),
                              painter: _CastleSilhouette(),
                            ),
                          ),
                          Positioned(
                            right: -2,
                            bottom: h * 0.24,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x2628374A),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.lock, size: 17, color: Color(0xFF8A96A1)),
                            ),
                          ),
                        ],
                        if (isActive)
                          Positioned(
                            top: -42 * s,
                            child: Transform.translate(
                              offset: Offset(0, -7 * _wave(_bob.value) * s),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(18, 7, 18, 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEE7C2E),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0xFFC95F1A), offset: Offset(0, 5)),
                                    BoxShadow(
                                        color: Color(0x59C95F1A),
                                        blurRadius: 14,
                                        offset: Offset(0, 9)),
                                  ],
                                ),
                                child: Text(
                                  'START',
                                  style: GoogleFonts.baloo2(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: isLocked ? 0.7 : 1.0,
              child: Column(
                children: [
                  Text(
                    'LEVEL ${l.num}',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 1.4,
                      color: isLocked ? const Color(0xFF9AA6B0) : const Color(0xFFE07A2C),
                    ),
                  ),
                  Text(
                    l.name,
                    style: GoogleFonts.baloo2(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      height: 1.1,
                      color: isLocked ? const Color(0xFF8B97A1) : const Color(0xFF3A4F3A),
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

  double _wave(double t) => math.sin(t * math.pi);

  Widget _buildHeader(double s) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 12, 18, 14),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.7, 1.0],
            colors: [Color(0xEBFFFFFF), Color(0xC7FFFFFF), Color(0x00FFFFFF)],
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: widget.onSubjects,
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Color(0x2428384A), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: const Icon(Icons.chevron_left, color: Color(0xFF46586A), size: 26),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Sign Alphabet',
                    style: GoogleFonts.baloo2(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: const Color(0xFF33485A),
                    ),
                  ),
                  Text(
                    'Level 1 of 4 · Letters',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: const Color(0xFF7C93A4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 42,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: List.generate(4, (i) {
                  return Container(
                    margin: const EdgeInsets.only(left: 5),
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == 0 ? const Color(0xFFEE7C2E) : const Color(0xFFD3DDE4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SUBJECTS ────────────────────────────────────────────────────────────────

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({
    super.key,
    required this.onMathMap,
    required this.onMusicNotes,
    required this.onPronunciation,
    required this.onFlashcards,
  });

  final VoidCallback onMathMap;
  final VoidCallback onMusicNotes;
  final VoidCallback onPronunciation;
  final VoidCallback onFlashcards;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 64, 20, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Предметы',
            style: AppTextStyles.style(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          Text(
            'Выбери, чем хочешь заняться',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          _SubjectCard(
            onTap: onMathMap,
            icon: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A4C),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Icon(CupertinoIcons.textformat_123, color: Colors.white, size: 30),
            ),
            title: 'Математика',
            subtitle: 'Числа · счёт · задачи · 5 уровней',
            badge: '36 тем',
            badgeBg: const Color(0xFFFFF1E6),
            badgeColor: const Color(0xFFFF8A4C),
          ),
          const SizedBox(height: 14),
          _SubjectCard(
            onTap: onMusicNotes,
            icon: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const SweepGradient(
                  colors: [
                    Color(0xFFFF6B6B),
                    Color(0xFFFF9F45),
                    Color(0xFFFFC93C),
                    Color(0xFF3DD68C),
                    Color(0xFF19BBD6),
                    Color(0xFF4D8BFF),
                    Color(0xFF9C6BFF),
                    Color(0xFFFF6B6B),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(CupertinoIcons.music_note, color: AppColors.textPrimary, size: 20),
                ),
              ),
            ),
            title: 'Музыка через вибрацию',
            subtitle: 'Ноты через цвет и вибрацию',
            badge: '7 нот',
            badgeBg: const Color(0xFFF0F6FF),
            badgeColor: const Color(0xFF4D8BFF),
          ),
          const SizedBox(height: 14),
          _SubjectCard(
            onTap: onFlashcards,
            icon: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF6BCB77),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Icon(CupertinoIcons.rectangle_stack, color: Colors.white, size: 30),
            ),
            title: 'Карточки жестов',
            subtitle: 'Учи жесты в игровом формате',
            badge: '25 карточек',
            badgeBg: const Color(0xFFEAF8EC),
            badgeColor: const Color(0xFF6BCB77),
          ),
          const SizedBox(height: 26),
          Text(
            'ДОПОЛНИТЕЛЬНО · ПО ЖЕЛАНИЮ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textTertiary,
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
              child: const Icon(CupertinoIcons.chat_bubble_text, color: AppColors.primary, size: 30),
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
                color: AppColors.textTertiary,
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
              color: AppColors.textPrimary.withValues(alpha: 0.15),
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
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
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

// ─── LEVEL MAP PAINTERS ──────────────────────────────────────────────────────

class _LevelPathPainter extends CustomPainter {
  final double s;
  _LevelPathPainter(this.s);

  @override
  void paint(Canvas canvas, Size size) {
    final pts = _kLevels.map((l) => Offset(l.cx * s, l.cy * s)).toList();
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final a = pts[i - 1], b = pts[i];
      final c1 = Offset(a.dx, a.dy + (b.dy - a.dy) * 0.45);
      final c2 = Offset(b.dx, b.dy - (b.dy - a.dy) * 0.45);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, b.dx, b.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 17 * s
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.65),
    );

    final dotPaint = Paint()..color = const Color(0xFFF3A64F).withValues(alpha: 0.9);
    final r = 4.5 * s;
    final step = 22.0 * s;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        final tan = metric.getTangentForOffset(d);
        if (tan != null) canvas.drawCircle(tan.position, r, dotPaint);
        d += step;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LevelPathPainter old) => old.s != s;
}

class _CastleSilhouette extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 44, sy = size.height / 40;
    canvas.scale(sx, sy);
    final body = Paint()..color = const Color(0xFF7B8893);
    void rect(double x, double y, double w, double h, [double r = 0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
        body,
      );
    }
    rect(3, 15, 9, 24, 1.5);
    rect(32, 15, 9, 24, 1.5);
    rect(7, 22, 30, 17);
    rect(17, 8, 10, 31, 1.5);
    for (final x in [3.0, 9.0, 32.0, 38.0]) { rect(x, 13, 3, 3); }
    for (final x in [17.0, 24.0]) { rect(x, 6, 3, 3); }
    final flag = Path()
      ..moveTo(27, 9)
      ..lineTo(27, 1)
      ..lineTo(36, 5)
      ..close();
    canvas.drawPath(flag, Paint()..color = const Color(0xFF9AA6B0));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(19, 29, 6, 10),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF5A6671),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
