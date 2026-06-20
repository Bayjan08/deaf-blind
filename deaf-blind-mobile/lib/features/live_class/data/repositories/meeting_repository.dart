import '../../../../config/env.dart';
import '../../domain/models/meeting.dart';
import '../cache/recent_meetings_cache.dart';
import '../datasources/meeting_remote_source.dart';

/// Coordinates meeting REST calls, recent-meeting cache, and LiveKit URL resolution.
class MeetingRepository {
  MeetingRepository(this._remote, [RecentMeetingsCache? cache])
      : _cache = cache ?? RecentMeetingsCache();

  final MeetingRemoteSource _remote;
  final RecentMeetingsCache _cache;

  Future<void> ensureAuthenticated() => _remote.ensureDevAuth();

  Future<MeetingConnection> createMeeting({String? title}) async {
    final data = await _remote.createMeeting(title: title);
    final connection = _parseConnection(data);
    await _cache.remember(connection.meeting);
    return connection;
  }

  Future<MeetingConnection> joinMeeting({String? meetingId, String? code}) async {
    final data = await _remote.joinMeeting(meetingId: meetingId, code: code);
    final connection = _parseConnection(data);
    await _cache.remember(connection.meeting);
    return connection;
  }

  Future<Meeting> leaveMeeting(String meetingId) async {
    final data = await _remote.leaveMeeting(meetingId);
    return Meeting.fromJson(data);
  }

  Future<Meeting> endMeeting(String meetingId) async {
    final data = await _remote.endMeeting(meetingId);
    return Meeting.fromJson(data);
  }

  Future<List<Meeting>> loadRecentMeetings() async {
    try {
      final remote = await _remote.recentMeetings();
      final meetings = remote.map(Meeting.fromJson).toList();
      await _cache.save(meetings);
      return meetings;
    } catch (_) {
      return _cache.load();
    }
  }

  MeetingConnection _parseConnection(Map<String, dynamic> data) {
    final connection = MeetingConnection.fromJson(data);
    return MeetingConnection(
      meeting: connection.meeting,
      token: connection.token,
      livekitUrl: Env.resolveLivekitUrl(connection.livekitUrl),
      isHost: connection.isHost,
    );
  }
}
