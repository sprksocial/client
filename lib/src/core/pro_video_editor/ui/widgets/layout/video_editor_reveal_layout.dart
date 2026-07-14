import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/recording_layout.dart';

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

class VideoEditorRevealController extends AnimationController {
  VideoEditorRevealController({
    required super.vsync,
    bool initiallyRevealed = false,
  }) : super(duration: _kRevealDuration, value: initiallyRevealed ? 1 : 0);

  double _panelHeight = recordingPageFooterHeight;
  double _dragStartValue = 0;
  Size? _viewportSize;
  double? _previewAspectRatio;

  double get panelHeight => _panelHeight;

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

  bool updateViewportGeometry(Size size, double previewAspectRatio) {
    if (_viewportSize == size && _previewAspectRatio == previewAspectRatio) {
      return false;
    }
    _viewportSize = size;
    _previewAspectRatio = previewAspectRatio;
    return true;
  }

  void updatePanelHeight(double height) {
    if (height <= 0 || (_panelHeight - height).abs() < 0.5) return;
    _panelHeight = height;
    notifyListeners();
  }

  void beginDrag() {
    stop();
    _dragStartValue = value;
  }

  void updateDrag({
    required double primaryDelta,
    required double availableHeight,
  }) {
    final travelDistance = (availableHeight * 0.38).clamp(180.0, 320.0);
    value = (value - primaryDelta / travelDistance).clamp(0.0, 1.0);
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
      value = target;
      return;
    }

    final remainingDistance = (target - value).abs();
    final duration = Duration(
      milliseconds: math.max(
        120,
        (_kRevealDuration.inMilliseconds * remainingDistance).round(),
      ),
    );
    await animateTo(target, duration: duration, curve: _kRevealCurve);
  }
}

class VideoEditorRevealBody extends StatefulWidget {
  const VideoEditorRevealBody({
    required this.controller,
    required this.previewAspectRatio,
    required this.child,
    required this.overlay,
    required this.onViewportGeometryChanged,
    this.previewOverlay,
    this.isPositionOnLayer,
    super.key,
  });

  final VideoEditorRevealController controller;
  final double previewAspectRatio;
  final Widget child;
  final Widget overlay;
  final Widget? previewOverlay;
  final VoidCallback onViewportGeometryChanged;
  final bool Function(Offset globalPosition)? isPositionOnLayer;

  @override
  State<VideoEditorRevealBody> createState() => _VideoEditorRevealBodyState();
}

class _VideoEditorRevealBodyState extends State<VideoEditorRevealBody> {
  void _onVerticalDragStart(DragStartDetails details) {
    widget.controller.beginDrag();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    widget.controller.updateDrag(
      primaryDelta: details.delta.dy,
      availableHeight: MediaQuery.sizeOf(context).height,
    );
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    widget.controller.endDrag(
      primaryVelocity: details.velocity.pixelsPerSecond.dy,
      reduceMotion: MediaQuery.disableAnimationsOf(context),
    );
  }

  void _onVerticalDragCancel() {
    widget.controller.endDrag(
      primaryVelocity: 0,
      reduceMotion: MediaQuery.disableAnimationsOf(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sourceSize = constraints.biggest;
        final geometryChanged = widget.controller.updateViewportGeometry(
          sourceSize,
          widget.previewAspectRatio,
        );
        if (geometryChanged) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onViewportGeometryChanged();
          });
        }
        return AnimatedBuilder(
          animation: widget.controller,
          child: SizedBox.fromSize(size: sourceSize, child: widget.child),
          builder: (context, child) {
            final targetRect = widget.controller.viewport!.previewRect;

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
                        ..isPositionOnLayer = widget.isPositionOnLayer
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
                      child: child,
                    ),
                    Positioned.fromRect(
                      rect: targetRect,
                      child: const IgnorePointer(
                        child: SizedBox.expand(
                          key: ValueKey('video-editor-preview-frame'),
                        ),
                      ),
                    ),
                    if (widget.previewOverlay != null)
                      Positioned.fromRect(
                        rect: targetRect,
                        child: widget.previewOverlay!,
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
      if (delta.distanceSquared > 16 && delta.dy.abs() > delta.dx.abs()) {
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
    required this.controller,
    required this.child,
    super.key,
  });

  final VideoEditorRevealController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: controller,
        child: child,
        builder: (_, child) {
          final previewBottom = controller.viewport?.previewRect.bottom;
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
    required this.controller,
    required this.child,
    this.visible = true,
    super.key,
  });

  final VideoEditorRevealController controller;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _overlayController.show();
      WidgetsBinding.instance.addPostFrameCallback((_) => _reportPanelHeight());
    });
  }

  @override
  void didUpdateWidget(VideoEditorRevealBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportPanelHeight());
  }

  void _reportPanelHeight() {
    if (!mounted) return;
    final height = _panelKey.currentContext?.size?.height;
    if (height != null) widget.controller.updatePanelHeight(height);
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
                animation: widget.controller,
                child: panel,
                builder: (_, child) => Positioned(
                  left: 0,
                  right: 0,
                  bottom:
                      MediaQuery.viewPaddingOf(overlayContext).bottom *
                          widget.controller.value -
                      widget.controller.panelHeight *
                          (1 - widget.controller.value),
                  child: child!,
                ),
              );
            },
            child: ColoredBox(
              color: AppColors.greyBlack,
              child: AnimatedBuilder(
                animation: widget.controller,
                builder: (_, _) {
                  final cueOpacity = (1 - widget.controller.value * 3).clamp(
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
