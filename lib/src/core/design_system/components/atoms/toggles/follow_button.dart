import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

class FollowButton extends StatelessWidget {
  const FollowButton({
    required this.isFollowing,
    required this.onFollow,
    required this.onUnfollow,
    super.key,
    this.followText = 'Follow',
    this.unfollowText = 'Unfollow',
    this.isBlocking = false,
    this.onUnblock,
    this.unblockText = 'Unblock',
    this.width,
  });

  final bool isFollowing;
  final VoidCallback onFollow;
  final VoidCallback onUnfollow;
  final String followText;
  final String unfollowText;
  final bool isBlocking;
  final VoidCallback? onUnblock;
  final String unblockText;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isBlocking && onUnblock != null) {
      return InteractivePressable(
        onTap: onUnblock,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Container(
          width: width ?? 109.47,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? AppColors.red900 : AppColors.red50,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.fromBorderSide(
              BorderSide(
                color: isDark ? AppColors.red800 : AppColors.red200,
                width: 1,
              ),
            ),
          ),
          child: Align(
            child: Text(
              unblockText,
              textAlign: TextAlign.center,
              style: AppTypography.textSmallMedium.copyWith(
                color: isDark ? AppColors.red400 : AppColors.red700,
              ),
            ),
          ),
        ),
      );
    }

    return InteractivePressable(
      onTap: isFollowing ? onUnfollow : onFollow,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Container(
        width: width ?? 109.47,
        height: 36,
        decoration: isFollowing
            ? BoxDecoration(
                color: isDark ? AppColors.darkGreyButton : AppColors.lightGreyButton,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: Border.fromBorderSide(
                  BorderSide(
                    color: isDark ? AppColors.grey700.withOpacity(0.3) : AppColors.grey100.withOpacity(0.3),
                    width: 1.14667,
                  ),
                ),
              )
            : const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: AppColors.primary600,
              ),
        child: Align(
          child: Text(
            isFollowing ? unfollowText : followText,
            textAlign: TextAlign.center,
            style: AppTypography.textSmallMedium,
          ),
        ),
      ),
    );
  }
}
