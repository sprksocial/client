import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/providers/video_state_provider.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/video_controller_overlay.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/video_info_bar.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/action_buttons/side_action_bar.dart';

class PreloadedVideoItem extends ConsumerStatefulWidget {
  final int index;
  final VideoPlayerController controller;
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

  const PreloadedVideoItem({
    super.key,
    required this.index,
    required this.controller,
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
    this.videoAlt,
  });

  @override
  ConsumerState<PreloadedVideoItem> createState() => _PreloadedVideoItemState();
}

class _PreloadedVideoItemState extends ConsumerState<PreloadedVideoItem> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize provider in the next frame to avoid build issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideoState();
    });
  }
  
  void _initializeVideoState() {
    // Create the provider using the preloaded controller
    ref.read(
      preloadedVideoStateProvider(
        widget.index, 
        controller: widget.controller,
        isVisible: widget.isVisible,
        initialCommentCount: widget.commentCount,
      ).notifier
    );
  }

  @override
  void didUpdateWidget(PreloadedVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    final videoStateNotifier = ref.read(
      preloadedVideoStateProvider(
        widget.index,
        controller: widget.controller,
        isVisible: widget.isVisible
      ).notifier
    );

    // Update comment count if it changed
    if (oldWidget.commentCount != widget.commentCount) {
      videoStateNotifier.updateCommentCount(widget.commentCount);
    }

    // Update visibility if it changed
    if (oldWidget.isVisible != widget.isVisible) {
      // Defer state update to after the build cycle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // Ensure widget is still in the tree
          videoStateNotifier.setVisibility(widget.isVisible);
        }
      });
    }
    
    // If controller changed, we'd need to recreate the provider
    // but this is unlikely in the preloaded scenario
    if (oldWidget.controller != widget.controller) {
      _initializeVideoState();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final videoStateNotifier = ref.read(
      preloadedVideoStateProvider(
        widget.index,
        controller: widget.controller,
        isVisible: widget.isVisible
      ).notifier
    );
    
    videoStateNotifier.handleAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(
      preloadedVideoStateProvider(
        widget.index,
        controller: widget.controller,
        isVisible: widget.isVisible
      )
    );
    
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background (blurred video)
        IgnorePointer(
          ignoring: true, 
          child: _BlurredBackground(
            controller: widget.controller,
            isInitialized: videoState.isInitialized,
            disableBackgroundBlur: widget.disableBackgroundBlur,
            isDarkMode: isDarkMode,
          ),
        ),
        
        // Main content (video)
        Center(
          child: videoState.isInitialized
              ? _VideoPlayerContent(
                  controller: widget.controller,
                )
              : const Center(child: CircularProgressIndicator(color: AppColors.white)),
        ),
        
        // Video overlay controls
        if (videoState.isInitialized) 
          VideoControllerOverlay(
            controller: widget.controller,
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
              ref.read(preloadedVideoStateProvider(
                widget.index,
                controller: widget.controller,
                isVisible: widget.isVisible
              ).notifier).toggleDescription(isExpanded);
            },
          ),
        ),
        
        // Side action bar (like, comment, share buttons)
        Positioned(
          right: 16,
          bottom: 16,
          child: SideActionBar(
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
                final notifier = ref.read(preloadedVideoStateProvider(
                  widget.index,
                  controller: widget.controller,
                  isVisible: widget.isVisible
                ).notifier);
                
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
        
        // Loading indicator
        if (!videoState.isInitialized) 
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

/// Widget to display a blurred background from the video
class _BlurredBackground extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isInitialized;
  final bool disableBackgroundBlur;
  final bool isDarkMode;

  const _BlurredBackground({
    required this.controller,
    required this.isInitialized,
    required this.disableBackgroundBlur,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Container(color: isDarkMode ? Colors.black : AppColors.darkBackground);
    }
    
    return Container(
      color: isDarkMode ? Colors.black : AppColors.darkBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!disableBackgroundBlur)
            ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                child: Transform.scale(
                  scale: 1.2, 
                  child: Opacity(
                    opacity: 0.5, 
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
            ),
          Container(
            color: isDarkMode 
              ? Colors.black.withAlpha(120) 
              : AppColors.darkBackground.withAlpha(120)
          ),
        ],
      ),
    );
  }
}

/// Widget to display the video content
class _VideoPlayerContent extends StatelessWidget {
  final VideoPlayerController controller;

  const _VideoPlayerContent({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final videoSize = controller.value.size;
    if (videoSize.width <= 0 || videoSize.height <= 0) {
      return const Center(
        child: Text(
          "Invalid video size", 
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    
    double aspectRatio = videoSize.width / videoSize.height;

    if (aspectRatio > 1) {
      return FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: videoSize.width, 
          height: videoSize.height, 
          child: VideoPlayer(controller),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: videoSize.width, 
          height: videoSize.height, 
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

/// Widget to display a gradient overlay
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