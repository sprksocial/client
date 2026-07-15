import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/layout/video_editor_toolbar.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/scrollable_timeline.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

void main() {
  testWidgets('text layers expose edit, arrange, and delete actions', (
    tester,
  ) async {
    final textLayer = TextLayer(id: 'text', text: 'Hello');
    final editor = _EditorMock()
      ..layers = [
        WidgetLayer(id: 'back', widget: const SizedBox()),
        textLayer,
        WidgetLayer(id: 'front', widget: const SizedBox()),
      ];
    final timelineState = VideoTimelineState(
      videoDuration: const Duration(seconds: 10),
    );
    addTearDown(timelineState.dispose);

    await tester.pumpWidget(
      _ToolbarTestApp(
        editor: editor,
        timelineState: timelineState,
        selectedLayer: textLayer,
      ),
    );

    expect(_action('edit-text'), findsOneWidget);
    expect(_action('forward'), findsOneWidget);
    expect(_action('backward'), findsOneWidget);
    expect(_action('delete'), findsOneWidget);
    expect(_action('crop'), findsNothing);

    await tester.tap(_action('edit-text'));
    await tester.tap(_action('delete'));
    expect(editor.editedTextLayer, same(textLayer));
    expect(editor.removedLayer, same(textLayer));
  });

  testWidgets('primary and audio tracks expose track-specific actions', (
    tester,
  ) async {
    final editor = _EditorMock()..layers = [];
    final timelineState = VideoTimelineState(
      videoDuration: const Duration(seconds: 10),
    );
    addTearDown(timelineState.dispose);
    var muteCount = 0;
    var removeCount = 0;
    var selectionClearCount = 0;

    await tester.pumpWidget(
      _ToolbarTestApp(
        editor: editor,
        timelineState: timelineState,
        selectedTrack: TimelineTrackSelection.primary,
        onToggleOriginalAudio: () => muteCount++,
      ),
    );
    expect(_action('mute'), findsOneWidget);
    expect(_action('crop'), findsOneWidget);
    expect(_action('tune'), findsOneWidget);
    expect(_action('filter'), findsOneWidget);
    expect(_action('blur'), findsOneWidget);
    expect(_action('delete'), findsNothing);
    await tester.tap(_action('mute'));
    expect(muteCount, 1);

    await tester.pumpWidget(
      _ToolbarTestApp(
        editor: editor,
        timelineState: timelineState,
        selectedTrack: TimelineTrackSelection.audio,
        onToggleCustomAudio: () => muteCount++,
        onRemoveSound: () => removeCount++,
        onClearTrackSelection: () => selectionClearCount++,
      ),
    );
    await tester.pumpAndSettle();
    expect(_action('replace-audio'), findsOneWidget);
    expect(_action('mute'), findsOneWidget);
    expect(_action('remove-audio'), findsOneWidget);
    expect(_action('crop'), findsNothing);

    await tester.tap(_action('mute'));
    await tester.tap(_action('remove-audio'));
    expect(muteCount, 2);
    expect(removeCount, 1);
    expect(selectionClearCount, 1);
  });
}

Finder _action(String id) {
  return find.byKey(ValueKey('video-toolbar-action-$id'));
}

class _ToolbarTestApp extends StatelessWidget {
  const _ToolbarTestApp({
    required this.editor,
    required this.timelineState,
    this.selectedLayer,
    this.selectedTrack,
    this.onToggleOriginalAudio,
    this.onToggleCustomAudio,
    this.onRemoveSound,
    this.onClearTrackSelection,
  });

  final ProImageEditorState editor;
  final VideoTimelineState timelineState;
  final Layer? selectedLayer;
  final TimelineTrackSelection? selectedTrack;
  final VoidCallback? onToggleOriginalAudio;
  final VoidCallback? onToggleCustomAudio;
  final VoidCallback? onRemoveSound;
  final VoidCallback? onClearTrackSelection;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: VideoEditorToolbar(
          editor: editor,
          videoTimelineState: timelineState,
          selectedLayer: selectedLayer,
          selectedTrack: selectedTrack,
          onAddSound: () {},
          onRemoveSound: onRemoveSound ?? () {},
          onToggleOriginalAudio: onToggleOriginalAudio ?? () {},
          onToggleCustomAudio: onToggleCustomAudio ?? () {},
          onClearTrackSelection: onClearTrackSelection ?? () {},
        ),
      ),
    );
  }
}

class _EditorMock implements ProImageEditorState {
  List<Layer> layers = [];
  Layer? editedTextLayer;
  Layer? removedLayer;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '_EditorMock';
  }

  @override
  List<Layer> get activeLayers => layers;

  @override
  int getLayerStackIndex(Layer layer) {
    return layers.indexWhere((candidate) => candidate.id == layer.id);
  }

  @override
  void editTextLayer(TextLayer layerData) {
    editedTextLayer = layerData;
  }

  @override
  void removeLayer(Layer layer, {bool blockCaptureScreenshot = false}) {
    removedLayer = layer;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
