import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'activity_icon.dart';
import '../../utils/app_colors.dart';

class ActivityListItem extends StatelessWidget {
  final String username;
  final ActivityType type;
  final String time;
  final String? additionalInfo;
  final int colorIndex;
  final VoidCallback? onTap;
  final String? avatarUrl;

  const ActivityListItem({
    super.key,
    required this.username,
    required this.type,
    required this.time,
    this.additionalInfo,
    required this.colorIndex,
    this.onTap,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black : Colors.white,
          border: Border(bottom: BorderSide(color: isDarkMode ? Colors.grey.shade900 : AppColors.divider.withOpacity(0.3), width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getAvatarColor(colorIndex),
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? Text(
                          username.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getActivityColor(),
                      shape: BoxShape.circle,
                      border: Border.all(color: isDarkMode ? Colors.black : Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        _getActivityIcon(),
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getActivityDescription(),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (additionalInfo != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      additionalInfo!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon() {
    switch (type) {
      case ActivityType.like:
        return FluentIcons.heart_16_filled;
      case ActivityType.comment:
        return FluentIcons.chat_16_filled;
      case ActivityType.follow:
        return FluentIcons.person_add_16_filled;
    }
  }

  Color _getActivityColor() {
    switch (type) {
      case ActivityType.like:
        return Colors.red.shade500;
      case ActivityType.comment:
        return Colors.green.shade600;
      case ActivityType.follow:
        return Colors.blue.shade600;
    }
  }

  String _getActivityDescription() {
    switch (type) {
      case ActivityType.like:
        return '$username liked your post';
      case ActivityType.comment:
        return '$username commented on your post';
      case ActivityType.follow:
        return '$username started following you';
    }
  }

  Color _getAvatarColor(int index) {
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}
