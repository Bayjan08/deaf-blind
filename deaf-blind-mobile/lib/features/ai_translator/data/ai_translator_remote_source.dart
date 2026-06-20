import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AiTranslatorRemoteSource {
  AiTranslatorRemoteSource(this._api);
  final ApiClient _api;

  Future<String> speechToText(String audioFilePath) async {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(audioFilePath),
    });
    final res = await _api.dio.post('/translation/speech-to-text', data: formData);
    return res.data['text'] as String;
  }

  Future<String> signToText(List<String> gestures) async {
    final res = await _api.dio.post('/translation/sign-to-text', data: {
      'gestures': gestures,
    });
    return res.data['text'] as String;
  }
}
