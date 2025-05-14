import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:video_player/video_player.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

/// A video player widget used for previewing videos before posting.
/// 
/// This widget displays a video with play/pause controls that auto-hide
/// after a specified duration.
class VideoPreviewPlayer extends StatefulWidget {
  /// The controller for the video being played
  final VideoPlayerController controller;

  /// Creates a [VideoPreviewPlayer] widget.
  const VideoPreviewPlayer({
    super.key,
    required this.controller,
  });

  @override
  State<VideoPreviewPlayer> createState() => _VideoPreviewPlayerState();
}

class _VideoPreviewPlayerState extends State<VideoPreviewPlayer> {
  bool _showControls = true;
  static const Duration _autoHideDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _scheduleControlsAutoHide();
  }

  /// Schedules the controls to automatically hide after [_autoHideDuration]
  void _scheduleControlsAutoHide() {
    Future.delayed(_autoHideDuration, () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  /// Toggles play/pause state of the video
  void _togglePlayPause() {
    setState(() {
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
      } else {
        widget.controller.play();
        _scheduleControlsAutoHide();
      }
    });
  }

  /// Toggles visibility of the controls overlay
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      
      if (_showControls) {
        _scheduleControlsAutoHide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _VideoPlayerView(controller: widget.controller),
          if (_showControls) _PlayerControls(
            isPlaying: widget.controller.value.isPlaying,
            onPlayPause: _togglePlayPause,
          ),
        ],
      ),
    );
  }
}

/// The video player view component
class _VideoPlayerView extends StatelessWidget {
  final VideoPlayerController controller;

  const _VideoPlayerView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: VideoPlayer(controller),
    );
  }
}

/// The play/pause controls overlay
class _PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;

  const _PlayerControls({
    required this.isPlaying,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.black.withAlpha(100),
      child: Center(
        child: IconButton(
          icon: Icon(
            isPlaying
                ? FluentIcons.pause_24_filled
                : FluentIcons.play_24_filled,
            color: Colors.white,
            size: 50,
          ),
          onPressed: onPlayPause,
        ),
      ),
    );
  }
} 