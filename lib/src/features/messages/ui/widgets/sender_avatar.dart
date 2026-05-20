import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/components/atoms/user_avatar.dart';
import 'package:spark/src/features/messages/ui/pages/chat_page.dart';

class SenderAvatar extends StatelessWidget {
  const SenderAvatar({
    required this.isCurrentUser,
    required this.otherUserAvatar,
    required this.otherUserHandle,
    super.key,
  });

  final bool isCurrentUser;
  final String? otherUserAvatar;
  final String? otherUserHandle;

  @override
  Widget build(BuildContext context) {
    if (isCurrentUser) {
      return const UserAvatar(
        username: 'You',
        size: 32,
        backgroundColor: AppColors.primary,
      );
    }

    return UserAvatar(
      imageUrl: otherUserAvatar ?? '',
      username: otherUserHandle ?? 'User',
      size: 32,
      backgroundColor: getAvatarColor((otherUserHandle ?? 'User').hashCode),
    );
  }
}
