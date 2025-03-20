import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../video/video_item.dart';
import '../../utils/app_colors.dart';

class ProfileVideoTile extends StatelessWidget {
  final String? videoUrl;
  final String? thumbnailUrl;
  final String username;
  final String description;
  final List<String> hashtags;
  final int index;
  final int likeCount;
  final VoidCallback onTap;

  const ProfileVideoTile({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.username,
    required this.description,
    required this.hashtags,
    required this.index,
    this.likeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.richPurple.withAlpha(120),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video thumbnail
            thumbnailUrl != null && thumbnailUrl!.isNotEmpty
                ? Image.network(
                    thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        FluentIcons.video_24_regular,
                        color: AppColors.white.withAlpha(204),
                        size: 24
                      )
                    ),
                  )
                : Center(
                    child: Icon(
                      FluentIcons.video_24_regular,
                      color: AppColors.white.withAlpha(204),
                      size: 24
                    )
                  ),

            // View count indicator
            Positioned(
              bottom: 5,
              left: 5,
              child: Row(
                children: [
                  const Icon(
                    FluentIcons.eye_24_regular,
                    color: AppColors.white,
                    size: 12
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$likeCount',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12
                    ),
                  ),
                ],
              ),
            ),

            // Play indicator
            const Positioned(
              top: 5,
              right: 5,
              child: Icon(
                FluentIcons.play_circle_24_filled,
                color: AppColors.white,
                size: 16
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to expand this tile into a full video player
  VideoItem toVideoItem({
    required VoidCallback onLikePressed,
    required VoidCallback onBookmarkPressed,
    required VoidCallback onSharePressed,
    required VoidCallback onProfilePressed,
    required VoidCallback onUsernameTap,
    required VoidCallback onHashtagTap,
  }) {
    return VideoItem(
      index: index,
      videoUrl: videoUrl,
      username: username,
      description: description,
      hashtags: hashtags,
      likeCount: likeCount,
      commentCount: (index + 1) * 12,
      bookmarkCount: (index + 1) * 8,
      shareCount: (index + 1) * 20,
      onLikePressed: onLikePressed,
      onBookmarkPressed: onBookmarkPressed,
      onSharePressed: onSharePressed,
      onProfilePressed: onProfilePressed,
      onUsernameTap: onUsernameTap,
      onHashtagTap: onHashtagTap,
    );
  }
}