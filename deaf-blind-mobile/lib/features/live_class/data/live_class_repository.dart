import 'live_class_remote_source.dart';

/// §1 Coordinates session REST + the Socket.IO caption/label stream.
class LiveClassRepository {
  LiveClassRepository(this._remote);
  final LiveClassRemoteSource _remote;

  Future<Map<String, dynamic>> createSession() => _remote.createSession();
}
