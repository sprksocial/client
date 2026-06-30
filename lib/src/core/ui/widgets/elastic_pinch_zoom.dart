import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ElasticPinchZoom extends StatefulWidget {
  const ElasticPinchZoom({
    required this.child,
    super.key,
    this.minScale = 1,
    this.maxScale = 3,
    this.minScaleOvershoot = 0.12,
    this.maxScaleOvershoot = 0.45,
    this.snapBackDuration = const Duration(milliseconds: 180),
    this.enabled = true,
  }) : assert(minScale > 0),
       assert(maxScale >= minScale),
       assert(minScaleOvershoot >= 0),
       assert(maxScaleOvershoot >= 0);

  final Widget child;
  final double minScale;
  final double maxScale;
  final double minScaleOvershoot;
  final double maxScaleOvershoot;
  final Duration snapBackDuration;
  final bool enabled;

  @override
  State<ElasticPinchZoom> createState() => _ElasticPinchZoomState();
}

class _ElasticPinchZoomState extends State<ElasticPinchZoom>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _translationAnimation;
  late double _scale;
  double _pinchStartScale = 1;
  Offset _translation = Offset.zero;
  Offset _pinchStartSceneFocalPoint = Offset.zero;

  @override
  void initState() {
    super.initState();
    _scale = widget.minScale;
    _animationController =
        AnimationController(duration: widget.snapBackDuration, vsync: this)
          ..addListener(() {
            setState(() {
              _scale = _scaleAnimation.value;
              _translation = _translationAnimation.value;
            });
          });
    _scaleAnimation = AlwaysStoppedAnimation(_scale);
    _translationAnimation = AlwaysStoppedAnimation(_translation);
  }

  @override
  void didUpdateWidget(covariant ElasticPinchZoom oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animationController.duration = widget.snapBackDuration;

    if (!widget.enabled && oldWidget.enabled) {
      _resetTransform();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePinchStart(ScaleStartDetails details) {
    _animationController.stop();
    _pinchStartScale = _scale;
    _pinchStartSceneFocalPoint =
        (details.localFocalPoint - _translation) / _scale;
  }

  void _handlePinchUpdate(ScaleUpdateDetails details) {
    final nextScale = _resistedScale(_pinchStartScale * details.scale);
    setState(() {
      _scale = nextScale;
      _translation =
          details.localFocalPoint - _pinchStartSceneFocalPoint * nextScale;
    });
  }

  double _resistedScale(double rawScale) {
    if (rawScale < widget.minScale) {
      final overshoot = _rubberBandDistance(
        widget.minScale - rawScale,
        widget.minScaleOvershoot,
      );
      return widget.minScale - overshoot;
    }

    if (rawScale > widget.maxScale) {
      final overshoot = _rubberBandDistance(
        rawScale - widget.maxScale,
        widget.maxScaleOvershoot,
      );
      return widget.maxScale + overshoot;
    }

    return rawScale;
  }

  double _rubberBandDistance(double excess, double limit) {
    if (limit == 0) return 0;
    return limit * excess / (excess + limit);
  }

  void _handlePinchEnd(ScaleEndDetails details) {
    if (_scale == widget.minScale && _translation == Offset.zero) {
      return;
    }

    if (MediaQuery.of(context).disableAnimations) {
      setState(_resetTransform);
      return;
    }

    _scaleAnimation = Tween<double>(begin: _scale, end: widget.minScale)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _translationAnimation = Tween<Offset>(begin: _translation, end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward(from: 0);
  }

  void _resetTransform() {
    _scale = widget.minScale;
    _translation = Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: <Type, GestureRecognizerFactory>{
        _TwoFingerScaleGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
              _TwoFingerScaleGestureRecognizer
            >(() => _TwoFingerScaleGestureRecognizer(debugOwner: this), (
              _TwoFingerScaleGestureRecognizer recognizer,
            ) {
              recognizer
                ..onStart = _handlePinchStart
                ..onUpdate = _handlePinchUpdate
                ..onEnd = _handlePinchEnd;
            }),
      },
      child: ClipRect(
        child: Transform(
          alignment: Alignment.topLeft,
          transform: Matrix4.identity()
            ..translateByDouble(_translation.dx, _translation.dy, 0, 1)
            ..scaleByDouble(_scale, _scale, _scale, 1),
          child: widget.child,
        ),
      ),
    );
  }
}

class _TwoFingerScaleGestureRecognizer extends OneSequenceGestureRecognizer {
  _TwoFingerScaleGestureRecognizer({super.debugOwner});

  GestureScaleStartCallback? onStart;
  GestureScaleUpdateCallback? onUpdate;
  GestureScaleEndCallback? onEnd;

  final Map<int, Offset> _pointerLocations = <int, Offset>{};
  bool _accepted = false;
  bool _started = false;
  double _initialSpan = 1;

  @override
  String get debugDescription => "two finger scale";

  @override
  void addAllowedPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    _pointerLocations[event.pointer] = event.localPosition;

    if (_pointerLocations.length == 2) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _pointerLocations[event.pointer] = event.localPosition;
      if (_accepted && _pointerLocations.length >= 2) {
        _startIfNeeded(event.timeStamp);
        onUpdate?.call(
          ScaleUpdateDetails(
            scale: _currentSpan / _initialSpan,
            focalPoint: _currentFocalPoint,
            localFocalPoint: _currentFocalPoint,
            pointerCount: _pointerLocations.length,
            sourceTimeStamp: event.timeStamp,
          ),
        );
      }
      return;
    }

    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _pointerLocations.remove(event.pointer);
      stopTrackingPointer(event.pointer);

      if (_started && _pointerLocations.length < 2) {
        _end();
      }
    }
  }

  @override
  void acceptGesture(int pointer) {
    _accepted = true;
    _startIfNeeded(null);
  }

  @override
  void rejectGesture(int pointer) {
    _pointerLocations.remove(pointer);
    stopTrackingPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    if (!_accepted) {
      resolve(GestureDisposition.rejected);
    }
    _reset();
  }

  Offset get _currentFocalPoint {
    final positions = _activePositions;
    return Offset(
      (positions.first.dx + positions.second.dx) / 2,
      (positions.first.dy + positions.second.dy) / 2,
    );
  }

  double get _currentSpan {
    final positions = _activePositions;
    return (positions.first - positions.second).distance;
  }

  ({Offset first, Offset second}) get _activePositions {
    final positions = _pointerLocations.values.take(2).toList();
    return (first: positions[0], second: positions[1]);
  }

  void _startIfNeeded(Duration? sourceTimeStamp) {
    if (_started || _pointerLocations.length < 2) {
      return;
    }

    _started = true;
    _initialSpan = _currentSpan;
    if (_initialSpan == 0) {
      _initialSpan = 1;
    }
    onStart?.call(
      ScaleStartDetails(
        focalPoint: _currentFocalPoint,
        localFocalPoint: _currentFocalPoint,
        pointerCount: _pointerLocations.length,
        sourceTimeStamp: sourceTimeStamp,
      ),
    );
  }

  void _end() {
    onEnd?.call(ScaleEndDetails(pointerCount: _pointerLocations.length));
    _started = false;
    _initialSpan = 1;
  }

  void _reset() {
    _accepted = false;
    _started = false;
    _initialSpan = 1;
    _pointerLocations.clear();
  }
}
