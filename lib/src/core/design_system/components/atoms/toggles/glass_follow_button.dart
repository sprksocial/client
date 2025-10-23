import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

class GlassFollowButton extends StatelessWidget {
  const GlassFollowButton({
    required this.isFollowing,
    required this.onFollow,
    required this.onUnfollow,
    required this.followText,
    required this.unfollowText,
    super.key,
  });

  final bool isFollowing;
  final VoidCallback onFollow;
  final VoidCallback onUnfollow;
  final String followText;
  final String unfollowText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isFollowing ? onUnfollow : onFollow,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 60),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Colors.white.withAlpha(37),
              ),
            ),
            child: Center(
              child: Text(isFollowing ? unfollowText : followText, style: AppTypography.textExtraSmallMedium),
            ),
          ),
        ),
      ),
    );
  }
}
