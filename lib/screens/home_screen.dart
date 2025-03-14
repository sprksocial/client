import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, BackdropFilter;
import 'dart:ui'; // For ImageFilter
import 'package:ionicons/ionicons.dart';
import '../widgets/video_side_action_bar.dart';
import '../widgets/video_info/video_info_bar.dart';
import '../widgets/video_controls/video_controller_overlay.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Calculate proper padding based on screen size and safe area
    final bottomNavHeight = 50.0; // Standard height for bottom navigation bar
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final totalBottomPadding = bottomNavHeight + bottomSafeArea;
    final topPadding = MediaQuery.of(context).padding.top;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        children: [
          // Full-screen video feed
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: 5, // Sample videos
              itemBuilder: (context, index) {
                // Sample videos with different aspect ratios to demonstrate proper sizing
                final videoUrls = [
                  'https://cdn.justdavi.dev/vid_9_16.mp4', // Vertical 9:16
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', // Horizontal 16:9
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4', // Horizontal 16:9
                  null, // Custom colored container
                  null, // Custom colored container
                ];
                
                return Padding(
                  // Add padding at bottom to prevent content from being hidden behind bottom nav
                  padding: EdgeInsets.only(bottom: totalBottomPadding),
                  child: VideoItem(
                    index: index,
                    videoUrl: index < videoUrls.length ? videoUrls[index] : null,
                  ),
                );
              },
            ),
          ),
          
          // Overlay for top navigation
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              // Add gradient background to ensure readability of the top navigation
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CupertinoColors.black.withOpacity(0.7),
                    CupertinoColors.black.withOpacity(0.0),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: topPadding + 10,
                  left: 16.0,
                  right: 16.0,
                  bottom: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 30), // For balance
                    Expanded(
                      child: Center(
                        child: CupertinoSegmentedControl<int>(
                          children: const {
                            0: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text('Following'),
                            ),
                            1: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text('For You'),
                            ),
                          },
                          onValueChanged: (value) {},
                          groupValue: 1, // Default to "For You"
                          borderColor: CupertinoColors.systemGrey,
                          selectedColor: CupertinoColors.white,
                          unselectedColor: CupertinoColors.black,
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                    ),
                    const Icon(
                      Ionicons.search_outline,
                      color: CupertinoColors.white,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom navigation bar (simulated)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: totalBottomPadding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    CupertinoColors.black.withOpacity(0.9),
                    CupertinoColors.black.withOpacity(0.0),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomSafeArea),
                  child: SizedBox(
                    height: bottomNavHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(Ionicons.home, true),
                        _buildNavItem(Ionicons.search_outline, false),
                        _buildNavItem(Ionicons.add_circle_outline, false),
                        _buildNavItem(Ionicons.chatbubble_outline, false),
                        _buildNavItem(Ionicons.person_outline, false),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(IconData icon, bool isSelected) {
    return Icon(
      icon,
      color: isSelected ? CupertinoColors.white : CupertinoColors.systemGrey,
      size: 26,
    );
  }
}

class VideoItem extends StatefulWidget {
  final int index;
  final String? videoUrl;

