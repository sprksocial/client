import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';
import '../common/user_avatar.dart';

class SuggestedAccountCard extends StatelessWidget {
  final String username;
  final String handle;
  final String avatarUrl;
  final String? description;
  final VoidCallback? onTap;
  final VoidCallback? onFollowTap;
  final bool showFollowButton;

  const SuggestedAccountCard({
    super.key,
    required this.username,
    required this.handle,
    required this.avatarUrl,
    this.description,
    this.onTap,
    this.onFollowTap,
    this.showFollowButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900]!.withOpacity(0.4) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.getTextColor(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    handle,
                    style: TextStyle(fontSize: 14, color: AppTheme.getSecondaryTextColor(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description != null && description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        description!,
                        style: TextStyle(fontSize: 13, color: AppTheme.getSecondaryTextColor(context)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            if (showFollowButton)
              GestureDetector(
                onTap: onFollowTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.pink, borderRadius: BorderRadius.circular(24)),
                  child: const Text('Follow', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
