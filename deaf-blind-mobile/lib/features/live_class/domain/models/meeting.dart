/// Video meeting domain models.
class Meeting {
  const Meeting({
    required this.id,
    required this.title,
    required this.hostId,
    required this.code,
    required this.status,
    required this.createdAt,
    this.endedAt,
    this.participantCount = 0,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] as String,
      title: json['title'] as String,
      hostId: json['host_id'] as String,
      code: json['code'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      participantCount: (json['participant_count'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String title;
  final String hostId;
  final String code;
  final String status;
  final DateTime createdAt;
  final DateTime? endedAt;
  final int participantCount;

  bool get isActive => status == 'active';

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'host_id': hostId,
        'code': code,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
        'participant_count': participantCount,
      };
}

/// Everything needed to connect a LiveKit room after create/join API calls.
class MeetingConnection {
  const MeetingConnection({
    required this.meeting,
    required this.token,
    required this.livekitUrl,
    required this.isHost,
  });

  factory MeetingConnection.fromJson(Map<String, dynamic> json) {
    return MeetingConnection(
      meeting: Meeting.fromJson(json['meeting'] as Map<String, dynamic>),
      token: json['token'] as String,
      livekitUrl: json['livekit_url'] as String,
      isHost: json['is_host'] as bool? ?? false,
    );
  }

  final Meeting meeting;
  final String token;
  final String livekitUrl;
  final bool isHost;
}
