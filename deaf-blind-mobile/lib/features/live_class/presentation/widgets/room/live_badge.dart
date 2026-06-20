import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../../core/theme/design_colors.dart';

class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key, required this.quality});

  final ConnectionQuality quality;

  @override
  Widget build(BuildContext context) {
    final color = switch (quality) {
      ConnectionQuality.excellent || ConnectionQuality.good => DesignColors.green,
      ConnectionQuality.poor => Colors.orange,
      _ => DesignColors.redLive,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: DesignColors.redLive.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          const Text(
            'В эфире',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
