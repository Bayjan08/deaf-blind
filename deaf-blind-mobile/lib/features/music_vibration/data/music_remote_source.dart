import '../../../core/network/api_client.dart';

class MusicRemoteSource {
  MusicRemoteSource(this._api);
  final ApiClient _api;

  Future<List<dynamic>> getNotes() async {
    final res = await _api.dio.get('/music/notes');
    return res.data as List<dynamic>;
  }
}
