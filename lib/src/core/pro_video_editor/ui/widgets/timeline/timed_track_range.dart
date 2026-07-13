import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_selection_handle.dart';

const _kRangeHandleHitWidth = 32.0;
const _kOutsideRangeMarkerWidth = 8.0;
const _kRepositionAxisDeadZone = 4.0;

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
    this.onRepositionStart,
    this.onVerticalRepositionChanged,
    this.onRepositionEnd,
    this.onRepositionCancel,
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
  final VoidCallback? onRepositionStart;
  final ValueChanged<double>? onVerticalRepositionChanged;
  final void Function(double start, double end, bool rangeChanged)?
  onRepositionEnd;
  final VoidCallback? onRepositionCancel;

  @override
  State<TimedTrackRange> createState() => _TimedTrackRangeState();
}

class _TimedTrackRangeState extends State<TimedTrackRange> {
  late double _start = widget.startFraction;
  late double _end = widget.endFraction;
  late double _repositionStart;
  late double _repositionEnd;
  late double _repositionAnchorStart;
  bool _isDragging = false;
  bool _isRepositioning = false;
  bool _rangeChangedDuringDrag = false;

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

  void _dragStart(DragStartDetails _) {
    _isDragging = true;
    _rangeChangedDuringDrag = false;
  }

  void _onRepositionStart(LongPressStartDetails _) {
    setState(() {
      _isDragging = true;
      _isRepositioning = true;
      _rangeChangedDuringDrag = false;
      _repositionStart = _start;
      _repositionEnd = _end;
      _repositionAnchorStart = _repositionStartForVisibleRange;
    });
    HapticFeedback.selectionClick();
    widget.onRepositionStart?.call();
  }

  double get _repositionStartForVisibleRange {
    final duration = _end - _start;
    final viewportStart = _viewportStartFraction;
    final viewportEnd = _viewportEndFraction;
    if (_end <= viewportStart) return viewportStart - duration;
    if (_start >= viewportEnd) return viewportEnd;
    if (_start < viewportStart) return viewportStart;
    if (_end > viewportEnd) return viewportEnd - duration;
    return _start;
  }

  void _onRepositionUpdate(LongPressMoveUpdateDetails details) {
    if (widget.sourceWidth <= 0) return;
    widget.onVerticalRepositionChanged?.call(details.offsetFromOrigin.dy);
    if (details.offsetFromOrigin.dx.abs() < _kRepositionAxisDeadZone) return;
    final duration = (_repositionEnd - _repositionStart)
        .clamp(0.0, 1.0)
        .toDouble();
    final maxStart = math.max(0.0, 1 - duration);
    final nextStart =
        (_repositionAnchorStart +
                details.offsetFromOrigin.dx / widget.sourceWidth)
            .clamp(0.0, maxStart)
            .toDouble();
    _update(nextStart, nextStart + duration);
  }

  void _onRepositionEnd(LongPressEndDetails _) => _finishReposition();

  void _finishReposition() {
    if (!_isRepositioning) return;
    widget.onRepositionEnd?.call(_start, _end, _rangeChangedDuringDrag);
    _finishDrag(commitRange: widget.onRepositionEnd == null);
  }

