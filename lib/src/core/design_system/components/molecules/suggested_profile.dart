import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/toggles/follow_button.dart';

import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

class SuggestedProfile extends StatelessWidget {
  const SuggestedProfile({
    required this.imageUrl,
    required this.userName,
    required this.userHandle,
    required this.isFollowing,
    required this.onFollow,
    required this.onUnfollow,
    super.key,
  });

  final String imageUrl;
  final String userName;
  final String userHandle;
  final bool isFollowing;
  final VoidCallback onFollow;
  final VoidCallback onUnfollow;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 313,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey700 : AppColors.grey100,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: AppTypography.textMediumBold),
                      const SizedBox(height: 3),
                      Text(userHandle, style: AppTypography.textExtraSmallThin),
                    ],
                  ),
                ],
              ),
              FollowButton(
                isFollowing: isFollowing,
                onFollow: onFollow,
                onUnfollow: onUnfollow,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
