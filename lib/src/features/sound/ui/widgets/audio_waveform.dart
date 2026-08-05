import 'dart:math' as math;

import 'package:flutter/material.dart';

enum AudioWaveformPresentation { timeline, selection }

class AudioWaveform extends StatelessWidget {
  const AudioWaveform({
    required this.samples,
    required this.color,
    required this.presentation,
    this.size = Size.zero,
    super.key,
  });

  final List<double> samples;
  final Color color;
  final AudioWaveformPresentation presentation;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _AudioWaveformPainter(
        samples: samples,
        color: color,
        presentation: presentation,
      ),
    );
  }
}

class _AudioWaveformPainter extends CustomPainter {
  const _AudioWaveformPainter({
    required this.samples,
    required this.color,
    required this.presentation,
  });

  final List<double> samples;
  final Color color;
  final AudioWaveformPresentation presentation;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty && presentation == AudioWaveformPresentation.timeline) {
      return;
    }
    final strokeWidth = switch (presentation) {
      AudioWaveformPresentation.timeline => 2.0,
      AudioWaveformPresentation.selection => 2.4,
    };
    final barStep = switch (presentation) {
      AudioWaveformPresentation.timeline => 4.0,
      AudioWaveformPresentation.selection => 5.0,
    };
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final barCount = math.max(1, (size.width / barStep).floor());
    final centerY = size.height / 2;

    for (var index = 0; index < barCount; index++) {
      final position = barCount == 1 ? 0.0 : index / (barCount - 1);
      final amplitude = _amplitudeAt(position);
      final barHeight = switch (presentation) {
        AudioWaveformPresentation.timeline =>
          (amplitude * size.height * 0.7).clamp(2.0, size.height - 4),
        AudioWaveformPresentation.selection =>
          8 + amplitude * (size.height - 12),
      };
      final x = barCount == 1 ? size.width / 2 : position * size.width;
      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  double _amplitudeAt(double position) {
    if (samples.isEmpty) {
      return (0.3 +
              math.sin(position * math.pi * 13).abs() * 0.38 +
              math.sin(position * math.pi * 29).abs() * 0.22)
          .clamp(0.0, 1.0);
    }
    final sampleIndex = (position * (samples.length - 1)).round();
    return samples[sampleIndex].abs().clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(covariant _AudioWaveformPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.color != color ||
        oldDelegate.presentation != presentation;
  }
}
