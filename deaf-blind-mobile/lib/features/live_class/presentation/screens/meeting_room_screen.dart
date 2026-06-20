import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_colors.dart';
import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_room_phase.dart';
import '../providers/meeting_providers.dart';
import '../widgets/room/meeting_controls.dart';
import '../widgets/room/meeting_room_header.dart';
import '../widgets/room/meeting_room_states.dart';
import '../widgets/room/meeting_video_stage.dart';

/// Full-screen LiveKit room — entered only after lobby create/join.
class MeetingRoomScreen extends ConsumerStatefulWidget {
  const MeetingRoomScreen({
    super.key,
    required this.connection,
    required this.onExit,
  });

  final MeetingConnection connection;
  final VoidCallback onExit;

  @override
  ConsumerState<MeetingRoomScreen> createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends ConsumerState<MeetingRoomScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(meetingRoomControllerProvider.notifier).connect(widget.connection);
    });
  }

  Future<void> _leave() async {
    final controller = ref.read(meetingRoomControllerProvider);
    try {
      await ref.read(meetingRepositoryProvider).leaveMeeting(widget.connection.meeting.id);
    } catch (_) {}
    await controller.disconnect();
    if (mounted) widget.onExit();
  }

  Future<void> _endMeeting() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Завершить урок?'),
        content: const Text('Все участники будут отключены.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Завершить')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(meetingRepositoryProvider).endMeeting(widget.connection.meeting.id);
    } catch (_) {}
    await ref.read(meetingRoomControllerProvider).disconnect();
    if (mounted) widget.onExit();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(meetingRoomControllerProvider);
    final meeting = widget.connection.meeting;

    if (controller.phase == MeetingRoomPhase.connecting ||
        controller.phase == MeetingRoomPhase.reconnecting) {
      return MeetingRoomLoading(
        message: controller.phase == MeetingRoomPhase.reconnecting
            ? 'Переподключение…'
            : 'Подключение к классу…',
      );
    }

    if (controller.phase == MeetingRoomPhase.error ||
        controller.phase == MeetingRoomPhase.disconnected) {
      return MeetingRoomError(
        message: controller.errorMessage ??
            (controller.phase == MeetingRoomPhase.disconnected
                ? 'Встреча завершена'
                : 'Ошибка подключения'),
        onBack: widget.onExit,
      );
    }

    final room = controller.room;
    final remotes = controller.remoteParticipants;
    final oneToOne = remotes.length <= 1;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.5),
              radius: 1.2,
              colors: [Color(0xFF2E2B4D), DesignColors.liveBg],
            ),
          ),
        ),
        MeetingVideoStage(
          room: room,
          remotes: remotes,
          activeSpeakerIdentity: controller.activeSpeakerIdentity,
        ),
        Positioned(
          top: 56,
          left: 20,
          right: 20,
          child: MeetingRoomHeader(
            title: meeting.title,
            code: meeting.code,
            participantCount: controller.participantCount,
            quality: controller.connectionQuality,
            onLeave: _leave,
          ),
        ),
        if (oneToOne && remotes.isNotEmpty && room?.localParticipant != null)
          Positioned(
            bottom: 120,
            right: 20,
            child: LocalPreviewTile(participant: room!.localParticipant!),
          ),
        if (controller.cameraStatusHint != null)
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                controller.cameraStatusHint!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 36,
          left: 0,
          right: 0,
          child: MeetingControlsBar(
            controller: controller,
            onLeave: _leave,
            onEnd: _endMeeting,
            isHost: widget.connection.isHost,
          ),
        ),
      ],
    );
  }
}
