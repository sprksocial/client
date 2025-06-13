import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/network/chat/data/models/models.dart';
import 'conversation_list_item.dart';

class ConversationList extends StatelessWidget {
  final List<ChatConversation> conversations;
  final Function(ChatConversation)? onConversationTap;
  final Function(ChatConversation)? onConversationLongPress;

  const ConversationList({super.key, required this.conversations, this.onConversationTap, this.onConversationLongPress});

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'DMs feature is coming soon',
              style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text('Start a conversation to see it here', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: conversations.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final conversation = conversations[index];

        return ConversationListItem(
          conversation: conversation,
          onTap: () => onConversationTap?.call(conversation),
          onLongPress: () => onConversationLongPress?.call(conversation),
        );
      },
    );
  }
}
