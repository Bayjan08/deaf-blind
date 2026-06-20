import '../domain/models/articulation_lesson.dart';
import 'pronunciation_remote_source.dart';

/// Result of a submitted attempt (server is authoritative for storage).
class AttemptFeedback {
  AttemptFeedback({
    required this.feedbackText,
    required this.cues,
    this.audioUrl,
    this.aiFeedbackText,
  });
  final String feedbackText;
  final List<String> cues;
  final String? audioUrl;
  final String? aiFeedbackText;

  factory AttemptFeedback.fromJson(Map<String, dynamic> json) => AttemptFeedback(
        feedbackText: json['feedback_text'] as String? ?? '',
        cues: (json['cues'] as List? ?? const [])
            .map((e) => e as String)
            .toList(),
        audioUrl: json['audio_url'] as String?,
        aiFeedbackText: json['ai_feedback_text'] as String?,
      );
}

class PronunciationRepository {
  PronunciationRepository(this._remote);
  final PronunciationRemoteSource _remote;

  Future<List<({String letter, String viseme, String example})>> letters() async {
    final raw = await _remote.getLetters();
    return raw
        .map((e) => (
              letter: e['letter'] as String,
              viseme: e['viseme'] as String,
              example: e['example'] as String? ?? '',
            ))
        .toList();
  }

  Future<ArticulationLesson> lesson(String key) async =>
      ArticulationLesson.fromJson(await _remote.getLesson(key));

  Future<AttemptFeedback> submitAttempt({
    required String targetViseme,
    required Map<String, double> metrics,
    String? audioPath,
  }) async {
    final json = await _remote.submitAttempt(
      targetViseme: targetViseme,
      metrics: metrics,
      audioPath: audioPath,
    );
    return AttemptFeedback.fromJson(json);
  }
}
