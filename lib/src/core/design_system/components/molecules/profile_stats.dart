import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    super.key,
    this.onFollowersTap,
    this.onFollowingTap,
  });

  final String postsCount;
  final String followersCount;
  final String followingCount;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(count: postsCount, label: 'Posts'),
        GestureDetector(
          onTap: onFollowersTap,
          behavior: HitTestBehavior.opaque,
          child: _StatItem(count: followersCount, label: 'Followers'),
        ),
        GestureDetector(
          onTap: onFollowingTap,
          behavior: HitTestBehavior.opaque,
          child: _StatItem(count: followingCount, label: 'Following'),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.count,
    required this.label,
  });

  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count,
          style: AppTypography.textLargeBold.copyWith(
            color: theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Skeleton.keep(
          child: Text(
            label,
            style: AppTypography.textSmallThin.copyWith(
              color: theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
