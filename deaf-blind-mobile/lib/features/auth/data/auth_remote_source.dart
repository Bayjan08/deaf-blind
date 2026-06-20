import '../../../core/network/api_client.dart';

/// Calls the backend /auth endpoints (Firebase token login).
class AuthRemoteSource {
  AuthRemoteSource(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> login(String idToken) async => throw UnimplementedError();
}
