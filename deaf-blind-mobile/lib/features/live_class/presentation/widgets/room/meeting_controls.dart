import 'package:flutter/material.dart';

import '../../../../../core/theme/design_colors.dart';
import '../../../data/livekit/meeting_room_controller.dart';

/// Bottom control bar for an active video meeting.
class MeetingControlsBar extends StatelessWidget {
  const MeetingControlsBar({
    super.key,
    required this.controller,
    required this.onLeave,
    required this.onEnd,
    required this.isHost,
  });

  final MeetingRoomController controller;
  final VoidCallback onLeave;
  final VoidCallback onEnd;
  final bool isHost;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ControlButton(
            icon: controller.micEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
            color: controller.micEnabled
                ? Colors.white.withValues(alpha: 0.18)
                : DesignColors.redLive.withValues(alpha: 0.85),
            onTap: controller.toggleMicrophone,
          ),
          const SizedBox(width: 10),
          _ControlButton(
            icon: controller.cameraEnabled ? Icons.videocam_rounded : Icons.videocam_off_rounded,
            color: controller.cameraEnabled
                ? Colors.white.withValues(alpha: 0.18)
                : DesignColors.redLive.withValues(alpha: 0.85),
            onTap: controller.toggleCamera,
          ),
          const SizedBox(width: 10),
          _ControlButton(
            icon: Icons.cameraswitch_rounded,
            color: Colors.white.withValues(alpha: 0.18),
            onTap: controller.switchCamera,
          ),
          const SizedBox(width: 10),
          _ControlButton(
            icon: controller.speakerEnabled ? Icons.volume_up_rounded : Icons.hearing_rounded,
            color: Colors.white.withValues(alpha: 0.18),
            onTap: controller.toggleSpeaker,
          ),
          if (controller.screenShareSupported) ...[
            const SizedBox(width: 10),
            _ControlButton(
              icon: controller.screenShareEnabled
                  ? Icons.stop_screen_share_rounded
                  : Icons.screen_share_rounded,
              color: DesignColors.purple.withValues(alpha: 0.9),
              onTap: controller.toggleScreenShare,
            ),
          ],
          const SizedBox(width: 14),
          _ControlButton(
            icon: Icons.call_end_rounded,
            color: DesignColors.redLive,
            size: 64,
            onTap: onLeave,
          ),
          if (isHost) ...[
            const SizedBox(width: 10),
            _ControlButton(
              icon: Icons.stop_circle_outlined,
              color: Colors.orange.withValues(alpha: 0.9),
              onTap: onEnd,
            ),
          ],
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 52,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
