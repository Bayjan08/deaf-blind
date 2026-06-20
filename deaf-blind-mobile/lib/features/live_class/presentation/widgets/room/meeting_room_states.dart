import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class MeetingRoomLoading extends StatelessWidget {
  const MeetingRoomLoading({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0E0E0E),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class MeetingRoomError extends StatelessWidget {
  const MeetingRoomError({super.key, required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0E0E0E),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 20),
          FilledButton(onPressed: onBack, child: const Text('Назад')),
        ],
      ),
    );
  }
}
