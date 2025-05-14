import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/providers/video_state_provider.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/video_controller_overlay.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/video_info_bar.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/video_side_action_bar.dart';

class VideoPostItem extends ConsumerStatefulWidget {
  final int index;
  final String? videoUrl;
  final VideoPlayerController? preloadedController;
  final String? localVideoPath;
  final bool isVisible;
  
  // Content info
  final String username;
  final String description;
  final List<String> hashtags;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final int shareCount;
  final String? profileImageUrl;
  final String? videoAlt;
  
  // Flags
  final bool isLiked;
  final bool isSprk; 
  final bool disableBackgroundBlur;
  
  // Post identifiers for actions
  final String? postUri;
  final String? postCid;
  final String? authorDid;
  
  // Callbacks
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onUsernameTap;
  final Function(String)? onHashtagTap;
  final VoidCallback? onPostDeleted;

  const VideoPostItem({
    super.key,
    required this.index,
    this.videoUrl,
    this.videoAlt,
    this.preloadedController,
    this.localVideoPath,
    required this.isVisible,
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
    this.onPostDeleted,
    this.isLiked = false,
    this.isSprk = false,
    this.postUri,
    this.postCid,
    this.disableBackgroundBlur = false,
  });

  @override
  ConsumerState<VideoPostItem> createState() => _VideoItemState();
}

class _VideoItemState extends ConsumerState<VideoPostItem> {

  @override
  void initState() {
    super.initState();
    // Initialize the video state in the next frame to avoid build issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideoState();
    });
  }

  void _initializeVideoState() {
    final videoStateNotifier = ref.read(
      videoStateProvider(widget.index, initialCommentCount: widget.commentCount).notifier
    );
    
    if (widget.preloadedController != null) {
      videoStateNotifier.setPreloadedController(widget.preloadedController!);
    } else if (widget.localVideoPath != null) {
      videoStateNotifier.initializeWithFile(widget.localVideoPath!);
    } else if (widget.videoUrl != null) {
      videoStateNotifier.initializeWithUrl(widget.videoUrl!);
    }
    
    // Set initial visibility
    videoStateNotifier.setVisibility(widget.isVisible);
  }

  @override
  void didUpdateWidget(VideoPostItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final videoStateNotifier = ref.read(
      videoStateProvider(widget.index).notifier
    );
    
    // Update comment count if it changed
    if (oldWidget.commentCount != widget.commentCount) {
      videoStateNotifier.updateCommentCount(widget.commentCount);
    }
    
    // Update visibility if it changed
    if (oldWidget.isVisible != widget.isVisible) {
      videoStateNotifier.setVisibility(widget.isVisible);
    }
    
    // Reinitialize if video source changed
    if (oldWidget.preloadedController != widget.preloadedController ||
        oldWidget.videoUrl != widget.videoUrl ||
        oldWidget.localVideoPath != widget.localVideoPath) {
      _initializeVideoState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoStateProvider(widget.index));
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background (blurred video or placeholder)
        IgnorePointer(
          ignoring: true, 
          child: _VideoBackground(
            controller: videoState.controller,
            isInitialized: videoState.isInitialized,
            disableBackgroundBlur: widget.disableBackgroundBlur,
            isDarkMode: isDarkMode,
          ),
        ),
        
        // Main content (video or placeholder)
        Center(
          child: videoState.isInitialized && videoState.controller != null 
              ? _VideoContent(controller: videoState.controller!)
              : _VideoPlaceholder(index: widget.index),
        ),
        
        // Video overlay controls (if video is initialized)
        if (videoState.isInitialized && videoState.controller != null) 
          VideoControllerOverlay(
            controller: videoState.controller!,
            onLikePressed: widget.onLikePressed,
            isLiked: widget.isLiked,
            onTap: () {}, // Empty as it's handled internally
          ),
        
        // Gradient overlay
        IgnorePointer(
          ignoring: true, 
          child: _GradientOverlay(isExpanded: videoState.isDescriptionExpanded),
        ),
        
        // Info bar (username, description)
        Positioned(
          bottom: 20,
          left: 10,
          right: 65,
          child: VideoInfoBar(
            username: widget.username,
            description: widget.description,
            hashtags: widget.hashtags,
            isSprk: widget.isSprk,
            altText: widget.videoAlt,
            onUsernameTap: widget.onUsernameTap,
            onHashtagTap: widget.onHashtagTap,
            onDescriptionExpandToggle: (isExpanded) {
              ref.read(videoStateProvider(widget.index).notifier)
                 .toggleDescription(isExpanded);
            },
          ),
        ),
        
        // Side action bar (like, comment, share buttons)
        Positioned(
          right: 16,
          bottom: 16,
          child: VideoSideActionBar(
            likeCount: "${widget.likeCount}",
            commentCount: "${videoState.commentCount}",
            shareCount: "${widget.shareCount}",
            profileImageUrl: widget.profileImageUrl,
            isLiked: widget.isLiked,
            onLikePressed: widget.onLikePressed,
            onCommentPressed: () {
              if (widget.onCommentPressed != null) {
                widget.onCommentPressed!();
              } else {
                final notifier = ref.read(videoStateProvider(widget.index).notifier);
                notifier.setShowComments(true);
                // Here you would trigger comments display
                // When comments close, call notifier.setShowComments(false)
              }
            },
            onSharePressed: widget.onSharePressed,
            onProfilePressed: widget.onProfilePressed,
            postCid: widget.postCid,
            postUri: widget.postUri,
            authorDid: widget.authorDid,
            onPostDeleted: widget.onPostDeleted,
            isImage: false,
          ),
        ),
        
        // Loading indicator for network videos
        if (widget.videoUrl != null && widget.localVideoPath == null && 
            widget.preloadedController == null && !videoState.isInitialized)
          const Center(child: CircularProgressIndicator(color: AppColors.white)),
          
        // Error message if video failed to load
        if (videoState.error != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                videoState.error!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget that displays the blurred video background
class _VideoBackground extends StatelessWidget {
  final VideoPlayerController? controller;
  final bool isInitialized;
  final bool disableBackgroundBlur;
  final bool isDarkMode;

  const _VideoBackground({
    required this.controller,
    required this.isInitialized,
    required this.disableBackgroundBlur,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    if (!isInitialized || controller == null || disableBackgroundBlur) {
      return Container(color: isDarkMode ? Colors.black : AppColors.darkBackground);
    }

    return Container(
      color: isDarkMode ? Colors.black : AppColors.darkBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Transform.scale(
                scale: 1.1, 
                child: Opacity(
                  opacity: 0.4, 
                  child: VideoPlayer(controller!),
                ),
              ),
            ),
          ),
          Container(color: isDarkMode 
            ? Colors.black.withAlpha(100) 
            : AppColors.darkBackground.withAlpha(100)
          ),
        ],
      ),
    );
  }
}

