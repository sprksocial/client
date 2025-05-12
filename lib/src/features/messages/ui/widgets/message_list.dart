import 'package:flutter/material.dart';
import 'package:sparksocial/src/features/messages/data/models/message_data.dart';
import 'package:sparksocial/src/features/messages/ui/widgets/message_list_item.dart';

/// A list widget that displays multiple message items
class MessageList extends StatelessWidget {
  final List<MessageData> messages;
  final Function(MessageData)? onMessageTap;

  const MessageList({
    super.key, 
    required this.messages, 
    this.onMessageTap
  });

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