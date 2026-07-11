import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_selection_handle.dart';

const _kRangeHandleHitWidth = 32.0;
const _kOutsideRangeMarkerWidth = 8.0;

class TimedTrackRange extends StatefulWidget {
  const TimedTrackRange({
    required this.totalWidth,
    required this.sourceWidth,
    required this.sourceOffset,
    required this.height,
    required this.startFraction,
    required this.endFraction,
    required this.color,
    required this.child,
    required this.onRangeChanged,
    required this.onRangeChangeEnd,
    required this.isSelected,
    this.minimumRangeFraction = 0.01,
    this.onTap,
    this.borderColor,
    this.foreground,
    super.key,
  });

  final double totalWidth;
  final double sourceWidth;
  final double sourceOffset;
  final double height;
  final double startFraction;
  final double endFraction;
  final Color color;
  final Widget child;
  final void Function(double start, double end) onRangeChanged;
  final void Function(double start, double end) onRangeChangeEnd;
  final bool isSelected;
  final double minimumRangeFraction;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Widget? foreground;

  @override
  State<TimedTrackRange> createState() => _TimedTrackRangeState();
}

class _TimedTrackRangeState extends State<TimedTrackRange> {
  late double _start = widget.startFraction;
  late double _end = widget.endFraction;
  bool _isDragging = false;

