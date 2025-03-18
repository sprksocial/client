import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';

class MessagePreview extends StatelessWidget {
  final String username;
  final String message;
  final String time;
  final bool isUnread;
  final bool isDarkMode;

  const MessagePreview({
    super.key,
    required this.username,
    required this.message,
    required this.time,
    this.isUnread = false,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username and time row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UsernameText(username: username, isBold: isUnread, isDarkMode: isDarkMode),
            TimeText(time: time, isHighlighted: isUnread, isDarkMode: isDarkMode),
          ],
        ),
        const SizedBox(height: 4),
        // Message preview text
        MessageText(message: message, isUnread: isUnread, isDarkMode: isDarkMode),
      ],
    );
  }
}

class UsernameText extends StatelessWidget {
  final String username;
  final bool isBold;
  final bool isDarkMode;

  const UsernameText({super.key, required this.username, this.isBold = false, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      username,
      style: TextStyle(
        color: AppTheme.getTextColor(context),
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontSize: 16,
      ),
    );
  }
}

class TimeText extends StatelessWidget {
  final String time;
  final bool isHighlighted;
  final bool isDarkMode;

  const TimeText({super.key, required this.time, this.isHighlighted = false, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      style: TextStyle(color: isHighlighted ? AppColors.primary : AppTheme.getSecondaryTextColor(context), fontSize: 12),
    );
  }
}

class MessageText extends StatelessWidget {
  final String message;
  final bool isUnread;
  final bool isDarkMode;

  const MessageText({super.key, required this.message, this.isUnread = false, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        color: isUnread ? AppTheme.getTextColor(context) : AppTheme.getSecondaryTextColor(context),
        fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
