import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import 'user_profile_picture.dart';
import 'message_preview.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';

class MessageListItem extends StatelessWidget {
  final String username;
  final String message;
  final String time;
  final int? unreadCount;
  final int colorIndex;
  final VoidCallback? onTap;
  
  const MessageListItem({
    super.key,
    required this.username,
    required this.message,
    required this.time,
    this.unreadCount,
    required this.colorIndex,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final bool hasUnread = unreadCount != null && unreadCount! > 0;
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.deepPurple : AppColors.white,
          border: Border(
            bottom: BorderSide(
              color: isDarkMode ? AppColors.darkPurple : AppColors.divider,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Profile image with unread indicator
            UserProfilePicture(
              colorIndex: colorIndex,
              unreadCount: unreadCount,
              onTap: onTap,
            ),
            
            const SizedBox(width: 12),
            
            // Message content
            Expanded(
              child: MessagePreview(
                username: username,
                message: message,
                time: time,
                isUnread: hasUnread,
                isDarkMode: isDarkMode,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Right chevron
            Icon(
              Ionicons.chevron_forward,
              color: AppTheme.getSecondaryTextColor(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
} 