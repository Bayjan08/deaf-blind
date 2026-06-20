import 'package:flutter/material.dart';

import '../../../../../core/theme/design_colors.dart';

class LobbyHeader extends StatelessWidget {
  const LobbyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Класс',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: DesignColors.textDark,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Видеоурок с учителем и одноклассниками',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: DesignColors.textMuted,
          ),
        ),
      ],
    );
  }
}
