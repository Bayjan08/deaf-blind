import 'auth_remote_source.dart';

/// Coordinates auth state + remote source.
class AuthRepository {
  AuthRepository(this._remote);
  final AuthRemoteSource _remote;

  Future<Map<String, dynamic>> login(String idToken) => _remote.login(idToken);
}
