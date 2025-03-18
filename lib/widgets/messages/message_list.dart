import 'package:flutter/material.dart';
import 'message_list_item.dart';

class MessageList extends StatelessWidget {
  final List<MessageData> messages;
  final Function(MessageData)? onMessageTap;

  const MessageList({super.key, required this.messages, this.onMessageTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final MessageData message = messages[index];
        return MessageListItem(
          username: message.username,
          message: message.messagePreview,
          time: message.timeString,
          unreadCount: message.unreadCount,
          colorIndex: index,
          avatarUrl: message.avatarUrl,
          onTap: () {
            if (onMessageTap != null) {
              onMessageTap!(message);
            }
          },
        );
      },
    );
  }
}

class MessageData {
  final String username;
  final String messagePreview;
  final String timeString;
  final int? unreadCount;
  final String? avatarUrl;
  final String id;

  MessageData({
    required this.username,
    required this.messagePreview,
    required this.timeString,
    this.unreadCount,
    this.avatarUrl,
    required this.id,
  });
}
