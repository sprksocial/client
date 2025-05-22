import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

@RoutePage()
class VideoPlaybackPage extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoPlaybackPage({super.key, required this.controller});

  @override
  State<VideoPlaybackPage> createState() => _VideoPlaybackPageState();
}

class _VideoPlaybackPageState extends State<VideoPlaybackPage> {
  bool _showControls = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.controller.value.isPlaying;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Hide controls after a delay
    _autoHideControls();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
        _isPlaying = false;
      } else {
        widget.controller.play();
        _isPlaying = true;
        _autoHideControls();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _autoHideControls();
      }
    });
  }

  void _autoHideControls() {
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = widget.controller.value.duration;
    final position = widget.controller.value.position;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Video Player
            Center(child: AspectRatio(aspectRatio: widget.controller.value.aspectRatio, child: VideoPlayer(widget.controller))),

            // Controls overlay
            if (_showControls)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withAlpha(102),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Play/Pause button
                      IconButton(
                        icon: Icon(
                          _isPlaying ? FluentIcons.pause_48_filled : FluentIcons.play_48_filled,
                          color: Colors.white,
                          size: 60,
                        ),
                        onPressed: _togglePlayPause,
                      ),

                      // Back button
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 16,
                        child: IconButton(
                          icon: const Icon(FluentIcons.arrow_left_24_filled, color: Colors.white, size: 28),
                          onPressed: () => context.router.maybePop(),
                        ),
                      ),

                      // Progress bar and time
                      Positioned(
                        bottom: MediaQuery.of(context).padding.bottom + 24,
                        left: 16,
                        right: 16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Time indicators
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDuration(position), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  Text(_formatDuration(duration), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),

                            // Progress slider
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 4,
                                activeTrackColor: theme.colorScheme.primary,
                                inactiveTrackColor: Colors.white.withAlpha(77),
                                thumbColor: theme.colorScheme.primary,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                              ),
                              child: Slider(
                                value: position.inMilliseconds.toDouble(),
                                min: 0,
                                max: duration.inMilliseconds.toDouble(),
                                onChanged: (value) {
                                  widget.controller.seekTo(Duration(milliseconds: value.toInt()));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
