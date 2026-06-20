import '../../../core/network/api_client.dart';

class VideoRemoteSource {
  VideoRemoteSource(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> createJob(String sourceUrl) async {
    final res = await _api.dio.post('/video-translation/jobs', data: {'source_url': sourceUrl});
    return res.data as Map<String, dynamic>;
  }
}
