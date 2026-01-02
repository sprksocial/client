import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/text_button.dart' as ds;
import 'package:sparksocial/src/core/design_system/components/atoms/toggles/follow_button.dart';

class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({
    required this.isCurrentUser,
    super.key,
    this.isFollowing = false,
    this.isBlocking = false,
    this.onEditTap,
    this.onFollowTap,
    this.onUnfollowTap,
    this.onUnblockTap,
    this.onShareTap,
  });

  final bool isCurrentUser;
  final bool isFollowing;
  final bool isBlocking;
  final VoidCallback? onEditTap;
  final VoidCallback? onFollowTap;
  final VoidCallback? onUnfollowTap;
  final VoidCallback? onUnblockTap;
  final VoidCallback? onShareTap;

  @override
  Widget build(BuildContext context) {
    if (isCurrentUser) {
      return Row(
        children: [
          Expanded(
            child: ds.TextButton(
              label: 'Edit',
              onTap: onEditTap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ds.TextButton(
              label: 'Share Profile',
              onTap: onShareTap,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: FollowButton(
            isFollowing: isFollowing,
            isBlocking: isBlocking,
            onFollow: onFollowTap ?? () {},
            onUnfollow: onUnfollowTap ?? () {},
            onUnblock: onUnblockTap,
            unfollowText: 'Following',
            width: double.infinity,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
