import '../network/api_client.dart';

/// §1/§6/§7 KEYSTONE: single client to the backend translation engine.
/// Reused by live_class, video_translation, and ai_translator features.
class TranslationClient {
  TranslationClient(this._api);
  final ApiClient _api;

  /// Text -> ordered avatar animation ids. Stub.
  Future<List<int>> textToSign(String text, {String language = 'ru'}) async {
    throw UnimplementedError();
  }

  /// Recognized gesture labels -> text. Stub.
  Future<String> signToText(List<String> labels) async {
    throw UnimplementedError();
  }
}
