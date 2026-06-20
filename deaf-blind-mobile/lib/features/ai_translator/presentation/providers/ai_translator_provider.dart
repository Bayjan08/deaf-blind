import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/api_client.dart';
import '../../data/ai_translator_remote_source.dart';

final _apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final _aiTranslatorSourceProvider = Provider<AiTranslatorRemoteSource>((ref) {
  return AiTranslatorRemoteSource(ref.watch(_apiClientProvider));
});

class AiTranslatorState {
  final bool isLoading;
  final String resultText;
  final List<int> animationIds;
  AiTranslatorState({
    this.isLoading = false,
    this.resultText = '',
    this.animationIds = const [],
  });
}

class AiTranslatorNotifier extends StateNotifier<AiTranslatorState> {
  AiTranslatorNotifier(this._source) : super(AiTranslatorState());
  final AiTranslatorRemoteSource _source;

  Future<void> translateSpeech(String audioFilePath, {bool andShowGestures = false}) async {
    state = AiTranslatorState(isLoading: true, resultText: '', animationIds: []);
    try {
      final res = await _source.speechToText(audioFilePath);
      if (andShowGestures) {
        final ids = await _source.textToSign(res);
        state = AiTranslatorState(isLoading: false, resultText: res, animationIds: ids);
      } else {
        state = AiTranslatorState(isLoading: false, resultText: res, animationIds: []);
      }
    } catch (e) {
      state = AiTranslatorState(isLoading: false, resultText: 'Error: $e', animationIds: []);
    }
  }

  Future<void> translateGestures(List<String> gestures) async {
    state = AiTranslatorState(isLoading: true, resultText: '', animationIds: []);
    try {
      final res = await _source.signToText(gestures);
      state = AiTranslatorState(isLoading: false, resultText: res, animationIds: []);
    } catch (e) {
      state = AiTranslatorState(isLoading: false, resultText: 'Error: $e', animationIds: []);
    }
  }

  Future<void> translateTextToSign(String text) async {
    state = AiTranslatorState(isLoading: true, resultText: '', animationIds: []);
    try {
      final ids = await _source.textToSign(text);
      state = AiTranslatorState(isLoading: false, resultText: text, animationIds: ids);
    } catch (e) {
      state = AiTranslatorState(isLoading: false, resultText: 'Error: $e', animationIds: []);
    }
  }
}

final aiTranslatorProvider = StateNotifierProvider<AiTranslatorNotifier, AiTranslatorState>((ref) {
  return AiTranslatorNotifier(ref.watch(_aiTranslatorSourceProvider));
});
