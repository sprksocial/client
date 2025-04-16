import 'dart:ui'; // For ImageFilter if needed for background

import 'package:flutter/material.dart';
import 'package:sparksocial/widgets/image/image_carousel.dart';

import '../../utils/app_colors.dart'; // For potential background fallback
import '../post/post_item_base.dart'; // Import the base class

// Convert to StatefulWidget extending PostItemBase
class ImagePostItem extends PostItemBase {
  final List<String> imageUrls;
  @override
  final List<String> imageAlts;
  // isVisible is often managed externally for image carousels or pages, pass it in
  final bool isVisible;
  // Add postCid if needed for comments, passed to super
  // final String postCid; // Inherited from PostItemBase

  const ImagePostItem({
    super.key,
    required super.index,
    required this.imageUrls,
    required this.imageAlts,
    required super.username,
    required super.description,
    required super.hashtags,
    required super.likeCount,
    required super.commentCount,
    super.bookmarkCount,
    required super.shareCount,
    super.profileImageUrl,
    required super.authorDid,
    required super.isLiked,
    required super.isSprk,
    required super.postUri, // Pass postUri for comments
    required super.postCid, // Pass postCid for comments
    this.isVisible = false, // Default visibility
    super.disableBackgroundBlur,
    required super.onLikePressed,
    super.onCommentPressed, // Pass callback to base
    required super.onBookmarkPressed,
    required super.onSharePressed,
    super.onProfilePressed, // Pass callback to base
    required super.onUsernameTap,
    super.onHashtagTap,
  });

  @override
  State<ImagePostItem> createState() => _ImagePostItemState();
}

// Create State class extending PostItemBaseState
class _ImagePostItemState extends PostItemBaseState<ImagePostItem> {
  // --- Implement required abstract members ---

  @override
  bool get isVisible => widget.isVisible; // Get visibility from widget property

  @override
  void pauseMedia() {
    // No media to pause for images
  }

  @override
  void playMedia() {
    // No media to play for images
  }

  @override
  Widget buildBackground(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    if (widget.disableBackgroundBlur || widget.imageUrls.isEmpty) {
      return Container(color: isDarkMode ? Colors.black : AppColors.darkBackground);
    }

    // Use ImageCarousel's background logic if suitable, or replicate here
    return Container(
      color: isDarkMode ? Colors.black : AppColors.darkBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred first image
          ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
              child: Transform.scale(
                scale: 1.2,
                child: Opacity(
                  opacity: 0.5,
                  child: Image.network(
                    widget.imageUrls.first,
                    fit: BoxFit.cover,
                    // Add error builder for background image
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          // Darkened overlay
          Container(color: isDarkMode ? Colors.black.withAlpha(120) : AppColors.darkBackground.withAlpha(120)),
        ],
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    // The main content is the ImageCarousel
    return ImageCarousel(
      imageUrls: widget.imageUrls,
      imageAlts: widget.imageAlts,
      disableBackgroundBlur: widget.disableBackgroundBlur,
      // Ensure ImageCarousel doesn't conflict with the base background
    );
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    // Use the base class build method which assembles the common parts
    // The base build calls buildBackground, buildContent, buildGradientOverlay, etc.
    return super.build(context);
    // No need to manually position SideActionBar or InfoBar here anymore.
  }
}
