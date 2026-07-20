import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/models/audio_audition_timing.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_waveform.dart';

const _waveformHeight = 72.0;
const _selectionHorizontalInset = 28.0;

class AudioRangeSelectionOverlay extends StatefulWidget {
  const AudioRangeSelectionOverlay({
    required this.track,
    required this.videoDuration,
    required this.waveformData,
    required this.isWaveformLoading,
    required this.playbackProgress,
    required this.onScrubStarted,
    required this.onPreviewRequested,
    required this.onCancel,
    required this.onDone,
    super.key,
  });

  final AudioTrack track;
  final Duration videoDuration;
  final List<double> waveformData;
  final bool isWaveformLoading;
  final ValueListenable<double> playbackProgress;
  final VoidCallback onScrubStarted;
  final ValueChanged<Duration> onPreviewRequested;
  final VoidCallback onCancel;
  final ValueChanged<Duration> onDone;

  @override
  State<AudioRangeSelectionOverlay> createState() =>
      _AudioRangeSelectionOverlayState();
}

class _AudioRangeSelectionOverlayState
    extends State<AudioRangeSelectionOverlay> {
  final ScrollController _scrollController = ScrollController();
  bool _didSetInitialPosition = false;
  bool _isSettingInitialPosition = false;
  bool _isUserScrolling = false;

  Duration get _selectionDuration => audioSelectionDuration(
    audioDuration: widget.track.duration,
    videoDuration: widget.videoDuration,
  );

  Duration get _maximumStart => widget.track.duration - _selectionDuration;

  @override
  void didUpdateWidget(covariant AudioRangeSelectionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.track.id != widget.track.id ||
        oldWidget.videoDuration != widget.videoDuration) {
      _didSetInitialPosition = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _fractionForStart(Duration start) {
    final maximumStartUs = _maximumStart.inMicroseconds;
    if (maximumStartUs <= 0) return 0;
    return (start.inMicroseconds / maximumStartUs).clamp(0.0, 1.0).toDouble();
  }

  void _setInitialScrollPosition() {
    if (_didSetInitialPosition || !_scrollController.hasClients) return;
    _didSetInitialPosition = true;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final initialFraction = _fractionForStart(
      widget.track.audioStartTime ?? Duration.zero,
    );
    _isSettingInitialPosition = true;
    try {
      _scrollController.jumpTo(maxScrollExtent * initialFraction);
    } finally {
      _isSettingInitialPosition = false;
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final isScrollMovement =
        notification is ScrollStartNotification ||
        notification is ScrollUpdateNotification ||
        notification is OverscrollNotification;
    if (isScrollMovement && !_isSettingInitialPosition && !_isUserScrolling) {
      _isUserScrolling = true;
      widget.onScrubStarted();
    }

    if (notification is ScrollEndNotification && _isUserScrolling) {
      _isUserScrolling = false;
      widget.onPreviewRequested(_selectedStart());
    }
    return false;
  }

  Duration _selectedStart() {
    final maximumStartUs = _maximumStart.inMicroseconds;
    if (maximumStartUs <= 0 || !_scrollController.hasClients) {
      return Duration.zero;
    }
    final position = _scrollController.position;
    final fraction = position.maxScrollExtent <= 0
        ? 0.0
        : (position.pixels / position.maxScrollExtent)
              .clamp(0.0, 1.0)
              .toDouble();
    return Duration(microseconds: (maximumStartUs * fraction).round());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final overlay = Material(
      key: const ValueKey('audio-range-selection-overlay'),
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _AudioPickerScrim(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      AppButton(
                        key: const ValueKey('audio-range-cancel'),
                        label: l10n.buttonCancel,
                        onPressed: widget.onCancel,
                        variant: AppButtonVariant.neutral,
                        size: AppButtonSize.compact,
                        minWidth: 76,
                        minHeight: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      Expanded(
                        child: Text(
                          l10n.labelSelectSoundClip,
                          textAlign: TextAlign.center,
                          style: AppTypography.textMediumBold.copyWith(
                            color: AppColors.greyWhite,
                          ),
                        ),
                      ),
                      AppButton(
                        key: const ValueKey('audio-range-done'),
                        label: l10n.buttonDone,
                        onPressed: () => widget.onDone(_selectedStart()),
                        size: AppButtonSize.compact,
                        minWidth: 76,
                        minHeight: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        widget.track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textMediumBold.copyWith(
                          color: AppColors.greyWhite,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.hintDragWaveform,
                        textAlign: TextAlign.center,
                        style: AppTypography.textSmallMedium.copyWith(
                          color: AppColors.greyWhite.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: _waveformHeight + 20,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final selectionWidth = math.max(
                        1.0,
                        constraints.maxWidth - _selectionHorizontalInset * 2,
                      );
                      final selectionUs = math.max(
                        1,
                        _selectionDuration.inMicroseconds,
                      );
                      final widthRatio =
                          widget.track.duration.inMicroseconds / selectionUs;
                      final waveformWidth = math.max(
                        selectionWidth,
                        selectionWidth * widthRatio,
                      );
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _setInitialScrollPosition(),
                      );

                      return Stack(
                        key: const ValueKey('audio-range-waveform-stack'),
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            key: const ValueKey('audio-range-playback-layer'),
                            left: _selectionHorizontalInset,
                            right: _selectionHorizontalInset,
                            child: IgnorePointer(
                              child: SizedBox(
                                height: _waveformHeight + 12,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: ValueListenableBuilder<double>(
                                    valueListenable: widget.playbackProgress,
                                    builder: (context, progress, _) =>
                                        _SmoothPlaybackProgressFill(
                                          progress: progress,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          NotificationListener<ScrollNotification>(
                            key: const ValueKey('audio-range-waveform-layer'),
                            onNotification: _handleScrollNotification,
                            child: SingleChildScrollView(
                              key: const ValueKey(
                                'audio-range-waveform-scroller',
                              ),
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: _selectionHorizontalInset,
                                ),
                                child: AudioWaveform(
                                  size: Size(waveformWidth, _waveformHeight),
                                  samples: widget.waveformData,
                                  color: AppColors.greyWhite.withValues(
                                    alpha: 0.9,
                                  ),
                                  presentation:
                                      AudioWaveformPresentation.selection,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            key: const ValueKey(
                              'audio-range-selection-border-layer',
                            ),
                            left: _selectionHorizontalInset,
                            right: _selectionHorizontalInset,
                            child: IgnorePointer(
                              child: SizedBox(
                                key: const ValueKey(
                                  'audio-range-selection-frame',
                                ),
                                height: _waveformHeight + 12,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primary500,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary500.withValues(
                                          alpha: 0.28,
                                        ),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (widget.isWaveformLoading)
                            const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary500,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
    return _AudioPickerModalBoundary(
      semanticsLabel: l10n.labelSelectSoundClip,
      child: overlay,
    );
  }
}

class _AudioPickerModalBoundary extends StatelessWidget {
  const _AudioPickerModalBoundary({
    required this.semanticsLabel,
    required this.child,
  });

  final String semanticsLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlockSemantics(
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        scopesRoute: true,
        label: semanticsLabel,
        child: Listener(behavior: HitTestBehavior.opaque, child: child),
      ),
    );
  }
}

class _SmoothPlaybackProgressFill extends StatefulWidget {
  const _SmoothPlaybackProgressFill({required this.progress});

  final double progress;

  @override
  State<_SmoothPlaybackProgressFill> createState() =>
      _SmoothPlaybackProgressFillState();
}

class _SmoothPlaybackProgressFillState
    extends State<_SmoothPlaybackProgressFill>
    with SingleTickerProviderStateMixin {
  static const _smoothingDuration = Duration(milliseconds: 160);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: _clampedProgress(widget.progress),
  );

  @override
  void didUpdateWidget(covariant _SmoothPlaybackProgressFill oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _clampedProgress(widget.progress);
    if (target < _controller.value) {
      _controller.value = target;
      return;
    }
    _controller.animateTo(
      target,
      duration: _smoothingDuration,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        child: const ColoredBox(
          key: ValueKey('audio-range-playback-fill'),
          color: AppColors.primary500,
        ),
        builder: (context, child) => Transform.scale(
          key: const ValueKey('audio-range-playback-progress'),
          alignment: Alignment.centerLeft,
          scaleX: _controller.value,
          child: child,
        ),
      ),
    );
  }

  static double _clampedProgress(double progress) {
    return progress.clamp(0.0, 1.0).toDouble();
  }
}

class _AudioPickerScrim extends StatelessWidget {
  const _AudioPickerScrim();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xB8000000),
              Color(0x00000000),
              Color(0x12000000),
              Color(0xE8000000),
            ],
            stops: [0, 0.22, 0.54, 1],
          ),
        ),
      ),
    );
  }
}
