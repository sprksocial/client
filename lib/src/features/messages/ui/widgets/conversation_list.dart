import 'package:flutter/material.dart';

import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message_models.dart';
import 'package:sparksocial/src/features/messages/ui/widgets/conversation_list_item.dart';

class ConversationList extends StatelessWidget {
  const ConversationList({required this.conversations, super.key, this.onConversationTap, this.onConversationLongPress});
  final List<(ProfileViewDetailed, Message)> conversations;
  final Function((ProfileViewDetailed, Message))? onConversationTap;
  final Function((ProfileViewDetailed, Message))? onConversationLongPress;

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
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
          message: conversation.$2,
          otherUserProfile: conversation.$1,
          onTap: () => onConversationTap?.call(conversation),
          onLongPress: () => onConversationLongPress?.call(conversation),
        );
      },
    );
  }
}
