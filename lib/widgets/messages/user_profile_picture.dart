import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../utils/app_colors.dart';

class UserProfilePicture extends StatelessWidget {
  final int colorIndex;
  final int? unreadCount;
  final double size;
  final VoidCallback? onTap;

  const UserProfilePicture({super.key, required this.colorIndex, this.unreadCount, this.size = 60, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = unreadCount != null && unreadCount! > 0;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: colorIndex % 2 == 0 ? AppColors.brightPurple.withAlpha(51) : AppColors.richPurple.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                FluentIcons.person_24_regular,
                color: colorIndex % 2 == 0 ? AppColors.brightPurple : AppColors.richPurple,
                size: size * 0.5,
              ),
            ),
          ),

          if (hasUnread) Positioned(top: 0, right: 0, child: UnreadIndicator(count: unreadCount!)),
        ],
      ),
    );
  }
}

class UnreadIndicator extends StatelessWidget {
  final int count;
  final double size;

  const UnreadIndicator({super.key, required this.count, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: AppColors.unreadIndicator, shape: BoxShape.circle),
      child: Center(
        child: Text(
          count > 9 ? '9+' : count.toString(),
          style: TextStyle(color: AppColors.white, fontSize: size * 0.625, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
