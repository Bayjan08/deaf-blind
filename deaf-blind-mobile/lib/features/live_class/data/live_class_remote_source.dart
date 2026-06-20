import '../../../core/network/api_client.dart';

/// REST: create/join session. Real-time relay is over Socket.IO.
class LiveClassRemoteSource {
  LiveClassRemoteSource(this._api);
  final ApiClient _api;
  Future<Map<String, dynamic>> createSession() async => throw UnimplementedError();
}
