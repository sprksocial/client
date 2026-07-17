import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/sound_picker_sheet_scaffold.dart';

void main() {
  testWidgets('provides a visible Material surface for ListTile effects', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SoundPickerSheetScaffold(
            title: 'Sounds',
            child: ListTile(
              selected: true,
              selectedColor: Colors.teal,
              contentPadding: EdgeInsets.zero,
              title: const Text('Track'),
              onTap: () => tapCount++,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final sheetMaterial = tester.widget<Material>(
      find.descendant(
        of: find.byType(SoundPickerSheetScaffold),
        matching: find.byType(Material),
      ),
    );
    expect(
      sheetMaterial.borderRadius,
      const BorderRadius.vertical(top: Radius.circular(20)),
    );
    expect(sheetMaterial.clipBehavior, Clip.antiAlias);

    await tester.tap(find.byType(ListTile));
    await tester.pump();

    expect(tapCount, 1);
    expect(tester.takeException(), isNull);
  });
}
