import 'package:vibration/vibration.dart';

import 'note_patterns.dart';

/// §3 Plays note vibration patterns (uses the `vibration` package).
///
/// Reused as-is by the pronunciation feature for the stress/rhythm cue: a word's
/// stress pattern is just a `List<NotePattern>` with a stronger [NotePattern.intensity]
/// on the stressed syllable.
abstract class HapticService {
  Future<void> playNote(NotePattern pattern);

  /// Plays a sequence of patterns back-to-back (e.g. a syllable stress cue).
  Future<void> playPattern(List<NotePattern> patterns);
}

class VibrationHapticService implements HapticService {
  const VibrationHapticService();

  @override
  Future<void> playNote(NotePattern pattern) async {
    if (await Vibration.hasVibrator() != true) return;
    if (await Vibration.hasAmplitudeControl() == true) {
      await Vibration.vibrate(
        duration: pattern.durationMs,
        amplitude: (pattern.intensity.clamp(0.0, 1.0) * 255).round().clamp(1, 255),
      );
    } else {
      await Vibration.vibrate(duration: pattern.durationMs);
    }
    // Let the pulse finish before returning so callers can sequence beats.
    await Future<void>.delayed(Duration(milliseconds: pattern.durationMs));
  }

  @override
  Future<void> playPattern(List<NotePattern> patterns) async {
    for (final p in patterns) {
      await playNote(p);
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
  }
}
