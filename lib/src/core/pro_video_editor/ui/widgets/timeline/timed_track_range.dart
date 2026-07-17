import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/layer_reorder_controller.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timed_track_range_parts.dart';

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
    this.reorderInteraction,
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
  final LayerReorderInteraction? reorderInteraction;

  @override
  State<TimedTrackRange> createState() => _TimedTrackRangeState();
}

class _TimedTrackRangeState extends State<TimedTrackRange> {
  late double _start = widget.startFraction;
  late double _end = widget.endFraction;
  late double _repositionStart;
  late double _repositionEnd;
  late double _repositionAnchorStart;
  late double _horizontalDragStart;
  late double _horizontalDragEnd;
  double _horizontalDragOffset = 0;
  bool _isDragging = false;
  bool _isHorizontalDragging = false;
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
    _isHorizontalDragging = true;
    _rangeChangedDuringDrag = false;
    _horizontalDragStart = _start;
    _horizontalDragEnd = _end;
    _horizontalDragOffset = 0;
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
    widget.reorderInteraction?.start();
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
    widget.reorderInteraction?.update(details.offsetFromOrigin.dy);
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
    final reorderInteraction = widget.reorderInteraction;
    if (reorderInteraction == null) {
      _finishDrag();
    } else {
      reorderInteraction.finish(_start, _end, _rangeChangedDuringDrag);
      _finishDrag(commitRange: false);
    }
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
    widget.reorderInteraction?.cancel();
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
    if (widget.sourceWidth <= 0) return;
    _horizontalDragOffset += details.delta.dx;
    if (_horizontalDragOffset <= 0) return;
    final viewportStart = _viewportStartFraction;
    final viewportEnd = _viewportEndFraction;
    final minEnd = math.min(
      viewportEnd,
      viewportStart + widget.minimumRangeFraction,
    );
    final next = (viewportStart + _horizontalDragOffset / widget.sourceWidth)
        .clamp(minEnd, viewportEnd)
        .toDouble();
    _update(_start, next);
  }

  void _dragStartIntoViewport(DragUpdateDetails details) {
    if (widget.sourceWidth <= 0) return;
    _horizontalDragOffset += details.delta.dx;
    if (_horizontalDragOffset >= 0) return;
    final viewportStart = _viewportStartFraction;
    final viewportEnd = _viewportEndFraction;
    final maxStart = math.max(
      viewportStart,
      viewportEnd - widget.minimumRangeFraction,
    );
    final next = (viewportEnd + _horizontalDragOffset / widget.sourceWidth)
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
    _isHorizontalDragging = false;
    _finishDrag();
  }

  void _cancelHorizontalDrag() {
    if (!_isHorizontalDragging) return;
    final shouldRestoreRange = _rangeChangedDuringDrag;
    setState(() {
      _start = _horizontalDragStart;
      _end = _horizontalDragEnd;
      _isDragging = false;
      _isHorizontalDragging = false;
      _rangeChangedDuringDrag = false;
    });
    if (shouldRestoreRange) {
      widget.onRangeChanged(_horizontalDragStart, _horizontalDragEnd);
    }
  }

  void _cancelActiveDrag() {
    if (_isHorizontalDragging) {
      _cancelHorizontalDrag();
    } else {
      _cancelReposition();
    }
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
    final visibleRangeWidth = math.max(
      0.0,
      (visibleEnd - visibleStart) * widget.sourceWidth,
    );
    final handleHitWidth = math.min(
      timedTrackRangeHandleHitWidth,
      visibleRangeWidth / 2,
    );
    final hiddenLeadingWidth = math.max(
      0.0,
      (visibleStart - _start) * widget.sourceWidth,
    );

    return Listener(
      onPointerCancel: (_) => _cancelActiveDrag(),
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
                        TimedTrackRangeHandle(
                          left: visibleStart * widget.sourceWidth,
                          width: handleHitWidth,
                          height: widget.height,
                          isLeft: true,
                          isStartHandle: true,
                          isVisible: !_isRepositioning,
                          onDragStart: _dragStart,
                          onDragUpdate: _dragStartHandle,
                          onDragEnd: _dragEnd,
                          onDragCancel: _cancelHorizontalDrag,
                          onLongPressStart: _onRepositionStart,
                          onLongPressMoveUpdate: _onRepositionUpdate,
                          onLongPressEnd: _onRepositionEnd,
                          onLongPressCancel: _cancelReposition,
                        ),
                        TimedTrackRangeHandle(
                          left:
                              visibleEnd * widget.sourceWidth - handleHitWidth,
                          width: handleHitWidth,
                          height: widget.height,
                          isLeft: false,
                          isStartHandle: false,
                          isVisible: !_isRepositioning,
                          onDragStart: _dragStart,
                          onDragUpdate: _dragEndHandle,
                          onDragEnd: _dragEnd,
                          onDragCancel: _cancelHorizontalDrag,
                          onLongPressStart: _onRepositionStart,
                          onLongPressMoveUpdate: _onRepositionUpdate,
                          onLongPressEnd: _onRepositionEnd,
                          onLongPressCancel: _cancelReposition,
                        ),
                      ],
                    ] else if (isBeforeViewport || isAfterViewport) ...[
                      TimedTrackOutsideRangeMarker(
                        left: isBeforeViewport
                            ? viewportStart * widget.sourceWidth
                            : viewportEnd * widget.sourceWidth -
                                  timedTrackRangeHandleHitWidth,
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
                        TimedTrackRangeHandle(
                          left: viewportStart * widget.sourceWidth,
                          height: widget.height,
                          isLeft: true,
                          isStartHandle: false,
                          isVisible: !_isRepositioning,
                          onDragStart: _dragStart,
                          onDragUpdate: _dragEndIntoViewport,
                          onDragEnd: _dragEnd,
                          onDragCancel: _cancelHorizontalDrag,
                          onTap: widget.onTap,
                          onLongPressStart: _onRepositionStart,
                          onLongPressMoveUpdate: _onRepositionUpdate,
                          onLongPressEnd: _onRepositionEnd,
                          onLongPressCancel: _cancelReposition,
                        ),
                      if (widget.isSelected && isAfterViewport)
                        TimedTrackRangeHandle(
                          left:
                              viewportEnd * widget.sourceWidth -
                              timedTrackRangeHandleHitWidth,
                          height: widget.height,
                          isLeft: false,
                          isStartHandle: true,
                          isVisible: !_isRepositioning,
                          onDragStart: _dragStart,
                          onDragUpdate: _dragStartIntoViewport,
                          onDragEnd: _dragEnd,
                          onDragCancel: _cancelHorizontalDrag,
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
