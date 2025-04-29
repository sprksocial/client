enum DragState { idle, dragging, animatingForward, animatingBackward, animatingToCancel }

enum ScrollDirection { FORWARD, BACKWARDS }

enum ScrollSuccess { SUCCESS, FAILED_END_OF_LIST, FAILED_THRESHOLD_NOT_REACHED }

class ScrollEvent {
  final ScrollDirection direction;
  final ScrollSuccess success;
  final int? targetIndex;
  final double? scrollPosition;
  final double? percentWhenReleased;

  ScrollEvent(this.direction, this.success, this.targetIndex, {this.scrollPosition, this.percentWhenReleased});
}

enum ControllerCommandTypes { jumpToPosition, animateToPosition }

class ControllerEvent {
  final ControllerCommandTypes command;
  final dynamic data;

  ControllerEvent(this.command, this.data);
}
