import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/recording_layout.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

const _kRevealDuration = Duration(milliseconds: 240);
const _kRevealCurve = Cubic(0.32, 0.72, 0, 1);
const _kRevealThreshold = 0.35;
const _kFlingVelocity = 350.0;

@immutable
class VideoEditorViewport {
  const VideoEditorViewport({
    required this.previewRect,
    required this.scale,
    required this.offset,
  });

  final Rect previewRect;
  final double scale;
  final Offset offset;
}

class VideoEditorRevealCoordinator extends ChangeNotifier {
  VideoEditorRevealCoordinator({
    required TickerProvider vsync,
    bool initiallyRevealed = false,
  }) : _animation = AnimationController(
         vsync: vsync,
         duration: _kRevealDuration,
         value: initiallyRevealed ? 1 : 0,
       ) {
    _animation.addListener(_onAnimationChanged);
  }

  final AnimationController _animation;
  double _panelHeight = recordingPageFooterHeight;
  Size? _viewportSize;
  double? _previewAspectRatio;
  double _dragStartValue = 0;
  VideoEditorViewport? _pendingViewport;
  bool _viewportCallbackScheduled = false;
  bool _isDisposed = false;

  ValueChanged<VideoEditorViewport>? onViewportChanged;

  double get panelHeight => _panelHeight;
  double get value => _animation.value;
  set value(double value) => _animation.value = value;
  bool get isFullscreen => value == 0;

  VideoEditorViewport? get viewport {
    final sourceSize = _viewportSize;
    final aspectRatio = _previewAspectRatio;
    if (sourceSize == null || aspectRatio == null) return null;

    final panelIntrusion = math.max(
      0.0,
      panelHeight - recordingPageFooterHeight,
    );
    final availableHeight = math.max(
      1.0,
      sourceSize.height - panelIntrusion * value,
    );
    final sourcePreviewSize = _containedSize(sourceSize, aspectRatio);
    final sourcePreviewRect = Alignment.center.inscribe(
      sourcePreviewSize,
      Offset.zero & sourceSize,
    );
    final scale = math.min(1.0, availableHeight / sourcePreviewSize.height);
    final targetSize = sourcePreviewSize * scale;
    final previewRect = Rect.fromLTWH(
      (sourceSize.width - targetSize.width) / 2,
      (availableHeight - targetSize.height) / 2,
      targetSize.width,
      targetSize.height,
    );

    return VideoEditorViewport(
      previewRect: previewRect,
      scale: scale,
      offset: previewRect.topLeft - sourcePreviewRect.topLeft * scale,
    );
  }

  void updateViewport(Size size, double previewAspectRatio) {
    if (_viewportSize == size && _previewAspectRatio == previewAspectRatio) {
      return;
    }
    _viewportSize = size;
    _previewAspectRatio = previewAspectRatio;
    _pendingViewport = viewport;
    if (_viewportCallbackScheduled) return;

    _viewportCallbackScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewportCallbackScheduled = false;
      final pendingViewport = _pendingViewport;
      _pendingViewport = null;
      if (_isDisposed || pendingViewport == null) return;
      onViewportChanged?.call(pendingViewport);
    });
  }

  void updatePanelHeight(double height) {
    if (height <= 0 || (_panelHeight - height).abs() < 0.5) return;
    _panelHeight = height;
    _notifyViewportChanged();
  }

  void beginDrag() {
    _animation.stop();
    _dragStartValue = value;
  }

  void updateDrag({
    required double primaryDelta,
    required double availableHeight,
  }) {
    final travelDistance = (availableHeight * 0.38).clamp(180.0, 320.0);
    _animation.value = (value - primaryDelta / travelDistance).clamp(0, 1);
  }

  Future<void> endDrag({
    required double primaryVelocity,
    required bool reduceMotion,
  }) async {
    final hasFling = primaryVelocity.abs() >= _kFlingVelocity;
    final shouldReveal = hasFling
        ? primaryVelocity < 0
        : _dragStartValue >= 1
        ? value > 1 - _kRevealThreshold
        : _dragStartValue <= 0
        ? value >= _kRevealThreshold
        : value >= 0.5;
    final target = shouldReveal ? 1.0 : 0.0;
    if (reduceMotion) {
      _animation.value = target;
      return;
    }

    final remainingDistance = (target - value).abs();
    final duration = Duration(
      milliseconds: math.max(
        120,
        (_kRevealDuration.inMilliseconds * remainingDistance).round(),
      ),
    );
    try {
      await _animation
          .animateTo(target, duration: duration, curve: _kRevealCurve)
          .orCancel;
    } on TickerCanceled {
      // A new drag or disposal supersedes the previous settle operation.
    }
  }

  void _onAnimationChanged() => _notifyViewportChanged();

  void _notifyViewportChanged() {
    final currentViewport = viewport;
    if (currentViewport != null) onViewportChanged?.call(currentViewport);
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pendingViewport = null;
    _animation
      ..removeListener(_onAnimationChanged)
      ..dispose();
    super.dispose();
  }
}

