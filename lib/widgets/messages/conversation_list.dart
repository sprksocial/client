import 'package:flutter/material.dart';
import '../../models/chat.dart';
import 'conversation_list_item.dart';

class ConversationList extends StatelessWidget {
  final List<Conversation> conversations;
  final Function(Conversation)? onConversationTap;
  final Function(Conversation)? onConversationLongPress;

  const ConversationList({
    super.key,
    required this.conversations,
    this.onConversationTap,
    this.onConversationLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start a conversation to see it here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final pinnedConversations = conversations.where((c) => c.isPinned).toList();
    final regularConversations = conversations.where((c) => !c.isPinned).toList();

    return ListView.builder(
      itemCount: conversations.length + (pinnedConversations.isNotEmpty ? 1 : 0),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        if (pinnedConversations.isNotEmpty && index == 0) {
          return _buildSectionHeader('Pinned');
        }

        final adjustedIndex = pinnedConversations.isNotEmpty ? index - 1 : index;
        final conversation = conversations[adjustedIndex];

        return ConversationListItem(
          conversation: conversation,
          onTap: () => onConversationTap?.call(conversation),
          onLongPress: () => onConversationLongPress?.call(conversation),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }
} 