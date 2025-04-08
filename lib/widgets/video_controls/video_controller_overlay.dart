import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'play_pause_controls.dart';
import 'speed_indicator.dart';
import 'time_display.dart';

class VideoControllerOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onTap;
  final VoidCallback? onLikePressed;
  final bool isLiked;

  const VideoControllerOverlay({
    super.key,
    required this.controller,
    required this.onTap,
    this.onLikePressed,
    this.isLiked = false,
  });

  @override
  State<VideoControllerOverlay> createState() => _VideoControllerOverlayState();
}

class _VideoControllerOverlayState extends State<VideoControllerOverlay> with TickerProviderStateMixin {
  bool _controlsVisible = false;
  bool _isSpeedUp = false;
  Timer? _hideTimer;
  Timer? _updateTimer;
  double _dragPosition = 0.0;
  bool _isDragging = false;
  late AnimationController _heartAnimationController;
  bool _showHeart = false;

  // Track taps more reliably
  int _tapCount = 0;
  Timer? _tapDebounceTimer;

  @override
  void initState() {
    super.initState();

    _heartAnimationController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _updateTimer = Timer.periodic(const Duration(milliseconds: 360), (timer) {
      if (mounted && !_isDragging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _updateTimer?.cancel();
    _tapDebounceTimer?.cancel();
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapCount++;

    // Cancel any existing timer first
    _tapDebounceTimer?.cancel();

    _tapDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_tapCount == 1) {
        // Single tap - toggle controls
        _toggleControls();
      } else if (_tapCount == 2) {
        // Double tap - like action
        _showLikeAnimation();
      }

      // Reset tap count after processing
      _tapCount = 0;
    });
  }

  void _showLikeAnimation() {
    // Don't toggle controls for double tap
    setState(() {
      _showHeart = true;
    });

    _heartAnimationController.reset();
    _heartAnimationController.forward().then((_) {
      if (mounted) {
        setState(() {
          _showHeart = false;
        });
      }
    });

    if (widget.onLikePressed != null && !widget.isLiked) {
      widget.onLikePressed!();
    }
  }

  void _toggleControls() {
    // Pass the single tap to parent if needed
    widget.onTap();

    setState(() {
      _controlsVisible = !_controlsVisible;
      if (_controlsVisible) {
        _startHideTimer();
      } else {
        _hideTimer?.cancel();
      }
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controlsVisible && !_isDragging) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
  }

  void _playPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
    _startHideTimer();
    setState(() {});
  }

  void _rewind() {
    final newPosition = widget.controller.value.position - const Duration(seconds: 5);
    widget.controller.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
    _startHideTimer();
    setState(() {});
  }

  void _fastForward() {
    final newPosition = widget.controller.value.position + const Duration(seconds: 5);
    final duration = widget.controller.value.duration;
    widget.controller.seekTo(newPosition > duration ? duration : newPosition);
    _startHideTimer();
    setState(() {});
  }

  void _onDragStart(double position) {
    _cancelHideTimer();
    setState(() {
      _isDragging = true;
      _dragPosition = position;
    });
  }

  void _onDragUpdate(double position) {
    setState(() {
      _dragPosition = position;
    });
  }

  void _onDragEnd() {
    final duration = widget.controller.value.duration;
    final position = duration * _dragPosition;

    widget.controller.seekTo(position);

    setState(() {
      _isDragging = false;
    });

    _startHideTimer();
  }

  void _handleSpeedUp(bool isLongPress) {
    if (isLongPress != _isSpeedUp) {
      setState(() {
        _isSpeedUp = isLongPress;
      });
      widget.controller.setPlaybackSpeed(_isSpeedUp ? 2.0 : 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.controller.value.duration;
    final position = _isDragging ? duration * _dragPosition : widget.controller.value.position;

    final screenHeight = MediaQuery.of(context).size.height;

    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final bottomNavHeight = 50.0; // Match the HomeScreen bottom nav height
    final progressBarBottomPadding = bottomNavHeight + bottomSafeArea + 10;

    return GestureDetector(
      onTap: _handleTap,
      // Remove separate onDoubleTap since we handle it in _handleTap
      onLongPressStart: (_) => _handleSpeedUp(true),
      onLongPressEnd: (_) => _handleSpeedUp(false),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.transparent),

          Positioned(left: 10, bottom: 120, child: SpeedIndicator(isVisible: _isSpeedUp)),

          if (_showHeart)
            FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                CurvedAnimation(parent: _heartAnimationController, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.2).animate(
                  CurvedAnimation(parent: _heartAnimationController, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
                ),
                child: const Icon(FluentIcons.heart_24_filled, color: Colors.pink, size: 100),
              ),
            ),

          if (_controlsVisible)
            AnimatedOpacity(
              opacity: _controlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                color: Colors.black.withAlpha(128),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: screenHeight * 0.55, // Position below play controls
                      child: Center(child: TimeDisplay(position: position, duration: duration)),
                    ),

                    Center(
                      child: PlayPauseControls(
                        controller: widget.controller,
                        onRewind: _rewind,
                        onPlayPause: _playPause,
                        onFastForward: _fastForward,
                      ),
                    ),

                    // Positioned(
                    //   left: 0,
                    //   right: 0,
                    //   bottom: progressBarBottomPadding,
                    //   child: Center(
                    //     child: VideoProgressBar(
                    //       position: position,
                    //       duration: duration,
                    //       isDragging: _isDragging,
                    //       dragPosition: _dragPosition,
                    //       onDragStart: _onDragStart,
                    //       onDragUpdate: _onDragUpdate,
                    //       onDragEnd: _onDragEnd,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
