import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/layer_reorder_controller.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timed_track_range.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_subtrack_content.dart';

class LayerTimingTrack extends StatelessWidget {
  const LayerTimingTrack({
    required this.totalWidth,
    required this.sourceWidth,
    required this.sourceOffset,
    required this.height,
    required this.videoDuration,
    required this.layer,
    required this.onTimingChanged,
    required this.isSelected,
    required this.onTap,
    this.reorderInteraction,
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
  final bool isSelected;
  final VoidCallback onTap;
  final LayerReorderInteraction? reorderInteraction;

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
    final (icon, label, color) = _visualsFor(context);

    return TimedTrackRange(
      key: ValueKey(layer.id),
      totalWidth: totalWidth,
      sourceWidth: sourceWidth,
      sourceOffset: sourceOffset,
      height: height,
      startFraction: clampedStart <= clampedEnd ? clampedStart : clampedEnd,
      endFraction: clampedStart <= clampedEnd ? clampedEnd : clampedStart,
      color: color,
      isSelected: isSelected,
      borderColor: isSelected ? AppColors.greyWhite : null,
      onTap: onTap,
      reorderInteraction: reorderInteraction,
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
      foreground: TimelineSubtrackContent(icon: icon, label: label),
      child: const SizedBox.expand(),
    );
  }

  Duration _durationAtFraction(double fraction) {
    return Duration(
      milliseconds: (videoDuration.inMilliseconds * fraction).round(),
    );
  }

  (IconData, String, Color) _visualsFor(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (layer.isTextLayer) {
      return (Icons.text_fields_rounded, l10n.labelText, AppColors.indigo600);
    }
    if (layer.isPaintLayer) {
      return (Icons.brush_rounded, l10n.labelPaint, AppColors.blue600);
    }
    if (layer.isEmojiLayer) {
      return (
        Icons.emoji_emotions_rounded,
        l10n.labelEmoji,
        AppColors.rajah900,
      );
    }
    return (
      Icons.sticky_note_2_rounded,
      l10n.labelStickers,
      AppColors.turquoise900,
    );
  }
}
