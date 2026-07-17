import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_selection_handle.dart';

const timedTrackRangeHandleHitWidth = 32.0;
const _outsideRangeMarkerWidth = 8.0;

class TimedTrackOutsideRangeMarker extends StatelessWidget {
  const TimedTrackOutsideRangeMarker({
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
    super.key,
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
      width: timedTrackRangeHandleHitWidth,
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
            child: SizedBox(width: _outsideRangeMarkerWidth, height: height),
          ),
        ),
      ),
    );
  }
}

class TimedTrackRangeHandle extends StatelessWidget {
  const TimedTrackRangeHandle({
    required this.left,
    this.width = timedTrackRangeHandleHitWidth,
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
    super.key,
  });

  final double left;
  final double width;
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
      width: width,
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
          child: OverflowBox(
            alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            minWidth: 18,
            maxWidth: 18,
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
      ),
    );
  }
}
