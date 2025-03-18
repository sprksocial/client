import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../utils/app_colors.dart';

enum ActivityType { like, comment, follow }

class ActivityIcon extends StatelessWidget {
  final ActivityType type;
  final double size;

  const ActivityIcon({super.key, required this.type, this.size = 40});

  @override
  Widget build(BuildContext context) {
    // Determine icon and color based on activity type
    IconData iconData;
    Color backgroundColor;
    Color iconColor;

    switch (type) {
      case ActivityType.like:
        iconData = FluentIcons.heart_24_filled;
        backgroundColor = AppColors.likeColor.withAlpha(51);
        iconColor = AppColors.likeColor;
        break;
      case ActivityType.comment:
        iconData = FluentIcons.chat_24_filled;
        backgroundColor = AppColors.commentColor.withAlpha(51);
        iconColor = AppColors.commentColor;
        break;
      case ActivityType.follow:
        iconData = FluentIcons.person_add_24_filled;
        backgroundColor = AppColors.followColor.withAlpha(51);
        iconColor = AppColors.followColor;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(child: Icon(iconData, color: iconColor, size: size * 0.5)),
    );
  }
}
