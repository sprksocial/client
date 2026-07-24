import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:spark/src/features/settings/ui/widgets/label_setting_tile.dart';

void main() {
  testWidgets('selecting a moderation action reports the label and setting', (
    tester,
  ) async {
    String? updatedLabel;
    Setting? updatedSetting;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LabelSettingTile(
            label: 'graphic-media',
            labelName: 'Graphic media',
            showSeverity: false,
            preference: LabelPreference(
              value: 'graphic-media',
              blurs: Blurs.media,
              severity: Severity.alert,
              defaultSetting: Setting.warn,
              setting: Setting.warn,
              adultOnly: false,
            ),
            onPreferenceUpdate: (label, {blurs, setting, severity}) async {
              updatedLabel = label;
              updatedSetting = setting;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'HIDE'));
    await tester.pump();

    expect((updatedLabel, updatedSetting), ('graphic-media', Setting.hide));
    expect(find.text('Severity Level'), findsNothing);
  });
}
