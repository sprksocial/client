import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/toggles/follow_button.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/design_system/tokens/shapes.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

class SuggestedProfile extends StatelessWidget {
  const SuggestedProfile({
    required this.imageUrl,
    required this.userName,
    required this.userHandle,
    required this.isFollowing,
    required this.onFollow,
    required this.onUnfollow,
    this.showFollowButton = true,
    this.description,
    super.key,
  });

  // Convenience constructor to surface description explicitly
  const SuggestedProfile.withDescription({
    required String imageUrl,
    required String userName,
    required String userHandle,
    required bool isFollowing,
    required VoidCallback onFollow,
    required VoidCallback onUnfollow,
    required String description,
    bool showFollowButton = true,
    Key? key,
  }) : this(
         imageUrl: imageUrl,
         userName: userName,
         userHandle: userHandle,
         isFollowing: isFollowing,
         onFollow: onFollow,
         onUnfollow: onUnfollow,
         showFollowButton: showFollowButton,
         description: description,
         key: key,
       );

  final String imageUrl;
  final String userName;
  final String userHandle;
  final bool isFollowing;
  final VoidCallback onFollow;
  final VoidCallback onUnfollow;
  final bool showFollowButton;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppShapes.squircleRadius);
    final borderColor = isDark ? AppColors.grey800 : AppColors.grey200;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Material(
        color: isDark ? AppColors.grey700 : AppColors.grey100,
        shape: RoundedSuperellipseBorder(borderRadius: radius),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: ShapeDecoration(
            shape: RoundedSuperellipseBorder(
              side: BorderSide(color: borderColor),
              borderRadius: radius,
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
                        if (description?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 3),
                          SizedBox(
                            width: 180,
                            child: Text(
                              description!,
                              style: AppTypography.textExtraSmallThin,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                if (showFollowButton)
                  FollowButton(
                    isFollowing: isFollowing,
                    onFollow: onFollow,
                    onUnfollow: onUnfollow,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
