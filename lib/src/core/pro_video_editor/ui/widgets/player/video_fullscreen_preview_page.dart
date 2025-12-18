import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/circle_icon_button.dart';
import 'package:sparksocial/src/core/design_system/theme/text_theme.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';
import 'package:video_player/video_player.dart';

class VideoFullscreenPreviewPage extends StatefulWidget {
  const VideoFullscreenPreviewPage({
    required this.controller,
    required this.videoTimelineState,
    required this.onTogglePlay,
    required this.onSeek,
    super.key,
  });

  final VideoPlayerController controller;
  final VideoTimelineState videoTimelineState;
  final VoidCallback onTogglePlay;
  final void Function(double progress) onSeek;

  @override
  State<VideoFullscreenPreviewPage> createState() => _VideoFullscreenPreviewPageState();
}

class _VideoFullscreenPreviewPageState extends State<VideoFullscreenPreviewPage> {
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBlack,
      body: Stack(
        children: [
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleControls,
              child: widget.controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: widget.controller.value.size.aspectRatio,
                      child: VideoPlayer(widget.controller),
                    )
                  : const SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator.adaptive(),
                    ),
            ),
          ),
          _OverlayControls(
            visible: _controlsVisible,
            videoTimelineState: widget.videoTimelineState,
            onClose: () => Navigator.of(context).pop(),
            onTogglePlay: widget.onTogglePlay,
            onSeek: widget.onSeek,
            formatDuration: _formatDuration,
          ),
        ],
      ),
    );
  }
}

class _OverlayControls extends StatelessWidget {
  const _OverlayControls({
    required this.visible,
    required this.videoTimelineState,
    required this.onClose,
    required this.onTogglePlay,
    required this.onSeek,
    required this.formatDuration,
  });

  final bool visible;
  final VideoTimelineState videoTimelineState;
  final VoidCallback onClose;
  final VoidCallback onTogglePlay;
  final void Function(double progress) onSeek;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Stack(
          children: [
            // Top scrim + close
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.greyBlack.withAlpha(220),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleIconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close, size: 22),
                        backgroundColor: AppColors.greyBlack.withAlpha(140),
                        iconColor: AppColors.greyWhite,
                        size: 40,
                        semanticLabel: 'Close',
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom scrim + controls
            SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.greyBlack.withAlpha(240),
                        AppColors.greyBlack.withAlpha(160),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: AnimatedBuilder(
                    animation: videoTimelineState,
                    builder: (context, _) {
                      final duration = videoTimelineState.videoDuration;
                      final isDurationValid = duration.inMilliseconds > 0;
                      final progress = isDurationValid ? videoTimelineState.progress.clamp(0.0, 1.0) : 0.0;
                      final currentPosition = Duration(
                        milliseconds: (progress * duration.inMilliseconds).round(),
                      );

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              CircleIconButton(
                                onPressed: onTogglePlay,
                                icon: Icon(
                                  videoTimelineState.isPlaying ? Icons.pause : Icons.play_arrow,
                                  size: 22,
                                ),
                                backgroundColor: AppColors.greyBlack.withAlpha(140),
                                iconColor: AppColors.greyWhite,
                                size: 40,
                                semanticLabel: videoTimelineState.isPlaying ? 'Pause' : 'Play',
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${formatDuration(currentPosition)}/${formatDuration(duration)}',
                                style: AppTextTheme.dark.bodySmall?.copyWith(
                                  color: AppColors.greyWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                              activeTrackColor: AppColors.primary400,
                              inactiveTrackColor: AppColors.grey700,
                              thumbColor: AppColors.greyWhite,
                              overlayColor: AppColors.primary400.withAlpha(25),
                            ),
                            child: Slider(
                              value: progress,
                              onChanged: isDurationValid ? onSeek : null,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
