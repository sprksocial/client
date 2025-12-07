import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A widget that displays an audio waveform with playback cursor.
class AudioWaveformWidget extends StatelessWidget {
  const AudioWaveformWidget({
    required this.waveformData,
    required this.progress,
    required this.audioName,
    this.audioSubtitle,
    this.audioImageUrl,
    this.height = 48,
    this.playedColor = const Color(0xFF3B82F6),
    this.unplayedColor = const Color(0xFF374151),
    this.cursorColor = Colors.white,
    this.showCursor = true,
    this.barWidth = 2,
    this.barSpacing = 1,
    this.borderRadius = 8,
    this.isCompact = false,
    super.key,
  });

  /// Normalized waveform data (values between 0.0 and 1.0).
  final List<double> waveformData;

  /// Current playback progress (0.0 to 1.0).
  final double progress;

  /// Name of the audio track to display.
  final String audioName;

  /// Subtitle (e.g., author handle) for the audio track.
  final String? audioSubtitle;

  /// Image URL (e.g., author avatar) to display.
  final String? audioImageUrl;

  /// Height of the waveform widget.
  final double height;

  /// Color for the played portion of the waveform.
  final Color playedColor;

  /// Color for the unplayed portion of the waveform.
  final Color unplayedColor;

  /// Color of the playback cursor.
  final Color cursorColor;

  /// Whether to show the playback cursor.
  final bool showCursor;

  /// Width of each waveform bar.
  final double barWidth;

  /// Spacing between waveform bars.
  final double barSpacing;

  /// Border radius for the container.
  final double borderRadius;

  /// Whether to use compact layout (smaller height, inline name).
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactLayout(context);
    }
    return _buildDetailedLayout(context);
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(
            Icons.music_note_rounded,
            color: Color(0xFF9CA3AF),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        audioName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (audioSubtitle != null) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          audioSubtitle!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 20,
                  child: _buildWaveform(),
                ),
              ],
            ),
          ),
          if (audioImageUrl != null) ...[
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: audioImageUrl!,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 32,
                  height: 32,
                  color: const Color(0xFF374151),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 32,
                  height: 32,
                  color: const Color(0xFF374151),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF9CA3AF),
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildDetailedLayout(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                const Icon(
                  Icons.music_note_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    audioName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: SizedBox(
              height: height - 32,
              child: _buildWaveform(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    if (waveformData.isEmpty) {
      return _buildPlaceholderWaveform();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _WaveformPainter(
            waveformData: waveformData,
            progress: progress,
            playedColor: playedColor,
            unplayedColor: unplayedColor,
            cursorColor: cursorColor,
            showCursor: showCursor,
            barWidth: barWidth,
            barSpacing: barSpacing,
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderWaveform() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _PlaceholderWaveformPainter(
            color: unplayedColor.withValues(alpha: 0.5),
            barWidth: barWidth,
            barSpacing: barSpacing,
            progress: progress,
            cursorColor: cursorColor,
            showCursor: showCursor,
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.waveformData,
    required this.progress,
    required this.playedColor,
    required this.unplayedColor,
    required this.cursorColor,
    required this.showCursor,
    required this.barWidth,
    required this.barSpacing,
  });

  final List<double> waveformData;
  final double progress;
  final Color playedColor;
  final Color unplayedColor;
  final Color cursorColor;
  final bool showCursor;
  final double barWidth;
  final double barSpacing;

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final barStep = barWidth + barSpacing;
    final barCount = (size.width / barStep).floor();
    final samplesPerBar = waveformData.length / barCount;

    final playedPaint = Paint()
      ..color = playedColor
      ..strokeCap = StrokeCap.round;

    final unplayedPaint = Paint()
      ..color = unplayedColor
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final cursorX = size.width * progress;

    for (var i = 0; i < barCount; i++) {
      final sampleIndex = (i * samplesPerBar).floor().clamp(0, waveformData.length - 1);
      final amplitude = waveformData[sampleIndex];
      final barHeight = (amplitude * size.height * 0.8).clamp(2.0, size.height);

      final x = i * barStep + barWidth / 2;
      final isPlayed = x <= cursorX;

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        isPlayed ? playedPaint : unplayedPaint,
      );
    }

    if (showCursor) {
      final cursorPaint = Paint()
        ..color = cursorColor
        ..strokeWidth = 2;

      canvas.drawLine(
        Offset(cursorX, 0),
        Offset(cursorX, size.height),
        cursorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.waveformData != waveformData ||
        oldDelegate.playedColor != playedColor ||
        oldDelegate.unplayedColor != unplayedColor;
  }
}

class _PlaceholderWaveformPainter extends CustomPainter {
  _PlaceholderWaveformPainter({
    required this.color,
    required this.barWidth,
    required this.barSpacing,
    required this.progress,
    required this.cursorColor,
    required this.showCursor,
  });

  final Color color;
  final double barWidth;
  final double barSpacing;
  final double progress;
  final Color cursorColor;
  final bool showCursor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round;

    final barStep = barWidth + barSpacing;
    final barCount = (size.width / barStep).floor();
    final centerY = size.height / 2;

    for (var i = 0; i < barCount; i++) {
      final x = i * barStep + barWidth / 2;
      final barHeight = size.height * 0.3;

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }

    // Draw cursor on placeholder too
    if (showCursor) {
      final cursorX = size.width * progress;
      final cursorPaint = Paint()
        ..color = cursorColor
        ..strokeWidth = 2;

      canvas.drawLine(
        Offset(cursorX, 0),
        Offset(cursorX, size.height),
        cursorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PlaceholderWaveformPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.progress != progress;
  }
}
