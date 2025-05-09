import 'package:flutter/material.dart';

/// Abstract class defining the contract for a State that can use [RefreshMixin].
abstract class RefreshableState {
  /// Callback to execute when a refresh is triggered.
  VoidCallback? get onRefreshCallback;

  /// The index of the item, used to determine if it's the first item (eligible for refresh).
  int get itemIndex;

  /// Pauses any media playback.
  void pauseMedia();

  /// Plays or resumes media playback.
  void playMedia();

  /// Indicates if the media content is currently visible.
  bool get isMediaVisible;

  /// The build context.
  BuildContext get context;

  /// A way to call setState from the mixin.
  void refreshSetState(VoidCallback fn);

  /// A way to check if the state is mounted from the mixin.
  bool get mountedState;

  /// Provides the TickerProvider for animations.
  TickerProvider get vsyncProvider;
}

/// Mixin to add pull-to-refresh functionality to a StatefulWidget's State.
/// The State using this mixin must also implement [RefreshableState].
mixin RefreshMixin<T extends StatefulWidget> on State<T> implements RefreshableState {
  // Refresh related properties will go here
  bool _isRefreshing = false;
  double _refreshProgress = 0.0;
  final double _refreshThreshold = 100.0; // Threshold to trigger a refresh

  // Animation related properties
  late AnimationController _springController;
  late Animation<double> _springAnimation;
  double _pullOffset = 0.0;
  final double _maxPullDistance = 200.0; // Max pull distance allowed
  bool _isHandlingRefresh = false;

  /// Initializes the refresh state, including the spring animation controller.
  /// Should be called in [initState] of the consuming State.
  void initRefreshState() {
    _springController = AnimationController(
      vsync: vsyncProvider, // Use the getter from RefreshableState
      duration: const Duration(milliseconds: 300),
    );

    _springAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _springController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInBack,
      ),
    );

    _springController.addListener(() {
      if (mountedState) {
        refreshSetState(() {
          _pullOffset = _springAnimation.value;
          _refreshProgress = (_pullOffset / _refreshThreshold).clamp(0.0, 1.0);
        });
      }
    });
  }

  /// Disposes of the refresh state resources, primarily the animation controller.
  /// Should be called in [dispose] of the consuming State.
  void disposeRefreshState() {
    _springController.dispose();
  }

  /// Public method to trigger refresh programmatically.
  Future<void> triggerRefresh() async {
    if (_isRefreshing || onRefreshCallback == null) return;

    refreshSetState(() {
      _isRefreshing = true;
    });

    pauseMedia();

    _springAnimation = Tween<double>(begin: _pullOffset, end: _refreshThreshold).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutBack),
    );
    _springController.reset();
    _springController.forward();

    try {
      await Future.delayed(const Duration(milliseconds: 300)); // Allow animation
      onRefreshCallback?.call();
      await Future.delayed(const Duration(milliseconds: 300)); // Delay before bounce back
    } finally {
      if (mountedState) {
        _springAnimation = Tween<double>(begin: _pullOffset, end: 0.0).animate(
          CurvedAnimation(parent: _springController, curve: Curves.easeInOut),
        );
        _springController.reset();
        await _springController.forward();

        refreshSetState(() {
          _isRefreshing = false;
          _refreshProgress = 0.0;
          _pullOffset = 0.0;
          _isHandlingRefresh = false;
        });
      }
      if (isMediaVisible && mountedState) {
        playMedia();
      }
    }
  }

  bool _shouldHandleRefreshGesture(DragStartDetails details) {
    if (itemIndex != 0 || _isRefreshing || _springController.isAnimating) {
      return false;
    }
    final screenHeight = MediaQuery.of(context).size.height;
    return details.localPosition.dy < screenHeight * 0.3; // Only in top 30%
  }

  /// Handles pointer down events for the refresh gesture.
  void handleRefreshPointerDown(PointerDownEvent event) {
     if (itemIndex == 0 && !_isRefreshing && !_springController.isAnimating) {
      _isHandlingRefresh = false; // Reset on new interaction
    }
  }

  /// Handles pointer move events for the refresh gesture.
  void handleRefreshPointerMove(PointerMoveEvent event) {
    if (itemIndex != 0) return;

    if (_isHandlingRefresh && !_isRefreshing && !_springController.isAnimating) {
      if (event.delta.dy > 0 && _pullOffset < _maxPullDistance) {
        refreshSetState(() {
          _pullOffset += event.delta.dy * (1.0 - (_pullOffset / (_maxPullDistance * 2)));
          _pullOffset = _pullOffset.clamp(0.0, _maxPullDistance);
          _refreshProgress = (_pullOffset / _refreshThreshold).clamp(0.0, 1.0);
        });
      }
    } else if (!_isHandlingRefresh && !_isRefreshing && event.delta.dy > 3.0 && _pullOffset == 0.0) {
       // Check if the gesture starts from the top or if we should consider it
        final startDetails = DragStartDetails(globalPosition: event.position, localPosition: event.localPosition);
        if (_shouldHandleRefreshGesture(startDetails)) {
            _isHandlingRefresh = true;
        }
    }
  }

  /// Handles pointer up events for the refresh gesture.
  void handleRefreshPointerUp(PointerUpEvent event) {
    if (itemIndex != 0) return;

    if (_isHandlingRefresh && !_isRefreshing && !_springController.isAnimating) {
      if (_refreshProgress >= 1.0) {
        triggerRefresh();
      } else {
        _springAnimation = Tween<double>(begin: _pullOffset, end: 0.0).animate(
          CurvedAnimation(parent: _springController, curve: Curves.easeOutBack),
        );
        _springController.reset();
        _springController.forward().then((_) {
          if (mountedState) {
            refreshSetState(() {
              _pullOffset = 0.0;
              _refreshProgress = 0.0;
              _isHandlingRefresh = false;
            });
          }
        });
      }
    }
  }

  /// Builds the refresh indicator widget.
  /// Returns null if the item is not the first one.
  Widget? buildRefreshIndicator() {
    if (itemIndex != 0) {
      return null;
    }
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Pull effect overlay
          if (_pullOffset > 0)
            AnimatedOpacity(
              opacity: _pullOffset > 0 ? 0.2 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                height: _pullOffset.clamp(0.0, _maxPullDistance),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.transparent],
                  ),
                ),
              ),
            ),
          // Refresh icon/indicator
          Transform.translate(
            offset: Offset(0, _pullOffset - 80.0 + (80.0 * _refreshProgress)),
            child: Container(
              height: 80,
              padding: const EdgeInsets.only(top: 20.0),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isRefreshing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Transform.rotate(
                        angle: (_refreshProgress * 3.14), // Rotate 180 degrees
                        child: Icon(
                          _refreshProgress >= 1.0 ? Icons.refresh : Icons.arrow_downward,
                          color: Colors.white.withOpacity(_refreshProgress.clamp(0.0, 1.0)),
                          size: 24 + (_refreshProgress * 8), // Icon size increases with pull
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Wraps the given child with a [Listener] to handle refresh gestures.
  Widget buildRefreshListener({required Widget child}) {
    // Only apply the listener for the first item to enable pull-to-refresh
    if (itemIndex == 0) {
      return Listener(
        onPointerDown: handleRefreshPointerDown,
        onPointerMove: handleRefreshPointerMove,
        onPointerUp: handleRefreshPointerUp,
        // Opaque when handling refresh to capture gestures, translucent otherwise
        behavior: _isHandlingRefresh ? HitTestBehavior.opaque : HitTestBehavior.translucent,
        child: child,
      );
    }
    // For other items, return the child directly without the listener
    return child;
  }
} 