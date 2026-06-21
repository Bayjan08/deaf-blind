import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class VoiceToSignResult {
  VoiceToSignResult({required this.text, required this.words});
  final String text;
  final List<String> words;
}

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

  /// Whole spoken sentence -> (recognized text, ordered sign-gesture words).
  ///
  /// One backend round trip: Gemini transcribes the audio and glosses it into
  /// the known sign-asset vocabulary in the same call, so the avatar can play
  /// a meaningful gesture-by-gesture flow for the full sentence.
  Future<VoiceToSignResult> voiceToSign(String audioFilePath) async {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(audioFilePath),
    });
    final res = await _api.dio.post('/translation/ai/voice-to-sign', data: formData);
    return VoiceToSignResult(
      text: res.data['text'] as String,
      words: (res.data['words'] as List).cast<String>(),
    );
  }

  Future<String> signToText(List<String> gestures) async {
    final res = await _api.dio.post('/translation/sign-to-text', data: {
      'gestures': gestures,
    });
    return res.data['text'] as String;
  }

  Future<List<int>> textToSign(String text) async {
    final res = await _api.dio.post('/translation/text-to-sign', data: {
      'text': text,
      'language': 'ru',
    });
    return (res.data['avatar_animation_ids'] as List).cast<int>();
  }
}
