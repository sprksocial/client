import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../comments/comments_tray.dart';
import '../../screens/profile_screen.dart';

/// Base class for video player widgets to handle common functionality
abstract class VideoPlayerBase extends StatefulWidget {
  final int index;
  final String username;
  final String description;
  final List<String> hashtags;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final int shareCount;
  final String? profileImageUrl;
  final VoidCallback? onLikePressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onUsernameTap;
  final VoidCallback? onHashtagTap;
  final String? authorDid;
  final bool isLiked;
  final bool isSprk;
  final String? videoUri;

  const VideoPlayerBase({
    super.key,
    required this.index,
    this.username = '',
    this.description = '',
    this.hashtags = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.bookmarkCount = 0,
    this.shareCount = 0,
    this.profileImageUrl,
    this.onLikePressed,
    this.onBookmarkPressed,
    this.onSharePressed,
    this.onProfilePressed,
    this.onUsernameTap,
    this.onHashtagTap,
    this.authorDid,
    this.isLiked = false,
    this.isSprk = false,
    this.videoUri,
  });
}

/// Base state class with common methods for both video player types
abstract class VideoPlayerBaseState<T extends VideoPlayerBase> extends State<T> {
  // Protected variable accessible to subclasses
  bool showComments = false;

  /// Get the current video player controller
  VideoPlayerController? get videoController;

  /// Check if the video player is initialized
  bool get isInitialized;

  /// Check if the video is currently visible
  bool get isVisible;

  /// Pause the video player
  void pauseVideo();

  /// Play the video player
  void playVideo();

  /// Toggle comments visibility and show the comments tray
  void toggleComments() {
    if (widget.videoUri == null) {
      return;
    }

    pauseVideo();

    setState(() {
      showComments = true;
    });

    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    showCommentsTray(
      context: context,
      postUri: widget.videoUri!,
      commentCount: widget.commentCount,
      onClose: () {
        setState(() {
          showComments = false;
          if (isVisible && isInitialized) {
            playVideo();
          }
        });
      },
      isDarkMode: isDarkMode,
      isSprk: widget.isSprk,
    );
  }

  /// Navigate to profile screen
  void navigateToProfile() {
    if (widget.authorDid != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
            ProfileScreen(did: widget.authorDid),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }

    // Still call the original callback if provided
    if (widget.onProfilePressed != null) {
      widget.onProfilePressed!();
    }
  }
}