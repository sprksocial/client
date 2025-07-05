import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message_models.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/widgets/user_avatar.dart';

class ConversationListItem extends StatelessWidget {
  const ConversationListItem({
    required this.message,
    required this.otherUserProfile,
    super.key,
    this.onTap,
    this.onLongPress,
  });
  final Message message;
  final ProfileViewDetailed otherUserProfile;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline, width: 0.5)),
        ),
        child: Row(
          children: [
            ConversationAvatar(otherUserProfile: otherUserProfile),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherUserProfile.displayName ?? otherUserProfile.handle,
                          // style: TextStyle(
                          //   fontWeight: conversation.unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
                          //   fontSize: 16,
                          //   color: Theme.of(context).colorScheme.onSurface,
                          // ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '@${otherUserProfile.handle}',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.end,
            //   children: [
            //     if (conversation.unreadCount > 0)
            //       Container(
            //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            //         decoration: BoxDecoration(
            //           color: Theme.of(context).colorScheme.primary,
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //         child: Text(
            //           conversation.unreadCount > 99 ? '99+' : conversation.unreadCount.toString(),
            //           style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            //         ),
            //       ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  // String _formatTime(DateTime dateTime) {
  //   final now = DateTime.now();
  //   final difference = now.difference(dateTime);

  //   if (difference.inDays > 0) {
  //     return '${difference.inDays}d';
  //   } else if (difference.inHours > 0) {
  //     return '${difference.inHours}h';
  //   } else if (difference.inMinutes > 0) {
  //     return '${difference.inMinutes}m';
  //   } else {
  //     return 'now';
  //   }
  // }
}

class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({required this.otherUserProfile, super.key});
  final ProfileViewDetailed otherUserProfile;

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
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: UserAvatar(
        imageUrl: otherUserProfile.avatar.toString(),
        username: otherUserProfile.handle,
        size: 48,
        backgroundColor: _getAvatarColor(otherUserProfile.handle.hashCode),
      ),
    );
  }
}
