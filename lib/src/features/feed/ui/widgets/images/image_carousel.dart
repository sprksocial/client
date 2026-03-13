import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/features/feed/ui/widgets/images/moderate_page_scroll_physics.dart';

class ImageCarousel extends ConsumerStatefulWidget {
  const ImageCarousel({
    required this.imageUrls,
    super.key,
    this.alts,
    this.hasKnownInteractions = false,
  });
  final List<String> imageUrls;
  final List<String>? alts;
  final bool hasKnownInteractions;

  @override
  ConsumerState<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends ConsumerState<ImageCarousel> {
  late PageController _pageController;
  late List<ImageProvider> _imageProviders;
  late List<Widget> _cachedPages;
  int currentIndex = 0;
  bool _imagesPreloaded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    currentIndex = 0;
    // Create image providers for all images upfront
    _imageProviders = widget.imageUrls
        .map(CachedNetworkImageProvider.new)
        .toList();
    _cachedPages = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload images and build cached pages once we have context
    if (!_imagesPreloaded) {
      _imagesPreloaded = true;
      _preloadAllImages();
      _buildCachedPages();
    }
    // Ensure page controller is at page 0 after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pageController.hasClients) {
        final currentPage = _pageController.page?.round() ?? 0;
        if (currentPage != 0) {
          _pageController.jumpToPage(0);
          setState(() {
            currentIndex = 0;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _preloadAllImages() async {
    // Preload all images in parallel
    await Future.wait(
      _imageProviders.map((provider) => precacheImage(provider, context)),
    );
    // Rebuild to show loaded images
    if (mounted) {
      setState(_buildCachedPages);
    }
  }

  void _buildCachedPages() {
    _cachedPages = List.generate(
      widget.imageUrls.length,
      (index) => _KeepAlivePage(
        child: Stack(
          children: [
            _buildImage(index),
            if (widget.alts != null &&
                index < widget.alts!.length &&
                widget.alts![index] != '')
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Text(widget.alts![index]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(int index) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.black),
      child: Image(
        image: _imageProviders[index],
        fit: BoxFit.contain,
        height: double.infinity,
        width: double.infinity,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          if (frame != null) {
            return child;
          }
          return const SizedBox.shrink();
        },
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(FluentIcons.error_circle_24_regular)),
      ),
    );
  }

  Widget _buildSingleImage() {
    return Stack(
      children: [
        _buildImage(0),
        if (widget.alts != null &&
            widget.alts!.isNotEmpty &&
            widget.alts![0] != '')
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Text(widget.alts![0]),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Handle empty image URLs gracefully
    if (widget.imageUrls.isEmpty) {
      return const DecoratedBox(
        decoration: BoxDecoration(color: AppColors.black),
      );
    }

    final hasMultipleImages = widget.imageUrls.length > 1;

    // If only one image, show it directly without carousel
    if (!hasMultipleImages) {
      return _buildSingleImage();
    }

    // Multiple images: use PageView with keep-alive pages
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _cachedPages.length,
          allowImplicitScrolling: true,
          physics: const ModeratePageScrollPhysics(),
          itemBuilder: (context, index) {
            // Ensure we only build pages that exist
            if (index >= 0 && index < _cachedPages.length) {
              return _cachedPages[index];
            }
            return const SizedBox.shrink();
          },
          onPageChanged: (index) {
            if (index >= 0 && index < widget.imageUrls.length) {
              setState(() {
                currentIndex = index;
              });
            }
          },
        ),
        Positioned(
          // Position dots above the post overlay content area
          // When known interactions exist, they add ~48px (bar height + 12px)
          // Base position is 180px, reduced by 48px when no known interactions
          bottom: widget.hasKnownInteractions ? 180 : 132,
          left: 0,
          right: 0,
          child: Center(
            child: _ScrollingDotIndicator(
              itemCount: widget.imageUrls.length,
              currentIndex: currentIndex,
            ),
          ),
        ),
      ],
    );
  }
}

/// A compact dot indicator that shows max 5 dots at a time
/// with smooth scrolling animation where dots slide in/out
class _ScrollingDotIndicator extends StatefulWidget {
  const _ScrollingDotIndicator({
    required this.itemCount,
    required this.currentIndex,
  });

  final int itemCount;
  final int currentIndex;

  @override
  State<_ScrollingDotIndicator> createState() => _ScrollingDotIndicatorState();
}

class _ScrollingDotIndicatorState extends State<_ScrollingDotIndicator>
    with SingleTickerProviderStateMixin {
  static const int _maxVisibleDots = 5;
  static const double _dotSize = 6;
  static const double _dotSpacing = 4;
  static const double _dotTotalWidth = _dotSize + _dotSpacing;

  // Dot positions (indices 0-4 for 5 dots)
  static const int _secondPosition = 1; // Second from left
  static const int _centerPosition = 2; // Center
  static const int _fourthPosition = 3; // Second from right (fourth)

  late AnimationController _controller;
  late Animation<double> _scrollAnimation;
  double _currentScrollOffset = 0;
  double _targetScrollOffset = 0;
  int _previousIndex = 0;
  bool _scrollingForward = true;
  bool _wasScrollingForward = true;
  bool _useCenter = false; // True when we just changed direction

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scrollAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _previousIndex = widget.currentIndex;
    _targetScrollOffset = _calculateScrollOffset(widget.currentIndex);
    _currentScrollOffset = _targetScrollOffset;
  }

  @override
  void didUpdateWidget(_ScrollingDotIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _wasScrollingForward = _scrollingForward;
      _scrollingForward = widget.currentIndex > _previousIndex;

      // Check if direction changed
      if (_scrollingForward != _wasScrollingForward) {
        // Direction changed - use center position for this scroll
        _useCenter = true;
      } else if (_useCenter) {
        // Same direction after using center - now move to edge
        _useCenter = false;
      }

      _previousIndex = widget.currentIndex;
      _animateToIndex(widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _calculateScrollOffset(int index) {
    if (widget.itemCount <= _maxVisibleDots) {
      return 0;
    }

    final maxOffset = (widget.itemCount - _maxVisibleDots).toDouble();

    // Determine which position the active dot should be at
    int dotPosition;
    if (_useCenter) {
      // Just changed direction - use center
      dotPosition = _centerPosition;
    } else if (_scrollingForward) {
      // Scrolling forward: active dot at fourth position (second from right)
      dotPosition = _fourthPosition;
    } else {
      // Scrolling backward: active dot at second position (second from left)
      dotPosition = _secondPosition;
    }

    final offset = index - dotPosition.toDouble();
    return offset.clamp(0, maxOffset);
  }

  void _animateToIndex(int index) {
    final newOffset = _calculateScrollOffset(index);
    if (newOffset != _targetScrollOffset) {
      // Get the current visual position - use the animation value if animating,
      // otherwise use the stored offset to prevent jumps when new animations
      // start while previous ones are still in progress.
      final currentVisualPosition = _controller.isAnimating
          ? _scrollAnimation.value
          : _currentScrollOffset;

      // Update the stored offset to match the current visual position
      // This ensures continuity when rapid swipes occur
      _currentScrollOffset = currentVisualPosition;

      _scrollAnimation =
          Tween<double>(begin: currentVisualPosition, end: newOffset).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _targetScrollOffset = newOffset;
      _controller
        ..reset()
        ..forward().then((_) {
          _currentScrollOffset = newOffset;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount <= 1) return const SizedBox.shrink();

    // Calculate visible width based on number of dots to show
    final visibleDotCount = widget.itemCount.clamp(1, _maxVisibleDots);
    final visibleWidth = visibleDotCount * _dotTotalWidth;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedBuilder(
        animation: _scrollAnimation,
        builder: (context, child) {
          final scrollOffset = _controller.isAnimating
              ? _scrollAnimation.value
              : _targetScrollOffset;

          return SizedBox(
            width: visibleWidth,
            height: _dotSize,
            child: ClipRect(
              child: Stack(
                clipBehavior: Clip.none,
                children: _buildDots(scrollOffset),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildDots(double scrollOffset) {
    final dots = <Widget>[];
    final maxOffset = (widget.itemCount - _maxVisibleDots).toDouble();
    final hasMoreBefore = scrollOffset > 0;
    final hasMoreAfter = scrollOffset < maxOffset;

    for (var i = 0; i < widget.itemCount; i++) {
      // Calculate position relative to scroll offset
      final relativePosition = i - scrollOffset;

      // Skip dots that are way outside the visible area
      if (relativePosition < -1 || relativePosition > _maxVisibleDots) {
        continue;
      }

      // Calculate horizontal position
      final xPosition = relativePosition * _dotTotalWidth + _dotSpacing / 2;

      // Calculate scale based on position
      // Edge dots are smaller (0.6) when there are more dots in that direction
      final scale = _calculateDotScale(
        relativePosition,
        hasMoreBefore,
        hasMoreAfter,
      );

      final isActive = i == widget.currentIndex;
      final size = _dotSize * scale;

      dots.add(
        Positioned(
          left: xPosition + (_dotSize - size) / 2,
          top: (_dotSize - size) / 2,
          child: Opacity(
            opacity: scale.clamp(0.0, 1.0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? Colors.white : Colors.white.withAlpha(128),
              ),
            ),
          ),
        ),
      );
    }

    return dots;
  }

  double _calculateDotScale(
    double relativePosition,
    bool hasMoreBefore,
    bool hasMoreAfter,
  ) {
    const edgeScale = 0.6;
    const edgeZone = 0.5; // How far from edge before dot is full size

    // Left side: dots entering/exiting or at edge
    if (relativePosition < edgeZone) {
      if (relativePosition < 0) {
        // Dot is outside visible area (entering/exiting on left)
        // Scale from 0 (at -1) to edgeScale or 1 (at 0)
        // depending on hasMoreBefore
        final targetScale = hasMoreBefore ? edgeScale : 1.0;
        return ((1 + relativePosition) * targetScale).clamp(0.0, 1.0);
      } else if (hasMoreBefore) {
        // Dot is in the left edge zone with more dots before
        // Scale from edgeScale (at 0) to 1.0 (at edgeZone)
        return (edgeScale + (relativePosition / edgeZone) * (1 - edgeScale))
            .clamp(0.0, 1.0);
      }
    }

    // Right side: dots entering/exiting or at edge
    const rightEdgeStart = _maxVisibleDots - 1 - edgeZone;
    if (relativePosition > rightEdgeStart) {
      final distanceFromRight = _maxVisibleDots - 1 - relativePosition;

      if (relativePosition > _maxVisibleDots - 1) {
        // Dot is outside visible area (entering/exiting on right)
        // Scale from 0 (at _maxVisibleDots)
        // to edgeScale or 1 (at _maxVisibleDots-1)
        final targetScale = hasMoreAfter ? edgeScale : 1.0;
        return ((1 + distanceFromRight) * targetScale).clamp(0.0, 1.0);
      } else if (hasMoreAfter) {
        // Dot is in the right edge zone with more dots after
        // Scale from edgeScale (at _maxVisibleDots-1) to 1 (at rightEdgeStart)
        return (edgeScale + (distanceFromRight / edgeZone) * (1 - edgeScale))
            .clamp(0.0, 1.0);
      }
    }

    // Middle dots are full size
    return 1;
  }
}

/// Wrapper widget that keeps its child alive in PageView
class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({required this.child});
  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
