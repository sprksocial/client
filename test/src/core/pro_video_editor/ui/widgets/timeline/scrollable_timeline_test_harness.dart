import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/scrollable_timeline.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timed_track_range.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_selection.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

TimedTrackRange rangeWithin(WidgetTester tester, Finder parent) {
  return tester.widget<TimedTrackRange>(
    find.descendant(of: parent, matching: find.byType(TimedTrackRange)),
  );
}

BoxDecoration surfaceDecorationWithin(WidgetTester tester, Finder parent) {
  final surface = tester.widget<DecoratedBox>(
    find.descendant(
      of: parent,
      matching: find.byKey(const ValueKey('timed-track-range-surface')),
    ),
  );
  return surface.decoration as BoxDecoration;
}

class TimelineTestApp extends StatefulWidget {
  const TimelineTestApp({
    required this.state,
    required this.layers,
    required this.onLayerSelectionChanged,
    this.selectedLayerId,
    this.onLayerTimingChanged,
    this.onLayerReordered,
    this.onSeek,
    this.onSeekStart,
    this.onSeekEnd,
    this.onSelectionChanged,
    this.onTrimChanged,
    this.onTrimEnd,
    super.key,
  });

  final VideoTimelineState state;
  final List<Layer> layers;
  final ValueChanged<Layer?> onLayerSelectionChanged;
  final String? selectedLayerId;
  final void Function(Layer layer, Duration start, Duration end)?
  onLayerTimingChanged;
  final LayerReorderedCallback? onLayerReordered;
  final ValueChanged<double>? onSeek;
  final VoidCallback? onSeekStart;
  final VoidCallback? onSeekEnd;
  final ValueChanged<TimelineSelection>? onSelectionChanged;
  final void Function(double start, double end)? onTrimChanged;
  final void Function(double start, double end, bool isStartHandle)? onTrimEnd;

  @override
  State<TimelineTestApp> createState() => _TimelineTestAppState();
}

class _TimelineTestAppState extends State<TimelineTestApp> {
  late TimelineSelection _selection = _selectionFromWidget();

  TimelineSelection _selectionFromWidget() {
    final layerId = widget.selectedLayerId;
    return layerId == null
        ? TimelineSelection.none
        : TimelineSelection.layer(layerId);
  }

  @override
  void didUpdateWidget(covariant TimelineTestApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedLayerId != widget.selectedLayerId) {
      _selection = _selectionFromWidget();
    }
  }

  void _onSelectionChanged(TimelineSelection selection) {
    setState(() => _selection = selection);
    widget.onSelectionChanged?.call(selection);
    Layer? layer;
    if (selection.kind == TimelineSelectionKind.layer) {
      for (final candidate in widget.layers) {
        if (candidate.id == selection.layerId) {
          layer = candidate;
          break;
        }
      }
    }
    widget.onLayerSelectionChanged(layer);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          width: 430,
          child: ScrollableTimeline(
            videoTimelineState: widget.state,
            onSeek: widget.onSeek ?? (_) {},
            onSeekStart: widget.onSeekStart,
            onSeekEnd: widget.onSeekEnd,
            layers: widget.layers,
            selection: _selection,
            onSelectionChanged: _onSelectionChanged,
            onAudioTimingChanged: (_) {},
            onLayerTimingChanged: widget.onLayerTimingChanged ?? (_, _, _) {},
            onLayerReordered: widget.onLayerReordered ?? (_, _, _, _) {},
            onTrimChanged: widget.onTrimChanged ?? (_, _) {},
            onTrimEnd: widget.onTrimEnd,
          ),
        ),
      ),
    );
  }
}
