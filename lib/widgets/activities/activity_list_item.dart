import 'package:flutter/cupertino.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'activity_icon.dart';
import 'activity_content.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';

class ActivityListItem extends StatelessWidget {
  final String username;
  final ActivityType type;
  final String time;
  final String? additionalInfo;
  final VoidCallback? onTap;
  
  const ActivityListItem({
    super.key,
    required this.username,
    required this.type,
    required this.time,
    this.additionalInfo,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
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
            // Activity icon
            ActivityIcon(type: type),
            
            const SizedBox(width: 12),
            
            // Activity content
            Expanded(
              child: ActivityContent(
                username: username,
                type: type,
                time: time,
                additionalInfo: additionalInfo,
                isDarkMode: isDarkMode,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Chevron
            Icon(
              FluentIcons.chevron_right_16_regular,
              color: AppTheme.getSecondaryTextColor(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
} 