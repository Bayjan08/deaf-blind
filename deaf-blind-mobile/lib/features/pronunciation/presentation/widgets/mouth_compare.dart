import 'package:flutter/material.dart';

import '../../../../core/ml/face_landmark_models.dart';
import '../../../../core/theme/design_colors.dart';

/// §4.4 Side-by-side stylized mouths: the target shape vs the learner's best
/// attempt. Both are drawn the same way (from normalized metrics) so they're
/// directly comparable. Side-by-side is primary; we don't overlay differently
/// shaped faces.
class MouthCompare extends StatelessWidget {
  const MouthCompare({super.key, required this.target, this.attempt});

  /// Target metric midpoints (lipGap, mouthWidth) from the lesson.
  final Map<String, double> target;
  final MouthMetrics? attempt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MouthCard(
            label: 'Target',
            lipGap: target['lipGap'] ?? 0.1,
            mouthWidth: target['mouthWidth'] ?? 0.45,
            accent: DesignColors.green,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _MouthCard(
            label: 'You',
            lipGap: attempt?.lipGap ?? 0.1,
            mouthWidth: attempt?.mouthWidth ?? 0.45,
            accent: DesignColors.purple,
            empty: attempt == null,
          ),
        ),
      ],
    );
  }
}

class _MouthCard extends StatelessWidget {
  const _MouthCard({
    required this.label,
    required this.lipGap,
    required this.mouthWidth,
    required this.accent,
    this.empty = false,
  });

  final String label;
  final double lipGap;
  final double mouthWidth;
  final Color accent;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: 0.4), width: 2),
            ),
            child: empty
                ? Center(
                    child: Text(
                      '—',
                      style: TextStyle(
                        color: DesignColors.textDim,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                : CustomPaint(
                    painter: MouthPainter(
                      lipGap: lipGap,
                      mouthWidth: mouthWidth,
                      color: accent,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: accent,
          ),
        ),
      ],
    );
  }
}

/// Draws a simple stylized mouth from normalized metrics (interocular units).
class MouthPainter extends CustomPainter {
  MouthPainter({
    required this.lipGap,
    required this.mouthWidth,
    required this.color,
  });

  final double lipGap;
  final double mouthWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width * 0.85; // interocular ~ canvas width
    final halfW = (mouthWidth.clamp(0.15, 1.0) / 2) * unit;
    final gap = (lipGap.clamp(0.0, 0.7)) * unit;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final curve = halfW * 0.6;

    final left = Offset(cx - halfW, cy);
    final right = Offset(cx + halfW, cy);

    final outline = Path()
      ..moveTo(left.dx, left.dy)
      ..quadraticBezierTo(cx, cy - gap / 2 - curve * 0.4, right.dx, right.dy)
      ..quadraticBezierTo(cx, cy + gap / 2 + curve * 0.4, left.dx, left.dy)
      ..close();

    canvas.drawPath(outline, Paint()..color = const Color(0xFF3A2230));
    canvas.drawPath(
      outline,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant MouthPainter old) =>
      old.lipGap != lipGap || old.mouthWidth != mouthWidth || old.color != color;
}
