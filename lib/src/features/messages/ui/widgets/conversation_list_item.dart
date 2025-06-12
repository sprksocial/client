import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/widgets/user_avatar.dart';

class ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ConversationListItem({super.key, required this.conversation, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline, width: 0.5)),
        ),
        child: Row(
          children: [
            ConversationAvatar(conversation: conversation),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.displayTitle,
                          style: TextStyle(
                            fontWeight: conversation.hasUnreadMessages ? FontWeight.bold : FontWeight.w500,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.isPinned) ...[
                        const SizedBox(width: 4),
                        Icon(FluentIcons.pin_16_filled, size: 14, color: Theme.of(context).colorScheme.primary),
                      ],
                      if (conversation.isMuted) ...[
                        const SizedBox(width: 4),
                        Icon(FluentIcons.speaker_mute_16_filled, size: 14, color: Colors.grey),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessagePreview,
                          style: TextStyle(
                            fontWeight: conversation.hasUnreadMessages ? FontWeight.w500 : FontWeight.normal,
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      if (conversation.lastMessage?.status == MessageStatus.sending) ...[
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      ] else if (conversation.lastMessage?.senderId == 'current_user_id') ...[
                        const SizedBox(width: 4),
                        Icon(
                          _getMessageStatusIcon(conversation.lastMessage?.status),
                          size: 14,
                          color: _getMessageStatusColor(conversation.lastMessage?.status),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  conversation.formattedLastActivity,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                if (conversation.hasUnreadMessages)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      conversation.unreadCount > 99 ? '99+' : conversation.unreadCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMessageStatusIcon(MessageStatus? status) {
    switch (status) {
      case MessageStatus.sending:
        return FluentIcons.clock_16_regular;
      case MessageStatus.sent:
        return FluentIcons.checkmark_16_regular;
      case MessageStatus.delivered:
        return FluentIcons.checkmark_circle_16_regular;
      case MessageStatus.read:
        return FluentIcons.checkmark_circle_16_filled;
      case MessageStatus.failed:
        return FluentIcons.error_circle_16_filled;
      default:
        return FluentIcons.checkmark_16_regular;
    }
  }

  Color _getMessageStatusColor(MessageStatus? status) {
    switch (status) {
      case MessageStatus.sending:
        return Colors.grey;
      case MessageStatus.sent:
        return Colors.grey;
      case MessageStatus.delivered:
        return AppColors.primary;
      case MessageStatus.read:
        return AppColors.primary;
      case MessageStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class ConversationAvatar extends StatelessWidget {
  final Conversation conversation;
  const ConversationAvatar({super.key, required this.conversation});

  Color _getAvatarColor(int seed) {
    final colors = [
      AppColors.primary,
      AppColors.pink,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[seed.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (conversation.type == ConversationType.group) {
      if (conversation.avatarUrl != null) {
        return Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          clipBehavior: Clip.antiAlias,
          child: UserAvatar(
            imageUrl: conversation.avatarUrl,
            username: conversation.displayTitle,
            size: 48,
            backgroundColor: _getAvatarColor(conversation.id.hashCode),
          ),
        );
      }

      final otherParticipants = conversation.participants.where((p) => p.id != 'current_user_id').take(2).toList();

      if (otherParticipants.length >= 2) {
        return SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: UserAvatar(
                    imageUrl: otherParticipants[0].avatarUrl,
                    username: otherParticipants[0].username,
                    size: 32,
                    backgroundColor: _getAvatarColor(otherParticipants[0].username.hashCode),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: UserAvatar(
                    imageUrl: otherParticipants[1].avatarUrl,
                    username: otherParticipants[1].username,
                    size: 32,
                    backgroundColor: _getAvatarColor(otherParticipants[1].username.hashCode),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(shape: BoxShape.circle, color: _getAvatarColor(conversation.id.hashCode)),
        child: const Icon(FluentIcons.people_16_filled, color: Colors.white, size: 24),
      );
    } else {
      final otherParticipant = conversation.participants.firstWhere(
        (p) => p.id != 'current_user_id',
        orElse: () => conversation.participants.first,
      );

      return Stack(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: UserAvatar(
              imageUrl: otherParticipant.avatarUrl,
              username: otherParticipant.username,
              size: 48,
              backgroundColor: _getAvatarColor(otherParticipant.username.hashCode),
            ),
          ),
          if (otherParticipant.isOnline)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                ),
              ),
            ),
        ],
      );
    }
  }
}
