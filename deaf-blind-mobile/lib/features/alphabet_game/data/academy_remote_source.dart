import '../../../core/network/api_client.dart';

/// Calls backend /academy (levels, lessons, gesture-check, exam, pets).
class AcademyRemoteSource {
  AcademyRemoteSource(this._api);
  final ApiClient _api;

  Future<List<dynamic>> getLevels() async {
    final res = await _api.dio.get('/academy/levels');
    return res.data as List<dynamic>;
  }
}
