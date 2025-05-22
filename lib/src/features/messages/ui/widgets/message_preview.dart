import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

/// A compact preview of a message showing username, message content, and time
class MessagePreview extends StatelessWidget {
  final String username;
  final String message;
  final String time;
  final bool isUnread;

  const MessagePreview({super.key, required this.username, required this.message, required this.time, this.isUnread = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [UsernameText(username: username, isBold: isUnread), TimeText(time: time, isHighlighted: isUnread)],
        ),
        const SizedBox(height: 4),
        MessageText(message: message, isUnread: isUnread),
      ],
    );
  }
}

/// Username display component with optional bold styling
class UsernameText extends StatelessWidget {
  final String username;
  final bool isBold;

  const UsernameText({super.key, required this.username, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      username,
      style: TextStyle(color: colorScheme.onSurface, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 16),
    );
  }
}

/// Time display component with optional highlighting
class TimeText extends StatelessWidget {
  final String time;
  final bool isHighlighted;

  const TimeText({super.key, required this.time, this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(time, style: TextStyle(color: isHighlighted ? AppColors.primary : colorScheme.onSurfaceVariant, fontSize: 12));
  }
}

/// Message content display component with read/unread styling
class MessageText extends StatelessWidget {
  final String message;
  final bool isUnread;

  const MessageText({super.key, required this.message, this.isUnread = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      message,
      style: TextStyle(
        color: isUnread ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
        fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
