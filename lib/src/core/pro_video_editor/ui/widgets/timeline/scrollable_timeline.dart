import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/layer_timing_track.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timed_track_range.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_selection_handle.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_subtrack_content.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

const _kHandleWidth = 12.0;

const _kCapWidth = 6.0;
const _kHandleHitWidth = 32.0;
const _kMinTrimDuration = Duration(seconds: 1);
const _kSubtrackSpacing = 6.0;
const _kSubtrackScrollIndicatorHeight = 20.0;
const _kSubtrackScrollIndicatorFadeDuration = Duration(milliseconds: 160);
const _kTimelineHeightAnimationDuration = Duration(milliseconds: 220);
const _kScrollEdgeTolerance = 0.5;
const _kMaxVisibleSubtracks = 4;
const _kReorderAutoScrollEdge = 28.0;
const _kReorderAutoScrollMaxSpeed = 240.0;
const _kReorderAutoScrollInterval = Duration(milliseconds: 16);

typedef LayerReorderedCallback =
    void Function(
      Layer layer,
      int hierarchyIndex,
      Duration? start,
      Duration? end,
    );

enum TimelineTrackSelection { primary, audio }

enum _TrimHandleSide { start, end }

class ScrollableTimeline extends StatefulWidget {
  const ScrollableTimeline({
    required this.videoTimelineState,
    required this.onSeek,
    required this.layers,
    required this.selectedLayerId,
    required this.onAudioTimingChanged,
    required this.onLayerTimingChanged,
    required this.onLayerSelectionChanged,
    required this.onTrackSelectionChanged,
    required this.onLayerReordered,
    this.onSeekStart,
    this.onSeekEnd,
    this.onTrimChanged,
    this.onTrimEnd,
    this.thumbnailHeight = 56,
    this.subtrackHeight = 34,
    this.rulerHeight = 24,
    this.pixelsPerSecond = 40.0,
    super.key,
  });

  final VideoTimelineState videoTimelineState;
  final void Function(double progress) onSeek;
  final List<Layer> layers;
  final String? selectedLayerId;
  final ValueChanged<AudioTrack> onAudioTimingChanged;
  final void Function(Layer layer, Duration start, Duration end)
  onLayerTimingChanged;
  final ValueChanged<Layer?> onLayerSelectionChanged;
  final ValueChanged<TimelineTrackSelection?> onTrackSelectionChanged;
  final LayerReorderedCallback onLayerReordered;
  final VoidCallback? onSeekStart;
  final VoidCallback? onSeekEnd;
  final void Function(double start, double end)? onTrimChanged;
  final void Function(double start, double end, bool isStartHandle)? onTrimEnd;
  final double thumbnailHeight;
  final double subtrackHeight;
  final double rulerHeight;
  final double pixelsPerSecond;

  @override
  State<ScrollableTimeline> createState() => _ScrollableTimelineState();
}

class _ScrollableTimelineState extends State<ScrollableTimeline> {
  late ScrollController _scrollController;
  late ScrollController _subtrackScrollController;
  bool _isUserScrolling = false;
  bool _isProgrammaticScroll = false;
  bool _isDraggingHandle = false;
  String? _selectedTrackId;
  String? _reorderingLayerId;
  int? _reorderingStartIndex;
  int? _reorderingTargetIndex;
  List<Layer>? _reorderPreviewLayers;
  double _reorderingStartScrollOffset = 0;
  double _reorderingLastOffsetY = 0;
  double _reorderAutoScrollSpeed = 0;
  _TrimHandleSide? _activeTrimHandle;
  Timer? _scrollEndTimer;
  Timer? _reorderAutoScrollTimer;

  static const _primaryTrackId = 'primary';
  static const _audioTrackId = 'audio';

  bool get _canTrim => widget.onTrimChanged != null || widget.onTrimEnd != null;

  double get _sourceWidth => math.max(
    1.0,
    widget.videoTimelineState.videoDuration.inMilliseconds /
        1000 *
        widget.pixelsPerSecond,
  );

  double get _timelineWidth =>
      math.max(1.0, _sourceWidth * widget.videoTimelineState.trimSpanFraction);

  int get _subtrackCount =>
      widget.layers.length + (widget.videoTimelineState.useCustomAudio ? 1 : 0);

