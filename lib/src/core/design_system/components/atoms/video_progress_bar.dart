import 'dart:math' as math;

import 'package:flutter/material.dart';

class DSVideoProgressBar extends StatelessWidget {
  const DSVideoProgressBar({
    required this.progress,
    super.key,
    this.bufferedSegments = const <(double, double)>[],
    this.height = 4,
    this.thumbRadius = 6,
    this.showThumb = true,
    this.dense = true,
    this.enableGestures = false,
    this.tapTargetHeight = 24,
    this.debugShowHitbox = false,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.semanticLabel = 'Video progress',
  });

  /// Played fraction (0..1).
  final double progress;

  /// Buffered segments (each tuple is startFrac/endFrac in 0..1 space).
  final List<(double, double)> bufferedSegments;

  /// Visual track height.
  final double height;

  /// Thumb radius.
  final double thumbRadius;

  /// Whether to show the thumb.
  final bool showThumb;

  /// Dense variant (slightly smaller thumb and height adjustments if true).
  final bool dense;

  /// Whether this widget should react to gestures.
  /// If true, wraps a GestureDetector.
  final bool enableGestures;

  /// Height of the interactive tap/drag target when gestures are enabled.
  final double tapTargetHeight;

  /// When true, renders a translucent overlay to visualize the gesture hitbox.
  final bool debugShowHitbox;

  final VoidCallback? onDragStart;
  final ValueChanged<double>? onDragUpdate;
  final ValueChanged<double>? onDragEnd;

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = dense ? height : math.max(height, height + 2);
    const trackRadius = Radius.zero;

    final backgroundColor = Colors.white.withValues(alpha: 40 / 255);
    final bufferedColor = Colors.white.withValues(alpha: 90 / 255);
    const playedColor = Colors.white;

    Widget painted = _ProgressPainterWidget(
      progress: progress.clamp(0, 1),
      bufferedSegments: bufferedSegments
          .where((seg) => seg.$2 > seg.$1)
          .map<(double, double)>((s) => (s.$1.clamp(0, 1), s.$2.clamp(0, 1)))
          .toList(growable: false),
      height: effectiveHeight,
      trackRadius: trackRadius,
      backgroundColor: backgroundColor,
      bufferedColor: bufferedColor,
      playedColor: playedColor,
      showThumb: showThumb,
      thumbRadius: thumbRadius,
    );

    if (enableGestures) {
      final gestureHeight = math.max(tapTargetHeight, effectiveHeight);
      painted = _GestureWrapper(
        onDragStart: onDragStart,
        onDragUpdate: onDragUpdate,
        onDragEnd: onDragEnd,
        child: SizedBox(
          height: gestureHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (debugShowHitbox)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.withValues(alpha: 0.13),
                    border: Border(
                      top: BorderSide(
                        color: Colors.pinkAccent.withValues(alpha: 0.3),
                      ),
                      bottom: BorderSide(
                        color: Colors.pinkAccent.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              Align(alignment: Alignment.bottomCenter, child: painted),
            ],
          ),
        ),
      );
    }

    return Semantics(
      label: semanticLabel,
      value: '${(progress * 100).toStringAsFixed(1)}%',
      child: SizedBox(
        // height: math.max(thumbRadius * 2, effectiveHeight),
        child: Center(child: painted),
      ),
    );
  }
}

class _ProgressPainterWidget extends StatelessWidget {
  const _ProgressPainterWidget({
    required this.progress,
    required this.bufferedSegments,
    required this.height,
    required this.trackRadius,
    required this.backgroundColor,
    required this.bufferedColor,
    required this.playedColor,
    required this.showThumb,
    required this.thumbRadius,
  });

  final double progress;
  final List<(double, double)> bufferedSegments;
  final double height;
  final Radius trackRadius;
  final Color backgroundColor;
  final Color bufferedColor;
  final Color playedColor;
  final bool showThumb;
  final double thumbRadius;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, height),
          painter: _ProgressPainter(
            progress: progress,
            bufferedSegments: bufferedSegments,
            trackRadius: trackRadius,
            backgroundColor: backgroundColor,
            bufferedColor: bufferedColor,
            playedColor: playedColor,
            showThumb: showThumb,
            thumbRadius: thumbRadius,
          ),
        );
      },
    );
  }
}

class _ProgressPainter extends CustomPainter {
  _ProgressPainter({
    required this.progress,
    required this.bufferedSegments,
    required this.trackRadius,
    required this.backgroundColor,
    required this.bufferedColor,
    required this.playedColor,
    required this.showThumb,
    required this.thumbRadius,
  });

  final double progress;
  final List<(double, double)> bufferedSegments;
  final Radius trackRadius;
  final Color backgroundColor;
  final Color bufferedColor;
  final Color playedColor;
  final bool showThumb;
  final double thumbRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final trackRect = Rect.fromLTWH(0, 0, size.width, size.height);

    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(trackRect, bgPaint);

    final bufferedPaint = Paint()..color = bufferedColor;
    for (final (start, end) in bufferedSegments) {
      final segRect = Rect.fromLTWH(
        size.width * start,
        0,
        size.width * (end - start),
        size.height,
      );
      canvas
        ..save()
        ..clipRect(trackRect)
        ..drawRect(segRect, bufferedPaint)
        ..restore();
    }

    final playedPaint = Paint()..color = playedColor;
    final playedRect = Rect.fromLTWH(0, 0, size.width * progress, size.height);
    canvas
      ..save()
      ..clipRect(trackRect)
      ..drawRect(playedRect, playedPaint)
      ..restore();

    if (showThumb) {
      final cx = size.width * progress;
      final cy = size.height / 2;
      final thumbPaint = Paint()..color = playedColor;
      canvas.drawCircle(Offset(cx, cy), thumbRadius, thumbPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter old) {
    return old.progress != progress ||
        old.bufferedSegments != bufferedSegments ||
        old.showThumb != showThumb ||
        old.thumbRadius != thumbRadius ||
        old.backgroundColor != backgroundColor ||
        old.bufferedColor != bufferedColor ||
        old.playedColor != playedColor;
  }
}

class _GestureWrapper extends StatefulWidget {
  const _GestureWrapper({
    required this.child,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  final Widget child;
  final VoidCallback? onDragStart;
  final ValueChanged<double>? onDragUpdate;
  final ValueChanged<double>? onDragEnd;

  @override
  State<_GestureWrapper> createState() => _GestureWrapperState();
}

class _GestureWrapperState extends State<_GestureWrapper> {
  double _lastFraction = 0;

  void _handleUpdate(BuildContext context, Offset localPosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final width = box.size.width;
    final fx = (localPosition.dx / width).clamp(0, 1).toDouble();
    _lastFraction = fx;
    widget.onDragUpdate?.call(fx);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (_) => widget.onDragStart?.call(),
          onHorizontalDragUpdate: (d) =>
              _handleUpdate(context, d.localPosition),
          onHorizontalDragEnd: (_) => widget.onDragEnd?.call(_lastFraction),
          onTapDown: (d) {
            widget.onDragStart?.call();
            _handleUpdate(context, d.localPosition);
          },
          onTapUp: (_) => widget.onDragEnd?.call(_lastFraction),
          child: widget.child,
        );
      },
    );
  }
}
