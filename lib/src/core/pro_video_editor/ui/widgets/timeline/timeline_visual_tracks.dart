import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

class TimelineTimeRuler extends StatelessWidget {
  const TimelineTimeRuler({
    required this.totalWidth,
    required this.pixelsPerSecond,
    required this.height,
    required this.videoDuration,
    super.key,
  });

  final double totalWidth;
  final double pixelsPerSecond;
  final double height;
  final Duration videoDuration;

  @override
  Widget build(BuildContext context) {
    final totalSeconds = videoDuration.inSeconds;
    return SizedBox(
      width: totalWidth,
      height: height,
      child: CustomPaint(
        painter: _TimelineTimeRulerPainter(
          totalSeconds: totalSeconds,
          pixelsPerSecond: pixelsPerSecond,
          tickInterval: _tickInterval(totalSeconds),
        ),
      ),
    );
  }

  int _tickInterval(int totalSeconds) {
    if (totalSeconds <= 10) return 1;
    if (totalSeconds <= 30) return 5;
    if (totalSeconds <= 60) return 10;
    if (totalSeconds <= 300) return 30;
    return 60;
  }
}

class _TimelineTimeRulerPainter extends CustomPainter {
  _TimelineTimeRulerPainter({
    required this.totalSeconds,
    required this.pixelsPerSecond,
    required this.tickInterval,
  });

  final int totalSeconds;
  final double pixelsPerSecond;
  final int tickInterval;

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
        textPainter
          ..text = TextSpan(
            text: _formatTime(seconds),
            style: const TextStyle(
              color: AppColors.grey300,
              fontSize: 10,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          )
          ..layout()
          ..paint(canvas, Offset(x - textPainter.width / 2, 2));
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

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  bool shouldRepaint(covariant _TimelineTimeRulerPainter oldDelegate) {
    return oldDelegate.totalSeconds != totalSeconds ||
        oldDelegate.pixelsPerSecond != pixelsPerSecond;
  }
}

class VideoThumbnailTrack extends StatelessWidget {
  const VideoThumbnailTrack({
    required this.totalWidth,
    required this.sourceWidth,
    required this.sourceOffset,
    required this.height,
    required this.videoTimelineState,
    super.key,
  });

  final double totalWidth;
  final double sourceWidth;
  final double sourceOffset;
  final double height;
  final VideoTimelineState videoTimelineState;

  @override
  Widget build(BuildContext context) {
    final thumbnails = videoTimelineState.thumbnails;
    return Container(
      key: const ValueKey('timeline-primary-track'),
      width: totalWidth,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.grey700,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.grey500),
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          minWidth: sourceWidth,
          maxWidth: sourceWidth,
          minHeight: height,
          maxHeight: height,
          child: Transform.translate(
            offset: Offset(-sourceOffset, 0),
            child: SizedBox(
              width: sourceWidth,
              height: height,
              child: thumbnails == null || thumbnails.isEmpty
                  ? _buildSkeleton()
                  : Row(
                      children: thumbnails
                          .map(
                            (thumbnail) => Expanded(
                              child: Image(
                                image: thumbnail,
                                fit: BoxFit.cover,
                                height: height,
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Row(
      children: List.generate(
        10,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(left: index > 0 ? 1 : 0),
            color: AppColors.grey600,
          ),
        ),
      ),
    );
  }
}
