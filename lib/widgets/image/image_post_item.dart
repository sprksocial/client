import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:sparksocial/widgets/image/image_carousel.dart';
import 'package:sparksocial/widgets/video_info/hashtag_list.dart';

class ImagePostItem extends StatelessWidget {
  final int index;
  final List<String> imageUrls;
  final String username;
  final String description;
  final List<String> hashtags;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final int shareCount;
  final String? profileImageUrl;
  final String authorDid;
  final bool isLiked;
  final bool isSprk;
  final String postUri;
  final bool isVisible;
  final bool disableBackgroundBlur;
  final Function() onLikePressed;
  final Function() onBookmarkPressed;
  final Function() onSharePressed;
  final Function() onProfilePressed;
  final Function() onUsernameTap;
  final Function(String)? onHashtagTap;

  const ImagePostItem({
    Key? key,
    required this.index,
    required this.imageUrls,
    required this.username,
    required this.description,
    required this.hashtags,
    required this.likeCount,
    required this.commentCount,
    this.bookmarkCount = 0,
    required this.shareCount,
    this.profileImageUrl,
    required this.authorDid,
    required this.isLiked,
    required this.isSprk,
    required this.postUri,
    this.isVisible = false,
    this.disableBackgroundBlur = false,
    required this.onLikePressed,
    required this.onBookmarkPressed,
    required this.onSharePressed,
    required this.onProfilePressed,
    required this.onUsernameTap,
    this.onHashtagTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image carousel
        Positioned.fill(
          child: ImageCarousel(
            imageUrls: imageUrls,
            disableBackgroundBlur: disableBackgroundBlur,
          ),
        ),

        // Gradient overlay for better text visibility
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  stops: const [0.7, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Right side actions
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: [
              // Profile image
              GestureDetector(
                onTap: onProfilePressed,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: profileImageUrl != null
                        ? Image.network(
                            profileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          )
                        : const CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Like button
              Column(
                children: [
                  IconButton(
                    onPressed: onLikePressed,
                    icon: Icon(
                      isLiked
                          ? FluentIcons.heart_24_filled
                          : FluentIcons.heart_24_regular,
                      color: isLiked ? Colors.red : Colors.white,
                      size: 30,
                    ),
                  ),
                  Text(
                    '$likeCount',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Comment button
              Column(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      FluentIcons.comment_24_regular,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Text(
                    '$commentCount',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Share button
              Column(
                children: [
                  IconButton(
                    onPressed: onSharePressed,
                    icon: const Icon(
                      FluentIcons.share_24_regular,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Text(
                    '$shareCount',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),

        //Bottom text info
        Positioned(
          left: 12,
          right: 70,
          bottom: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username
              GestureDetector(
                onTap: onUsernameTap,
                child: Row(
                  children: [
                    Text(
                      '@$username',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isSprk)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Icon(
                          FluentIcons.sparkle_24_filled,
                          color: Colors.amber[300],
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                description,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Hashtags
              if (hashtags.isNotEmpty)
                HashtagList(
                  hashtags: hashtags,
                  onHashtagTap: onHashtagTap,
                ),
            ],
          ),
        ),
      ],
    );
  }
}