import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/widgets/common/user_avatar.dart';
import 'package:sparksocial/src/features/messages/data/models/activity_data.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Activity properties based on type
    final IconData activityIcon = type == ActivityType.like 
        ? FluentIcons.heart_16_filled
        : type == ActivityType.comment 
            ? FluentIcons.chat_16_filled 
            : FluentIcons.person_add_16_filled;
            
    final Color activityColor = type == ActivityType.like 
        ? Colors.red.shade500
        : type == ActivityType.comment 
            ? Colors.green.shade600 
            : Colors.blue.shade600;
            
    final String activityDescription = type == ActivityType.like 
        ? '$username liked your post'
        : type == ActivityType.comment 
            ? '$username commented on your post' 
            : '$username started following you';
            
    // Avatar colors
    final List<Color> avatarColors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.indigo];
    final Color avatarColor = avatarColors[colorIndex % avatarColors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.black : AppColors.white,
          border: Border(
            bottom: BorderSide(
              color: isDarkMode 
                ? Colors.grey.shade900 
                : AppColors.divider.withAlpha(77),
              width: 0.5
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: UserAvatar(
                    imageUrl: avatarUrl,
                    username: username,
                    size: 48,
                    backgroundColor: avatarColor,
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: activityColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDarkMode ? AppColors.black : AppColors.white, width: 2),
                    ),
                    child: Center(child: Icon(activityIcon, color: AppColors.white, size: 14)),
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
                    activityDescription,
                    style: TextStyle(
                      fontSize: 16, 
                      color: isDarkMode ? AppColors.white : AppColors.black, 
                      fontWeight: FontWeight.w500
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
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700
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
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600
              )
            ),
          ],
        ),
      ),
    );
  }
} 