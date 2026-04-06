import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/stories/ui/pages/story_page.dart';

@RoutePage()
class AuthorStoriesPage extends ConsumerStatefulWidget {
  const AuthorStoriesPage({
    required this.author,
    required this.stories,
    super.key,
    this.initialStoryIndex = 0,
    this.onPreviousAuthor,
    this.onNextAuthor,
  });

  final ProfileViewBasic author;
  final List<StoryView> stories;
  final int initialStoryIndex;

  /// Called when the user attempts to go to a previous story but is already at
  /// the first story of the current author.
  final VoidCallback? onPreviousAuthor;

  /// Called when the user attempts to go to a next story but is already at the
  /// last story of the current author.
  final VoidCallback? onNextAuthor;

  @override
  ConsumerState<AuthorStoriesPage> createState() => _AuthorStoriesPageState();
}

class _AuthorStoriesPageState extends ConsumerState<AuthorStoriesPage>
    with TickerProviderStateMixin {
  static const _defaultStoryDuration = Duration(seconds: 5);
  late final PageController _pageController;
  late final List<AnimationController> _progressControllers;
  late final List<bool> _storyLoadingStates;
  int _currentStoryIndex = 0;
  double _dragOffset = 0;
  double _dragScale = 1;
  bool _isDragging = false;
  bool _isCurrentStoryLoading = true;

  @override
  void initState() {
    super.initState();
    _currentStoryIndex = widget.initialStoryIndex.clamp(
      0,
      widget.stories.length - 1,
    );
    _pageController = PageController(initialPage: _currentStoryIndex);
    _initializeProgressControllers();
    _startCurrentStory();
  }

  @override
  void dispose() {
    for (final c in _progressControllers) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _initializeProgressControllers() {
    _progressControllers = List.generate(
      widget.stories.length,
      (_) => AnimationController(duration: _defaultStoryDuration, vsync: this),
    );
    _storyLoadingStates = List<bool>.filled(widget.stories.length, true);
  }

  void _onStoryDurationChanged(int index, Duration duration) {
    if (index < 0 || index >= _progressControllers.length) return;
    final normalized = duration > Duration.zero
        ? duration
        : _defaultStoryDuration;
    _progressControllers[index].duration = normalized;
  }

  void _startCurrentStory() {
    if (_currentStoryIndex >= widget.stories.length) return;

    if (!_isCurrentStoryLoading) {
      _startProgressForCurrentStory();
    }
  }

  void _startProgressForCurrentStory() {
    final storyIndex = _currentStoryIndex;
    final controller = _progressControllers[storyIndex];
    controller.forward().whenComplete(() {
      if (!mounted) return;
      if (_currentStoryIndex != storyIndex) return;
      if (controller.status == AnimationStatus.completed) {
        _nextStory();
      }
    });
  }

  void _pause() {
    _progressControllers[_currentStoryIndex].stop();
  }

  void _resume() {
    final controller = _progressControllers[_currentStoryIndex];
    if (controller.status != AnimationStatus.completed &&
        !_isCurrentStoryLoading) {
      _startProgressForCurrentStory();
    }
  }

  void _onStoryLoadingStateChanged(int index, bool isLoading) {
    if (index < 0 || index >= _storyLoadingStates.length) return;
    _storyLoadingStates[index] = isLoading;
    if (index != _currentStoryIndex) return;

    if (_isCurrentStoryLoading != isLoading) {
      setState(() {
        _isCurrentStoryLoading = isLoading;
      });

      if (isLoading) {
        _pause();
      } else {
        final controller = _progressControllers[_currentStoryIndex];
        if (controller.status != AnimationStatus.completed &&
            !controller.isAnimating) {
          _startProgressForCurrentStory();
        }
      }
    }
  }

  void _nextStory() {
    final isLastStory = _currentStoryIndex >= widget.stories.length - 1;

    if (!isLastStory) {
      setState(() {
        _currentStoryIndex++;
        _isCurrentStoryLoading = true;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
      return;
    }

    if (widget.onNextAuthor != null) {
      widget.onNextAuthor!.call();
    } else if (context.mounted) {
      context.router.maybePop();
    }
  }

  void _previousStory() {
    final isFirstStory = _currentStoryIndex == 0;

    if (!isFirstStory) {
      _progressControllers[_currentStoryIndex].reset();
      setState(() {
        _currentStoryIndex--;
        _isCurrentStoryLoading = true;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
      return;
    }

    if (widget.onPreviousAuthor != null) {
      widget.onPreviousAuthor!.call();
    } else if (context.mounted) {
      context.router.maybePop();
    }
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _pause();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final verticalDelta = details.delta.dy;
    if (verticalDelta > 0) {
      setState(() {
        _dragOffset += verticalDelta;
        final screenHeight = MediaQuery.of(context).size.height;
        final maxDrag = screenHeight * 0.5;
        final progress = (_dragOffset / maxDrag).clamp(0.0, 1.0);
        _dragScale = (1 - progress * 0.3).clamp(0.7, 1.0);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dismissThreshold = screenHeight * 0.25;
    if (_dragOffset > dismissThreshold) {
      context.router.maybePop();
    } else {
      _animateReset();
    }
    _isDragging = false;
  }

  void _animateReset() {
    final startOffset = _dragOffset;
    final startScale = _dragScale;
    const steps = 30;
    const duration = Duration(milliseconds: 10);
    var step = 0;
    Timer.periodic(duration, (timer) {
      step++;
      final t = step / steps;
      final ease = 1 - (1 - t) * (1 - t);
      setState(() {
        _dragOffset = startOffset * (1 - ease);
        _dragScale = startScale + (1 - startScale) * ease;
      });
      if (step >= steps) {
        timer.cancel();
        _dragOffset = 0;
        _dragScale = 1;
        _resume();
      }
    });
  }

  String _timeAgo(StoryView story) {
    final now = DateTime.now();
    final diff = now.difference(story.indexedAt);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) {
      return const Scaffold(body: Center(child: Text('No stories')));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onLongPressStart: (_) => _pause(),
          onLongPressEnd: (_) => _resume(),
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Transform.translate(
            offset: Offset(0, _dragOffset),
            child: Transform.scale(
              scale: _dragScale,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    physics: const ClampingScrollPhysics(),
                    itemCount: widget.stories.length,
                    onPageChanged: (index) {
                      if (!_isDragging) {
                        final previousIndex = _currentStoryIndex;
                        _progressControllers[previousIndex].stop();
                        _progressControllers[index].reset();
                        setState(() {
                          _currentStoryIndex = index;
                          _isCurrentStoryLoading = _storyLoadingStates[index];
                        });
                        if (!_isCurrentStoryLoading) {
                          _startProgressForCurrentStory();
                        }
                      }
                    },
                    itemBuilder: (context, index) {
                      final story = widget.stories[index];
                      return StoryPage(
                        story: story,
                        onLoadingStateChanged: (isLoading) =>
                            _onStoryLoadingStateChanged(index, isLoading),
                        onStoryDurationChanged: (duration) =>
                            _onStoryDurationChanged(index, duration),
                        onPauseRequested: _pause,
                        onResumeRequested: _resume,
                        onPrevious: _previousStory,
                        onNext: _nextStory,
                      );
                    },
                  ),
                  Positioned(
                    top: 8,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: List.generate(widget.stories.length, (index) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                              right: index < widget.stories.length - 1 ? 4 : 0,
                            ),
                            child: AnimatedBuilder(
                              animation: _progressControllers[index],
                              builder: (context, child) {
                                double value;
                                if (index < _currentStoryIndex) {
                                  value = 1;
                                } else if (index == _currentStoryIndex) {
                                  value = _progressControllers[index].value;
                                } else {
                                  value = 0;
                                }
                                return LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: Colors.white.withAlpha(76),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
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
                        GestureDetector(
                          onTap: () {
                            context.router.push(
                              ProfileRoute(
                                did: widget.author.did,
                                initialProfile: widget.author,
                              ),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: widget.author.avatar.toString(),
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.author.displayName ??
                                    widget.author.handle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _timeAgo(widget.stories[_currentStoryIndex]),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
