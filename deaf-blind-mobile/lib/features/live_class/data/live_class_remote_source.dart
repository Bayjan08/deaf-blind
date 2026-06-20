import '../../../core/network/api_client.dart';

/// REST: create/join session. Real-time relay is over Socket.IO.
class LiveClassRemoteSource {
  LiveClassRemoteSource(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> createSession() async {
    final res = await _api.dio.post('/live-class/sessions');
    return res.data as Map<String, dynamic>;
  }
}
