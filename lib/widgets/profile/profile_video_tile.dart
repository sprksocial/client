import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  final bool isSprk;

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
    this.isSprk = false,
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
            // Video thumbnail with caching
            if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Icon(
                    FluentIcons.video_24_regular,
                    color: AppColors.white.withAlpha(204),
                    size: 24
                  )
                ),
                // Key prevents unnecessary rebuilds
                key: ValueKey('thumbnail_$index'),
                // Memory caching
                memCacheHeight: 300,
                memCacheWidth: 200,
              )
            else
              Center(
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

            // Sprk indicator
            Positioned(
              top: 5,
              left: 5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(42),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withAlpha(30),
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: isSprk
                  ? SvgPicture.asset('assets/images/sprk.svg', width: 14, height: 14)
                  : SvgPicture.asset('assets/images/bsky.svg', width: 14, height: 14),
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
    required Function(String) onHashtagTap,
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