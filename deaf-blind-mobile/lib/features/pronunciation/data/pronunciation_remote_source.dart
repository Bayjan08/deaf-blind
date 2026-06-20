import '../../../core/network/api_client.dart';

class PronunciationRemoteSource {
  PronunciationRemoteSource(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> getLesson(String key) async {
    final res = await _api.dio.get('/pronunciation/lessons/$key');
    return res.data as Map<String, dynamic>;
  }

  /// Submits *derived mouth metrics only* — never the camera image.
  Future<Map<String, dynamic>> submitAttempt({
    required String targetViseme,
    required Map<String, double> metrics,
  }) async {
    final res = await _api.dio.post(
      '/pronunciation/attempt',
      data: {'target_viseme': targetViseme, 'metrics': metrics},
    );
    return res.data as Map<String, dynamic>;
  }
}
