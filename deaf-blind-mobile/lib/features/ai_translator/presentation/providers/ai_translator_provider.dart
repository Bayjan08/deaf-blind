import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/ai_translator_remote_source.dart';

final _apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final _aiTranslatorSourceProvider = Provider<AiTranslatorRemoteSource>((ref) {
  return AiTranslatorRemoteSource(ref.watch(_apiClientProvider));
});

class AiTranslatorState {
  final bool isLoading;
  final String resultText;
  AiTranslatorState({this.isLoading = false, this.resultText = ''});
}

class AiTranslatorNotifier extends StateNotifier<AiTranslatorState> {
  AiTranslatorNotifier(this._source) : super(AiTranslatorState());
  final AiTranslatorRemoteSource _source;

  Future<void> translateSpeech(String audioFilePath) async {
    state = AiTranslatorState(isLoading: true, resultText: '');
    try {
      final res = await _source.speechToText(audioFilePath);
      state = AiTranslatorState(isLoading: false, resultText: res);
    } catch (e) {
      state = AiTranslatorState(isLoading: false, resultText: 'Error: $e');
    }
  }

  Future<void> translateGestures(List<String> gestures) async {
    state = AiTranslatorState(isLoading: true, resultText: '');
    try {
      final res = await _source.signToText(gestures);
      state = AiTranslatorState(isLoading: false, resultText: res);
    } catch (e) {
      state = AiTranslatorState(isLoading: false, resultText: 'Error: $e');
    }
  }
}

final aiTranslatorProvider = StateNotifierProvider<AiTranslatorNotifier, AiTranslatorState>((ref) {
  return AiTranslatorNotifier(ref.watch(_aiTranslatorSourceProvider));
});
