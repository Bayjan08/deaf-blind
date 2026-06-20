import '../../../core/network/api_client.dart';

class PronunciationRemoteSource {
  PronunciationRemoteSource(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> getLesson(String phoneme) async {
    final res = await _api.dio.get('/pronunciation/lessons/$phoneme');
    return res.data as Map<String, dynamic>;
  }
}
