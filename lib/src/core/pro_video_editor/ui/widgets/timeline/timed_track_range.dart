import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';

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
    this.minimumRangeFraction = 0.01,
    this.onTap,
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
  final double minimumRangeFraction;
  final VoidCallback? onTap;

  @override
  State<TimedTrackRange> createState() => _TimedTrackRangeState();
}

class _TimedTrackRangeState extends State<TimedTrackRange> {
  late double _start = widget.startFraction;
  late double _end = widget.endFraction;
  bool _isDragging = false;

  @override
  void didUpdateWidget(covariant TimedTrackRange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isDragging) return;
    _start = widget.startFraction;
    _end = widget.endFraction;
  }

  void _dragStart(DragStartDetails _) => _isDragging = true;

  void _dragStartHandle(DragUpdateDetails details) {
    final maxStart = (_end - widget.minimumRangeFraction)
        .clamp(0.0, 1.0)
        .toDouble();
    final next = (_start + details.delta.dx / widget.sourceWidth)
        .clamp(0.0, maxStart)
        .toDouble();
    _update(next, _end);
  }

  void _dragEndHandle(DragUpdateDetails details) {
    final minEnd = (_start + widget.minimumRangeFraction)
        .clamp(0.0, 1.0)
        .toDouble();
    final next = (_end + details.delta.dx / widget.sourceWidth)
        .clamp(minEnd, 1.0)
        .toDouble();
    _update(_start, next);
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
                  Positioned(
                    left: _start * widget.sourceWidth,
                    width: (_end - _start) * widget.sourceWidth,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onTap,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.color,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.greyWhite.withAlpha(180),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                  _RangeHandle(
                    left: _start * widget.sourceWidth,
                    height: widget.height,
                    alignment: Alignment.centerLeft,
                    onDragStart: _dragStart,
                    onDragUpdate: _dragStartHandle,
                    onDragEnd: _dragEnd,
                    onDragCancel: _finishDrag,
                  ),
                  _RangeHandle(
                    left: _end * widget.sourceWidth - 24,
                    height: widget.height,
                    alignment: Alignment.centerRight,
                    onDragStart: _dragStart,
                    onDragUpdate: _dragEndHandle,
                    onDragEnd: _dragEnd,
                    onDragCancel: _finishDrag,
                  ),
                ],
              ),
            ),
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
    required this.alignment,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
  });

  final double left;
  final double height;
  final Alignment alignment;
  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;
  final VoidCallback onDragCancel;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: 0,
      width: 24,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: onDragStart,
        onHorizontalDragUpdate: onDragUpdate,
        onHorizontalDragEnd: onDragEnd,
        onHorizontalDragCancel: onDragCancel,
        child: Align(
          alignment: alignment,
          child: Container(
            width: 4,
            height: height * 0.58,
            decoration: BoxDecoration(
              color: AppColors.greyWhite,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
