import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/messages/data/models/activity_data.dart';
import 'package:sparksocial/src/features/messages/ui/widgets/activity_list.dart';

class ActivitiesTab extends StatelessWidget {
  const ActivitiesTab({super.key, required this.activities, required this.onActivityTap});

  final List<ActivityData> activities;
  final Function(ActivityData) onActivityTap;

  @override
  Widget build(BuildContext context) {
    final logger = GetIt.instance<LogService>().getLogger('ActivitiesTab');
    logger.d('Building ActivitiesTab with ${activities.length} activities');

    return ActivityList(
      activities: activities,
      onActivityTap: (activity) {
        logger.d('Tapped on activity: ${activity.id}');
        onActivityTap(activity);
      },
    );
  }
}
