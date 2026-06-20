import '../../../core/network/api_client.dart';
class AiControllerRemoteSource {
  AiControllerRemoteSource(this._api);
  final ApiClient _api;
  Future<Map<String, dynamic>> getDashboard() async => throw UnimplementedError();
}
