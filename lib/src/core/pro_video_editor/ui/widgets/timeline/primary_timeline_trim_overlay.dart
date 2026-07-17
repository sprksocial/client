import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_selection_handle.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

const _handleWidth = 12.0;
const _capWidth = 6.0;
const _handleHitWidth = 32.0;
const _minimumTrimDuration = Duration(seconds: 1);

enum _TrimHandleSide { start, end }

class PrimaryTimelineTrimOverlay extends StatefulWidget {
  const PrimaryTimelineTrimOverlay({
    required this.timelineState,
    required this.sourceWidth,
    required this.trimStartLeft,
    required this.trimEndLeft,
    required this.rulerHeight,
    required this.thumbnailHeight,
    required this.onDragActivityChanged,
    this.onTrimChanged,
    this.onTrimEnd,
    super.key,
  });

  final VideoTimelineState timelineState;
  final double sourceWidth;
  final double trimStartLeft;
  final double trimEndLeft;
  final double rulerHeight;
  final double thumbnailHeight;
  final ValueChanged<bool> onDragActivityChanged;
  final void Function(double start, double end)? onTrimChanged;
  final void Function(double start, double end, bool isStartHandle)? onTrimEnd;

  @override
  State<PrimaryTimelineTrimOverlay> createState() =>
      _PrimaryTimelineTrimOverlayState();
}

class _PrimaryTimelineTrimOverlayState
    extends State<PrimaryTimelineTrimOverlay> {
  _TrimHandleSide? _activeHandle;
  double? _initialStart;
  double? _initialEnd;

  double get _minimumTrimFraction {
    final milliseconds = widget.timelineState.videoDuration.inMilliseconds;
    if (milliseconds <= 0) return 0;
    return _minimumTrimDuration.inMilliseconds / milliseconds;
  }

  void _startDrag(_TrimHandleSide side) {
    _activeHandle = side;
    _initialStart = widget.timelineState.trimStart;
    _initialEnd = widget.timelineState.trimEnd;
    widget.onDragActivityChanged(true);
  }

  void _updateStart(DragUpdateDetails details) {
    final state = widget.timelineState;
    final maxStart = (state.trimEnd - _minimumTrimFraction)
        .clamp(0.0, 1.0)
        .toDouble();
    final start = (state.trimStart + details.delta.dx / widget.sourceWidth)
        .clamp(0.0, maxStart)
        .toDouble();
    _updateRange(start, state.trimEnd);
  }

  void _updateEnd(DragUpdateDetails details) {
    final state = widget.timelineState;
    final minEnd = (state.trimStart + _minimumTrimFraction)
        .clamp(0.0, 1.0)
        .toDouble();
    final end = (state.trimEnd + details.delta.dx / widget.sourceWidth)
        .clamp(minEnd, 1.0)
        .toDouble();
    _updateRange(state.trimStart, end);
  }

  void _finishDrag(DragEndDetails _) {
    final activeHandle = _activeHandle;
    if (activeHandle == null) return;
    _clearDrag();
    widget.onTrimEnd?.call(
      widget.timelineState.trimStart,
      widget.timelineState.trimEnd,
      activeHandle == _TrimHandleSide.start,
    );
  }

  void _cancelDrag() {
    if (_activeHandle == null) return;
    final initialStart = _initialStart;
    final initialEnd = _initialEnd;
    _clearDrag();
    if (initialStart != null && initialEnd != null) {
      _updateRange(initialStart, initialEnd);
    }
  }

  void _clearDrag() {
    _activeHandle = null;
    _initialStart = null;
    _initialEnd = null;
    widget.onDragActivityChanged(false);
  }

  void _updateRange(double start, double end) {
    widget.timelineState.setTrimRange(start, end);
    widget.onTrimChanged?.call(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: widget.trimStartLeft,
            width: widget.trimEndLeft - widget.trimStartLeft,
            top: widget.rulerHeight,
            height: widget.thumbnailHeight,
            child: IgnorePointer(
              child: DecoratedBox(
                key: const ValueKey('timeline-primary-selection-frame'),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.greyWhite, width: 2),
                ),
              ),
            ),
          ),
          _buildHandle(
            left: widget.trimStartLeft,
            isLeft: true,
            side: _TrimHandleSide.start,
            onUpdate: _updateStart,
          ),
          _buildHandle(
            left: widget.trimEndLeft - _handleWidth - _capWidth,
            isLeft: false,
            side: _TrimHandleSide.end,
            onUpdate: _updateEnd,
          ),
        ],
      ),
    );
  }

  Widget _buildHandle({
    required double left,
    required bool isLeft,
    required _TrimHandleSide side,
    required GestureDragUpdateCallback onUpdate,
  }) {
    return Positioned(
      left: isLeft ? left : left - (_handleHitWidth - _handleWidth - _capWidth),
      top: widget.rulerHeight,
      width: _handleHitWidth,
      height: widget.thumbnailHeight,
      child: Listener(
        onPointerCancel: (_) => _cancelDrag(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (_) => _startDrag(side),
          onHorizontalDragUpdate: onUpdate,
          onHorizontalDragEnd: _finishDrag,
          onHorizontalDragCancel: _cancelDrag,
          child: Align(
            alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            child: TimelineSelectionHandle(
              key: ValueKey(
                isLeft
                    ? 'timeline-primary-selection-handle-start'
                    : 'timeline-primary-selection-handle-end',
              ),
              isLeft: isLeft,
              height: widget.thumbnailHeight,
            ),
          ),
        ),
      ),
    );
  }
}
