import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/components/atoms/surfaces/app_surface.dart';
import 'package:spark/src/core/design_system/components/molecules/app_choice_group.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/features/settings/ui/widgets/label_setting_tile.dart';

void main() {
  testWidgets('uses the app surface and choice-group design primitives', (
    tester,
  ) async {
    ModerationSetting? updatedSetting;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LabelSettingTile(
            label: 'graphic-media',
            labelName: 'Graphic media',
            labelDescription: 'Potentially disturbing media.',
            controlContext: LabelSettingTileContext.label,
            setting: ModerationSetting.warn,
            onChanged: (setting) => updatedSetting = setting,
          ),
        ),
      ),
    );

    final surface = tester.widget<AppSurface>(find.byType(AppSurface));
    expect(
      surface.margin,
      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
    expect(
      surface.padding,
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
    final choiceGroup = tester.widget<AppChoiceGroup<ModerationSetting>>(
      find.byType(AppChoiceGroup<ModerationSetting>),
    );
    expect(choiceGroup.options, hasLength(3));
    expect(find.byType(Card), findsNothing);
    expect(find.byType(ElevatedButton), findsNothing);
    for (final action in ['Off', 'Warn', 'Hide']) {
      expect(find.text(action), findsOneWidget);
    }

    await tester.tap(
      find
          .descendant(
            of: find.byType(AppChoiceGroup<ModerationSetting>),
            matching: find.byType(InteractivePressable),
          )
          .at(2),
    );
    await tester.pump();

    expect(updatedSetting, ModerationSetting.hide);
  });

  testWidgets('falls back to the label identifier when no name is available', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LabelSettingTile(
            label: 'custom-topic',
            controlContext: LabelSettingTileContext.adultContentFilter,
            setting: ModerationSetting.warn,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('custom-topic'), findsOneWidget);
    expect(find.text('Show'), findsOneWidget);
    expect(find.text('Off'), findsNothing);
  });

  testWidgets('inform labels use Badge for the warn setting', (tester) async {
    ModerationSetting? updatedSetting;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LabelSettingTile(
            label: 'context',
            controlContext: LabelSettingTileContext.informLabel,
            setting: ModerationSetting.ignore,
            onChanged: (setting) => updatedSetting = setting,
          ),
        ),
      ),
    );

    expect(find.text('Off'), findsOneWidget);
    expect(find.text('Badge'), findsOneWidget);
    expect(find.text('Hide'), findsOneWidget);
    expect(find.text('Warn'), findsNothing);

    await tester.tap(
      find
          .descendant(
            of: find.byType(AppChoiceGroup<ModerationSetting>),
            matching: find.byType(InteractivePressable),
          )
          .at(1),
    );
    await tester.pump();

    expect(updatedSetting, ModerationSetting.warn);
  });
}
