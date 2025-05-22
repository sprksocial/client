import 'package:flutter/material.dart';
import 'package:sparksocial/src/features/messages/data/models/activity_data.dart';
import 'package:sparksocial/src/features/messages/ui/widgets/activity_list_item.dart';

class ActivityList extends StatelessWidget {
  final List<ActivityData> activities;
  final Function(ActivityData)? onActivityTap;

  const ActivityList({super.key, required this.activities, this.onActivityTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: activities.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final ActivityData activity = activities[index];
        return ActivityListItem(
          username: activity.username,
          type: activity.type,
          time: activity.timeString,
          additionalInfo: activity.additionalInfo,
          colorIndex: index,
          avatarUrl: activity.avatarUrl,
          onTap: () {
            if (onActivityTap != null) {
              onActivityTap!(activity);
            }
          },
        );
      },
    );
  }
}
