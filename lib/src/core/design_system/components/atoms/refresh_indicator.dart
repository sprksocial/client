import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/constants.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

/// Spark's pull-to-refresh treatment. The child must contain a vertical
/// scrollable; use AlwaysScrollableScrollPhysics for short or empty content.
class DSRefreshIndicator extends StatefulWidget {
  const DSRefreshIndicator({
    required this.onRefresh,
    required this.child,
    this.edgeOffset = 0,
    super.key,
  }) : assert(edgeOffset >= 0);

  final RefreshCallback onRefresh;
  final Widget child;

  /// Top inset for the indicator only. The scrollable content is not inset.
  /// Pass MediaQuery.paddingOf(context).top when drawing behind system UI.
  final double edgeOffset;

  @override
  State<DSRefreshIndicator> createState() => DSRefreshIndicatorState();
}

class DSRefreshIndicatorState extends State<DSRefreshIndicator>
    with TickerProviderStateMixin {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  late final _reveal = AnimationController(
    vsync: this,
    duration: AppConstants.animationFast,
  );
  late final _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  RefreshIndicatorStatus? _status;
  double _pullExtent = 0;
  bool _reduceMotion = false;

  bool get _refreshing =>
      _status == RefreshIndicatorStatus.snap ||
      _status == RefreshIndicatorStatus.refresh;

  /// Runs the same refresh as a pull gesture, coalescing concurrent requests.
  Future<void> show() => _refreshKey.currentState!.show();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _updateRipple();
  }

  void _updateRipple() {
    if (_refreshing && !_reduceMotion) {
      if (!_ripple.isAnimating) _ripple.repeat();
    } else {
      _ripple.stop();
    }
  }

  void _onStatusChange(RefreshIndicatorStatus? status) {
    setState(() => _status = status);
    switch (status) {
      case RefreshIndicatorStatus.drag:
        _pullExtent = 0;
        _reveal.value = 0;
        _ripple.value = 0;
      case RefreshIndicatorStatus.armed:
      case RefreshIndicatorStatus.snap:
      case RefreshIndicatorStatus.refresh:
        _reveal.animateTo(1, curve: Curves.easeOutCubic);
      case RefreshIndicatorStatus.done:
      case RefreshIndicatorStatus.canceled:
      case null:
        _reveal.animateBack(0, curve: Curves.easeOutCubic);
    }
    _updateRipple();
  }

  bool _onScroll(ScrollNotification notification) {
    // Flutter owns arming, cancellation and refresh lifetime. These deltas only
    // scrub the same ripple that continues on release; they never trigger a
    // refresh.
    if (notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical ||
        (_status != RefreshIndicatorStatus.drag &&
            _status != RefreshIndicatorStatus.armed)) {
      return false;
    }
    final delta = switch (notification) {
      ScrollUpdateNotification(:final scrollDelta) => scrollDelta ?? 0,
      OverscrollNotification(:final overscroll) => overscroll,
      _ => 0.0,
    };
    final direction = notification.metrics.axisDirection == AxisDirection.down
        ? -1
        : 1;
    _pullExtent = math.max(0, _pullExtent + delta * direction);
    final pullProgress = (_pullExtent / 120).clamp(0.0, 1.0);
    if (_status == RefreshIndicatorStatus.drag) {
      _reveal.value = pullProgress.clamp(0, 0.95);
    }
    if (!_reduceMotion) _ripple.value = pullProgress;
    return false;
  }

  @override
  void dispose() {
    _reveal.dispose();
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final label = switch (_status) {
      RefreshIndicatorStatus.snap ||
      RefreshIndicatorStatus.refresh ||
      RefreshIndicatorStatus.done => l10n.refreshIndicatorRefreshing,
      RefreshIndicatorStatus.armed => l10n.refreshIndicatorRelease,
      _ => l10n.refreshIndicatorPull,
    };

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: RefreshIndicator.noSpinner(
            key: _refreshKey,
            onRefresh: widget.onRefresh,
            onStatusChange: _onStatusChange,
            child: widget.child,
          ),
        ),
        Positioned(
          top: widget.edgeOffset + 12,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _reveal,
              builder: (context, child) {
                final progress = _reveal.value;
                if (progress == 0) return const SizedBox.shrink();
                return Opacity(
                  opacity: progress,
                  child: Transform.translate(
                    offset: Offset(0, _reduceMotion ? 0 : -12 * (1 - progress)),
                    child: Center(child: child),
                  ),
                );
              },
              child: Semantics(
                label: label,
                liveRegion: true,
                child: RepaintBoundary(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: SizedBox(
                      width: 64,
                      height: 36,
                      child: CustomPaint(
                        painter: _RefreshDotsPainter(
                          animation: _ripple,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RefreshDotsPainter extends CustomPainter {
  _RefreshDotsPainter({required this.animation, required this.color})
    : super(repaint: animation);

  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final phase = animation.value % 1;
    // Each cycle begins and ends with three matching dots at rest.
    final envelope = math.sin(phase * math.pi);
    final intensity = envelope * envelope;
    for (var i = 0; i < 3; i++) {
      final wave = (math.sin((phase - i * 0.16) * math.pi * 2) + 1) / 2;
      paint.color = color.withValues(alpha: 1 - intensity * (1 - wave) * 0.6);
      final center = Offset(size.width / 2 + (i - 1) * 12, size.height / 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center,
            width: 6,
            height: 6 + intensity * wave * 6,
          ),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RefreshDotsPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.animation != animation;
}
