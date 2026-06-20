import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../deaf_school/presentation/widgets/design_widgets.dart';
import 'live_badge.dart';

class MeetingRoomHeader extends StatelessWidget {
  const MeetingRoomHeader({
    super.key,
    required this.title,
    required this.code,
    required this.participantCount,
    required this.quality,
    required this.onLeave,
  });

  final String title;
  final String code;
  final int participantCount;
  final ConnectionQuality quality;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DesignBackButton(onTap: onLeave, light: true),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              Text(
                'Код $code · $participantCount участн.',
                style: const TextStyle(
                  color: Color(0x99FFFFFF),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        LiveBadge(quality: quality),
      ],
    );
  }
}
