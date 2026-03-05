import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// Displays and allows selection of an audio waveform segment.
class AudioWaveformSelector extends StatefulWidget {
  /// Creates an [AudioWaveformSelector].
  const AudioWaveformSelector({
    required this.configs,
    required this.audioTrack,
    required this.videoDuration,
    this.amplitudes,
    this.onStartTimeChanged,
    super.key,
  });

  /// Editor configuration settings.
  final ProImageEditorConfigs configs;

  /// The audio track to visualize.
  final AudioTrack audioTrack;

  /// The total duration of the video.
  final Duration videoDuration;

  /// Optional precomputed waveform amplitudes.
  final List<double>? amplitudes;

  /// Called when the start time changes.
  final ValueChanged<Duration>? onStartTimeChanged;

  @override
  State<AudioWaveformSelector> createState() => _AudioWaveformSelectorState();
}

class _AudioWaveformSelectorState extends State<AudioWaveformSelector> {
  late final _style = widget.configs.audioEditor.style;

  late ScrollController _scrollController;
  final _rebuildController = StreamController<void>.broadcast();
  int _currentStartTime = 0;
  final List<double> _amplitudes = [];

  late final double _waveformHeight = _style.startTimeWaveMaxHeight;
  late final double _waveItemWidth = _style.startTimeWaveItemWidth;
  late final double _waveItemSpacing = _style.startTimeWaveItemSpacing;
  late final double _totalItemWidth = _waveItemWidth + _waveItemSpacing;

  final double _outsideHorizontalPadding = 18;
  late final double _borderWidth = _style.startTimeSelectorSelectionBorderWidth;

  double _lastScreenWidth = 0;
  int _audioTrackItems = 0;

  @override
  void initState() {
    super.initState();
    _currentStartTime =
        (widget.audioTrack.startTime ?? Duration.zero).inMilliseconds;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _rebuildController.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AudioWaveformSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioTrack != widget.audioTrack && _lastScreenWidth != 0) {
      _currentStartTime =
          (widget.audioTrack.startTime ?? Duration.zero).inMilliseconds;
      _generateAmplitudes(_lastScreenWidth);
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    _rebuildController.add(null);
    super.setState(fn);
  }

  void _generateAmplitudes(double selectionWidth) {
    _lastScreenWidth = selectionWidth;
    _amplitudes.clear();
    _audioTrackItems = 0;

    if (widget.amplitudes != null && widget.amplitudes!.isNotEmpty) {
      _amplitudes.addAll(widget.amplitudes!);
      _audioTrackItems = widget.amplitudes!.length;
    } else {
      final random = Random();
      final videoDuration = widget.videoDuration.inMilliseconds;
      final audioDuration = widget.audioTrack.duration.inMilliseconds;
      if (audioDuration <= 0) return;

      final videoDurationItemCount = (selectionWidth / _totalItemWidth).ceil();
      _audioTrackItems =
          (videoDurationItemCount * videoDuration / audioDuration).ceil();

      _amplitudes
        ..addAll(List.generate(_audioTrackItems, (_) => random.nextDouble()))
        ..addAll(List.generate(videoDurationItemCount, (_) => 0));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
      if (_scrollController.hasClients) {
        final maxExtent = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(
          _timeToOffset(
            Duration(milliseconds: _currentStartTime),
          ).clamp(0.0, maxExtent),
        );
      }
    });
  }

  int _offsetToTime(double offset) {
    if (_amplitudes.isEmpty || _audioTrackItems == 0) return 0;

    final maxScrollExtent = _audioTrackItems * _totalItemWidth;
    final progress = maxScrollExtent == 0 ? 0 : offset / maxScrollExtent;
    final audioDuration = widget.audioTrack.duration.inMilliseconds;
    final currentTimeInTimeline = (progress * audioDuration).round();

    return currentTimeInTimeline.clamp(0, audioDuration);
  }

  double _timeToOffset(Duration time) {
    if (_audioTrackItems == 0) return 0;
    final audioDuration = widget.audioTrack.duration.inMilliseconds;
    if (audioDuration <= 0) return 0;
    final maxScrollExtent = _audioTrackItems * _totalItemWidth;
    final clampedMs = time.inMilliseconds.clamp(0, audioDuration);
    return (clampedMs / audioDuration) * maxScrollExtent;
  }

  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).floor().toString().padLeft(2, '0');
    final milliseconds = ((seconds % 1) * 100).floor().toString().padLeft(
      2,
      '0',
    );

    return '$minutes:$remainingSeconds:$milliseconds';
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final newTime = _offsetToTime(offset);

    if (newTime != _currentStartTime) {
      setState(() {
        _currentStartTime = newTime.clamp(
          0,
          widget.audioTrack.duration.inMilliseconds,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.configs.theme ?? Theme.of(context);
    final backgroundColor = _style.startTimeSelectorBackground;

    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          _style.startTimeSelectorBorderRadius,
        ),
        border: Border.all(
          color: _style.startTimeSelectorBorderColor,
          width: _style.startTimeSelectorBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.configs.audioEditor.widgets.startTimeDisplay?.call(
                _rebuildController.stream,
                _currentStartTime,
              ) ??
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: _outsideHorizontalPadding,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _style.startTimeSelectorColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _formatTime(_currentStartTime / 1000),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _style.startTimeSelectorColor,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
          Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    _onScroll();
                  } else if (notification is ScrollEndNotification) {
                    _onScroll();
                    widget.onStartTimeChanged?.call(
                      Duration(milliseconds: _currentStartTime),
                    );
                  }
                  return false;
                },
                child: SizedBox(
                  height: _waveformHeight + _borderWidth * 4,
                  child: ListView.builder(
                    itemCount: _amplitudes.length,
                    padding: EdgeInsets.symmetric(
                      horizontal: _outsideHorizontalPadding,
                    ),
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (_, index) {
                      final amplitude = _amplitudes[index];
                      final height = max(
                        4,
                        _waveformHeight * amplitude,
                      ).toDouble();
                      return Align(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: _waveItemSpacing),
                          width: _waveItemWidth,
                          height: height,
                          decoration: BoxDecoration(
                            color: _style.startTimeSelectorWaveColor,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: _outsideHorizontalPadding,
                child: ColoredBox(color: backgroundColor.withAlpha(220)),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: _outsideHorizontalPadding,
                child: ColoredBox(color: backgroundColor.withAlpha(220)),
              ),
              Positioned(
                left: _outsideHorizontalPadding,
                right: _outsideHorizontalPadding,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      if (_lastScreenWidth != constraints.maxWidth) {
                        _generateAmplitudes(constraints.maxWidth);
                      }
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _style.startTimeSelectorSelectionBorderColor,
                            width: _borderWidth,
                          ),
                          borderRadius: BorderRadius.circular(
                            _style.startTimeSelectorSelectionBorderRadius,
                          ),
                          color: _style.startTimeSelectorSelectionBorderColor
                              .withAlpha(25),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
