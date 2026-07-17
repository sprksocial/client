import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/layout/video_editor_bottom_section.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_selection.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

void main() {
  testWidgets('keeps one selection owner across timeline and editor changes', (
    tester,
  ) async {
    final selectedLayerId = ValueNotifier<String?>(null);
    final layer = TextLayer(id: 'text', text: 'Text');
    final editor = _SelectionEditorMock(selectedLayerId)..layers = [layer];
    final timelineState = VideoTimelineState(
      videoDuration: const Duration(seconds: 10),
    );
    addTearDown(selectedLayerId.dispose);
    addTearDown(timelineState.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: VideoEditorBottomSection(
            editor: editor,
            videoTimelineState: timelineState,
            selectedLayerIdListenable: selectedLayerId,
            onSeek: (_) {},
            onTogglePlay: () {},
            onToggleOriginalAudio: () {},
            onToggleCustomAudio: () {},
            onAddSound: () {},
            onRemoveSound: () {},
            onAudioTimingChanged: (_) {},
            onSeekStart: () {},
            onSeekEnd: () {},
            onTrimChanged: (_, _) {},
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('timeline-primary-track')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('video-toolbar-action-crop')),
      findsOneWidget,
    );

    selectedLayerId.value = layer.id;
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('video-toolbar-action-delete')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('video-toolbar-action-crop')),
      findsNothing,
    );
  });

  testWidgets('synchronizes immediately when the selection notifier changes', (
    tester,
  ) async {
    final firstSelection = ValueNotifier<String?>('text');
    final replacementSelection = ValueNotifier<String?>(null);
    final layer = TextLayer(id: 'text', text: 'Text');
    final editor = _SelectionEditorMock(firstSelection)..layers = [layer];
    final timelineState = VideoTimelineState(
      videoDuration: const Duration(seconds: 10),
    );
    addTearDown(firstSelection.dispose);
    addTearDown(replacementSelection.dispose);
    addTearDown(timelineState.dispose);

    await tester.pumpWidget(_testApp(editor, timelineState, firstSelection));
    expect(
      tester.widget<VideoTimeline>(find.byType(VideoTimeline)).selection,
      TimelineSelection.layer(layer.id),
    );

    await tester.pumpWidget(
      _testApp(editor, timelineState, replacementSelection),
    );

    expect(
      tester.widget<VideoTimeline>(find.byType(VideoTimeline)).selection,
      TimelineSelection.none,
    );
  });

  testWidgets('clears selection when the selected layer disappears', (
    tester,
  ) async {
    final selectedLayerId = ValueNotifier<String?>('text');
    final layer = TextLayer(id: 'text', text: 'Text');
    final editor = _SelectionEditorMock(selectedLayerId)..layers = [layer];
    final timelineState = VideoTimelineState(
      videoDuration: const Duration(seconds: 10),
    );
    addTearDown(selectedLayerId.dispose);
    addTearDown(timelineState.dispose);

    await tester.pumpWidget(_testApp(editor, timelineState, selectedLayerId));
    editor.layers = [];
    await tester.pumpWidget(_testApp(editor, timelineState, selectedLayerId));

    expect(
      tester.widget<VideoTimeline>(find.byType(VideoTimeline)).selection,
      TimelineSelection.none,
    );
  });
}

Widget _testApp(
  ProImageEditorState editor,
  VideoTimelineState timelineState,
  ValueListenable<String?> selectedLayerId,
) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: VideoEditorBottomSection(
        editor: editor,
        videoTimelineState: timelineState,
        selectedLayerIdListenable: selectedLayerId,
        onSeek: (_) {},
        onTogglePlay: () {},
        onToggleOriginalAudio: () {},
        onToggleCustomAudio: () {},
        onAddSound: () {},
        onRemoveSound: () {},
        onAudioTimingChanged: (_) {},
        onSeekStart: () {},
        onSeekEnd: () {},
        onTrimChanged: (_, _) {},
      ),
    ),
  );
}

class _SelectionEditorMock implements ProImageEditorState {
  _SelectionEditorMock(this.selectedLayerId);

  final ValueNotifier<String?> selectedLayerId;
  List<Layer> layers = [];

  @override
  List<Layer> get activeLayers => layers;

  @override
  bool get canUndo => false;

  @override
  bool get canRedo => false;

  @override
  Layer? selectLayerById(String id, {bool enableMultiSelect = false}) {
    selectedLayerId.value = id;
    for (final layer in layers) {
      if (layer.id == id) return layer;
    }
    return null;
  }

  @override
  void unselectAllLayers() {
    selectedLayerId.value = null;
  }

  @override
  int getLayerStackIndex(Layer layer) => layers.indexOf(layer);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '_SelectionEditorMock';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
