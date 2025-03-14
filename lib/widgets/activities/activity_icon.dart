import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import '../../utils/app_colors.dart';

enum ActivityType {
  like,
  comment,
  follow,
}

class ActivityIcon extends StatelessWidget {
  final ActivityType type;
  final double size;

  const ActivityIcon({
    super.key,
    required this.type,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    // Determine icon and color based on activity type
    IconData iconData;
    Color backgroundColor;
    Color iconColor;

    switch (type) {
      case ActivityType.like:
        iconData = Ionicons.heart;
        backgroundColor = AppColors.likeColor.withOpacity(0.2);
        iconColor = AppColors.likeColor;
        break;
      case ActivityType.comment:
        iconData = Ionicons.chatbubble;
        backgroundColor = AppColors.commentColor.withOpacity(0.2);
        iconColor = AppColors.commentColor;
        break;
      case ActivityType.follow:
        iconData = Ionicons.person_add;
        backgroundColor = AppColors.followColor.withOpacity(0.2);
        iconColor = AppColors.followColor;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: size * 0.5,
        ),
      ),
    );
  }
} 