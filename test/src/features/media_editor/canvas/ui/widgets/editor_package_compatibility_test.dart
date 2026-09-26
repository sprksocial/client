import 'package:flutter/material.dart' as sdk;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/l10n/app_localization_delegates.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/media_editor/canvas/ui/theme/editor_theme.dart';
import 'package:spark/src/features/media_editor/canvas/ui/widgets/blur/blur_editor_bar.dart';
import 'package:spark/src/features/media_editor/canvas/ui/widgets/paint/paint_editor_bar.dart';

void main() {
  testWidgets('blur route supports custom sliders in an SDK app', (
    tester,
  ) async {
    final editor = await _pumpEditor(
      tester,
      ProImageEditorConfigs(
        theme: editorTheme,
        blurEditor: BlurEditorConfigs(
          widgets: BlurEditorWidgets(
            appBar: (_, _) => null,
            bottomBar: (editor, rebuildStream) => ReactiveWidget(
              stream: rebuildStream,
              builder: (_) => BlurEditorBar(
                configs: editor.configs,
                callbacks: editor.callbacks,
                editor: editor,
              ),
            ),
          ),
        ),
      ),
    );
    editor.openBlurEditor();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(Slider), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(BlurEditorBar))).brightness,
      Brightness.dark,
    );
    await tester.drag(find.byType(Slider), const Offset(100, 0));
    await tester.pumpAndSettle();
    expect(tester.widget<Slider>(find.byType(Slider)).value, greaterThan(0));

    await tester.tap(
      find.descendant(
        of: find.byType(BlurEditorBar),
        matching: find.byTooltip(editor.configs.i18n.cancel),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BlurEditorBar), findsNothing);
  });

  testWidgets('paint route supports custom bottom app bars in an SDK app', (
    tester,
  ) async {
    final editor = await _pumpEditor(
      tester,
      ProImageEditorConfigs(
        theme: editorTheme,
        paintEditor: PaintEditorConfigs(
          widgets: PaintEditorWidgets(
            appBar: (_, _) => null,
            bottomBar: (editor, rebuildStream) => ReactiveWidget(
              stream: rebuildStream,
              builder: (_) => PaintEditorBar(
                configs: editor.configs,
                callbacks: editor.callbacks,
                editor: editor,
                i18nColor: 'Color',
                showColorPicker: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    editor.openPaintEditor();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(PaintEditorBar),
        matching: find.byType(BottomAppBar),
      ),
      findsOneWidget,
    );
    expect(
      Theme.of(tester.element(find.byType(PaintEditorBar))).brightness,
      Brightness.dark,
    );
    await tester.tap(
      find.descendant(
        of: find.byType(PaintEditorBar),
        matching: find.byTooltip(editor.configs.i18n.cancel),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PaintEditorBar), findsNothing);
  });
}

Future<ProImageEditorState> _pumpEditor(
  WidgetTester tester,
  ProImageEditorConfigs configs,
) async {
  final editorKey = GlobalKey<ProImageEditorState>();
  await tester.pumpWidget(
    sdk.MaterialApp(
      theme: sdk.ThemeData.light(),
      localizationsDelegates: appLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ProImageEditor.blank(
        const Size(390, 844),
        key: editorKey,
        callbacks: ProImageEditorCallbacks(),
        configs: configs,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return editorKey.currentState!;
}
