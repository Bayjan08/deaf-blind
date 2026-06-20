import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/mappers/meeting_error_mapper.dart';
import '../../domain/models/meeting.dart';
import '../providers/meeting_providers.dart';
import '../widgets/lobby/lobby_header.dart';
import '../widgets/lobby/lobby_scheduled_lesson_card.dart';
import '../widgets/lobby/recent_meetings_list.dart';

/// Lobby for the «Класс» tab — create or join without auto-starting video.
class MeetingLobbyScreen extends ConsumerStatefulWidget {
  const MeetingLobbyScreen({super.key, required this.onEnterMeeting});

  final ValueChanged<MeetingConnection> onEnterMeeting;

  @override
  ConsumerState<MeetingLobbyScreen> createState() => _MeetingLobbyScreenState();
}

class _MeetingLobbyScreenState extends ConsumerState<MeetingLobbyScreen> {
  bool _loading = false;
  String? _error;
  List<Meeting> _recent = const [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _run(() async {
      final repo = ref.read(meetingRepositoryProvider);
      await repo.ensureAuthenticated();
      _recent = await repo.loadRecentMeetings();
    }, serverError: true);
  }

  Future<void> _createMeeting() async {
    await _run(() async {
      final connection =
          await ref.read(meetingRepositoryProvider).createMeeting(title: 'Урок · Класс');
      if (mounted) widget.onEnterMeeting(connection);
    });
  }

  Future<void> _rejoin(Meeting meeting) async {
    if (!meeting.isActive) {
      setState(() => _error = 'Встреча уже завершена');
      return;
    }
    await _run(() async {
      final connection =
          await ref.read(meetingRepositoryProvider).joinMeeting(meetingId: meeting.id);
      if (mounted) widget.onEnterMeeting(connection);
    });
  }

  Future<void> _run(Future<void> Function() action, {bool serverError = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = serverError
              ? 'Не удалось подключиться к серверу: $e'
              : MeetingErrorMapper.from(e);
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LobbyHeader(),
          const SizedBox(height: 24),
          LobbyScheduledLessonCard(
            onJoin: _createMeeting,
            loading: _loading,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Недавние',
            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: RecentMeetingsList(
              meetings: _recent,
              loading: _loading,
              onRejoin: _rejoin,
            ),
          ),
        ],
      ),
    );
  }
}
