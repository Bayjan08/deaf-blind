import '../../../../config/env.dart';
import '../../../../core/network/api_client.dart';

/// REST calls for video meetings + dev JWT bootstrap.
class MeetingRemoteSource {
  MeetingRemoteSource(this._api);

  final ApiClient _api;

  Future<void> ensureDevAuth() async {
    final res = await _api.post<Map<String, dynamic>>(
      '/auth/dev-token',
      data: {
        'user_id': Env.userId,
        'display_name': Env.displayName,
      },
    );
    final token = res.data?['access_token'] as String?;
    if (token == null) {
      throw StateError('Dev auth failed: missing access_token');
    }
    _api.setAuthToken(token);
  }

  Future<Map<String, dynamic>> createMeeting({String? title}) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/meetings/create',
      data: {'title': title ?? 'Новый урок'},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> joinMeeting({String? meetingId, String? code}) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/meetings/join',
      data: {
        if (meetingId != null) 'meeting_id': meetingId,
        if (code != null) 'code': code,
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> leaveMeeting(String meetingId) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/meetings/leave',
      data: {'meeting_id': meetingId},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> endMeeting(String meetingId) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/meetings/end',
      data: {'meeting_id': meetingId},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<Map<String, dynamic>>> recentMeetings() async {
    final res = await _api.get<List<dynamic>>('/meetings/recent');
    return (res.data ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}
