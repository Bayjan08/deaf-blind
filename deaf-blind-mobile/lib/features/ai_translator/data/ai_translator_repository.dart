import 'ai_translator_remote_source.dart';

/// §7 Thin wrapper reusing core/translation + core/ml.
class AiTranslatorRepository {
  AiTranslatorRepository(this._remote);
  final AiTranslatorRemoteSource _remote;

  Future<Map<String, dynamic>> translate(Map<String, dynamic> body) => _remote.translate(body);
}
