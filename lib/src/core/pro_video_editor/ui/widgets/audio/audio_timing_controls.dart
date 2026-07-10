import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

class AudioTimingControls extends StatelessWidget {
  const AudioTimingControls({
    required this.track,
    required this.videoDuration,
    required this.onChanged,
    required this.onChangeEnd,
    super.key,
  });

  final AudioTrack track;
  final Duration videoDuration;
  final ValueChanged<AudioTrack> onChanged;
  final ValueChanged<AudioTrack> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sourceRange = _rangeFor(
      start: track.audioStartTime,
      end: track.audioEndTime,
      duration: track.duration,
    );
    final placementRange = _rangeFor(
      start: track.startTime,
      end: track.endTime,
      duration: videoDuration,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimingRangeControl(
          label: l10n.labelAudioSourceRange,
          range: sourceRange,
          duration: track.duration,
          onChanged: (range) => onChanged(
            track.copyWith(
              audioStartTime: _durationAt(range.start, track.duration),
              audioEndTime: _durationAt(range.end, track.duration),
            ),
          ),
          onChangeEnd: (range) => onChangeEnd(
            track.copyWith(
              audioStartTime: _durationAt(range.start, track.duration),
              audioEndTime: _durationAt(range.end, track.duration),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _TimingRangeControl(
          label: l10n.labelVideoPlacement,
          range: placementRange,
          duration: videoDuration,
          onChanged: (range) => onChanged(
            track.copyWith(
              startTime: _durationAt(range.start, videoDuration),
              endTime: _durationAt(range.end, videoDuration),
            ),
          ),
          onChangeEnd: (range) => onChangeEnd(
            track.copyWith(
              startTime: _durationAt(range.start, videoDuration),
              endTime: _durationAt(range.end, videoDuration),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.labelTrackVolume,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Slider(
          value: track.volume.clamp(0.0, 1.0).toDouble(),
          onChanged: (value) => onChanged(track.copyWith(volume: value)),
          onChangeEnd: (value) => onChangeEnd(track.copyWith(volume: value)),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.labelLoopAudio),
          value: track.loop,
          onChanged: (value) {
            final updatedTrack = track.copyWith(loop: value);
            onChanged(updatedTrack);
            onChangeEnd(updatedTrack);
          },
        ),
      ],
    );
  }

  RangeValues _rangeFor({
    required Duration? start,
    required Duration? end,
    required Duration duration,
  }) {
    final durationMs = duration.inMilliseconds;
    if (durationMs <= 0) return const RangeValues(0, 1);
    final startFraction = (start ?? Duration.zero).inMilliseconds / durationMs;
    final endFraction = (end ?? duration).inMilliseconds / durationMs;
    final clampedStart = startFraction.clamp(0.0, 1.0).toDouble();
    final clampedEnd = endFraction.clamp(0.0, 1.0).toDouble();
    return RangeValues(
      clampedStart <= clampedEnd ? clampedStart : clampedEnd,
      clampedStart <= clampedEnd ? clampedEnd : clampedStart,
    );
  }

  Duration _durationAt(double fraction, Duration duration) {
    return Duration(milliseconds: (duration.inMilliseconds * fraction).round());
  }
}

class _TimingRangeControl extends StatelessWidget {
  const _TimingRangeControl({
    required this.label,
    required this.range,
    required this.duration,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String label;
  final RangeValues range;
  final Duration duration;
  final ValueChanged<RangeValues> onChanged;
  final ValueChanged<RangeValues> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.labelLarge),
            ),
            Text(
              '${_format(_durationAt(range.start))} – '
              '${_format(_durationAt(range.end))}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        RangeSlider(
          values: range,
          min: 0,
          max: 1,
          onChanged: (value) {
            const minimumRange = 0.005;
            if (value.end - value.start < minimumRange) return;
            onChanged(value);
          },
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
  }

  Duration _durationAt(double fraction) {
    return Duration(milliseconds: (duration.inMilliseconds * fraction).round());
  }

  String _format(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    final tenths = (value.inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$minutes:$seconds.$tenths';
  }
}