class VideoEditorRevealBody extends StatefulWidget {
  const VideoEditorRevealBody({
    required this.coordinator,
    required this.previewAspectRatio,
    required this.editor,
    required this.timelineState,
    required this.selectedLayerIdListenable,
    required this.child,
    required this.overlay,
    required this.onPreviewTap,
    super.key,
  });

  final VideoEditorRevealCoordinator coordinator;
  final double previewAspectRatio;
  final ProImageEditorState editor;
  final VideoTimelineState timelineState;
  final ValueListenable<String?> selectedLayerIdListenable;
  final Widget child;
  final Widget overlay;
  final VoidCallback onPreviewTap;

  @override
  State<VideoEditorRevealBody> createState() => _VideoEditorRevealBodyState();
}

class _VideoEditorRevealBodyState extends State<VideoEditorRevealBody> {
  int? _previewTapPointer;
  Offset? _previewTapOrigin;
  Duration? _previewTapStart;
  bool _previewTapMoved = false;
  bool _previewTapStartedOnLayer = false;
  bool _previewTapStartedWithSelection = false;

  void _onPreviewPointerDown(PointerDownEvent event) {
    if (_previewTapPointer != null || !widget.coordinator.isFullscreen) {
      _clearPreviewTap();
      return;
    }

    _previewTapPointer = event.pointer;
    _previewTapOrigin = event.position;
    _previewTapStart = event.timeStamp;
    _previewTapStartedOnLayer = _isPositionOnLayer(event.position);
    _previewTapStartedWithSelection = widget.editor.hasSelectedLayers;
  }

  void _onPreviewPointerMove(PointerMoveEvent event) {
    if (event.pointer != _previewTapPointer) return;
    final origin = _previewTapOrigin;
    if (origin != null && (event.position - origin).distance >= kTouchSlop) {
      _previewTapMoved = true;
    }
  }

  void _onPreviewPointerUp(PointerUpEvent event) {
    if (event.pointer != _previewTapPointer) return;
    final start = _previewTapStart;
    final shouldTogglePlayback =
        widget.coordinator.isFullscreen &&
        !_previewTapMoved &&
        !_previewTapStartedOnLayer &&
        !_previewTapStartedWithSelection &&
        start != null &&
        event.timeStamp - start <= kLongPressTimeout;
    _clearPreviewTap();
    if (shouldTogglePlayback) widget.onPreviewTap();
  }

  void _onPreviewPointerCancel(PointerCancelEvent event) {
    if (event.pointer == _previewTapPointer) _clearPreviewTap();
  }

  void _clearPreviewTap() {
    _previewTapPointer = null;
    _previewTapOrigin = null;
    _previewTapStart = null;
    _previewTapMoved = false;
    _previewTapStartedOnLayer = false;
    _previewTapStartedWithSelection = false;
  }

  void _onVerticalDragStart(DragStartDetails details) {
    widget.coordinator.beginDrag();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    widget.coordinator.updateDrag(
      primaryDelta: details.delta.dy,
      availableHeight: MediaQuery.sizeOf(context).height,
    );
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    widget.coordinator.endDrag(
      primaryVelocity: details.velocity.pixelsPerSecond.dy,
      reduceMotion: MediaQuery.disableAnimationsOf(context),
    );
  }

  void _onVerticalDragCancel() {
    widget.coordinator.endDrag(
      primaryVelocity: 0,
      reduceMotion: MediaQuery.disableAnimationsOf(context),
    );
  }