  double get _viewportStartFraction {
    if (widget.sourceWidth <= 0) return 0;
    return (widget.sourceOffset / widget.sourceWidth)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  double get _viewportEndFraction {
    if (widget.sourceWidth <= 0) return 1;
    return ((widget.sourceOffset + widget.totalWidth) / widget.sourceWidth)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  @override
  void didUpdateWidget(covariant TimedTrackRange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isDragging) return;
    _start = widget.startFraction;
    _end = widget.endFraction;
  }

  void _dragStart(DragStartDetails _) => _isDragging = true;

  void _dragStartHandle(DragUpdateDetails details) {
    final viewportStart = _viewportStartFraction;
    final visibleEnd = math.min(_end, _viewportEndFraction);
    final maxStart = math.max(
      viewportStart,
      visibleEnd - widget.minimumRangeFraction,
    );
    final visibleStart = math.max(_start, viewportStart);
    final nextVisible = visibleStart + details.delta.dx / widget.sourceWidth;
    if (_start < viewportStart && nextVisible <= viewportStart) return;
    final next = nextVisible.clamp(viewportStart, maxStart).toDouble();
    _update(next, _end);
  }

  void _dragEndHandle(DragUpdateDetails details) {
    final viewportEnd = _viewportEndFraction;
    final visibleStart = math.max(_start, _viewportStartFraction);
    final minEnd = math.min(
      viewportEnd,
      visibleStart + widget.minimumRangeFraction,
    );
    final visibleEnd = math.min(_end, viewportEnd);
    final nextVisible = visibleEnd + details.delta.dx / widget.sourceWidth;
    if (_end > viewportEnd && nextVisible >= viewportEnd) return;
    final next = nextVisible.clamp(minEnd, viewportEnd).toDouble();
    _update(_start, next);
  }

  void _dragEndIntoViewport(DragUpdateDetails details) {
    if (widget.sourceWidth <= 0 || details.delta.dx <= 0) return;
    final viewportStart = _viewportStartFraction;
    final viewportEnd = _viewportEndFraction;
    final minEnd = math.min(
      viewportEnd,
      viewportStart + widget.minimumRangeFraction,
    );
    final next = (viewportStart + details.delta.dx / widget.sourceWidth)
        .clamp(minEnd, viewportEnd)
        .toDouble();
    _update(_start, next);
  }

  void _dragStartIntoViewport(DragUpdateDetails details) {
    if (widget.sourceWidth <= 0 || details.delta.dx >= 0) return;
    final viewportStart = _viewportStartFraction;
    final viewportEnd = _viewportEndFraction;
    final maxStart = math.max(
      viewportStart,
      viewportEnd - widget.minimumRangeFraction,
    );
    final next = (viewportEnd + details.delta.dx / widget.sourceWidth)
        .clamp(viewportStart, maxStart)
        .toDouble();
    _update(next, _end);
  }

  void _update(double start, double end) {
    setState(() {
      _start = start;
      _end = end;
    });
    widget.onRangeChanged(start, end);
  }

  void _dragEnd(DragEndDetails _) {
    _finishDrag();
  }

  void _finishDrag() {
    _isDragging = false;
    widget.onRangeChangeEnd(_start, _end);
  }

  @override
  Widget build(BuildContext context) {
    final viewportStart = _viewportStartFraction;
    final viewportEnd = _viewportEndFraction;
    final visibleStart = math.max(_start, viewportStart);
    final visibleEnd = math.min(_end, viewportEnd);
    final hasVisibleRange = visibleEnd > visibleStart;
    final isBeforeViewport = _end <= viewportStart;
    final isAfterViewport = _start >= viewportEnd;
    final rangeWidth = math.max(0.0, (_end - _start) * widget.sourceWidth);
    final hiddenLeadingWidth = math.max(
      0.0,
      (visibleStart - _start) * widget.sourceWidth,
    );

    return SizedBox(
      width: widget.totalWidth,
      height: widget.height,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          minWidth: widget.sourceWidth,
          maxWidth: widget.sourceWidth,
          minHeight: widget.height,
          maxHeight: widget.height,
          child: Transform.translate(
            offset: Offset(-widget.sourceOffset, 0),
            child: SizedBox(
              width: widget.sourceWidth,
              height: widget.height,
              child: Stack(
                children: [
                  if (hasVisibleRange) ...[
                    Positioned(
                      left: visibleStart * widget.sourceWidth,
                      width: (visibleEnd - visibleStart) * widget.sourceWidth,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.onTap,
                        child: DecoratedBox(
                          key: const ValueKey('timed-track-range-surface'),
                          decoration: BoxDecoration(
                            color: widget.color,
                            borderRadius: BorderRadius.circular(6),
                            border: widget.isSelected
                                ? Border.all(
                                    color:
                                        widget.borderColor ??
                                        AppColors.greyWhite,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRect(
                                  child: OverflowBox(
                                    alignment: Alignment.centerLeft,
                                    minWidth: rangeWidth,
                                    maxWidth: rangeWidth,
                                    minHeight: widget.height,
                                    maxHeight: widget.height,
                                    child: Transform.translate(
                                      offset: Offset(-hiddenLeadingWidth, 0),
                                      child: SizedBox(
                                        width: rangeWidth,
                                        height: widget.height,
                                        child: widget.child,
                                      ),
                                    ),
                                  ),
                                ),
                                ?widget.foreground,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.isSelected) ...[
                      _RangeHandle(
                        left: visibleStart * widget.sourceWidth,
                        height: widget.height,
                        isLeft: true,
                        isStartHandle: true,
                        onDragStart: _dragStart,
                        onDragUpdate: _dragStartHandle,
                        onDragEnd: _dragEnd,
                        onDragCancel: _finishDrag,
                      ),
                      _RangeHandle(
                        left:
                            visibleEnd * widget.sourceWidth -
                            _kRangeHandleHitWidth,
                        height: widget.height,
                        isLeft: false,
                        isStartHandle: false,
                        onDragStart: _dragStart,
                        onDragUpdate: _dragEndHandle,
                        onDragEnd: _dragEnd,
                        onDragCancel: _finishDrag,
                      ),
                    ],
                  ] else if (isBeforeViewport || isAfterViewport) ...[
                    _OutsideRangeMarker(
                      left: isBeforeViewport
                          ? viewportStart * widget.sourceWidth
                          : viewportEnd * widget.sourceWidth -
                                _kRangeHandleHitWidth,
                      height: widget.height,
                      alignLeft: isBeforeViewport,
                      color: widget.color,
                      isSelected: widget.isSelected,
                      borderColor: widget.borderColor,
                      onTap: widget.onTap,
                    ),
                    if (widget.isSelected && isBeforeViewport)
                      _RangeHandle(
                        left: viewportStart * widget.sourceWidth,
                        height: widget.height,
                        isLeft: true,
                        isStartHandle: false,
                        onDragStart: _dragStart,
                        onDragUpdate: _dragEndIntoViewport,
                        onDragEnd: _dragEnd,
                        onDragCancel: _finishDrag,
                        onTap: widget.onTap,
                      ),
                    if (widget.isSelected && isAfterViewport)
                      _RangeHandle(
                        left:
                            viewportEnd * widget.sourceWidth -
                            _kRangeHandleHitWidth,
                        height: widget.height,
                        isLeft: false,
                        isStartHandle: true,
                        onDragStart: _dragStart,
                        onDragUpdate: _dragStartIntoViewport,
                        onDragEnd: _dragEnd,
                        onDragCancel: _finishDrag,
                        onTap: widget.onTap,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutsideRangeMarker extends StatelessWidget {
  const _OutsideRangeMarker({
    required this.left,
    required this.height,
    required this.alignLeft,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.borderColor,
  });

  final double left;
  final double height;
  final bool alignLeft;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: 0,
      width: _kRangeHandleHitWidth,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Align(
          alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: DecoratedBox(
            key: const ValueKey('timed-track-range-surface'),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
              border: isSelected
                  ? Border.all(
                      color: borderColor ?? AppColors.greyWhite,
                      width: 1,
                    )
                  : null,
            ),
            child: SizedBox(width: _kOutsideRangeMarkerWidth, height: height),
          ),
        ),
      ),
    );
  }
}

class _RangeHandle extends StatelessWidget {
  const _RangeHandle({
    required this.left,
    required this.height,
    required this.isLeft,
    required this.isStartHandle,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
    this.onTap,
  });

  final double left;
  final double height;
  final bool isLeft;
  final bool isStartHandle;
  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;
  final VoidCallback onDragCancel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: 0,
      width: _kRangeHandleHitWidth,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: onDragStart,
        onHorizontalDragUpdate: onDragUpdate,
        onHorizontalDragEnd: onDragEnd,
        onHorizontalDragCancel: onDragCancel,
        onTap: onTap,
        child: Align(
          alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: TimelineSelectionHandle(
            key: ValueKey(
              isStartHandle
                  ? 'timeline-selection-handle-start'
                  : 'timeline-selection-handle-end',
            ),
            isLeft: isLeft,
            height: height,
          ),
        ),
      ),
    );
  }
}
