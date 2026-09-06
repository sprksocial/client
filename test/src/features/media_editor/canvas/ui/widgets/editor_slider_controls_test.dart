import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/media_editor/canvas/ui/widgets/editor_slider_controls.dart';

void main() {
  testWidgets('font scale reset restores the value from opening the sheet', (
    tester,
  ) async {
    var value = 1.7;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => EditorFontScaleSlider(
              value: value,
              min: 0.5,
              max: 4,
              onChanged: (updated) => setState(() => value = updated),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );
    tester.widget<Slider>(find.byType(Slider)).onChanged!(2.5);
    await tester.pump();

    expect(value, 2.5);
    expect(find.byType(Icon), findsNothing);
    expect(tester.widget<AppIcon>(find.byType(AppIcon)).icon, AppIconData.undo);
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(value, 1.7);
    expect(tester.widget<Slider>(find.byType(Slider)).value, 1.7);
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );
  });
}
