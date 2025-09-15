import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/design_system/tokens/gradients.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

class FollowButton extends StatelessWidget {
  const FollowButton({
    required this.isFollowing,
    required this.onFollow,
    required this.onUnfollow,
    super.key,
    this.followText = 'Follow',
    this.unfollowText = 'Unfollow',
  });

  final bool isFollowing;
  final VoidCallback onFollow;
  final VoidCallback onUnfollow;
  final String followText;
  final String unfollowText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InteractivePressable(
      onTap: isFollowing ? onUnfollow : onFollow,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Container(
        width: 109.47,
        height: 36,
        decoration: isFollowing
            ? const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                gradient: AppGradients.accent,
              )
            : BoxDecoration(
                color: isDark ? AppColors.darkGreyButton : AppColors.lightGreyButton,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: const Border.fromBorderSide(
                  BorderSide(
                    color: Color.fromRGBO(255, 255, 255, 0.15),
                    width: 1.14667,
                  ),
                ),
              ),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        child: Center(
          child: Text(
            // The text depends on the current state.
            isFollowing ? unfollowText : followText,
            textAlign: TextAlign.center,
            style: AppTypography.textSmallMedium,
          ),
        ),
      ),
    );
  }
}
