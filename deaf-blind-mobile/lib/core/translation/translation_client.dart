import '../network/api_client.dart';

/// §1/§6/§7 KEYSTONE: single client to the backend translation engine.
/// Reused by live_class, video_translation, and ai_translator features.
class TranslationClient {
  TranslationClient(this._api);
  final ApiClient _api;

  /// Text -> ordered avatar animation ids.
  Future<List<int>> textToSign(String text, {String language = 'ru'}) async {
    final res = await _api.dio.post('/translation/text-to-sign',
        data: {'text': text, 'language': language});
    return (res.data['avatar_animation_ids'] as List).cast<int>();
  }

  /// Recognized gesture labels -> text.
  Future<String> signToText(List<String> labels) async {
    final res = await _api.dio.post('/translation/sign-to-text', data: {'labels': labels});
    return res.data['text'] as String;
  }
}
