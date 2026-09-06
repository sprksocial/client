import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/media_editor/canvas/ui/widgets/editor_layer_interactions.dart';

void main() {
  testWidgets('layer handles preserve actions and canvas pointer delivery', (
    tester,
  ) async {
    final widgets = buildEditorLayerInteractions();
    const stream = Stream<void>.empty();
    var edits = 0;
    var removals = 0;
    var rotateDowns = 0;
    var rotateUps = 0;
    var canvasDowns = 0;
    var canvasMoves = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (_) => canvasDowns++,
                      onPointerMove: (_) => canvasMoves++,
                    ),
                  ),
                  widgets.editButton!(stream, () => edits++, 0)!,
                  widgets.removeButton!(stream, () => removals++, 0)!,
                  widgets.rotateScaleButton!(
                    stream,
                    (_) => rotateDowns++,
                    (_) => rotateUps++,
                    0,
                  )!,
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Finder glyph(AppIconData icon) => find.byWidgetPredicate(
      (widget) => widget is AppIcon && widget.icon == icon,
    );

    await tester.tapAt(tester.getCenter(glyph(AppIconData.edit)));
    await tester.tapAt(tester.getCenter(glyph(AppIconData.cancel)));
    expect(edits, 1);
    expect(removals, 1);

    final gesture = await tester.startGesture(
      tester.getCenter(glyph(AppIconData.rotate)),
    );
    await gesture.moveBy(const Offset(20, 20));
    await gesture.up();
    expect(rotateDowns, 1);
    expect(rotateUps, 1);
    expect(canvasDowns, 3);
    expect(canvasMoves, greaterThan(0));
  });
}
