import 'dart:async';
import 'types.dart';

/// A controller for the [SnapScroller] widget.
///
/// This controller can be used to programmatically control the scroll position
/// and to listen to scroll events.
class Controller {
  StreamController<ControllerEvent>? _streamController;
  int _scrollPosition = 0;

  /// Returns the current scroll position
  int getScrollPosition() => _scrollPosition;

  /// Attaches a listener to the controller
  Stream<ControllerEvent>? attach() {
    if (_streamController != null) {
      _streamController?.close();
    }
    _streamController = StreamController<ControllerEvent>();
    return _streamController?.stream;
  }

  /// Notifies listeners of a scroll event
  void notifyListeners(ScrollEvent event) {
    if (event.targetIndex != null) {
      _scrollPosition = event.targetIndex!;
      _streamController?.add(ControllerEvent(ControllerCommandTypes.jumpToPosition, event.targetIndex!));
    }
  }

  /// Jumps to the specified position without animation
  void jumpToPosition(int position) {
    _scrollPosition = position;
    _streamController?.add(ControllerEvent(ControllerCommandTypes.jumpToPosition, position));
  }

  /// Animates to the specified position
  void animateToPosition(int position) {
    _scrollPosition = position;
    _streamController?.add(ControllerEvent(ControllerCommandTypes.animateToPosition, position));
  }

  /// Disposes the controller
  void dispose() {
    _streamController?.close();
    _streamController = null;
  }
}
