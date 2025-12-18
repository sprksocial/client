import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

/// A scrollable video timeline widget that displays thumbnails, audio track,
/// and a time ruler. The timeline scrolls horizontally and auto-follows playhead.
class ScrollableTimeline extends StatefulWidget {
  const ScrollableTimeline({
    required this.videoTimelineState,
    required this.onSeek,
    required this.onAddSound,
    this.thumbnailHeight = 56,
    this.audioTrackHeight = 44,
    this.rulerHeight = 24,
    this.pixelsPerSecond = 40.0,
    super.key,
  });

  final VideoTimelineState videoTimelineState;
  final void Function(double progress) onSeek;
  final VoidCallback onAddSound;
  final double thumbnailHeight;
  final double audioTrackHeight;
  final double rulerHeight;
  final double pixelsPerSecond;

  @override
  State<ScrollableTimeline> createState() => _ScrollableTimelineState();
}

class _ScrollableTimelineState extends State<ScrollableTimeline> {
  late ScrollController _scrollController;
  bool _isUserScrolling = false;
  bool _isProgrammaticScroll = false;
  Timer? _scrollEndTimer;

  double get _totalWidth => widget.videoTimelineState.videoDuration.inMilliseconds / 1000 * widget.pixelsPerSecond;

  double get _totalHeight => widget.rulerHeight + widget.thumbnailHeight + 8 + widget.audioTrackHeight;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.videoTimelineState.addListener(_onProgressChange);
  }

  @override
  void dispose() {
    widget.videoTimelineState.removeListener(_onProgressChange);
    _scrollEndTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onProgressChange() {
    if (_isUserScrolling || !_scrollController.hasClients) return;

    final targetScroll = widget.videoTimelineState.progress * _totalWidth;

    final clampedScroll = targetScroll.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _isProgrammaticScroll = true;
    _scrollController
        .animateTo(
          clampedScroll,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        )
        .then((_) => _isProgrammaticScroll = false);
  }

  void _onScrollUpdate() {
    if (!_scrollController.hasClients) return;

    final progress = (_scrollController.offset / _totalWidth).clamp(0.0, 1.0);
    widget.onSeek(progress);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.videoTimelineState,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final viewportWidth = constraints.maxWidth;

            return SizedBox(
              height: _totalHeight,
              child: Stack(
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollStartNotification) {
                        // Only mark as user scrolling if not a programmatic scroll
                        if (!_isProgrammaticScroll) {
                          _scrollEndTimer?.cancel();
                          _isUserScrolling = true;
                        }
                      } else if (notification is ScrollEndNotification) {
                        _scrollEndTimer?.cancel();
                        _scrollEndTimer = Timer(const Duration(milliseconds: 300), () {
                          if (mounted) {
                            _isUserScrolling = false;
                          }
                        });
                      } else if (notification is ScrollUpdateNotification) {
                        // Only seek when user is actually scrolling, not during programmatic scroll
                        if (_isUserScrolling && !_isProgrammaticScroll) {
                          _onScrollUpdate();
                        }
                      }
                      return false;
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: _totalWidth + viewportWidth,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: viewportWidth / 2),
                          child: Column(
                            children: [
                              _TimeRuler(
                                totalWidth: _totalWidth,
                                pixelsPerSecond: widget.pixelsPerSecond,
                                height: widget.rulerHeight,
                                videoDuration: widget.videoTimelineState.videoDuration,
                              ),
                              _VideoThumbnailTrack(
                                totalWidth: _totalWidth,
                                height: widget.thumbnailHeight,
                                videoTimelineState: widget.videoTimelineState,
                              ),
                              const SizedBox(height: 8),
                              _AudioTrack(
                                totalWidth: _totalWidth,
                                height: widget.audioTrackHeight,
                                videoTimelineState: widget.videoTimelineState,
                                onAddSound: widget.onAddSound,
                                pixelsPerSecond: widget.pixelsPerSecond,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Fixed playhead in center
                  Positioned(
                    left: viewportWidth / 2 - 1,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          color: AppColors.greyWhite,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.greyBlack.withAlpha(100),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TimeRuler extends StatelessWidget {
  const _TimeRuler({
    required this.totalWidth,
    required this.pixelsPerSecond,
    required this.height,
    required this.videoDuration,
  });

  final double totalWidth;
  final double pixelsPerSecond;
  final double height;
  final Duration videoDuration;

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = videoDuration.inSeconds;
    final tickInterval = _calculateTickInterval(totalSeconds);

    return SizedBox(
      width: totalWidth,
      height: height,
      child: CustomPaint(
        painter: _TimeRulerPainter(
          totalSeconds: totalSeconds,
          pixelsPerSecond: pixelsPerSecond,
          tickInterval: tickInterval,
          formatTime: _formatTime,
        ),
      ),
    );
  }

  int _calculateTickInterval(int totalSeconds) {
    if (totalSeconds <= 10) return 1;
    if (totalSeconds <= 30) return 5;
    if (totalSeconds <= 60) return 10;
    if (totalSeconds <= 300) return 30;
    return 60;
  }
}

class _TimeRulerPainter extends CustomPainter {
  _TimeRulerPainter({
    required this.totalSeconds,
    required this.pixelsPerSecond,
    required this.tickInterval,
    required this.formatTime,
  });

  final int totalSeconds;
  final double pixelsPerSecond;
  final int tickInterval;
  final String Function(int) formatTime;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grey400
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var seconds = 0; seconds <= totalSeconds; seconds++) {
      final x = seconds * pixelsPerSecond;

      if (seconds % tickInterval == 0) {
        canvas.drawLine(
          Offset(x, size.height - 12),
          Offset(x, size.height),
          paint,
        );

        textPainter.text = TextSpan(
          text: formatTime(seconds),
          style: const TextStyle(
            color: AppColors.grey300,
            fontSize: 10,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, 2));
      } else {
        canvas.drawLine(
          Offset(x, size.height - 6),
          Offset(x, size.height),
          paint..color = AppColors.grey500,
        );
        paint.color = AppColors.grey400;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TimeRulerPainter oldDelegate) {
    return oldDelegate.totalSeconds != totalSeconds || oldDelegate.pixelsPerSecond != pixelsPerSecond;
  }
}

class _VideoThumbnailTrack extends StatelessWidget {
  const _VideoThumbnailTrack({
    required this.totalWidth,
    required this.height,
    required this.videoTimelineState,
  });

  final double totalWidth;
  final double height;
  final VideoTimelineState videoTimelineState;

  @override
  Widget build(BuildContext context) {
    final thumbnails = videoTimelineState.thumbnails;

    return Container(
      width: totalWidth,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.grey700,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.grey500),
      ),
      clipBehavior: Clip.antiAlias,
      child: thumbnails == null || thumbnails.isEmpty
          ? _buildSkeleton()
          : Row(
              children: thumbnails.map((thumbnail) {
                return Expanded(
                  child: Image(
                    image: thumbnail,
                    fit: BoxFit.cover,
                    height: height,
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildSkeleton() {
    return Row(
      children: List.generate(10, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: index > 0 ? 1 : 0),
            color: AppColors.grey600,
          ),
        );
      }),
    );
  }
}

class _AudioTrack extends StatelessWidget {
  const _AudioTrack({
    required this.totalWidth,
    required this.height,
    required this.videoTimelineState,
    required this.onAddSound,
    required this.pixelsPerSecond,
  });

  final double totalWidth;
  final double height;
  final VideoTimelineState videoTimelineState;
  final VoidCallback onAddSound;
  final double pixelsPerSecond;

  @override
  Widget build(BuildContext context) {
    if (videoTimelineState.useCustomAudio) {
      return _buildAudioWaveformTrack();
    }
    return _buildAddSoundTrack();
  }

  Widget _buildAudioWaveformTrack() {
    return Container(
      width: totalWidth,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary600.withAlpha(180),
            AppColors.primary700.withAlpha(180),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Waveform
          Positioned.fill(
            child: CustomPaint(
              painter: _AudioWaveformPainter(
                waveformData: videoTimelineState.customWaveformData,
                totalWidth: totalWidth,
                pixelsPerSecond: pixelsPerSecond,
              ),
            ),
          ),
          // Audio info overlay at the start
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary700,
                    AppColors.primary700.withAlpha(200),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (videoTimelineState.authorAvatarUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: videoTimelineState.authorAvatarUrl!,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => _buildAvatarPlaceholder(),
                        errorWidget: (_, _, _) => _buildAvatarPlaceholder(),
                      ),
                    )
                  else
                    const Icon(Icons.music_note, color: AppColors.greyWhite, size: 18),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        videoTimelineState.activeAudioName,
                        style: const TextStyle(
                          color: AppColors.greyWhite,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (videoTimelineState.activeAudioSubtitle != null)
                        Text(
                          videoTimelineState.activeAudioSubtitle!,
                          style: TextStyle(
                            color: AppColors.greyWhite.withAlpha(180),
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.grey500,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.person, color: AppColors.grey300, size: 14),
    );
  }

  Widget _buildAddSoundTrack() {
    return GestureDetector(
      onTap: onAddSound,
      child: Container(
        width: totalWidth,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.grey700,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.grey500),
        ),
        child: const Stack(
          children: [
            // Centered add sound button (visible at the start)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.music_note, color: AppColors.grey300, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Add sound',
                      style: TextStyle(
                        color: AppColors.grey300,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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

class _AudioWaveformPainter extends CustomPainter {
  _AudioWaveformPainter({
    required this.waveformData,
    required this.totalWidth,
    required this.pixelsPerSecond,
  });

  final List<double> waveformData;
  final double totalWidth;
  final double pixelsPerSecond;

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.greyWhite.withAlpha(100)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const barWidth = 2.0;
    const barSpacing = 2.0;
    const barStep = barWidth + barSpacing;
    final barCount = (size.width / barStep).floor();
    final samplesPerBar = waveformData.length / barCount;
    final centerY = size.height / 2;

    for (var i = 0; i < barCount; i++) {
      final sampleIndex = (i * samplesPerBar).floor().clamp(0, waveformData.length - 1);
      final amplitude = waveformData[sampleIndex];
      final barHeight = (amplitude * size.height * 0.7).clamp(2.0, size.height - 4);
      final x = i * barStep + barWidth / 2;

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AudioWaveformPainter oldDelegate) {
    return oldDelegate.waveformData != waveformData || oldDelegate.totalWidth != totalWidth;
  }
}
