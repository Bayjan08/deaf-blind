/// §3 Note -> haptic pattern + color encoding.
class NotePattern {
  const NotePattern({
    required this.name,
    required this.colorHex,
    required this.vibrationHz,
    required this.durationMs,
    required this.intensity,
  });

  final String name;
  final int colorHex;
  final double vibrationHz;
  final int durationMs;
  final double intensity;
}
