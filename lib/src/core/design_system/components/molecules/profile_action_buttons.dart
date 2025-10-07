import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/text_button.dart' as ds;
import 'package:sparksocial/src/core/design_system/components/atoms/toggles/glass_follow_button.dart';

class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({
    required this.isCurrentUser,
    super.key,
    this.isFollowing = false,
    this.onEditTap,
    this.onFollowTap,
    this.onUnfollowTap,
    this.onShareTap,
  });

  final bool isCurrentUser;
  final bool isFollowing;
  final VoidCallback? onEditTap;
  final VoidCallback? onFollowTap;
  final VoidCallback? onUnfollowTap;
  final VoidCallback? onShareTap;

  @override
  Widget build(BuildContext context) {
    if (isCurrentUser) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 36,
              child: ds.TextButton(
                label: 'Edit',
                onTap: onEditTap,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 36,
              child: ds.TextButton(
                label: 'Share Profile',
                onTap: onShareTap,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: GlassFollowButton(
            isFollowing: isFollowing,
            onFollow: onFollowTap ?? () {},
            onUnfollow: onUnfollowTap ?? () {},
            followText: 'Follow',
            unfollowText: 'Following',
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
