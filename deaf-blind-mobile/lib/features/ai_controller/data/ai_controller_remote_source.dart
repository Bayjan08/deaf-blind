import '../../../core/network/api_client.dart';

class AiControllerRemoteSource {
  AiControllerRemoteSource(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> getDashboard() async {
    final res = await _api.dio.get('/ai-controller/dashboard');
    return res.data as Map<String, dynamic>;
  }
}
