import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/time_display.dart';
import 'package:video_player/video_player.dart';

class VideoProgressWidget extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoProgressWidget({super.key, required this.controller});

  @override
  State<VideoProgressWidget> createState() => _VideoProgressWidgetState();
}

class _VideoProgressWidgetState extends State<VideoProgressWidget> {
  bool _isDragging = false;
  Duration _dragPosition = Duration.zero;
  bool _showTimeDisplay = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted && !_isDragging) {
      setState(() {});
    }
  }

  void _onDragStart(double value) {
    setState(() {
      _isDragging = true;
      _showTimeDisplay = true;
      _dragPosition = Duration(milliseconds: (value * widget.controller.value.duration.inMilliseconds).round());
    });
  }

  void _onDragUpdate(double value) {
    setState(() {
      _dragPosition = Duration(milliseconds: (value * widget.controller.value.duration.inMilliseconds).round());
    });
  }

  void _onDragEnd(double value) {
    final newPosition = Duration(milliseconds: (value * widget.controller.value.duration.inMilliseconds).round());
    widget.controller.seekTo(newPosition);
    setState(() {
      _isDragging = false;
    });

    // Hide time display after a delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_isDragging) {
        setState(() {
          _showTimeDisplay = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final duration = widget.controller.value.duration;
    final position = _isDragging ? _dragPosition : widget.controller.value.position;
    final progress = duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showTimeDisplay)
          Padding(padding: const EdgeInsets.only(bottom: 8), child: TimeDisplay(position: position, duration: duration)),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.white.withAlpha(64),
              thumbColor: AppColors.white,
              overlayShape: SliderComponentShape.noThumb,
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChangeStart: (value) => _onDragStart(value),
              onChanged: (value) => _onDragUpdate(value),
              onChangeEnd: (value) => _onDragEnd(value),
            ),
          ),
        ),
      ],
    );
  }
}
