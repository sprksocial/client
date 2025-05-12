import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/widgets/common/user_avatar.dart';

/// A list item that displays a message preview with user avatar
class MessageListItem extends StatelessWidget {
  final String username;
  final String message;
  final String time;
  final int? unreadCount;
  final int colorIndex;
  final VoidCallback? onTap;
  final String? avatarUrl;

  const MessageListItem({
    super.key,
    required this.username,
    required this.message,
    required this.time,
    this.unreadCount,
    required this.colorIndex,
    this.onTap,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = unreadCount != null && unreadCount! > 0;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.surfaceContainerLow.withAlpha(30),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
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
                backgroundColor: _getAvatarColor(colorIndex),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time, 
                  style: TextStyle(
                    fontSize: 12, 
                    color: colorScheme.onSurfaceVariant,
                  )
                ),
                const SizedBox(height: 4),
                if (hasUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.unreadIndicator,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: AppColors.white, 
                        fontSize: 12, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(int index) {
    final List<Color> colors = [
      Colors.blue, 
      Colors.green, 
      Colors.orange, 
      Colors.purple, 
      Colors.teal, 
      AppColors.pink, 
      Colors.indigo
    ];
    return colors[index % colors.length];
  }
} 