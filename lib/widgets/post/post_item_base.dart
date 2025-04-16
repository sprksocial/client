import 'dart:developer';

import 'package:flutter/material.dart';

import '../../screens/profile_screen.dart';
import '../../utils/formatters/text_formatter.dart';
import '../comments/comments_tray.dart';
import '../video_info/video_info_bar.dart'; // Reusing VideoInfoBar for now
import '../video_side_action_bar.dart'; // Reusing VideoSideActionBar for now

/// Base class for post items (Video, Image, etc.) to handle common parameters.
abstract class PostItemBase extends StatefulWidget {
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
  final VoidCallback? onCommentPressed; // Added for unified handling
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onUsernameTap;
  final Function(String)? onHashtagTap;
  final String? authorDid;
  final bool isLiked;
  final bool isSprk;
  final String? postUri; // Renamed from videoUri
  final String? postCid; // Renamed from videoCid
  final bool disableBackgroundBlur;
  final String? videoAlt;
  final List<String> imageAlts;

  const PostItemBase({
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
    this.onCommentPressed,
    this.onBookmarkPressed,
    this.onSharePressed,
    this.onProfilePressed,
    this.onUsernameTap,
    this.onHashtagTap,
    this.authorDid,
    this.isLiked = false,
    this.isSprk = false,
    this.postUri,
    this.postCid,
    this.disableBackgroundBlur = false,
    this.videoAlt,
    this.imageAlts = const [],
  });
}

/// Base state class with common methods and UI building blocks.
abstract class PostItemBaseState<T extends PostItemBase> extends State<T> {
  bool isVisible = true;
  bool showComments = false;
  bool _isDescriptionExpanded = false;
  late int _commentCount;

  @override
  void initState() {
    super.initState();
    _commentCount = widget.commentCount;
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commentCount != widget.commentCount) {
      setState(() {
        _commentCount = widget.commentCount;
      });
    }
  }

  /// Abstract method for subclasses to build the main content (VideoPlayer, ImageCarousel).
  Widget buildContent(BuildContext context);

  /// Abstract method for subclasses to build the background (Blurred video, blurred image, solid color).
  Widget buildBackground(BuildContext context);

  /// Builds overlays that should sit directly on top of the content, below the gradient/UI bars.
  /// Returns an empty list by default. Video players can override this.
  List<Widget> buildContentOverlays(BuildContext context) {
    return []; // Default implementation returns no overlays
  }

  /// Abstract method to pause any media playing in the content.
  void pauseMedia();

  /// Abstract method to play/resume any media playing in the content.
  void playMedia();

  void _handleDescriptionExpandToggle(bool isExpanded) {
    if (!mounted) return;
    setState(() {
      _isDescriptionExpanded = isExpanded;
    });
  }

  /// Toggle comments tray.
  void toggleComments() {
    // Allow overriding via widget callback first
    if (widget.onCommentPressed != null) {
      widget.onCommentPressed!();
      return; // Assume the callback handles everything (pausing, showing tray)
    }

    // Default implementation: Pause media and show tray
    if (widget.postUri == null || widget.postCid == null) {
      debugPrint("Cannot open comments: postUri or postCid is null.");
      return;
    }

    pauseMedia();

    if (!mounted) return;
    setState(() {
      showComments = true;
    });

    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    showCommentsTray(
      context: context,
      postUri: widget.postUri!,
      postCid: widget.postCid!,
      commentCount: _commentCount,
      onClose: (updatedCount) {
        if (!mounted) return;
        if (updatedCount != _commentCount) {
          setState(() {
            showComments = false;
            _commentCount = updatedCount; // Update local comment count
          });
        } else {
          setState(() {
            showComments = false;
          });
        }

        // Resume media only if the item is still visible
        if (isVisible) {
          playMedia();
        }
      },
      isDarkMode: isDarkMode,
      isSprk: widget.isSprk,
    );
  }

  /// Navigate to profile screen.
  void navigateToProfile() {
    log("navigateToProfile");
    // Allow overriding via widget callback first
    if (widget.onProfilePressed != null) {
      widget.onProfilePressed!();
      // Optionally, still navigate if authorDid is present? Decide based on desired behavior.
      // For now, if onProfilePressed is provided, we assume it handles navigation.
      return;
    }

    // Default implementation: Navigate to ProfileScreen if authorDid exists
    if (widget.authorDid == null) {
      debugPrint("Cannot navigate to profile: authorDid is null.");
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ProfileScreen(did: widget.authorDid),
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

  // --- Common UI Building Blocks ---

  Widget buildGradientOverlay() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withAlpha(_isDescriptionExpanded ? 30 : 10),
            Colors.black.withAlpha(_isDescriptionExpanded ? 80 : 40),
            Colors.black.withAlpha(_isDescriptionExpanded ? 150 : 80),
            Colors.black.withAlpha(_isDescriptionExpanded ? 200 : 160),
          ],
          stops: _isDescriptionExpanded ? const [0.0, 0.4, 0.5, 0.6, 0.75, 0.9] : const [0.0, 0.5, 0.65, 0.75, 0.85, 0.95],
        ),
      ),
    );
  }

  Widget buildInfoBar() {
    return Positioned(
      bottom: 20,
      left: 10,
      right: 70, // Give space for the side action bar
      child: VideoInfoBar(
        // Consider renaming VideoInfoBar later if needed
        username: widget.username,
        description: widget.description,
        hashtags: widget.hashtags,
        isSprk: widget.isSprk,
        altText: widget.videoAlt ?? (widget.imageAlts.isNotEmpty ? widget.imageAlts.first : null),
        onUsernameTap: widget.onUsernameTap,
        onHashtagTap: widget.onHashtagTap,
        onDescriptionExpandToggle: _handleDescriptionExpandToggle,
      ),
    );
  }

  Widget buildSideActionBar() {
    return Positioned(
      right: 10,
      bottom: 100,
      child: VideoSideActionBar(
        // Consider renaming VideoSideActionBar later
        likeCount: TextFormatter.formatCount(widget.likeCount),
        commentCount: TextFormatter.formatCount(_commentCount), // Use local state
        bookmarkCount: TextFormatter.formatCount(widget.bookmarkCount),
        shareCount: TextFormatter.formatCount(widget.shareCount),
        profileImageUrl: widget.profileImageUrl,
        isLiked: widget.isLiked,
        onLikePressed: widget.onLikePressed ?? () {},
        onCommentPressed: toggleComments, // Use the unified method
        onBookmarkPressed: widget.onBookmarkPressed ?? () {},
        onSharePressed: widget.onSharePressed ?? () {},
        onProfilePressed: navigateToProfile, // Use the unified method
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Base structure using the abstract and common methods
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(ignoring: true, child: buildBackground(context)),
        Center(child: buildContent(context)),
        // Insert content-specific overlays here
        ...buildContentOverlays(context),
        IgnorePointer(ignoring: true, child: buildGradientOverlay()),
        // Add other common overlays like controls if needed (VideoControllerOverlay is video specific)
        buildInfoBar(),
        buildSideActionBar(),
        // Add common loading/error states if applicable (Subclasses might add more on top)
      ],
    );
  }
}
