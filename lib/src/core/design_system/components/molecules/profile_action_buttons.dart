import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/components/atoms/toggles/follow_button.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

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
  });

  final bool isCurrentUser;
  final bool isFollowing;
  final bool isBlocking;
  final VoidCallback? onEditTap;
  final VoidCallback? onFollowTap;
  final VoidCallback? onUnfollowTap;
  final VoidCallback? onUnblockTap;

  @override
  Widget build(BuildContext context) {
    if (isCurrentUser) {
      return Row(
        children: [
          Expanded(
            child: _EditButton(
              onTap: onEditTap,
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

/// Edit button that matches the FollowButton's following state style
class _EditButton extends StatelessWidget {
  const _EditButton({
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InteractivePressable(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Container(
        width: double.infinity,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGreyButton : AppColors.lightGreyButton,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.fromBorderSide(
            BorderSide(
              color: isDark
                  ? AppColors.grey700.withValues(alpha: 0.3)
                  : AppColors.grey100.withValues(alpha: 0.3),
              width: 1.14667,
            ),
          ),
        ),
        child: const Align(
          child: Text(
            'Edit',
            textAlign: TextAlign.center,
            style: AppTypography.textSmallMedium,
          ),
        ),
      ),
    );
  }
}
