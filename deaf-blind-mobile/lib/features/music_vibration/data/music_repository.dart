import 'music_remote_source.dart';

/// §3 Coordinates notes data + core/haptics playback.
class MusicRepository {
  MusicRepository(this._remote);
  final MusicRemoteSource _remote;

  Future<List<dynamic>> notes() => _remote.getNotes();
}
