import '../domain/models/articulation_lesson.dart';
import 'pronunciation_remote_source.dart';

/// Result of a submitted attempt (server is authoritative for storage).
class AttemptFeedback {
  AttemptFeedback({required this.feedbackText, required this.cues});
  final String feedbackText;
  final List<String> cues;

  factory AttemptFeedback.fromJson(Map<String, dynamic> json) => AttemptFeedback(
        feedbackText: json['feedback_text'] as String? ?? '',
        cues: (json['cues'] as List? ?? const [])
            .map((e) => e as String)
            .toList(),
      );
}

class PronunciationRepository {
  PronunciationRepository(this._remote);
  final PronunciationRemoteSource _remote;

  Future<ArticulationLesson> lesson(String key) async =>
      ArticulationLesson.fromJson(await _remote.getLesson(key));

  Future<AttemptFeedback> submitAttempt({
    required String targetViseme,
    required Map<String, double> metrics,
  }) async {
    final json = await _remote.submitAttempt(
      targetViseme: targetViseme,
      metrics: metrics,
    );
    return AttemptFeedback.fromJson(json);
  }
}
