import 'pronunciation_remote_source.dart';

class PronunciationRepository {
  PronunciationRepository(this._remote);
  final PronunciationRemoteSource _remote;

  Future<Map<String, dynamic>> lesson(String phoneme) => _remote.getLesson(phoneme);
}
