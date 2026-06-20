import '../../../core/network/api_client.dart';
class VideoRemoteSource {
  VideoRemoteSource(this._api);
  final ApiClient _api;
  Future<Map<String, dynamic>> createJob(String sourceUrl) async => throw UnimplementedError();
}
