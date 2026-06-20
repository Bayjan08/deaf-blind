import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class PronunciationRemoteSource {
  PronunciationRemoteSource(this._api);
  final ApiClient _api;

  Future<List<dynamic>> getLetters() async {
    final res = await _api.dio.get('/pronunciation/letters');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getLesson(String key) async {
    final res = await _api.dio.get('/pronunciation/lessons/$key');
    return res.data as Map<String, dynamic>;
  }

  /// Submits *derived mouth metrics only* plus an optional audio clip (stored
  /// for a teacher to review). The camera image never leaves the device.
  Future<Map<String, dynamic>> submitAttempt({
    required String targetViseme,
    required Map<String, double> metrics,
    String? audioPath,
  }) async {
    final form = FormData.fromMap({
      'target_viseme': targetViseme,
      'metrics': jsonEncode(metrics),
      if (audioPath != null)
        'audio': await MultipartFile.fromFile(audioPath, filename: 'attempt.wav'),
    });
    final res = await _api.dio.post('/pronunciation/attempt', data: form);
    return res.data as Map<String, dynamic>;
  }
}
