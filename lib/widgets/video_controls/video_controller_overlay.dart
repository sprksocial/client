import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:video_player/video_player.dart';

class VideoControllerOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onTap;

  const VideoControllerOverlay({
    Key? key,
    required this.controller,
    required this.onTap,
  }) : super(key: key);

  @override
  State<VideoControllerOverlay> createState() => _VideoControllerOverlayState();
}

class _VideoControllerOverlayState extends State<VideoControllerOverlay> with SingleTickerProviderStateMixin {
  bool _controlsVisible = false;
  bool _isSpeedUp = false;
  Timer? _hideTimer;
  Timer? _updateTimer;
  double _dragPosition = 0.0;
  bool _isDragging = false;
  bool _knobEnlarged = false;
  
  // Animation controller for the timestamp animation
  late AnimationController _timestampAnimationController;
  late Animation<Offset> _timestampAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for timestamp
    _timestampAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    // Create animation for moving timestamp upward
    _timestampAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -1.0),
    ).animate(CurvedAnimation(
      parent: _timestampAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start periodic timer to update UI with current video position
    _updateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted && !_isDragging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _updateTimer?.cancel();
    _timestampAnimationController.dispose();
    super.dispose();
  }

  void _toggleControls() {
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
    widget.controller.seekTo(
      newPosition < Duration.zero ? Duration.zero : newPosition,
    );
    _startHideTimer();
    setState(() {});
  }

  void _fastForward() {
    final newPosition = widget.controller.value.position + const Duration(seconds: 5);
    final duration = widget.controller.value.duration;
    widget.controller.seekTo(
      newPosition > duration ? duration : newPosition,
    );
    _startHideTimer();
    setState(() {});
  }

  void _onDragStart(double position) {
    _cancelHideTimer();
    setState(() {
      _isDragging = true;
      _dragPosition = position;
      _knobEnlarged = true;
      
      // Start the animation for timestamp
      _timestampAnimationController.forward();
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
      _knobEnlarged = false;
      
      // Reverse the timestamp animation
      _timestampAnimationController.reverse();
    });
    
    _startHideTimer();
  }

  void _handleSpeedUp(bool isLongPress) {
    if (isLongPress != _isSpeedUp) {
      setState(() {
        _isSpeedUp = isLongPress;
      });
      // Set playback speed
      widget.controller.setPlaybackSpeed(_isSpeedUp ? 2.0 : 1.0);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.controller.value.duration;
    final position = _isDragging
        ? duration * _dragPosition
        : widget.controller.value.position;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate bottom safe area for proper slider positioning
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final bottomNavHeight = 50.0; // Match the HomeScreen bottom nav height
    
    // Progress bar configuration - easily adjustable
    final progressBarWidthPercentage = 0.7; // 70% of screen width
    final progressBarWidth = screenWidth * progressBarWidthPercentage;
    final progressBarHeight = 4.0;
    final knobSizeNormal = 14.0;
    final knobSizeEnlarged = 20.0;
    final progressBarBottomPadding = bottomNavHeight + bottomSafeArea + 10;
    
    return GestureDetector(
      onTap: _toggleControls,
      onLongPressStart: (_) => _handleSpeedUp(true),
      onLongPressEnd: (_) => _handleSpeedUp(false),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Transparent layer for tap detection
          Container(color: Colors.transparent),
          
          // Speed indicator (2x) when long pressing
          if (_isSpeedUp)
            Positioned(
              left: 10,
              bottom: 120,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CupertinoColors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '2x',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          
          // Controls overlay
          if (_controlsVisible)
            AnimatedOpacity(
              opacity: _controlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                color: CupertinoColors.black.withOpacity(0.5),
                child: Stack(
                  children: [
                    // Timestamp indicator (centered below controls)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: screenHeight * 0.55, // Position below play controls
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: CupertinoColors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_formatDuration(position)}/${_formatDuration(duration)}',
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Center play/pause and skip buttons - perfectly centered 
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Rewind 5 seconds
                          IconButton(
                            icon: const Icon(Ionicons.play_back_outline, color: CupertinoColors.white, size: 36),
                            onPressed: _rewind,
                            padding: const EdgeInsets.all(16),
                          ),
                          const SizedBox(width: 24),
                          
                          // Play/Pause
                          GestureDetector(
                            onTap: _playPause,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: CupertinoColors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  widget.controller.value.isPlaying
                                      ? Ionicons.pause
                                      : Ionicons.play,
                                  color: CupertinoColors.white,
                                  size: 46,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          
                          // Fast forward 5 seconds
                          IconButton(
                            icon: const Icon(Ionicons.play_forward_outline, color: CupertinoColors.white, size: 36),
                            onPressed: _fastForward,
                            padding: const EdgeInsets.all(16),
                          ),
                        ],
                      ),
                    ),
                    
                    // Bottom progress bar - positioned just above bottom nav
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: progressBarBottomPadding,
                      child: Center(
                        child: Container(
                          width: progressBarWidth,
                          height: 40, // Taller touch area
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Get actual width from constraints for more accurate calculations
                              final actualWidth = constraints.maxWidth;
                              
                              return GestureDetector(
                                onHorizontalDragStart: (details) {
                                  final RenderBox box = context.findRenderObject() as RenderBox;
                                  final Offset localPos = box.globalToLocal(details.globalPosition);
                                  // Calculate position within the progress bar container
                                  final progressBarLeft = (screenWidth - progressBarWidth) / 2;
                                  final relativeX = localPos.dx - progressBarLeft;
                                  final normalizedPosition = (relativeX / progressBarWidth).clamp(0.0, 1.0);
                                  _onDragStart(normalizedPosition);
                                },
                                onHorizontalDragUpdate: (details) {
                                  final RenderBox box = context.findRenderObject() as RenderBox;
                                  final Offset localPos = box.globalToLocal(details.globalPosition);
                                  // Calculate position within the progress bar container
                                  final progressBarLeft = (screenWidth - progressBarWidth) / 2;
                                  final relativeX = localPos.dx - progressBarLeft;
                                  final normalizedPosition = (relativeX / progressBarWidth).clamp(0.0, 1.0);
                                  _onDragUpdate(normalizedPosition);
                                },
                                onHorizontalDragEnd: (_) => _onDragEnd(),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Background track
                                    Container(
                                      height: progressBarHeight,
                                      width: double.infinity, // Full width of the parent container
                                      color: CupertinoColors.systemGrey.withOpacity(0.5),
                                    ),
                                    
                                    // Filled progress - now white
                                    FractionallySizedBox(
                                      widthFactor: _isDragging
                                          ? _dragPosition.clamp(0.0, 1.0)
                                          : (position.inMilliseconds / duration.inMilliseconds)
                                              .clamp(0.0, 1.0),
                                      child: Container(
                                        height: progressBarHeight,
                                        color: CupertinoColors.white,
                                      ),
                                    ),
                                    
                                    // Draggable knob
                                    Positioned(
                                      left: _isDragging
                                          ? (_dragPosition * actualWidth).clamp(0.0, actualWidth)
                                          : ((position.inMilliseconds / duration.inMilliseconds) * actualWidth).clamp(0.0, actualWidth),
                                      top: -5,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onHorizontalDragStart: (details) {
                                          // Use the same calculation method as the parent
                                          final RenderBox box = context.findRenderObject() as RenderBox;
                                          final Offset localPos = box.globalToLocal(details.globalPosition);
                                          final progressBarLeft = (screenWidth - progressBarWidth) / 2;
                                          final relativeX = localPos.dx - progressBarLeft;
                                          final normalizedPosition = (relativeX / progressBarWidth).clamp(0.0, 1.0);
                                          _onDragStart(normalizedPosition);
                                        },
                                        onHorizontalDragUpdate: (details) {
                                          // Use the same calculation method as the parent
                                          final RenderBox box = context.findRenderObject() as RenderBox;
                                          final Offset localPos = box.globalToLocal(details.globalPosition);
                                          final progressBarLeft = (screenWidth - progressBarWidth) / 2;
                                          final relativeX = localPos.dx - progressBarLeft;
                                          final normalizedPosition = (relativeX / progressBarWidth).clamp(0.0, 1.0);
                                          _onDragUpdate(normalizedPosition);
                                        },
                                        onHorizontalDragEnd: (_) => _onDragEnd(),
                                        child: Container(
                                          width: _knobEnlarged ? knobSizeEnlarged : knobSizeNormal,
                                          height: _knobEnlarged ? knobSizeEnlarged : knobSizeNormal,
                                          decoration: BoxDecoration(
                                            color: CupertinoColors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: CupertinoColors.black.withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // Animated timestamp above knob when dragging
                                    if (_isDragging)
                                      Positioned(
                                        left: (_dragPosition * actualWidth - 25).clamp(0.0, actualWidth - 50),
                                        bottom: 15,
                                        child: SlideTransition(
                                          position: _timestampAnimation,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: CupertinoColors.black.withOpacity(0.7),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              _formatDuration(duration * _dragPosition),
                                              style: const TextStyle(
                                                color: CupertinoColors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }
                          ),
                        ),
                      ),
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