import 'video_remote_source.dart';

/// §6 Coordinates upload + job polling + core/translation playback.
class VideoRepository {
  VideoRepository(this._remote);
  final VideoRemoteSource _remote;

  Future<Map<String, dynamic>> createJob(String url) => _remote.createJob(url);
}
