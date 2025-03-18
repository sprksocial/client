import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../widgets/video_side_action_bar.dart';
import '../widgets/video_info/video_info_bar.dart';
import '../widgets/video_controls/video_controller_overlay.dart';
import '../widgets/comments_tray.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../utils/app_theme.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: 5, // Sample videos
              itemBuilder: (context, index) {
                final videoUrls = [
                  'https://cdn.justdavi.dev/vid_9_16.mp4', // Vertical 9:16
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', // Horizontal 16:9
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4', // Horizontal 16:9
                  null, // Custom colored container
                  null, // Custom colored container
                ];

                return VideoItem(index: index, videoUrl: index < videoUrls.length ? videoUrls[index] : null);
              },
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.only(top: topPadding + 10, left: 16.0, right: 16.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 30), // For balance
                  Expanded(
                    child: Center(
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment<int>(value: 0, label: Text('Following')),
                          ButtonSegment<int>(value: 1, label: Text('For You')),
                        ],
                        onSelectionChanged: (Set<int> value) {},
                        selected: const {1}, // Default to "For You"
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color>(
                            (states) => states.contains(WidgetState.selected) 
                              ? AppColors.white 
                              : isDarkMode ? Colors.black : AppColors.darkBackground,
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith<Color>(
                            (states) => states.contains(WidgetState.selected) 
                              ? AppColors.black 
                              : AppTheme.getTextColor(context),
                          ),
                          side: WidgetStateProperty.all(BorderSide(color: isDarkMode ? Colors.grey : AppColors.divider)),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(FluentIcons.search_24_regular),
                    color: AppTheme.getTextColor(context),
                    iconSize: 30,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
  bool _showComments = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    if (widget.videoUrl != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
        ..initialize().then((_) {
          setState(() {
            _isInitialized = true;
            if (_isVisible) {
              _controller?.play();
            }
          });
        });

      _controller?.addListener(() {
        if (_controller!.value.position >= _controller!.value.duration) {
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

  void _toggleComments() {
    if (_controller != null && _isInitialized) {
      _controller?.pause();
    }

    setState(() {
      _showComments = true;
    });

    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    
    showCommentsTray(
      context: context,
      videoId: 'video_${widget.index + 1}',
      commentCount: (widget.index + 1) * 12 * 1000, // Format as 12K
      onClose: () {
        setState(() {
          _showComments = false;
          if (_isVisible && _controller != null && _isInitialized) {
            _controller?.play();
          }
        });
      },
      isDarkMode: isDarkMode, // Use system theme preference
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
  
    final String username = 'username${widget.index + 1}';
    final String description =
        widget.videoUrl != null
            ? 'Sample video ${widget.index + 1}: This is a video that demonstrates proper fitting on the screen without cutting off content.'
            : 'This is a placeholder for video ${widget.index + 1}';
    final List<String> hashtags = ['spark', 'sample', 'video${widget.index + 1}'];

    final int commentCount = (widget.index + 1) * 12;

    return SizedBox.expand(
      child: VisibilityDetector(
        key: Key(_videoKey),
        onVisibilityChanged: (visibilityInfo) {
          final isVisible = visibilityInfo.visibleFraction > 0.8;

          if (isVisible != _isVisible) {
            _isVisible = isVisible;

            if (_controller != null && _isInitialized) {
              if (isVisible && !_showComments) {
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
            if (widget.videoUrl != null && _controller != null && _isInitialized) _buildBlurredBackground(isDarkMode),

            Center(child: _buildVideoContent()),

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
                      Colors.transparent,
                      isDarkMode ? Colors.black.withAlpha(77) : AppColors.darkBackground.withAlpha(42),
                      isDarkMode ? Colors.black.withAlpha(77) : AppColors.darkBackground.withAlpha(42),
                    ],
                    stops: const [0.0, 0.5, 0.65, 0.75, 0.85, 0.95],
                  ),
                ),
              ),
            ),

            if (widget.videoUrl != null && _controller != null && _isInitialized)
              VideoControllerOverlay(
                controller: _controller!,
                onTap: () {
                },
              ),

            Positioned(
              bottom: 20,
              left: 10,
              right: 70, // Give space for the side action bar
              child: VideoInfoBar(
                username: username,
                description: description,
                hashtags: hashtags,
                onUsernameTap: () {
                },
                onHashtagTap: () {
                },
              ),
            ),

            Positioned(
              right: 10,
              bottom: 100,
              child: VideoSideActionBar(
                likeCount: '${(widget.index + 1) * 35}K',
                commentCount: '${commentCount}K',
                bookmarkCount: '${(widget.index + 1) * 8}K',
                shareCount: '${(widget.index + 1) * 20}K',
                onLikePressed: () {
                },
                onCommentPressed: _toggleComments,
                onBookmarkPressed: () {
                },
                onSharePressed: () {
                },
                onProfilePressed: () {
                },
              ),
            ),

            if (widget.videoUrl != null && !_isInitialized) const Center(child: CircularProgressIndicator(color: AppColors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurredBackground(bool isDarkMode) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
          child: Container(
            color: isDarkMode ? Colors.black.withAlpha(77) : AppColors.darkBackground.withAlpha(42),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoContent() {
    if (widget.videoUrl != null && _controller != null && _isInitialized) {
      final videoSize = _controller!.value.size;

      double videoWidth = videoSize.width;
      double videoHeight = videoSize.height;

      double aspectRatio = videoWidth / videoHeight;

      Widget videoWidget;

      if (aspectRatio > 1) {
        videoWidget = FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(width: videoWidth, height: videoHeight, child: VideoPlayer(_controller!)),
        );
      } else {
        videoWidget = AspectRatio(aspectRatio: aspectRatio, child: VideoPlayer(_controller!));
      }

      return videoWidget;
    } else {
      final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
      
      return Container(
        color: widget.index % 2 == 0 ? 
          (isDarkMode ? Colors.indigo.shade900 : Colors.indigo.shade200) : 
          (isDarkMode ? Colors.purple.shade900 : Colors.purple.shade200),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.play_circle_24_regular, size: 80, color: AppTheme.getTextColor(context).withAlpha(179)),
              const SizedBox(height: 16),
              Text(
                'Video ${widget.index + 1}',
                style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
  }
}
