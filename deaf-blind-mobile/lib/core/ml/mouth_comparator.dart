import 'dart:math' as math;

import 'face_landmark_models.dart';

/// Result of comparing a mouth shape to a target viseme.
class MouthComparison {
  const MouthComparison({required this.cues, required this.coarseScore});

  /// Directional cues ("Open your mouth a little wider"). Never a percentage.
  final List<String> cues;

  /// Internal 0..1 closeness, used for the progress ring only.
  final double coarseScore;
}

/// On-device mirror of the backend `visemes.score` logic, so the learner gets
/// instant directional feedback. The backend remains authoritative for storage.
///
/// `ranges` maps a metric name to `[min, max]` (as returned by the lesson API),
/// keeping the backend the single source of truth for the thresholds.
class MouthComparator {
  const MouthComparator();

  static const Map<String, List<String>> _cues = {
    // (cue when value below range, cue when above range)
    'lipGap': ['Open your mouth a little wider', 'Close your mouth a little'],
    'mouthWidth': [
      'Spread your lips wider, like a small smile',
      'Bring your lip corners inward',
    ],
    'rounding': [
      'Round your lips more — make them small and circular',
      'Spread your lips wider, like a smile',
    ],
    'jawOpen': ['Drop your jaw more', 'Relax your jaw a little'],
    'lipClosure': ['Press your lips together', 'Part your lips a little'],
  };

  MouthComparison compare(MouthMetrics m, Map<String, List<double>> ranges) {
    final metrics = m.toJson();
    final scored = <({double dist, String cue})>[];
    final closeness = <double>[];

    ranges.forEach((metric, range) {
      final value = metrics[metric];
      final cuePair = _cues[metric];
      if (value == null || range.length < 2 || cuePair == null) return;
      final lo = range[0];
      final hi = range[1];
      final width = math.max(hi - lo, 1e-6);
      if (value < lo) {
        final dist = (lo - value) / width;
        scored.add((dist: dist, cue: cuePair[0]));
        closeness.add(math.max(0.0, 1.0 - dist));
      } else if (value > hi) {
        final dist = (value - hi) / width;
        scored.add((dist: dist, cue: cuePair[1]));
        closeness.add(math.max(0.0, 1.0 - dist));
      } else {
        closeness.add(1.0);
      }
    });

    final coarse = closeness.isEmpty
        ? 0.0
        : closeness.reduce((a, b) => a + b) / closeness.length;

    scored.sort((a, b) => b.dist.compareTo(a.dist));
    final cues = scored.take(2).map((e) => e.cue).toList();

    return MouthComparison(cues: cues, coarseScore: coarse);
  }
}
