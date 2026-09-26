import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/l10n/app_localization_delegates.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/media_editor/canvas/ui/theme/editor_theme.dart';
import 'package:spark/src/features/media_editor/story/ui/story_sticker_editor.dart';

void main() {
  testWidgets('Story sticker sheet preserves the configured editor lifecycle', (
    tester,
  ) async {
    final editorKey = GlobalKey<ProImageEditorState>();
    var constraintsBuildCount = 0;
    var stickerInitCount = 0;
    var mainEditorUpdateCount = 0;

    final callbacks = ProImageEditorCallbacks(
      mainEditorCallbacks: MainEditorCallbacks(
        onUpdateUI: () => mainEditorUpdateCount++,
      ),
      stickerEditorCallbacks: StickerEditorCallbacks(
        onInit: () => stickerInitCount++,
      ),
    );
    final configs = ProImageEditorConfigs(
      theme: editorTheme,
      stickerEditor: StickerEditorConfigs(
        style: StickerEditorStyle(
          showDragHandle: false,
          editorBoxConstraintsBuilder: (context, receivedConfigs) {
            expect(receivedConfigs.stickerEditor.builder, isNotNull);
            constraintsBuildCount++;
            return null;
          },
        ),
        builder: (setLayer, scrollController) => Material(
          child: Center(
            child: TextButton(
              key: const ValueKey('select-test-sticker'),
              onPressed: () => setLayer(
                WidgetLayer(
                  widget: const SizedBox(
                    key: ValueKey('selected-test-sticker'),
                  ),
                ),
              ),
              child: const Text('Select sticker'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProImageEditor.blank(
          const Size(390, 844),
          key: editorKey,
          callbacks: callbacks,
          configs: configs,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final editor = editorKey.currentState!;
    editor.addLayer(
      WidgetLayer(widget: const SizedBox()),
      blockCaptureScreenshot: true,
    );
    await tester.pump();
    expect(editor.selectedLayers, hasLength(1));

    final updatesBeforeOpening = mainEditorUpdateCount;
    final openFuture = openStoryStickerEditor(editor);
    await tester.pumpAndSettle();

    expect(constraintsBuildCount, 1);
    expect(stickerInitCount, 1);
    expect(editor.selectedLayers, isEmpty);
    expect(find.byKey(const ValueKey('select-test-sticker')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('select-test-sticker')));
    await tester.pumpAndSettle();
    await openFuture;

    expect(editor.activeLayers, hasLength(2));
    expect(mainEditorUpdateCount, updatesBeforeOpening + 1);
  });
}
