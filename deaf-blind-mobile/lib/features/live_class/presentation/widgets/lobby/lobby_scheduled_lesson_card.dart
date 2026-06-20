import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import 'lobby_actions.dart';

class LobbyScheduledLessonCard extends StatelessWidget {
  const LobbyScheduledLessonCard({
    super.key,
    required this.onJoin,
    required this.loading,
    this.scheduledTime = '11:00',
  });

  final VoidCallback? onJoin;
  final bool loading;
  final String scheduledTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Сегодня в $scheduledTime у вас запланирован урок.',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Нажмите кнопку ниже, чтобы присоединиться к занятию.',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          LobbyPrimaryButton(
            label: 'Присоединиться к уроку',
            icon: Icons.videocam_rounded,
            onTap: loading ? null : onJoin,
          ),
        ],
      ),
    );
  }
}
