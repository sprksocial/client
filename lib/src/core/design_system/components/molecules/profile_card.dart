import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/toggles/follow_button.dart';
import 'package:spark/src/core/design_system/components/molecules/profile_avatar.dart';
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
    this.hasStories = false,
    this.onAvatarTap,
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
    bool hasStories = false,
    VoidCallback? onAvatarTap,
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
         hasStories: hasStories,
         onAvatarTap: onAvatarTap,
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
  final bool hasStories;
  final VoidCallback? onAvatarTap;

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
                      ProfileAvatar(
                        avatarUrl: imageUrl.isNotEmpty ? imageUrl : null,
                        displayName: userName,
                        size: 36,
                        hasStories: hasStories,
                        onTap: onAvatarTap ?? onTap,
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
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}
