import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../screens/profile_screen.dart';
import '../services/story_view_service.dart';
import '../utils/app_colors.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> storiesByAuthor;
  final int initialUserIndex;

  const StoryViewerScreen({super.key, required this.storiesByAuthor, this.initialUserIndex = 0});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late List<List<AnimationController>> _allProgressControllers;
  late Map<int, int> _userStoryIndices; // Track story index for each user
  int _currentUserIndex = 0;
  int _currentStoryIndex = 0;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  double _dragOffset = 0.0;
  double _dragScale = 1.0;
  double _horizontalDragStart = 0.0;
  bool _isHorizontalDrag = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialUserIndex.clamp(0, widget.storiesByAuthor.length - 1);
    _pageController = PageController(initialPage: _currentUserIndex);
    _userStoryIndices = {};
    _initializeProgressControllers();
    _startCurrentStory();
  }

  void _initializeProgressControllers() {
    _allProgressControllers = [];
    for (final authorData in widget.storiesByAuthor) {
      final stories = authorData['stories'] as List<dynamic>;
      final controllers = List.generate(
        stories.length,
        (index) => AnimationController(duration: const Duration(seconds: 5), vsync: this),
      );
      _allProgressControllers.add(controllers);
    }
  }

  @override
  void dispose() {
    _saveCurrentStoryIndex();
    _markStoriesAsViewedUpToCurrent();
    _videoController?.dispose();
    _pageController.dispose();

    for (final controllerList in _allProgressControllers) {
      for (final controller in controllerList) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  List<Map<String, dynamic>> get _currentUserStories {
    if (_currentUserIndex >= widget.storiesByAuthor.length) return [];
    return (widget.storiesByAuthor[_currentUserIndex]['stories'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> get _currentAuthor {
    if (_currentUserIndex >= widget.storiesByAuthor.length) return {};
    return widget.storiesByAuthor[_currentUserIndex]['author'] as Map<String, dynamic>;
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

      final videoDuration = _videoController!.value.duration;
      _allProgressControllers[_currentUserIndex][_currentStoryIndex].dispose();
      _allProgressControllers[_currentUserIndex][_currentStoryIndex] = AnimationController(
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
    if (_currentUserIndex >= widget.storiesByAuthor.length) return;
    if (_currentStoryIndex >= _currentUserStories.length) return;

    _markCurrentStoryAsViewed();

    final currentStory = _currentUserStories[_currentStoryIndex];

    if (_isVideoStory(currentStory)) {
      final videoUrl = _getVideoUrl(currentStory);
      if (videoUrl.isNotEmpty) {
        _initializeVideo(videoUrl).then((_) {
          if (_videoController != null && _isVideoInitialized) {
            _allProgressControllers[_currentUserIndex][_currentStoryIndex].forward().then((_) {
              if (mounted) {
                _nextStory();
              }
            });

            _videoController!.addListener(_videoListener);
          }
        });
      } else {
        _allProgressControllers[_currentUserIndex][_currentStoryIndex].forward().then((_) {
          if (mounted) {
            _nextStory();
          }
        });
      }
    } else {
      _allProgressControllers[_currentUserIndex][_currentStoryIndex].forward().then((_) {
        if (mounted) {
          _nextStory();
        }
      });
    }
  }

  void _videoListener() {
    if (_videoController != null && _videoController!.value.isInitialized) {
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

    if (_currentStoryIndex < _currentUserStories.length - 1) {
      setState(() {
        _currentStoryIndex++;
        _isVideoInitialized = false;
      });
      _saveCurrentStoryIndex();
      _startCurrentStory();
    } else {
      _nextUser();
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      _videoController?.removeListener(_videoListener);
      _videoController?.pause();
      _allProgressControllers[_currentUserIndex][_currentStoryIndex].reset();

      setState(() {
        _currentStoryIndex--;
        _isVideoInitialized = false;
      });
      _allProgressControllers[_currentUserIndex][_currentStoryIndex].reset();
      _saveCurrentStoryIndex();
      _startCurrentStory();
    } else {
      _previousUser();
    }
  }

  void _nextUser() {
    if (_currentUserIndex < widget.storiesByAuthor.length - 1) {
      _saveCurrentStoryIndex();
      _resetCurrentUserProgress();
      setState(() {
        _currentUserIndex++;
        _currentStoryIndex = _getUserStoryIndex(_currentUserIndex);
        _isVideoInitialized = false;
      });
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _startCurrentStory();
    } else {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  void _previousUser() {
    if (_currentUserIndex > 0) {
      _saveCurrentStoryIndex();
      _resetCurrentUserProgress();
      setState(() {
        _currentUserIndex--;
        _currentStoryIndex = _getUserStoryIndex(_currentUserIndex);
        _isVideoInitialized = false;
      });
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _startCurrentStory();
    }
  }

  void _resetCurrentUserProgress() {
    _videoController?.removeListener(_videoListener);
    _videoController?.pause();
    for (final controller in _allProgressControllers[_currentUserIndex]) {
      controller.reset();
    }
  }

  void _pauseStory() {
    if (_currentUserIndex < _allProgressControllers.length &&
        _currentStoryIndex < _allProgressControllers[_currentUserIndex].length) {
      _allProgressControllers[_currentUserIndex][_currentStoryIndex].stop();
    }
    _videoController?.pause();
  }

  void _resumeStory() {
    if (_currentUserIndex >= _allProgressControllers.length ||
        _currentStoryIndex >= _allProgressControllers[_currentUserIndex].length) {
      return;
    }

    final controller = _allProgressControllers[_currentUserIndex][_currentStoryIndex];
    if (controller.status != AnimationStatus.completed) {
      if (_isVideoStory(_currentUserStories[_currentStoryIndex])) {
        _videoController?.play();
        controller.forward().then((_) {
          if (mounted) {
            _nextStory();
          }
        });
      } else {
        controller.forward().then((_) {
          if (mounted) {
            _nextStory();
          }
        });
      }
    }
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _horizontalDragStart = details.globalPosition.dx;
    _isHorizontalDrag = false; // Reset horizontal drag state
    _pauseStory();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final horizontalDelta = details.globalPosition.dx - _horizontalDragStart;
    final verticalDelta = details.delta.dy;

    // Only consider this a horizontal drag if we haven't started vertical dragging yet
    // and if the horizontal movement is significantly larger than vertical
    if (!_isHorizontalDrag && _dragOffset < 5.0) {
      if (horizontalDelta.abs() > 15 && horizontalDelta.abs() > verticalDelta.abs() * 2) {
        _isHorizontalDrag = true;
      }
    }

    // If we've determined this is a horizontal drag, don't process vertical movement
    if (_isHorizontalDrag) {
      return;
    }

    // Only process downward vertical movement for pull-to-dismiss
    if (verticalDelta > 0) {
      setState(() {
        _dragOffset += verticalDelta;
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
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isHorizontalDrag) {
      final horizontalVelocity = details.velocity.pixelsPerSecond.dx;
      final horizontalDistance = details.globalPosition.dx - _horizontalDragStart;

      // Use both velocity and distance for more reliable horizontal swipe detection
      if ((horizontalVelocity > 300 || horizontalDistance > 50) && _currentUserIndex > 0) {
        _previousUser();
      } else if ((horizontalVelocity < -300 || horizontalDistance < -50) &&
          _currentUserIndex < widget.storiesByAuthor.length - 1) {
        _nextUser();
      } else {
        // If swipe wasn't strong enough, just resume the story
        _resumeStory();
      }

      _isHorizontalDrag = false;
      _isDragging = false;
      return;
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final dismissThreshold = screenHeight * 0.25;

    if (_dragOffset > dismissThreshold) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else {
      _animateToReset();
    }

    _isDragging = false;
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
    if (_currentUserIndex < widget.storiesByAuthor.length && _currentStoryIndex < _currentUserStories.length) {
      final currentStory = _currentUserStories[_currentStoryIndex];
      final storyUri = currentStory['uri'] as String?;
      if (storyUri != null) {
        StoryViewService.instance.markStoryAsViewed(storyUri);
      }
    }
  }

  void _markStoriesAsViewedUpToCurrent() {
    final viewedStoryUris = <String>[];
    for (int userIndex = 0; userIndex <= _currentUserIndex && userIndex < widget.storiesByAuthor.length; userIndex++) {
      final stories = (widget.storiesByAuthor[userIndex]['stories'] as List<dynamic>).cast<Map<String, dynamic>>();
      final maxStoryIndex = userIndex == _currentUserIndex ? _currentStoryIndex : stories.length - 1;

      for (int storyIndex = 0; storyIndex <= maxStoryIndex && storyIndex < stories.length; storyIndex++) {
        final story = stories[storyIndex];
        final storyUri = story['uri'] as String?;
        if (storyUri != null) {
          viewedStoryUris.add(storyUri);
        }
      }
    }
    if (viewedStoryUris.isNotEmpty) {
      StoryViewService.instance.markStoriesAsViewed(viewedStoryUris);
    }
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

  void _navigateToProfile() {
    final userDid = _currentAuthor['did'] as String?;

    if (userDid != null && userDid.isNotEmpty) {
      _pauseStory();

      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileScreen(did: userDid))).then((_) {
        if (mounted) {
          _resumeStory();
        }
      });
    }
  }

  void _saveCurrentStoryIndex() {
    _userStoryIndices[_currentUserIndex] = _currentStoryIndex;
  }

  int _getUserStoryIndex(int userIndex) {
    return _userStoryIndices[userIndex] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.storiesByAuthor.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Text('No stories available', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          physics: const ClampingScrollPhysics(),
          clipBehavior: Clip.none,
          onPageChanged: (index) {
            if (!_isDragging) {
              _saveCurrentStoryIndex();
              _resetCurrentUserProgress();
              setState(() {
                _currentUserIndex = index;
                _currentStoryIndex = _getUserStoryIndex(index);
                _isVideoInitialized = false;
              });
              _startCurrentStory();
            }
          },
          itemCount: widget.storiesByAuthor.length,
          itemBuilder: (context, userIndex) {
            return _buildStoryView(userIndex);
          },
        ),
      ),
    );
  }

  Widget _buildStoryView(int userIndex) {
    final userStories = (widget.storiesByAuthor[userIndex]['stories'] as List<dynamic>).cast<Map<String, dynamic>>();
    final author = widget.storiesByAuthor[userIndex]['author'] as Map<String, dynamic>;

    if (userStories.isEmpty) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Text('No stories available', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16)),
        ),
      );
    }

    // For non-current users, show the first story as a preview
    final storyIndex = userIndex == _currentUserIndex ? _currentStoryIndex : 0;
    final currentStory = userStories[storyIndex];
    final username = author['displayName'] as String? ?? author['handle'] as String? ?? 'Unknown';
    final avatarUrl = author['avatar'] as String? ?? '';
    final storyImageUrl = _getStoryImageUrlForUser(currentStory, author);
    final timeAgo = _getTimeAgo(currentStory);

    return GestureDetector(
      onLongPressStart: userIndex == _currentUserIndex ? (_) => _pauseStory() : null,
      onLongPressEnd: userIndex == _currentUserIndex ? (_) => _resumeStory() : null,
      onPanStart: userIndex == _currentUserIndex ? _onPanStart : null,
      onPanUpdate: userIndex == _currentUserIndex ? _onPanUpdate : null,
      onPanEnd: userIndex == _currentUserIndex ? _onPanEnd : null,
      child: Transform.translate(
        offset: userIndex == _currentUserIndex ? Offset(0, _dragOffset) : Offset.zero,
        child: Transform.scale(
          scale: userIndex == _currentUserIndex ? _dragScale : 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(userIndex == _currentUserIndex && _dragOffset > 0 ? 12 : 0),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(userIndex == _currentUserIndex && _dragOffset > 0 ? 12 : 0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(userIndex == _currentUserIndex && _dragOffset > 0 ? 12 : 0),
                      child:
                          userIndex == _currentUserIndex && _isVideoStory(currentStory)
                              ? _buildVideoPlayer()
                              : _buildImageViewer(storyImageUrl),
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
                    children: List.generate(userStories.length, (index) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: index < userStories.length - 1 ? 4 : 0),
                          child:
                              userIndex == _currentUserIndex
                                  ? AnimatedBuilder(
                                    animation: _allProgressControllers[userIndex][index],
                                    builder: (context, child) {
                                      double progress = 0.0;
                                      if (index < _currentStoryIndex) {
                                        progress = 1.0;
                                      } else if (index == _currentStoryIndex) {
                                        progress = _allProgressControllers[userIndex][index].value;
                                      }

                                      return LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                        minHeight: 2,
                                      );
                                    },
                                  )
                                  : LinearProgressIndicator(
                                    value: 0.0,
                                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                    minHeight: 2,
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
                      GestureDetector(
                        onTap: userIndex == _currentUserIndex ? _navigateToProfile : null,
                        child: Container(
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
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: userIndex == _currentUserIndex ? _navigateToProfile : null,
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
                      ),
                    ],
                  ),
                ),
                if (userIndex == _currentUserIndex) ...[
                  Positioned(
                    top: 80,
                    bottom: 0,
                    left: 0,
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: GestureDetector(onTap: _previousStory, child: Container(color: Colors.transparent)),
                  ),
                  Positioned(
                    top: 80,
                    bottom: 0,
                    right: 0,
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: GestureDetector(onTap: _nextStory, child: Container(color: Colors.transparent)),
                  ),
                ],
              ],
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

  String _getStoryImageUrlForUser(Map<String, dynamic> story, Map<String, dynamic> author) {
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

    return author['avatar'] as String? ?? '';
  }
}
