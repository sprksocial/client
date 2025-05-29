import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../services/story_view_service.dart';
import '../utils/app_colors.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stories;

  const StoryViewerScreen({super.key, required this.stories});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with TickerProviderStateMixin {
  late List<AnimationController> _progressControllers;
  int _currentStoryIndex = 0;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  double _dragOffset = 0.0;
  double _dragScale = 1.0;

  @override
  void initState() {
    super.initState();

    _progressControllers = List.generate(
      widget.stories.length,
      (index) => AnimationController(duration: const Duration(seconds: 5), vsync: this),
    );

    _startCurrentStory();
  }

  @override
  void dispose() {
    _markStoriesAsViewedUpToCurrent();
    _videoController?.dispose();

    for (final controller in _progressControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isVideoStory(Map<String, dynamic> story) {
    if (story.containsKey('embed') && story['embed'] != null) {
      final storyEmbed = story['embed'] as Map<String, dynamic>;
      return storyEmbed['\$type'] == 'so.sprk.embed.video#view';
    }
    return false;
  }

  Future<void> _initializeVideo(String videoUrl) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    try {
      await _videoController!.initialize();
      _videoController!.setLooping(false);
      setState(() {
        _isVideoInitialized = true;
      });

      // Set the animation controller duration to match video duration
      final videoDuration = _videoController!.value.duration;
      _progressControllers[_currentStoryIndex].dispose();
      _progressControllers[_currentStoryIndex] = AnimationController(
        duration: videoDuration.inSeconds > 0 ? videoDuration : const Duration(seconds: 5),
        vsync: this,
      );

      await _videoController!.play();
    } catch (e) {
      setState(() {
        _isVideoInitialized = false;
      });
    }
  }

  void _startCurrentStory() {
    if (_currentStoryIndex < _progressControllers.length) {
      _markCurrentStoryAsViewed();

      final currentStory = widget.stories[_currentStoryIndex];

      if (_isVideoStory(currentStory)) {
        final videoUrl = _getVideoUrl(currentStory);
        if (videoUrl.isNotEmpty) {
          _initializeVideo(videoUrl).then((_) {
            if (_videoController != null && _isVideoInitialized) {
              // Start the progress animation
              _progressControllers[_currentStoryIndex].forward().then((_) {
                if (mounted) {
                  _nextStory();
                }
              });

              _videoController!.addListener(_videoListener);
            }
          });
        } else {
          _progressControllers[_currentStoryIndex].forward().then((_) {
            if (mounted) {
              _nextStory();
            }
          });
        }
      } else {
        _progressControllers[_currentStoryIndex].forward().then((_) {
          if (mounted) {
            _nextStory();
          }
        });
      }
    }
  }

  void _videoListener() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      // Check if video has ended
      if (_videoController!.value.position >= _videoController!.value.duration) {
        _videoController!.removeListener(_videoListener);
        if (mounted) {
          _nextStory();
        }
      }
    }
  }

  void _nextStory() {
    _videoController?.removeListener(_videoListener);
    _videoController?.pause();

    if (_currentStoryIndex < widget.stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
        _isVideoInitialized = false;
      });
      _startCurrentStory();
    } else {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      _videoController?.removeListener(_videoListener);
      _videoController?.pause();
      _progressControllers[_currentStoryIndex].reset();

      setState(() {
        _currentStoryIndex--;
        _isVideoInitialized = false;
      });
      _progressControllers[_currentStoryIndex].reset();
      _startCurrentStory();
    }
  }

  void _pauseStory() {
    _progressControllers[_currentStoryIndex].stop();
    _videoController?.pause();
  }

  void _resumeStory() {
    if (_progressControllers[_currentStoryIndex].status != AnimationStatus.completed) {
      if (_isVideoStory(widget.stories[_currentStoryIndex])) {
        _videoController?.play();
        _progressControllers[_currentStoryIndex].forward().then((_) {
          if (mounted) {
            _nextStory();
          }
        });
      } else {
        _progressControllers[_currentStoryIndex].forward().then((_) {
          if (mounted) {
            _nextStory();
          }
        });
      }
    }
  }

  void _onPanStart(DragStartDetails details) {
    _pauseStory();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
      _dragOffset = _dragOffset.clamp(0.0, double.infinity);

      final screenHeight = MediaQuery.of(context).size.height;
      final maxDragDistance = screenHeight * 0.5;

      double visualOffset;
      if (_dragOffset <= maxDragDistance * 0.7) {
        visualOffset = _dragOffset;
      } else {
        final excess = _dragOffset - (maxDragDistance * 0.7);
        final resistanceBase = maxDragDistance * 0.7;
        final maxExcess = maxDragDistance * 0.3;

        final resistanceFactor = 1.0 - (excess / (excess + maxExcess * 0.5));
        visualOffset = resistanceBase + (excess * resistanceFactor * 0.3);
      }

      final progress = (visualOffset / maxDragDistance).clamp(0.0, 1.0);
      _dragScale = (1.0 - (progress * 0.3)).clamp(0.7, 1.0);

      _dragOffset = visualOffset;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dismissThreshold = screenHeight * 0.25;

    if (_dragOffset > dismissThreshold) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else {
      _animateToReset();
    }
  }

  void _animateToReset() {
    final currentOffset = _dragOffset;
    final currentScale = _dragScale;

    const steps = 30;
    const stepDuration = Duration(milliseconds: 10);

    int step = 0;
    Timer.periodic(stepDuration, (timer) {
      step++;
      final progress = step / steps;

      final easeOutProgress = 1.0 - (1.0 - progress) * (1.0 - progress);

      setState(() {
        _dragOffset = currentOffset * (1.0 - easeOutProgress);
        _dragScale = currentScale + ((1.0 - currentScale) * easeOutProgress);
      });

      if (step >= steps) {
        timer.cancel();
        setState(() {
          _dragOffset = 0.0;
          _dragScale = 1.0;
        });
        _resumeStory();
      }
    });
  }

  void _markCurrentStoryAsViewed() {
    if (_currentStoryIndex < widget.stories.length) {
      final currentStory = widget.stories[_currentStoryIndex];
      final storyUri = currentStory['uri'] as String?;
      if (storyUri != null) {
        StoryViewService.instance.markStoryAsViewed(storyUri);
      }
    }
  }

  void _markStoriesAsViewedUpToCurrent() {
    final viewedStoryUris = <String>[];
    for (int i = 0; i <= _currentStoryIndex && i < widget.stories.length; i++) {
      final story = widget.stories[i];
      final storyUri = story['uri'] as String?;
      if (storyUri != null) {
        viewedStoryUris.add(storyUri);
      }
    }
    if (viewedStoryUris.isNotEmpty) {
      StoryViewService.instance.markStoriesAsViewed(viewedStoryUris);
    }
  }

  String _getStoryImageUrl(Map<String, dynamic> story) {
    if (story.containsKey('embed') && story['embed'] != null) {
      final storyEmbed = story['embed'] as Map<String, dynamic>;

      if (storyEmbed['\$type'] == 'so.sprk.embed.video#view' && storyEmbed.containsKey('thumbnail')) {
        return storyEmbed['thumbnail'] as String? ?? '';
      }

      if (storyEmbed['\$type'] == 'so.sprk.embed.images#view' && storyEmbed.containsKey('images')) {
        final images = storyEmbed['images'] as List<dynamic>;
        if (images.isNotEmpty) {
          final firstImage = images[0] as Map<String, dynamic>;
          final fullsizeUrl = firstImage['fullsize'] as String?;
          if (fullsizeUrl != null && fullsizeUrl.isNotEmpty) {
            return fullsizeUrl;
          }
        }
      }
    }

    final author = story['author'] as Map<String, dynamic>;
    return author['avatar'] as String? ?? '';
  }

  String _getTimeAgo(Map<String, dynamic> story) {
    try {
      final record = story['record'] as Map<String, dynamic>?;
      if (record != null && record.containsKey('createdAt')) {
        final createdAt = DateTime.parse(record['createdAt'] as String);
        final now = DateTime.now();
        final difference = now.difference(createdAt);

        if (difference.inDays > 0) {
          return '${difference.inDays}d';
        } else if (difference.inHours > 0) {
          return '${difference.inHours}h';
        } else if (difference.inMinutes > 0) {
          return '${difference.inMinutes}m';
        } else {
          return 'now';
        }
      }
    } catch (e) {
      return 'now';
    }
    return 'now';
  }

  String _getVideoUrl(Map<String, dynamic> story) {
    if (story.containsKey('embed') && story['embed'] != null) {
      final storyEmbed = story['embed'] as Map<String, dynamic>;
      if (storyEmbed['\$type'] == 'so.sprk.embed.video#view' && storyEmbed.containsKey('playlist')) {
        return storyEmbed['playlist'] as String? ?? '';
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Text('No stories available', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16)),
          ),
        ),
      );
    }

    final currentStory = widget.stories[_currentStoryIndex];
    final author = currentStory['author'] as Map<String, dynamic>;
    final username = author['displayName'] as String? ?? author['handle'] as String? ?? 'Unknown';
    final avatarUrl = author['avatar'] as String? ?? '';
    final storyImageUrl = _getStoryImageUrl(currentStory);
    final timeAgo = _getTimeAgo(currentStory);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onLongPressStart: (_) => _pauseStory(),
          onLongPressEnd: (_) => _resumeStory(),
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Transform.translate(
            offset: Offset(0, _dragOffset),
            child: Transform.scale(
              scale: _dragScale,
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(_dragOffset > 0 ? 12 : 0)),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(_dragOffset > 0 ? 12 : 0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(_dragOffset > 0 ? 12 : 0),
                          child: _isVideoStory(currentStory) ? _buildVideoPlayer() : _buildImageViewer(storyImageUrl),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: List.generate(widget.stories.length, (index) {
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: index < widget.stories.length - 1 ? 4 : 0),
                              child: AnimatedBuilder(
                                animation: _progressControllers[index],
                                builder: (context, child) {
                                  double progress = 0.0;
                                  if (index < _currentStoryIndex) {
                                    progress = 1.0;
                                  } else if (index == _currentStoryIndex) {
                                    progress = _progressControllers[index].value;
                                  }

                                  return LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                    minHeight: 2,
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    Positioned(
                      top: 24,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: avatarUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return Container(
                                    color: Colors.grey[700],
                                    child: const Icon(FluentIcons.person_24_regular, color: Colors.white, size: 20),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(timeAgo, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: GestureDetector(onTap: _previousStory, child: Container(color: Colors.transparent)),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: GestureDetector(onTap: _nextStory, child: Container(color: Colors.transparent)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoController != null && _isVideoInitialized) {
      return AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!));
    }
    return Center(child: CircularProgressIndicator(color: AppColors.primary));
  }

  Widget _buildImageViewer(String storyImageUrl) {
    return CachedNetworkImage(
      imageUrl: storyImageUrl,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return Center(child: CircularProgressIndicator(value: downloadProgress.progress, color: AppColors.primary));
      },
      errorWidget: (context, url, error) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FluentIcons.image_24_regular, size: 48, color: Colors.white.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text('Failed to load story', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16)),
            ],
          ),
        );
      },
    );
  }
}