  const VideoItem({super.key, required this.index, this.videoUrl});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isVisible = false;
  final String _videoKey = UniqueKey().toString();

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }
  
  void _initializeVideoPlayer() {
    if (widget.videoUrl != null) {
      _controller = VideoPlayerController.network(widget.videoUrl!)
        ..initialize().then((_) {
          setState(() {
            _isInitialized = true;
            // If video is visible when initialized, play it
            if (_isVisible) {
              _controller?.play();
            }
          });
        });
      
      // Add listener for video completion
      _controller?.addListener(() {
        if (_controller!.value.position >= _controller!.value.duration) {
          // Loop video
          _controller?.seekTo(Duration.zero);
          _controller?.play();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sample data for the video item
    final String username = 'username${widget.index + 1}';
    final String description = widget.videoUrl != null 
        ? 'Sample video ${widget.index + 1}: This is a video that demonstrates proper fitting on the screen without cutting off content.'
        : 'This is a placeholder for video ${widget.index + 1}';
    final List<String> hashtags = ['spark', 'sample', 'video${widget.index + 1}'];

    return SizedBox.expand(
      child: VisibilityDetector(
        key: Key(_videoKey),
        onVisibilityChanged: (visibilityInfo) {
          final isVisible = visibilityInfo.visibleFraction > 0.8;
          
          // Only take action if visibility state changed
          if (isVisible != _isVisible) {
            _isVisible = isVisible;
            
            if (_controller != null && _isInitialized) {
              if (isVisible) {
                _controller?.play();
              } else {
                _controller?.pause();
              }
            }
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Blurred video background
            if (widget.videoUrl != null && _controller != null && _isInitialized)
              _buildBlurredBackground(),
            
            // Video content - main focus
            Center(
              child: _buildVideoContent(),
            ),
            
            // Gradient overlay for better text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.3),
                    ],
                    stops: const [0.0, 0.5, 0.65, 0.75, 0.85, 0.95],
                  ),
                ),
              ),
            ),
            
            // Video controller overlay - new addition
            if (widget.videoUrl != null && _controller != null && _isInitialized)
              VideoControllerOverlay(
                controller: _controller!,
                onTap: () {
                  // This is handled internally by the controller
                },
              ),

            // Video info
            Positioned(
              bottom: 20,
              left: 10,
              right: 70, // Give space for the side action bar
              child: VideoInfoBar(
                username: username,
                description: description,
                hashtags: hashtags,
                onUsernameTap: () {
                  // Handle username tap
                },
                onHashtagTap: () {
                  // Handle hashtag tap
                },
              ),
            ),

            // Right side actions
            Positioned(
              right: 10,
              bottom: 100,
              child: VideoSideActionBar(
                likeCount: '${(widget.index + 1) * 35}K',
                commentCount: '${(widget.index + 1) * 12}K',
                bookmarkCount: '${(widget.index + 1) * 8}K',
                shareCount: '${(widget.index + 1) * 20}K',
                onLikePressed: () {
                  // Handle like action
                },
                onCommentPressed: () {
                  // Handle comment action
                },
                onBookmarkPressed: () {
                  // Handle bookmark action
                },
                onSharePressed: () {
                  // Handle share action
                },
                onProfilePressed: () {
                  // Handle profile action
                },
              ),
            ),
            
            // Loading indicator
            if (widget.videoUrl != null && !_isInitialized)
              const Center(
                child: CupertinoActivityIndicator(
                  color: CupertinoColors.white,
                  radius: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Build the blurred background
  Widget _buildBlurredBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Scaled version of the video that fills the entire background
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
        // Blur filter overlay
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
          child: Container(
            color: CupertinoColors.black.withOpacity(0.3), // Darkens the blur slightly
          ),
        ),
      ],
    );
  }

  Widget _buildVideoContent() {
    if (widget.videoUrl != null && _controller != null && _isInitialized) {
      // Calculate the appropriate size for the video while maintaining aspect ratio
      final videoSize = _controller!.value.size;
      
      double videoWidth = videoSize.width;
      double videoHeight = videoSize.height;
      
      // Calculate the scaling factor to fit the video properly
      double aspectRatio = videoWidth / videoHeight;
      
      Widget videoWidget;
      
      if (aspectRatio > 1) {
        // Horizontal video - use FittedBox with BoxFit.contain
        // This ensures the entire video is visible and centered
        videoWidget = FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: videoWidth,
            height: videoHeight,
            child: VideoPlayer(_controller!),
          ),
        );
      } else {
        // Vertical video - fit height to screen
        videoWidget = AspectRatio(
          aspectRatio: aspectRatio,
          child: VideoPlayer(_controller!),
        );
      }
      
      return videoWidget;
    } else {
      // Placeholder for videos without a URL or while loading
      return Container(
        color: widget.index % 2 == 0 ? CupertinoColors.systemIndigo : CupertinoColors.systemPurple,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Ionicons.play_circle_outline,
                size: 80,
                color: CupertinoColors.white.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Video ${widget.index + 1}',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}