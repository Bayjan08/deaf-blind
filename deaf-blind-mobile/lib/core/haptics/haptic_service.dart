import 'note_patterns.dart';

/// §3 Plays a note's vibration pattern (uses the `vibration` package). Stub.
abstract class HapticService {
  Future<void> playNote(NotePattern pattern);
}
