import 'package:flutter/material.dart';

import 'package:sparksocial/src/core/widgets/common/user_avatar.dart';

class SuggestedAccountCard extends StatelessWidget {
  final String username;
  final String handle;
  final String avatarUrl;
  final String? description;
  final VoidCallback? onTap;
  final VoidCallback? onFollowTap;
  final VoidCallback? onUnfollowTap;
  final bool showFollowButton;
  final bool isFollowing;

  const SuggestedAccountCard({
    super.key,
    required this.username,
    required this.handle,
    required this.avatarUrl,
    this.description,
    this.onTap,
    this.onFollowTap,
    this.onUnfollowTap,
    this.showFollowButton = true,
    this.isFollowing = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = theme.textTheme.bodyLarge?.color;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow.withAlpha(102),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              child: UserAvatar(imageUrl: avatarUrl, username: username, size: 48),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16, 
                      color: textColor
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    handle,
                    style: TextStyle(
                      fontSize: 14, 
                      color: secondaryTextColor
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description != null && description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        description!,
                        style: TextStyle(
                          fontSize: 13, 
                          color: secondaryTextColor
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            if (showFollowButton)
              isFollowing
                  ? GestureDetector(
                      onTap: onUnfollowTap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: colorScheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'Following',
                          style: TextStyle(
                            color: colorScheme.primary, 
                            fontWeight: FontWeight.w600, 
                            fontSize: 14
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: onFollowTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary, 
                          borderRadius: BorderRadius.circular(24)
                        ),
                        child: Text(
                          'Follow',
                          style: TextStyle(
                            color: colorScheme.onPrimary, 
                            fontWeight: FontWeight.w600, 
                            fontSize: 14
                          ),
                        ),
                      ),
                    ),
          ],
        ),
      ),
    );
  }
} 