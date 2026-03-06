import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/toggles/follow_button.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/shapes.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    required this.imageUrl,
    required this.userName,
    required this.userHandle,
    required this.isFollowing,
    required this.onFollow,
    required this.onUnfollow,
    this.isBlocking = false,
    this.onUnblock,
    this.showFollowButton = true,
    this.description,
    this.onTap,
    super.key,
  });

  // Convenience constructor to surface description explicitly
  const ProfileCard.withDescription({
    required String imageUrl,
    required String userName,
    required String userHandle,
    required bool isFollowing,
    required VoidCallback onFollow,
    required VoidCallback onUnfollow,
    required String description,
    bool isBlocking = false,
    VoidCallback? onUnblock,
    bool showFollowButton = true,
    VoidCallback? onTap,
    Key? key,
  }) : this(
         imageUrl: imageUrl,
         userName: userName,
         userHandle: userHandle,
         isFollowing: isFollowing,
         onFollow: onFollow,
         onUnfollow: onUnfollow,
         isBlocking: isBlocking,
         onUnblock: onUnblock,
         showFollowButton: showFollowButton,
         description: description,
         onTap: onTap,
         key: key,
       );

  final String imageUrl;
  final String userName;
  final String userHandle;
  final bool isFollowing;
  final bool isBlocking;
  final VoidCallback onFollow;
  final VoidCallback onUnfollow;
  final VoidCallback? onUnblock;
  final bool showFollowButton;
  final String? description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppShapes.squircleRadius);
    final borderColor = isDark ? AppColors.grey800 : AppColors.grey200;

    final Widget content = ConstrainedBox(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                fadeInDuration: Duration.zero,
                                imageUrl: imageUrl,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  width: 36,
                                  height: 36,
                                  color: isDark
                                      ? AppColors.grey600
                                      : AppColors.grey300,
                                  child: Icon(
                                    Icons.person,
                                    size: 20,
                                    color: isDark
                                        ? AppColors.grey400
                                        : AppColors.grey600,
                                  ),
                                ),
                              )
                            : Container(
                                width: 36,
                                height: 36,
                                color: isDark
                                    ? AppColors.grey600
                                    : AppColors.grey300,
                                child: Icon(
                                  Icons.person,
                                  size: 20,
                                  color: isDark
                                      ? AppColors.grey400
                                      : AppColors.grey600,
                                ),
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userName, style: AppTypography.textSmallBold),
                            Text(
                              userHandle,
                              style: AppTypography.textSmallThin,
                            ),
                            if (description?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 3),
                              Text(
                                description!,
                                style: AppTypography.textExtraSmallThin,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (showFollowButton) ...[
                  const SizedBox(width: 8),
                  FollowButton(
                    isFollowing: isFollowing,
                    isBlocking: isBlocking,
                    onFollow: onFollow,
                    onUnfollow: onUnfollow,
                    onUnblock: onUnblock,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
