import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/suggested_profile.dart';

class SuggestedAccountCard extends StatelessWidget {
  const SuggestedAccountCard({
    required this.username,
    required this.handle,
    required this.avatarUrl,
    super.key,
    this.description,
    this.onTap,
    this.onFollowTap,
    this.onUnfollowTap,
    this.showFollowButton = true,
    this.isFollowing = false,
  });
  final String username;
  final String handle;
  final String avatarUrl;
  final String? description;
  final VoidCallback? onTap;
  final VoidCallback? onFollowTap;
  final VoidCallback? onUnfollowTap;
  final bool showFollowButton;
  final bool isFollowing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SuggestedProfile.withDescription(
        imageUrl: avatarUrl,
        userName: username,
        userHandle: handle,
        isFollowing: isFollowing,
        onFollow: onFollowTap ?? () {},
        onUnfollow: onUnfollowTap ?? () {},
        showFollowButton: showFollowButton,
        description: description ?? '',
      ),
    );
  }
}