/// Widget that displays the main video content
class _VideoContent extends StatelessWidget {
  final VideoPlayerController controller;

  const _VideoContent({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final videoSize = controller.value.size;
    if (videoSize.width <= 0 || videoSize.height <= 0) {
      return const SizedBox.shrink();
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: videoSize.width, 
          height: videoSize.height, 
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

/// Widget that displays a placeholder when no video is available
class _VideoPlaceholder extends StatelessWidget {
  final int index;

  const _VideoPlaceholder({
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      color: index.isEven
          ? (isDarkMode ? Colors.indigo.shade900 : Colors.indigo.shade200)
          : (isDarkMode ? Colors.purple.shade900 : Colors.purple.shade200),
      child: const SizedBox.shrink(),
    );
  }
}

/// Widget that displays a gradient overlay
class _GradientOverlay extends StatelessWidget {
  final bool isExpanded;

  const _GradientOverlay({
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
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
            Colors.black.withAlpha(isExpanded ? 30 : 10),
            Colors.black.withAlpha(isExpanded ? 80 : 40),
            Colors.black.withAlpha(isExpanded ? 150 : 80),
            Colors.black.withAlpha(isExpanded ? 200 : 160),
          ],
          stops: isExpanded 
            ? const [0.0, 0.4, 0.5, 0.6, 0.75, 0.9] 
            : const [0.0, 0.5, 0.65, 0.75, 0.85, 0.95],
        ),
      ),
    );
  }
} 