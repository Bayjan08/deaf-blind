import '../../../core/network/api_client.dart';

class AiTranslatorRemoteSource {
  AiTranslatorRemoteSource(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> translate(Map<String, dynamic> body) async {
    final res = await _api.dio.post('/ai-translator/translate', data: body);
    return res.data as Map<String, dynamic>;
  }
}
