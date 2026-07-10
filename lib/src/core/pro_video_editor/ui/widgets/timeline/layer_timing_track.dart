import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timed_track_range.dart';

class LayerTimingTrack extends StatelessWidget {
  const LayerTimingTrack({
    required this.totalWidth,
    required this.sourceWidth,
    required this.sourceOffset,
    required this.height,
    required this.videoDuration,
    required this.layer,
    required this.onTimingChanged,
    super.key,
  });

  final double totalWidth;
  final double sourceWidth;
  final double sourceOffset;
  final double height;
  final Duration videoDuration;
  final Layer layer;
  final void Function(Layer layer, Duration start, Duration end)
  onTimingChanged;

  @override
  Widget build(BuildContext context) {
    final durationMs = videoDuration.inMilliseconds;
    final start = durationMs <= 0
        ? 0.0
        : (layer.startTime ?? Duration.zero).inMilliseconds / durationMs;
    final end = durationMs <= 0
        ? 1.0
        : (layer.endTime ?? videoDuration).inMilliseconds / durationMs;
    final clampedStart = start.clamp(0.0, 1.0).toDouble();
    final clampedEnd = end.clamp(0.0, 1.0).toDouble();
    final (icon, label) = _labelFor(context);

    return TimedTrackRange(
      key: ValueKey(layer.id),
      totalWidth: totalWidth,
      sourceWidth: sourceWidth,
      sourceOffset: sourceOffset,
      height: height,
      startFraction: clampedStart <= clampedEnd ? clampedStart : clampedEnd,
      endFraction: clampedStart <= clampedEnd ? clampedEnd : clampedStart,
      color: AppColors.indigo600,
      minimumRangeFraction: durationMs <= 0
          ? 0.01
          : (250 / durationMs).clamp(0.001, 1.0).toDouble(),
      onRangeChanged: (_, _) {},
      onRangeChangeEnd: (start, end) {
        onTimingChanged(
          layer,
          _durationAtFraction(start),
          _durationAtFraction(end),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 17, color: AppColors.greyWhite),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.greyWhite,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Duration _durationAtFraction(double fraction) {
    return Duration(
      milliseconds: (videoDuration.inMilliseconds * fraction).round(),
    );
  }

  (IconData, String) _labelFor(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (layer.isTextLayer) return (Icons.text_fields_rounded, l10n.labelText);
    if (layer.isPaintLayer) return (Icons.brush_rounded, l10n.labelPaint);
    if (layer.isEmojiLayer) {
      return (Icons.emoji_emotions_rounded, l10n.labelEmoji);
    }
    return (Icons.sticky_note_2_rounded, l10n.labelStickers);
  }
}
