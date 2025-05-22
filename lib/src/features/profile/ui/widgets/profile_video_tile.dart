import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

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
  final bool isImage;

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
    this.isImage = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget thumbnailWidget;
    if (thumbnailUrl case final String url when url.isNotEmpty) {
      thumbnailWidget = CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder:
            (context, url) => Container(
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            ),
        errorWidget:
            (context, url, error) => Container(
              color: Colors.black,
              child: const Center(child: Icon(FluentIcons.video_24_regular, color: Colors.white, size: 24)),
            ),
      );
    } else {
      thumbnailWidget = Center(child: Icon(FluentIcons.video_24_regular, color: AppColors.white.withAlpha(204), size: 24));
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.richPurple.withAlpha(120),
        child: Stack(
          fit: StackFit.expand,
          children: [
            thumbnailWidget,
            Positioned(
              bottom: 5,
              left: 5,
              child: Row(
                children: [
                  const Icon(FluentIcons.eye_24_regular, color: AppColors.white, size: 12),
                  const SizedBox(width: 4),
                  Text('$likeCount', style: const TextStyle(color: AppColors.white, fontSize: 12)),
                ],
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(42),
                  boxShadow: [
                    BoxShadow(color: AppColors.black.withAlpha(30), blurRadius: 4, spreadRadius: 1, offset: const Offset(0, 0)),
                  ],
                ),
                child: Icon(
                  isImage ? FluentIcons.image_24_regular : FluentIcons.play_circle_24_filled,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
            ),
            Positioned(
              top: 5,
              left: 5,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(42),
                  boxShadow: [
                    BoxShadow(color: AppColors.black.withAlpha(30), blurRadius: 4, spreadRadius: 1, offset: const Offset(0, 0)),
                  ],
                ),
                child:
                    isSprk
                        ? SvgPicture.asset('assets/images/sprk.svg', width: 14, height: 14)
                        : SvgPicture.asset('assets/images/bsky.svg', width: 14, height: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
