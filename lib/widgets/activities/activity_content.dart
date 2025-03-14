import 'package:flutter/cupertino.dart';
import 'activity_icon.dart';
import '../../utils/app_theme.dart';

class ActivityContent extends StatelessWidget {
  final String username;
  final ActivityType type;
  final String time;
  final String? additionalInfo;
  final bool isDarkMode;

  const ActivityContent({
    super.key,
    required this.username,
    required this.type,
    required this.time,
    this.additionalInfo,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Activity description and time
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ActivityDescription(
                username: username,
                type: type,
                isDarkMode: isDarkMode,
              ),
            ),
            ActivityTime(
              time: time,
              isDarkMode: isDarkMode,
            ),
          ],
        ),

        // Optional additional info
        if (additionalInfo != null) ...[
          const SizedBox(height: 4),
          AdditionalInfoText(
            text: additionalInfo!,
            isDarkMode: isDarkMode,
          ),
        ],
      ],
    );
  }
}

class ActivityDescription extends StatelessWidget {
  final String username;
  final ActivityType type;
  final bool isDarkMode;

  const ActivityDescription({
    super.key,
    required this.username,
    required this.type,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final String actionText = _getActionText(type);

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(
          fontSize: 16,
          color: AppTheme.getTextColor(context),
        ),
        children: [
          TextSpan(
            text: username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: ' $actionText',
          ),
        ],
      ),
    );
  }

  String _getActionText(ActivityType type) {
    switch (type) {
      case ActivityType.like:
        return 'liked your post';
      case ActivityType.comment:
        return 'commented on your post';
      case ActivityType.follow:
        return 'started following you';
    }
  }
}

class ActivityTime extends StatelessWidget {
  final String time;
  final bool isDarkMode;

  const ActivityTime({
    super.key,
    required this.time,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      style: TextStyle(
        color: AppTheme.getSecondaryTextColor(context),
        fontSize: 12,
      ),
    );
  }
}

class AdditionalInfoText extends StatelessWidget {
  final String text;
  final bool isDarkMode;

  const AdditionalInfoText({
    super.key,
    required this.text,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppTheme.getSecondaryTextColor(context),
        fontSize: 14,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}