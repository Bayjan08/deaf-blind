import '../../../core/network/api_client.dart';

/// Calls the backend /auth endpoints (Firebase token login).
class AuthRemoteSource {
  AuthRemoteSource(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> login(String idToken) async {
    final res = await _api.dio.post('/auth/login', data: {'id_token': idToken});
    return res.data as Map<String, dynamic>;
  }
}
