import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../../core/theme/app_colors.dart';
import 'participant_video_utils.dart';

/// Renders a participant camera track or a placeholder avatar.
class ParticipantTile extends StatelessWidget {
  const ParticipantTile({
    super.key,
    required this.participant,
    required this.isLocal,
    this.highlighted = false,
    this.compact = false,
  });

  final Participant participant;
  final bool isLocal;
  final bool highlighted;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final track = cameraTrackFor(participant);
    final borderColor =
        highlighted ? AppColors.success : Colors.white.withValues(alpha: 0.15);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1830),
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        border: Border.all(color: borderColor, width: highlighted ? 2.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (track != null)
            VideoTrackRenderer(track)
          else
            Center(
              child: Text(
                participant.name.isNotEmpty ? participant.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: compact ? 28 : 42,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isLocal ? 'Вы' : participant.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
