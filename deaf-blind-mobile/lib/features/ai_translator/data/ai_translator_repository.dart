import 'ai_translator_remote_source.dart';

/// §7 Thin wrapper reusing core/translation + core/ml.
class AiTranslatorRepository {
  AiTranslatorRepository(this._remote);
  final AiTranslatorRemoteSource _remote;

  Future<String> speechToText(String audioFilePath) => _remote.speechToText(audioFilePath);
  Future<String> signToText(List<String> gestures) => _remote.signToText(gestures);
  Future<List<int>> textToSign(String text) => _remote.textToSign(text);
}
