import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/models/meeting.dart';
import 'recent_meeting_tile.dart';

class RecentMeetingsList extends StatelessWidget {
  const RecentMeetingsList({
    super.key,
    required this.meetings,
    required this.loading,
    required this.onRejoin,
  });

  final List<Meeting> meetings;
  final bool loading;
  final ValueChanged<Meeting> onRejoin;

  @override
  Widget build(BuildContext context) {
    if (loading && meetings.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (meetings.isEmpty) {
      return const Center(
        child: Text('Пока нет недавних встреч', style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.separated(
      itemCount: meetings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        return RecentMeetingTile(
          meeting: meeting,
          onTap: meeting.isActive ? () => onRejoin(meeting) : null,
        );
      },
    );
  }
}