  bool _isPositionOnLayer(Offset globalPosition) {
    final interactionStyle = widget.editor.configs.layerInteraction.style;
    final hitPadding =
        interactionStyle.overlayPadding.horizontal / 2 +
        interactionStyle.buttonRadius +
        interactionStyle.strokeWidth;
    for (final layer in widget.editor.activeLayers.reversed) {
      if (!isVideoEditorLayerVisibleAt(
        layer,
        widget.timelineState.sourcePosition,
      )) {
        continue;
      }
      final renderObject = layer.repaintBoundaryKey.currentContext
          ?.findRenderObject();
      if (renderObject is! RenderBox ||
          !renderObject.attached ||
          !renderObject.hasSize) {
        continue;
      }

      final bounds = MatrixUtils.transformRect(
        renderObject.getTransformTo(null),
        Offset.zero & renderObject.size,
      ).inflate(hitPadding);
      if (bounds.contains(globalPosition)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sourceSize = constraints.biggest;
        widget.coordinator.updateViewport(
          sourceSize,
          widget.previewAspectRatio,
        );
        return AnimatedBuilder(
          animation: widget.coordinator,
          child: SizedBox.fromSize(size: sourceSize, child: widget.child),
          builder: (context, child) {
            final targetRect = widget.coordinator.viewport!.previewRect;

            return RawGestureDetector(
              key: const ValueKey('video-editor-reveal-gesture'),
              behavior: HitTestBehavior.translucent,
              gestures: {
                _LayerAwareVerticalDragGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                      _LayerAwareVerticalDragGestureRecognizer
                    >(
                      _LayerAwareVerticalDragGestureRecognizer.new,
                      (recognizer) => recognizer
                        ..isPositionOnLayer = _isPositionOnLayer
                        ..onStart = _onVerticalDragStart
                        ..onUpdate = _onVerticalDragUpdate
                        ..onEnd = _onVerticalDragEnd
                        ..onCancel = _onVerticalDragCancel,
                    ),
              },
              child: ColoredBox(
                color: AppColors.greyBlack,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      clipper: _PreviewFrameClipper(targetRect),
                      child: Listener(
                        behavior: HitTestBehavior.translucent,
                        onPointerDown: _onPreviewPointerDown,
                        onPointerMove: _onPreviewPointerMove,
                        onPointerUp: _onPreviewPointerUp,
                        onPointerCancel: _onPreviewPointerCancel,
                        child: child,
                      ),
                    ),
                    Positioned.fromRect(
                      rect: targetRect,
                      child: const IgnorePointer(
                        child: SizedBox.expand(
                          key: ValueKey('video-editor-preview-frame'),
                        ),
                      ),
                    ),
                    Positioned.fromRect(
                      rect: targetRect,
                      child: _VideoPlaybackIndicator(
                        timelineState: widget.timelineState,
                        reveal: widget.coordinator,
                        selectedLayerIdListenable:
                            widget.selectedLayerIdListenable,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: widget.overlay,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _LayerAwareVerticalDragGestureRecognizer
    extends VerticalDragGestureRecognizer {
  bool Function(Offset globalPosition)? isPositionOnLayer;
  final Set<int> _activePointers = {};
  Offset? _pointerOrigin;
  bool _hasResolvedGesture = false;

  @override
  bool isPointerAllowed(PointerEvent event) {
    if (isPositionOnLayer?.call(event.position) ?? false) return false;
    return super.isPointerAllowed(event);
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _activePointers.add(event.pointer);
    _pointerOrigin ??= event.position;
    super.addAllowedPointer(event);
    if (_activePointers.length > 1) {
      _hasResolvedGesture = true;
      resolve(GestureDisposition.rejected);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    final origin = _pointerOrigin;
    if (!_hasResolvedGesture &&
        _activePointers.length == 1 &&
        event is PointerMoveEvent &&
        origin != null) {
      final delta = event.position - origin;
      if (delta.distanceSquared >= kTouchSlop * kTouchSlop &&
          delta.dy.abs() > delta.dx.abs()) {
        _hasResolvedGesture = true;
        resolve(GestureDisposition.accepted);
      }
    }

    super.handleEvent(event);
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _activePointers.remove(event.pointer);
      if (_activePointers.isEmpty) {
        _pointerOrigin = null;
        _hasResolvedGesture = false;
      }
    }
  }
}

class _PreviewFrameClipper extends CustomClipper<RRect> {
  const _PreviewFrameClipper(this.rect);

  final Rect rect;

  @override
  RRect getClip(Size size) => recordingPagePreviewBorderRadius.toRRect(rect);

  @override
  bool shouldReclip(_PreviewFrameClipper oldClipper) => rect != oldClipper.rect;
}

class VideoEditorRevealRemoveArea extends StatelessWidget {
  const VideoEditorRevealRemoveArea({
    required this.coordinator,
    required this.child,
    super.key,
  });

  final VideoEditorRevealCoordinator coordinator;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: coordinator,
        child: child,
        builder: (_, child) {
          final previewBottom = coordinator.viewport?.previewRect.bottom;
          final bottomInset = previewBottom == null
              ? 0.0
              : math.max(0.0, constraints.maxHeight - previewBottom);
          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: child,
          );
        },
      ),
    );
  }
}

Size _containedSize(Size bounds, double aspectRatio) {
  if (aspectRatio <= 0 || !aspectRatio.isFinite) return bounds;
  if (bounds.aspectRatio > aspectRatio) {
    return Size(bounds.height * aspectRatio, bounds.height);
  }
  return Size(bounds.width, bounds.width / aspectRatio);
}

class VideoEditorRevealBottomBar extends StatefulWidget {
  const VideoEditorRevealBottomBar({
    required this.coordinator,
    required this.child,
    this.visible = true,
    super.key,
  });

  final VideoEditorRevealCoordinator coordinator;
  final Widget child;
  final bool visible;

  @override
  State<VideoEditorRevealBottomBar> createState() =>
      _VideoEditorRevealBottomBarState();
}

class _VideoEditorRevealBottomBarState
    extends State<VideoEditorRevealBottomBar> {
  final _overlayController = OverlayPortalController();
  final _panelKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // OverlayPortal inserts its overlay on the next frame; its content can only
    // be measured on the following frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _overlayController.show();
      WidgetsBinding.instance.addPostFrameCallback((_) => _reportPanelHeight());
    });
  }

  @override
  void didUpdateWidget(VideoEditorRevealBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child ||
        oldWidget.coordinator != widget.coordinator) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reportPanelHeight());
    }
  }

  void _reportPanelHeight() {
    if (!mounted) return;
    final height = _panelKey.currentContext?.size?.height;
    if (height != null) widget.coordinator.updatePanelHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final panel = SizedBox(
          width: width,
          child: NotificationListener<SizeChangedLayoutNotification>(
            onNotification: (_) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _reportPanelHeight(),
              );
              return false;
            },
            child: SizeChangedLayoutNotifier(
              key: _panelKey,
              child: widget.child,
            ),
          ),
        );

        return SizedBox(
          key: const ValueKey('video-editor-reveal-bottom-bar'),
          height: recordingPageFooterHeight,
          child: OverlayPortal(
            controller: _overlayController,
            overlayChildBuilder: (overlayContext) {
              if (!widget.visible) return const SizedBox.shrink();
              return AnimatedBuilder(
                animation: widget.coordinator,
                child: panel,
                builder: (_, child) => Positioned(
                  left: 0,
                  right: 0,
                  bottom:
                      -widget.coordinator.panelHeight *
                      (1 - widget.coordinator.value),
                  child: child!,
                ),
              );
            },
            child: ColoredBox(
              color: AppColors.greyBlack,
              child: AnimatedBuilder(
                animation: widget.coordinator,
                builder: (_, _) {
                  final cueOpacity = (1 - widget.coordinator.value * 3).clamp(
                    0.0,
                    1.0,
                  );
                  if (cueOpacity == 0) return const SizedBox.shrink();
                  return Center(
                    child: Opacity(
                      opacity: cueOpacity,
                      child: const _RevealCue(),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VideoPlaybackIndicator extends StatelessWidget {
  const _VideoPlaybackIndicator({
    required this.timelineState,
    required this.reveal,
    required this.selectedLayerIdListenable,
  });

  final VideoTimelineState timelineState;
  final VideoEditorRevealCoordinator reveal;
  final ValueListenable<String?> selectedLayerIdListenable;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          timelineState,
          reveal,
          selectedLayerIdListenable,
        ]),
        builder: (_, _) {
          if (selectedLayerIdListenable.value != null ||
              !reveal.isFullscreen ||
              timelineState.isPlaying) {
            return const SizedBox.shrink();
          }
          return Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: const ShapeDecoration(
                shape: CircleBorder(),
                color: Color.fromARGB(128, 0, 0, 0),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 44,
              ),
            ),
          );
        },
      ),
    );
  }
}

@visibleForTesting
bool isVideoEditorLayerVisibleAt(Layer layer, Duration videoPosition) {
  final startTime = layer.startTime;
  final endTime = layer.endTime;
  return (startTime == null || videoPosition >= startTime) &&
      (endTime == null || videoPosition <= endTime);
}

class _RevealCue extends StatelessWidget {
  const _RevealCue();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('video-editor-reveal-cue'),
      decoration: BoxDecoration(
        color: AppColors.grey700.withAlpha(220),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const SizedBox(
        width: 38,
        height: 24,
        child: Icon(
          Icons.keyboard_arrow_up_rounded,
          size: 21,
          color: AppColors.greyWhite,
        ),
      ),
    );
  }
}
