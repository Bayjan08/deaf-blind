import '../../../../core/haptics/note_patterns.dart';

/// §4 A target viseme (visually-distinct mouth shape) + its reference data.
///
/// Pivoted from audio articulation to camera mouth-shape: instead of a waveform
/// reference we carry the target metric ranges (for the vector reference mouth
/// and on-device scoring) plus the haptic stress cue.
class ArticulationLesson {
  ArticulationLesson({
    required this.viseme,
    required this.word,
    required this.phoneme,
    required this.instructions,
    required this.targetMetrics,
    required this.stressPattern,
  });

  final String viseme;
  final String word;
  final String phoneme;
  final String instructions;

  /// metric name -> [min, max] (normalized by interocular distance).
  final Map<String, List<double>> targetMetrics;

  /// Stress/rhythm cue played before each attempt (reuses [NotePattern]).
  final List<NotePattern> stressPattern;

  factory ArticulationLesson.fromJson(Map<String, dynamic> json) {
    final rawMetrics = (json['target_metrics'] as Map<String, dynamic>? ?? {});
    final metrics = rawMetrics.map(
      (k, v) => MapEntry(
        k,
        (v as List).map((e) => (e as num).toDouble()).toList(),
      ),
    );
    final beats = (json['stress_pattern'] as List? ?? const [])
        .map((b) => _beatFromJson(b as Map<String, dynamic>))
        .toList();
    return ArticulationLesson(
      viseme: json['viseme'] as String,
      word: json['word'] as String? ?? '',
      phoneme: json['phoneme'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      targetMetrics: metrics,
      stressPattern: beats,
    );
  }

  /// Midpoint of each target range — used to draw the reference mouth shape.
  Map<String, double> get targetMidpoints => targetMetrics.map(
        (k, v) => MapEntry(k, v.length >= 2 ? (v[0] + v[1]) / 2 : 0.0),
      );
}

NotePattern _beatFromJson(Map<String, dynamic> b) => NotePattern(
      name: b['name'] as String? ?? 'beat',
      colorHex: (b['colorHex'] as num?)?.toInt() ?? 0xFF6C5CE7,
      vibrationHz: (b['vibrationHz'] as num?)?.toDouble() ?? 150.0,
      durationMs: (b['durationMs'] as num?)?.toInt() ?? 200,
      intensity: (b['intensity'] as num?)?.toDouble() ?? 0.6,
    );
