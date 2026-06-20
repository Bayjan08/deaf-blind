import '../../../core/network/api_client.dart';

class MusicRemoteSource {
  MusicRemoteSource(this._api);
  final ApiClient _api;
  Future<List<dynamic>> getNotes() async => throw UnimplementedError();
}
