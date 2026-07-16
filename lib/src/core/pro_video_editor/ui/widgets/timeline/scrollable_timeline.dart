import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/audio_timeline_track.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/layer_reorder_controller.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/layer_timing_track.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/primary_timeline_trim_overlay.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_selection.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_visual_tracks.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

const _kSubtrackSpacing = 6.0;
const _kSubtrackScrollIndicatorHeight = 20.0;
const _kSubtrackScrollIndicatorFadeDuration = Duration(milliseconds: 160);
const _kTimelineHeightAnimationDuration = Duration(milliseconds: 220);
const _kScrollEdgeTolerance = 0.5;
const _kMaxVisibleSubtracks = 4;

typedef LayerReorderedCallback =
    void Function(
      Layer layer,
      int hierarchyIndex,
      Duration? start,
      Duration? end,
    );

class ScrollableTimeline extends StatefulWidget {
  const ScrollableTimeline({
    required this.videoTimelineState,
    required this.onSeek,
    required this.layers,
    required this.selection,
    required this.onSelectionChanged,
    required this.onAudioTimingChanged,
    required this.onLayerTimingChanged,
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
  final TimelineSelection selection;
  final ValueChanged<TimelineSelection> onSelectionChanged;
  final ValueChanged<AudioTrack> onAudioTimingChanged;
  final void Function(Layer layer, Duration start, Duration end)
  onLayerTimingChanged;
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
  late LayerReorderController _layerReorderController;
  Timer? _scrollEndTimer;

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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _subtrackScrollController = ScrollController();
    _layerReorderController = LayerReorderController(
      _subtrackScrollController,
      () => widget.layers,
      () => widget.subtrackHeight + _kSubtrackSpacing,
      () => widget.subtrackHeight,
      () => _subtrackViewportHeight,
      () => widget.videoTimelineState.useCustomAudio ? 1 : 0,
      _onLayerReorderCommit,
    )..addListener(_onLayerReorderChange);
    _scrollController.addListener(_onScrollChange);
    _subtrackScrollController.addListener(_onSubtrackScrollChange);
    widget.videoTimelineState.addListener(_onProgressChange);
  }

  @override
  void didUpdateWidget(covariant ScrollableTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.videoTimelineState, widget.videoTimelineState)) {
      oldWidget.videoTimelineState.removeListener(_onProgressChange);
      widget.videoTimelineState.addListener(_onProgressChange);
    }
    _layerReorderController.synchronizeLayers();
  }

  @override
  void dispose() {
    widget.videoTimelineState.removeListener(_onProgressChange);
    _scrollController.removeListener(_onScrollChange);
    _subtrackScrollController.removeListener(_onSubtrackScrollChange);
    _scrollEndTimer?.cancel();
    _layerReorderController
      ..removeListener(_onLayerReorderChange)
      ..dispose();
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

  void _onLayerReorderChange() {
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
    widget.onSelectionChanged(
      widget.selection.kind == TimelineSelectionKind.primary
          ? TimelineSelection.none
          : TimelineSelection.primary,
    );
  }

  void _onAudioTrackTap() {
    widget.onSelectionChanged(
      widget.selection.kind == TimelineSelectionKind.audio
          ? TimelineSelection.none
          : TimelineSelection.audio,
    );
  }

  void _onLayerTrackTap(Layer layer) {
    widget.onSelectionChanged(
      widget.selection.kind == TimelineSelectionKind.layer &&
              widget.selection.layerId == layer.id
          ? TimelineSelection.none
          : TimelineSelection.layer(layer.id),
    );
  }

  void _onLayerReorderCommit(
    LayerReorderResult result,
    double start,
    double end,
    bool rangeChanged,
  ) {
    if (result.startIndex != result.targetIndex) {
      widget.onLayerReordered(
        result.layer,
        result.targetIndex,
        rangeChanged ? _durationAtFraction(start) : null,
        rangeChanged ? _durationAtFraction(end) : null,
      );
    } else if (rangeChanged) {
      widget.onLayerTimingChanged(
        result.layer,
        _durationAtFraction(start),
        _durationAtFraction(end),
      );
    }
  }

  Duration _durationAtFraction(double fraction) {
    return Duration(
      milliseconds:
          (widget.videoTimelineState.videoDuration.inMilliseconds * fraction)
              .round(),
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
                                TimelineTimeRuler(
                                  totalWidth: timelineWidth,
                                  pixelsPerSecond: widget.pixelsPerSecond,
                                  height: widget.rulerHeight,
                                  videoDuration:
                                      widget.videoTimelineState.trimmedDuration,
                                ),
                                GestureDetector(
                                  onTap: _onThumbnailTap,
                                  child: VideoThumbnailTrack(
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
                    if (widget.selection.kind ==
                            TimelineSelectionKind.primary &&
                        _canTrim)
                      PrimaryTimelineTrimOverlay(
                        timelineState: widget.videoTimelineState,
                        sourceWidth: sourceWidth,
                        trimStartLeft: trimStartVp,
                        trimEndLeft: trimEndVp,
                        rulerHeight: widget.rulerHeight,
                        thumbnailHeight: widget.thumbnailHeight,
                        onDragActivityChanged: (isDragging) =>
                            _isDraggingHandle = isDragging,
                        onTrimChanged: widget.onTrimChanged,
                        onTrimEnd: widget.onTrimEnd,
                      ),
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
        AudioTimelineTrack(
          key: const ValueKey('timeline-subtrack-audio'),
          totalWidth: timelineWidth,
          sourceWidth: sourceWidth,
          sourceOffset: sourceOffset,
          height: widget.subtrackHeight,
          videoTimelineState: widget.videoTimelineState,
          onTimingChanged: widget.onAudioTimingChanged,
          isSelected: widget.selection.kind == TimelineSelectionKind.audio,
          onTap: _onAudioTrackTap,
        ),
      for (final layer in _layerReorderController.displayLayers)
        LayerTimingTrack(
          key: ValueKey('timeline-subtrack-layer-${layer.id}'),
          totalWidth: timelineWidth,
          sourceWidth: sourceWidth,
          sourceOffset: sourceOffset,
          height: widget.subtrackHeight,
          videoDuration: widget.videoTimelineState.videoDuration,
          layer: layer,
          isSelected:
              widget.selection.kind == TimelineSelectionKind.layer &&
              widget.selection.layerId == layer.id,
          onTap: () => _onLayerTrackTap(layer),
          onTimingChanged: widget.onLayerTimingChanged,
          reorderInteraction: _layerReorderController.interactionFor(layer),
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