  List<Layer> get _displayLayers => _reorderPreviewLayers ?? widget.layers;

  double get _subtrackContentHeight {
    if (_subtrackCount == 0) return 0;
    return _subtrackCount * widget.subtrackHeight +
        (_subtrackCount - 1) * _kSubtrackSpacing;
  }

  double get _subtrackViewportHeight {
    final maxHeight =
        _kMaxVisibleSubtracks * widget.subtrackHeight +
        (_kMaxVisibleSubtracks - 1) * _kSubtrackSpacing;
    return math.min(_subtrackContentHeight, maxHeight);
  }

  double get _totalHeight =>
      widget.rulerHeight +
      widget.thumbnailHeight +
      (_subtrackCount == 0 ? 0 : 8 + _subtrackViewportHeight);

  double get _minTrimFraction {
    final ms = widget.videoTimelineState.videoDuration.inMilliseconds;
    if (ms <= 0) return 0.0;
    return _kMinTrimDuration.inMilliseconds / ms;
  }

  @override
  void initState() {
    super.initState();
    _selectedTrackId = widget.selectedLayerId;
    _scrollController = ScrollController();
    _subtrackScrollController = ScrollController();
    _scrollController.addListener(_onScrollChange);
    _subtrackScrollController.addListener(_onSubtrackScrollChange);
    widget.videoTimelineState.addListener(_onProgressChange);
  }

