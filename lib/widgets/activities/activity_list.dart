import 'package:flutter/cupertino.dart';
import 'activity_list_item.dart';
import 'activity_icon.dart';

class ActivityList extends StatelessWidget {
  final List<ActivityData> activities;
  final Function(ActivityData)? onActivityTap;

  const ActivityList({
    super.key,
    required this.activities, 
    this.onActivityTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final ActivityData activity = activities[index];
        return ActivityListItem(
          username: activity.username,
          type: activity.type,
          time: activity.timeString,
          additionalInfo: activity.additionalInfo,
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

class ActivityData {
  final String id;
  final String username;
  final ActivityType type;
  final String timeString;
  final String? additionalInfo;
  final String? targetContentId;

  ActivityData({
    required this.id,
    required this.username,
    required this.type,
    required this.timeString,
    this.additionalInfo,
    this.targetContentId,
  });
} 