  void _cancelReposition() {
    if (!_isRepositioning) return;
    final shouldRestoreRange = _rangeChangedDuringDrag;
    setState(() {
      _start = _repositionStart;
      _end = _repositionEnd;
      _isDragging = false;
      _isRepositioning = false;
      _rangeChangedDuringDrag = false;
    });
    if (shouldRestoreRange) {
      widget.onRangeChanged(_repositionStart, _repositionEnd);
    }
    widget.onRepositionCancel?.call();
  }

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
    if (start == _start && end == _end) return;
    _rangeChangedDuringDrag = true;
    setState(() {
      _start = start;
      _end = end;
    });
    widget.onRangeChanged(start, end);
  }

  void _dragEnd(DragEndDetails _) {
    _finishDrag();
  }

  void _finishDrag({bool commitRange = true}) {
    final shouldCommitRange = _rangeChangedDuringDrag;
    if (_isRepositioning) {
      setState(() {
        _isDragging = false;
        _isRepositioning = false;
      });
    } else {
      _isDragging = false;
    }
    if (commitRange && shouldCommitRange) {
      widget.onRangeChangeEnd(_start, _end);
    }
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

    return Listener(
      onPointerCancel: (_) => _cancelReposition(),
      child: SizedBox(
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
                          onLongPressStart: _onRepositionStart,
                          onLongPressMoveUpdate: _onRepositionUpdate,
                          onLongPressEnd: _onRepositionEnd,
                          onLongPressCancel: _cancelReposition,
                          child: DecoratedBox(
                            key: const ValueKey('timed-track-range-surface'),
                            decoration: BoxDecoration(
                              color: widget.color,
                              borderRadius: BorderRadius.circular(6),
                              border: widget.isSelected && !_isRepositioning
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
                                  if (_isRepositioning)
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: DecoratedBox(
                                          key: const ValueKey(
                                            'timed-track-range-reposition-indicator',
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.greyWhite
                                                .withAlpha(28),
                                            border: Border.all(
                                              color: AppColors.greyWhite,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.open_with_rounded,
                                              size: 15,
                                              color: AppColors.greyWhite,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
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
                          isVisible: !_isRepositioning,
                          onDragStart: _dragStart,
                          onDragUpdate: _dragStartHandle,
                          onDragEnd: _dragEnd,
                          onDragCancel: _finishDrag,
                          onLongPressStart: _onRepositionStart,
                          onLongPressMoveUpdate: _onRepositionUpdate,
                          onLongPressEnd: _onRepositionEnd,
                          onLongPressCancel: _cancelReposition,
                        ),
                        _RangeHandle(
                          left:
                              visibleEnd * widget.sourceWidth -
                              _kRangeHandleHitWidth,
                          height: widget.height,
                          isLeft: false,
                          isStartHandle: false,
                          isVisible: !_isRepositioning,
                          onDragStart: _dragStart,
                          onDragUpdate: _dragEndHandle,
                          onDragEnd: _dragEnd,
                          onDragCancel: _finishDrag,
                          onLongPressStart: _onRepositionStart,
                          onLongPressMoveUpdate: _onRepositionUpdate,
                          onLongPressEnd: _onRepositionEnd,
                          onLongPressCancel: _cancelReposition,
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
                        isRepositioning: _isRepositioning,
                        borderColor: widget.borderColor,
                        onTap: widget.onTap,
                        onLongPressStart: _onRepositionStart,
                        onLongPressMoveUpdate: _onRepositionUpdate,
                        onLongPressEnd: _onRepositionEnd,
                        onLongPressCancel: _cancelReposition,
                      ),
                      if (widget.isSelected && isBeforeViewport)
                        _RangeHandle(
                          left: viewportStart * widget.sourceWidth,
                          height: widget.height,
                          isLeft: true,
                          isStartHandle: false,
                          isVisible: !_isRepositioning,
                          onDragStart: _dragStart,
                          onDragUpdate: _dragEndIntoViewport,
                          onDragEnd: _dragEnd,
                          onDragCancel: _finishDrag,
                          onTap: widget.onTap,
                          onLongPressStart: _onRepositionStart,
                          onLongPressMoveUpdate: _onRepositionUpdate,
                          onLongPressEnd: _onRepositionEnd,
                          onLongPressCancel: _cancelReposition,
                        ),
                      if (widget.isSelected && isAfterViewport)
                        _RangeHandle(
                          left:
                              viewportEnd * widget.sourceWidth -
                              _kRangeHandleHitWidth,
                          height: widget.height,
                          isLeft: false,
                          isStartHandle: true,
                          isVisible: !_isRepositioning,
                          onDragStart: _dragStart,
                          onDragUpdate: _dragStartIntoViewport,
                          onDragEnd: _dragEnd,
                          onDragCancel: _finishDrag,
                          onTap: widget.onTap,
                          onLongPressStart: _onRepositionStart,
                          onLongPressMoveUpdate: _onRepositionUpdate,
                          onLongPressEnd: _onRepositionEnd,
                          onLongPressCancel: _cancelReposition,
                        ),
                    ],
                  ],
                ),
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
    required this.isRepositioning,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressMoveUpdate,
    required this.onLongPressEnd,
    required this.onLongPressCancel,
    this.borderColor,
  });

  final double left;
  final double height;
  final bool alignLeft;
  final Color color;
  final bool isSelected;
  final bool isRepositioning;
  final VoidCallback? onTap;
  final GestureLongPressStartCallback onLongPressStart;
  final GestureLongPressMoveUpdateCallback onLongPressMoveUpdate;
  final GestureLongPressEndCallback onLongPressEnd;
  final VoidCallback onLongPressCancel;
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
        onLongPressStart: onLongPressStart,
        onLongPressMoveUpdate: onLongPressMoveUpdate,
        onLongPressEnd: onLongPressEnd,
        onLongPressCancel: onLongPressCancel,
        child: Align(
          alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: DecoratedBox(
            key: const ValueKey('timed-track-range-surface'),
            decoration: BoxDecoration(
              color: isRepositioning
                  ? Color.lerp(color, AppColors.greyWhite, 0.18)
                  : color,
              borderRadius: BorderRadius.circular(3),
              border: isRepositioning
                  ? Border.all(color: AppColors.greyWhite, width: 2)
                  : isSelected
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
    required this.isVisible,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
    required this.onLongPressStart,
    required this.onLongPressMoveUpdate,
    required this.onLongPressEnd,
    required this.onLongPressCancel,
    this.onTap,
  });

  final double left;
  final double height;
  final bool isLeft;
  final bool isStartHandle;
  final bool isVisible;
  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;
  final VoidCallback onDragCancel;
  final GestureLongPressStartCallback onLongPressStart;
  final GestureLongPressMoveUpdateCallback onLongPressMoveUpdate;
  final GestureLongPressEndCallback onLongPressEnd;
  final VoidCallback onLongPressCancel;
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
        onLongPressStart: onLongPressStart,
        onLongPressMoveUpdate: onLongPressMoveUpdate,
        onLongPressEnd: onLongPressEnd,
        onLongPressCancel: onLongPressCancel,
        child: Align(
          alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: Opacity(
            opacity: isVisible ? 1 : 0,
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
      ),
    );
  }
}