  @override
  void didUpdateWidget(covariant ScrollableTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedLayerId != widget.selectedLayerId) {
      if (widget.selectedLayerId != null) {
        _selectedTrackId = widget.selectedLayerId;
      } else if (_selectedTrackId == oldWidget.selectedLayerId) {
        _selectedTrackId = null;
      }
    }
    if (_selectedTrackId == _audioTrackId &&
        !widget.videoTimelineState.useCustomAudio) {
      _selectedTrackId = null;
    }
    if (_selectedTrackId != null &&
        _selectedTrackId != _primaryTrackId &&
        _selectedTrackId != _audioTrackId &&
        !widget.layers.any((layer) => layer.id == _selectedTrackId)) {
      _selectedTrackId = null;
    }
  }

  @override
  void dispose() {
    widget.videoTimelineState.removeListener(_onProgressChange);
    _scrollController.removeListener(_onScrollChange);
    _subtrackScrollController.removeListener(_onSubtrackScrollChange);
    _scrollEndTimer?.cancel();
    _reorderAutoScrollTimer?.cancel();
    _scrollController.dispose();
    _subtrackScrollController.dispose();
    super.dispose();
  }

  void _onScrollChange() {
    if (mounted) setState(() {});
  }

  void _onSubtrackScrollChange() {
    if (mounted) setState(() {});
  }

  bool get _showSubtrackTopIndicator {
    if (_subtrackContentHeight <= _subtrackViewportHeight ||
        !_subtrackScrollController.hasClients) {
      return false;
    }
    final position = _subtrackScrollController.position;
    return position.pixels > position.minScrollExtent + _kScrollEdgeTolerance;
  }

  bool get _showSubtrackBottomIndicator {
    if (_subtrackContentHeight <= _subtrackViewportHeight) return false;
    if (!_subtrackScrollController.hasClients) return true;
    final position = _subtrackScrollController.position;
    return position.pixels < position.maxScrollExtent - _kScrollEdgeTolerance;
  }

  void _onProgressChange() {
    if (_isUserScrolling ||
        _isDraggingHandle ||
        !_scrollController.hasClients) {
      return;
    }

    final targetScroll =
        widget.videoTimelineState.trimmedProgress * _timelineWidth;

    final clampedScroll = targetScroll
        .clamp(0.0, _scrollController.position.maxScrollExtent)
        .toDouble();

    _isProgrammaticScroll = true;
    _scrollController
        .animateTo(
          clampedScroll,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        )
        .then((_) => _isProgrammaticScroll = false);
  }

  void _onScrollUpdate() {
    if (!_scrollController.hasClients) return;

    final progress = (_scrollController.offset / _timelineWidth)
        .clamp(0.0, 1.0)
        .toDouble();
    widget.onSeek(
      widget.videoTimelineState.sourceProgressFromTrimmedProgress(progress),
    );
  }

  void _onThumbnailTap() {
    if (!_canTrim) return;
    final isSelecting = _selectedTrackId != _primaryTrackId;
    setState(() {
      _selectedTrackId = isSelecting ? _primaryTrackId : null;
    });
    if (isSelecting) widget.onLayerSelectionChanged(null);
    widget.onTrackSelectionChanged(
      isSelecting ? TimelineTrackSelection.primary : null,
    );
  }

  void _onAudioTrackTap() {
    final isSelecting = _selectedTrackId != _audioTrackId;
    setState(() {
      _selectedTrackId = isSelecting ? _audioTrackId : null;
    });
    if (isSelecting) widget.onLayerSelectionChanged(null);
    widget.onTrackSelectionChanged(
      isSelecting ? TimelineTrackSelection.audio : null,
    );
  }

  void _onLayerTrackTap(Layer layer) {
    final isDeselecting = _selectedTrackId == layer.id;
    setState(() {
      _selectedTrackId = isDeselecting ? null : layer.id;
    });
    widget.onTrackSelectionChanged(null);
    widget.onLayerSelectionChanged(isDeselecting ? null : layer);
  }

  void _onLayerRepositionStart(Layer layer) {
    if (widget.layers.length < 2) return;
    final index = widget.layers.indexWhere((item) => item.id == layer.id);
    if (index < 0) return;
    _reorderingLayerId = layer.id;
    _reorderingStartIndex = index;
    _reorderingTargetIndex = index;
    _reorderPreviewLayers = List<Layer>.of(widget.layers);
    _reorderingStartScrollOffset = _subtrackScrollController.hasClients
        ? _subtrackScrollController.offset
        : 0;
    _reorderingLastOffsetY = 0;
  }

  void _onLayerVerticalReposition(Layer layer, double offsetY) {
    if (_reorderingLayerId != layer.id) return;
    _reorderingLastOffsetY = offsetY;
    _updateLayerReorderTarget(layer);
    _updateLayerAutoScroll(offsetY);
  }

  void _updateLayerReorderTarget(Layer layer) {
    final startIndex = _reorderingStartIndex;
    if (startIndex == null) return;
    final rowExtent = widget.subtrackHeight + _kSubtrackSpacing;
    final scrollOffset = _subtrackScrollController.hasClients
        ? _subtrackScrollController.offset
        : _reorderingStartScrollOffset;
    final scrollDelta = scrollOffset - _reorderingStartScrollOffset;
    final targetIndex =
        (startIndex + (_reorderingLastOffsetY + scrollDelta) / rowExtent)
            .round()
            .clamp(0, widget.layers.length - 1);
    if (targetIndex == _reorderingTargetIndex) return;
    setState(() {
      final previewLayers = _reorderPreviewLayers;
      if (previewLayers == null) return;
      final oldIndex = previewLayers.indexWhere((item) => item.id == layer.id);
      if (oldIndex < 0) return;
      final movedLayer = previewLayers.removeAt(oldIndex);
      previewLayers.insert(targetIndex, movedLayer);
      _reorderingTargetIndex = targetIndex;
    });
  }

  void _updateLayerAutoScroll(double offsetY) {
    if (!_subtrackScrollController.hasClients ||
        _subtrackCount <= _kMaxVisibleSubtracks) {
      _setReorderAutoScrollSpeed(0);
      return;
    }
    final startIndex = _reorderingStartIndex;
    if (startIndex == null) return;
    final rowExtent = widget.subtrackHeight + _kSubtrackSpacing;
    final audioRowCount = widget.videoTimelineState.useCustomAudio ? 1 : 0;
    final startCenter =
        (startIndex + audioRowCount) * rowExtent +
        widget.subtrackHeight / 2 -
        _reorderingStartScrollOffset;
    final pointerY = startCenter + offsetY;
    final viewportHeight = _subtrackViewportHeight;
    double speed = 0;
    if (pointerY < _kReorderAutoScrollEdge) {
      final strength =
          ((_kReorderAutoScrollEdge - pointerY) / _kReorderAutoScrollEdge)
              .clamp(0.0, 1.0);
      speed = -_kReorderAutoScrollMaxSpeed * strength;
    } else if (pointerY > viewportHeight - _kReorderAutoScrollEdge) {
      final strength =
          ((pointerY - (viewportHeight - _kReorderAutoScrollEdge)) /
                  _kReorderAutoScrollEdge)
              .clamp(0.0, 1.0);
      speed = _kReorderAutoScrollMaxSpeed * strength;
    }
    _setReorderAutoScrollSpeed(speed);
  }

  void _setReorderAutoScrollSpeed(double speed) {
    _reorderAutoScrollSpeed = speed;
    if (speed == 0) {
      _reorderAutoScrollTimer?.cancel();
      _reorderAutoScrollTimer = null;
      return;
    }
    if (_reorderAutoScrollTimer != null) return;
    _reorderAutoScrollTimer = Timer.periodic(
      _kReorderAutoScrollInterval,
      (_) => _tickLayerAutoScroll(),
    );
  }

  void _tickLayerAutoScroll() {
    if (!_subtrackScrollController.hasClients || _reorderingLayerId == null) {
      _setReorderAutoScrollSpeed(0);
      return;
    }
    final position = _subtrackScrollController.position;
    final nextOffset =
        (position.pixels +
                _reorderAutoScrollSpeed *
                    _kReorderAutoScrollInterval.inMicroseconds /
                    Duration.microsecondsPerSecond)
            .clamp(position.minScrollExtent, position.maxScrollExtent)
            .toDouble();
    if (nextOffset == position.pixels) {
      _setReorderAutoScrollSpeed(0);
      return;
    }
    _subtrackScrollController.jumpTo(nextOffset);
    final layerIndex = widget.layers.indexWhere(
      (item) => item.id == _reorderingLayerId,
    );
    if (layerIndex >= 0) {
      _updateLayerReorderTarget(widget.layers[layerIndex]);
    }
  }

  void _onLayerRepositionEnd(
    Layer layer,
    double start,
    double end,
    bool rangeChanged,
  ) {
    if (_reorderingLayerId != layer.id) return;
    final startIndex = _reorderingStartIndex;
    final targetIndex = _reorderingTargetIndex;
    final reorderedLayer = _reorderPreviewLayers?.firstWhere(
      (item) => item.id == layer.id,
      orElse: () => layer,
    );
    _clearLayerReposition();
    if (reorderedLayer != null &&
        startIndex != null &&
        targetIndex != null &&
        startIndex != targetIndex) {
      widget.onLayerReordered(
        reorderedLayer,
        targetIndex,
        rangeChanged ? _durationAtFraction(start) : null,
        rangeChanged ? _durationAtFraction(end) : null,
      );
    } else if (rangeChanged) {
      widget.onLayerTimingChanged(
        layer,
        _durationAtFraction(start),
        _durationAtFraction(end),
      );
    }
  }

  void _onLayerRepositionCancel(Layer layer) {
    if (_reorderingLayerId != layer.id) return;
    _clearLayerReposition();
  }

  void _clearLayerReposition() {
    _setReorderAutoScrollSpeed(0);
    setState(() {
      _reorderPreviewLayers = null;
      _reorderingLayerId = null;
      _reorderingStartIndex = null;
      _reorderingTargetIndex = null;
    });
  }

  Duration _durationAtFraction(double fraction) {
    return Duration(
      milliseconds:
          (widget.videoTimelineState.videoDuration.inMilliseconds * fraction)
              .round(),
    );
  }

  void _onTrimStartDragStart(DragStartDetails _) {
    _isDraggingHandle = true;
    _activeTrimHandle = _TrimHandleSide.start;
  }

  void _onTrimStartDragUpdate(DragUpdateDetails details) {
    final delta = details.delta.dx / _sourceWidth;
    final state = widget.videoTimelineState;
    final maxStart = (state.trimEnd - _minTrimFraction)
        .clamp(0.0, 1.0)
        .toDouble();
    final newStart = (state.trimStart + delta).clamp(0.0, maxStart).toDouble();
    _updateTrim(newStart, state.trimEnd);
  }

  void _onTrimEndDragStart(DragStartDetails _) {
    _isDraggingHandle = true;
    _activeTrimHandle = _TrimHandleSide.end;
  }

  void _onTrimEndDragUpdate(DragUpdateDetails details) {
    final delta = details.delta.dx / _sourceWidth;
    final state = widget.videoTimelineState;
    final minEnd = (state.trimStart + _minTrimFraction)
        .clamp(0.0, 1.0)
        .toDouble();
    final newEnd = (state.trimEnd + delta).clamp(minEnd, 1.0).toDouble();
    _updateTrim(state.trimStart, newEnd);
  }

  void _onTrimDragEnd(DragEndDetails _) {
    _isDraggingHandle = false;
    final state = widget.videoTimelineState;
    final activeTrimHandle = _activeTrimHandle;
    _activeTrimHandle = null;
    widget.onTrimEnd?.call(
      state.trimStart,
      state.trimEnd,
      activeTrimHandle == _TrimHandleSide.start,
    );
  }

  void _updateTrim(double start, double end) {
    widget.videoTimelineState.setTrimRange(start, end);
    widget.onTrimChanged?.call(start, end);
  }

  Widget _buildTrimFrame({
    required double left,
    required double width,
    required double top,
    required double height,
  }) {
    return Positioned(
      left: left,
      width: width,
      top: top,
      height: height,
      child: IgnorePointer(
        child: DecoratedBox(
          key: const ValueKey('timeline-primary-selection-frame'),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.greyWhite, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildTrimHandle({
    required double left,
    required bool isLeft,
    required GestureDragStartCallback onDragStart,
    required GestureDragUpdateCallback onDragUpdate,
  }) {
    return Positioned(
      left: isLeft
          ? left
          : left - (_kHandleHitWidth - _kHandleWidth - _kCapWidth),
      top: widget.rulerHeight,
      width: _kHandleHitWidth,
      height: widget.thumbnailHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: onDragStart,
        onHorizontalDragUpdate: onDragUpdate,
        onHorizontalDragEnd: _onTrimDragEnd,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.videoTimelineState,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final viewportWidth = constraints.maxWidth;
            final scrollOffset = _scrollController.hasClients
                ? _scrollController.offset
                : 0.0;
            final sourceWidth = _sourceWidth;
            final timelineWidth = _timelineWidth;
            final sourceOffset =
                widget.videoTimelineState.trimStart * sourceWidth;
            final trimStartVp = viewportWidth / 2 - scrollOffset;
            final trimEndVp = viewportWidth / 2 + timelineWidth - scrollOffset;
            final leftHandleLeft = trimStartVp;
            final rightHandleLeft = trimEndVp - _kHandleWidth - _kCapWidth;

            return AnimatedSize(
              duration: _kTimelineHeightAnimationDuration,
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: _totalHeight,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.axis != Axis.horizontal) {
                          return false;
                        }
                        if (notification is ScrollStartNotification) {
                          if (notification.dragDetails != null) {
                            _isProgrammaticScroll = false;
                            _scrollEndTimer?.cancel();
                            _isUserScrolling = true;
                            widget.onSeekStart?.call();
                          }
                        } else if (notification is ScrollEndNotification) {
                          if (!_isUserScrolling) return false;
                          _scrollEndTimer?.cancel();
                          _scrollEndTimer = Timer(
                            const Duration(milliseconds: 300),
                            () {
                              if (!mounted) return;
                              _isUserScrolling = false;
                              widget.onSeekEnd?.call();
                            },
                          );
                        } else if (notification is ScrollUpdateNotification) {
                          if (_isUserScrolling && !_isProgrammaticScroll) {
                            _onScrollUpdate();
                          }
                        }
                        return false;
                      },
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: SizedBox(
                          width: timelineWidth + viewportWidth,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: viewportWidth / 2,
                            ),
                            child: Column(
                              children: [
                                _TimeRuler(
                                  totalWidth: timelineWidth,
                                  pixelsPerSecond: widget.pixelsPerSecond,
                                  height: widget.rulerHeight,
                                  videoDuration:
                                      widget.videoTimelineState.trimmedDuration,
                                ),
                                GestureDetector(
                                  onTap: _onThumbnailTap,
                                  child: _VideoThumbnailTrack(
                                    totalWidth: timelineWidth,
                                    sourceWidth: sourceWidth,
                                    sourceOffset: sourceOffset,
                                    height: widget.thumbnailHeight,
                                    videoTimelineState:
                                        widget.videoTimelineState,
                                  ),
                                ),
                                if (_subtrackCount > 0) ...[
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: _subtrackViewportHeight,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        SingleChildScrollView(
                                          key: const ValueKey(
                                            'timeline-subtrack-scroll',
                                          ),
                                          controller: _subtrackScrollController,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          child: Column(
                                            children: _buildSubtracks(
                                              timelineWidth: timelineWidth,
                                              sourceWidth: sourceWidth,
                                              sourceOffset: sourceOffset,
                                            ),
                                          ),
                                        ),
                                        AnimatedOpacity(
                                          key: const ValueKey(
                                            'timeline-subtrack-scroll-indicator-top',
                                          ),
                                          opacity: _showSubtrackTopIndicator
                                              ? 1
                                              : 0,
                                          duration:
                                              _kSubtrackScrollIndicatorFadeDuration,
                                          curve: Curves.easeOutCubic,
                                          child: const _SubtrackScrollIndicator(
                                            alignment: Alignment.topCenter,
                                          ),
                                        ),
                                        AnimatedOpacity(
                                          key: const ValueKey(
                                            'timeline-subtrack-scroll-indicator-bottom',
                                          ),
                                          opacity: _showSubtrackBottomIndicator
                                              ? 1
                                              : 0,
                                          duration:
                                              _kSubtrackScrollIndicatorFadeDuration,
                                          curve: Curves.easeOutCubic,
                                          child: const _SubtrackScrollIndicator(
                                            alignment: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_selectedTrackId == _primaryTrackId && _canTrim) ...[
                      _buildTrimFrame(
                        left: trimStartVp,
                        width: timelineWidth,
                        top: widget.rulerHeight,
                        height: widget.thumbnailHeight,
                      ),
                      _buildTrimHandle(
                        left: leftHandleLeft,
                        isLeft: true,
                        onDragStart: _onTrimStartDragStart,
                        onDragUpdate: _onTrimStartDragUpdate,
                      ),
                      _buildTrimHandle(
                        left: rightHandleLeft,
                        isLeft: false,
                        onDragStart: _onTrimEndDragStart,
                        onDragUpdate: _onTrimEndDragUpdate,
                      ),
                    ],
                    Positioned(
                      left: viewportWidth / 2 - 1,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Container(
                          width: 2,
                          decoration: BoxDecoration(
                            color: AppColors.greyWhite,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.greyBlack.withAlpha(100),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
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

  List<Widget> _buildSubtracks({
    required double timelineWidth,
    required double sourceWidth,
    required double sourceOffset,
  }) {
    final subtracks = <Widget>[
      if (widget.videoTimelineState.useCustomAudio)
        _AudioSubtrack(
          key: const ValueKey('timeline-subtrack-audio'),
          totalWidth: timelineWidth,
          sourceWidth: sourceWidth,
          sourceOffset: sourceOffset,
          height: widget.subtrackHeight,
          videoTimelineState: widget.videoTimelineState,
          pixelsPerSecond: widget.pixelsPerSecond,
          onTimingChanged: widget.onAudioTimingChanged,
          isSelected: _selectedTrackId == _audioTrackId,
          onTap: _onAudioTrackTap,
        ),
      for (final layer in _displayLayers)
        LayerTimingTrack(
          key: ValueKey('timeline-subtrack-layer-${layer.id}'),
          totalWidth: timelineWidth,
          sourceWidth: sourceWidth,
          sourceOffset: sourceOffset,
          height: widget.subtrackHeight,
          videoDuration: widget.videoTimelineState.videoDuration,
          layer: layer,
          isSelected: layer.id == _selectedTrackId,
          onTap: () => _onLayerTrackTap(layer),
          onTimingChanged: widget.onLayerTimingChanged,
          onRepositionStart: widget.layers.length < 2
              ? null
              : () => _onLayerRepositionStart(layer),
          onVerticalRepositionChanged: widget.layers.length < 2
              ? null
              : (offsetY) => _onLayerVerticalReposition(layer, offsetY),
          onRepositionEnd: widget.layers.length < 2
              ? null
              : (start, end, rangeChanged) =>
                    _onLayerRepositionEnd(layer, start, end, rangeChanged),
          onRepositionCancel: widget.layers.length < 2
              ? null
              : () => _onLayerRepositionCancel(layer),
        ),
    ];

    return [
      for (final (index, subtrack) in subtracks.indexed) ...[
        if (index > 0) const SizedBox(height: _kSubtrackSpacing),
        subtrack,
      ],
    ];
  }
}

class _SubtrackScrollIndicator extends StatelessWidget {
  const _SubtrackScrollIndicator({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isTop = alignment == Alignment.topCenter;
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: SizedBox(
          width: double.infinity,
          height: _kSubtrackScrollIndicatorHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
                end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
                colors: [AppColors.greyBlack, Colors.transparent],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeRuler extends StatelessWidget {
  const _TimeRuler({
    required this.totalWidth,
    required this.pixelsPerSecond,
    required this.height,
    required this.videoDuration,
  });

  final double totalWidth;
  final double pixelsPerSecond;
  final double height;
  final Duration videoDuration;

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = videoDuration.inSeconds;
    final tickInterval = _calculateTickInterval(totalSeconds);

    return SizedBox(
      width: totalWidth,
      height: height,
      child: CustomPaint(
        painter: _TimeRulerPainter(
          totalSeconds: totalSeconds,
          pixelsPerSecond: pixelsPerSecond,
          tickInterval: tickInterval,
          formatTime: _formatTime,
        ),
      ),
    );
  }

  int _calculateTickInterval(int totalSeconds) {
    if (totalSeconds <= 10) return 1;
    if (totalSeconds <= 30) return 5;
    if (totalSeconds <= 60) return 10;
    if (totalSeconds <= 300) return 30;
    return 60;
  }
}

class _TimeRulerPainter extends CustomPainter {
  _TimeRulerPainter({
    required this.totalSeconds,
    required this.pixelsPerSecond,
    required this.tickInterval,
    required this.formatTime,
  });

  final int totalSeconds;
  final double pixelsPerSecond;
  final int tickInterval;
  final String Function(int) formatTime;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grey400
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var seconds = 0; seconds <= totalSeconds; seconds++) {
      final x = seconds * pixelsPerSecond;

      if (seconds % tickInterval == 0) {
        canvas.drawLine(
          Offset(x, size.height - 12),
          Offset(x, size.height),
          paint,
        );

        textPainter
          ..text = TextSpan(
            text: formatTime(seconds),
            style: const TextStyle(
              color: AppColors.grey300,
              fontSize: 10,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          )
          ..layout()
          ..paint(canvas, Offset(x - textPainter.width / 2, 2));
      } else {
        canvas.drawLine(
          Offset(x, size.height - 6),
          Offset(x, size.height),
          paint..color = AppColors.grey500,
        );
        paint.color = AppColors.grey400;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TimeRulerPainter oldDelegate) {
    return oldDelegate.totalSeconds != totalSeconds ||
        oldDelegate.pixelsPerSecond != pixelsPerSecond;
  }
}

class _VideoThumbnailTrack extends StatelessWidget {
  const _VideoThumbnailTrack({
    required this.totalWidth,
    required this.sourceWidth,
    required this.sourceOffset,
    required this.height,
    required this.videoTimelineState,
  });

  final double totalWidth;
  final double sourceWidth;
  final double sourceOffset;
  final double height;
  final VideoTimelineState videoTimelineState;

  @override
  Widget build(BuildContext context) {
    final thumbnails = videoTimelineState.thumbnails;

    return Container(
      key: const ValueKey('timeline-primary-track'),
      width: totalWidth,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.grey700,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.grey500),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildSourceViewport(
        thumbnails == null || thumbnails.isEmpty
            ? _buildSkeleton()
            : Row(
                children: thumbnails.map((thumbnail) {
                  return Expanded(
                    child: Image(
                      image: thumbnail,
                      fit: BoxFit.cover,
                      height: height,
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildSourceViewport(Widget child) {
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.centerLeft,
        minWidth: sourceWidth,
        maxWidth: sourceWidth,
        minHeight: height,
        maxHeight: height,
        child: Transform.translate(
          offset: Offset(-sourceOffset, 0),
          child: SizedBox(width: sourceWidth, height: height, child: child),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Row(
      children: List.generate(10, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: index > 0 ? 1 : 0),
            color: AppColors.grey600,
          ),
        );
      }),
    );
  }
}

class _AudioSubtrack extends StatelessWidget {
  const _AudioSubtrack({
    required this.totalWidth,
    required this.sourceWidth,
    required this.sourceOffset,
    required this.height,
    required this.videoTimelineState,
    required this.pixelsPerSecond,
    required this.onTimingChanged,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final double totalWidth;
  final double sourceWidth;
  final double sourceOffset;
  final double height;
  final VideoTimelineState videoTimelineState;
  final double pixelsPerSecond;
  final ValueChanged<AudioTrack> onTimingChanged;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _buildAudioWaveformTrack();
  }

  Widget _buildAudioWaveformTrack() {
    final track = videoTimelineState.customAudioTrack!;
    final videoDurationMs = videoTimelineState.videoDuration.inMilliseconds;
    final start = videoDurationMs <= 0
        ? 0.0
        : (track.startTime ?? Duration.zero).inMilliseconds / videoDurationMs;
    final end = videoDurationMs <= 0
        ? 1.0
        : (track.endTime ?? videoTimelineState.videoDuration).inMilliseconds /
              videoDurationMs;
    final clampedStart = start.clamp(0.0, 1.0).toDouble();
    final clampedEnd = end.clamp(0.0, 1.0).toDouble();

    return TimedTrackRange(
      totalWidth: totalWidth,
      sourceWidth: sourceWidth,
      sourceOffset: sourceOffset,
      height: height,
      startFraction: clampedStart <= clampedEnd ? clampedStart : clampedEnd,
      endFraction: clampedStart <= clampedEnd ? clampedEnd : clampedStart,
      color: AppColors.primary700,
      isSelected: isSelected,
      borderColor: isSelected ? AppColors.greyWhite : null,
      onTap: onTap,
      minimumRangeFraction: videoDurationMs <= 0
          ? 0.01
          : (250 / videoDurationMs).clamp(0.001, 1.0).toDouble(),
      onRangeChanged: (start, end) {
        final updatedTrack = track.copyWith(
          startTime: _durationAtFraction(start),
          endTime: _durationAtFraction(end),
        );
        videoTimelineState.updateCustomAudioTrack(updatedTrack);
      },
      onRangeChangeEnd: (_, _) {
        final updatedTrack = videoTimelineState.customAudioTrack;
        if (updatedTrack != null) onTimingChanged(updatedTrack);
      },
      foreground: TimelineSubtrackContent(
        icon: Icons.music_note_rounded,
        label: videoTimelineState.activeAudioName,
        leading: videoTimelineState.authorAvatarUrl == null
            ? null
            : ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: CachedNetworkImage(
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  imageUrl: videoTimelineState.authorAvatarUrl!,
                  width: 18,
                  height: 18,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => _buildAvatarPlaceholder(),
                  errorWidget: (_, _, _) => _buildAvatarPlaceholder(),
                ),
              ),
      ),
      child: CustomPaint(
        painter: _AudioWaveformPainter(
          waveformData: videoTimelineState.customWaveformData,
          totalWidth: sourceWidth,
          pixelsPerSecond: pixelsPerSecond,
        ),
      ),
    );
  }

  Duration _durationAtFraction(double fraction) {
    return Duration(
      milliseconds: (videoTimelineState.videoDuration.inMilliseconds * fraction)
          .round(),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: AppColors.grey500,
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(Icons.person, color: AppColors.grey300, size: 12),
    );
  }
}

class _AudioWaveformPainter extends CustomPainter {
  _AudioWaveformPainter({
    required this.waveformData,
    required this.totalWidth,
    required this.pixelsPerSecond,
  });

  final List<double> waveformData;
  final double totalWidth;
  final double pixelsPerSecond;

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.greyWhite.withAlpha(100)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const barWidth = 2.0;
    const barSpacing = 2.0;
    const barStep = barWidth + barSpacing;
    final barCount = (size.width / barStep).floor();
    final samplesPerBar = waveformData.length / barCount;
    final centerY = size.height / 2;

    for (var i = 0; i < barCount; i++) {
      final sampleIndex = (i * samplesPerBar).floor().clamp(
        0,
        waveformData.length - 1,
      );
      final amplitude = waveformData[sampleIndex];
      final barHeight = (amplitude * size.height * 0.7).clamp(
        2.0,
        size.height - 4,
      );
      final x = i * barStep + barWidth / 2;

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AudioWaveformPainter oldDelegate) {
    return oldDelegate.waveformData != waveformData ||
        oldDelegate.totalWidth != totalWidth;
  }
}
