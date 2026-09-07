import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/components/atoms/toggles/app_toggle.dart';
import 'package:spark/src/core/design_system/components/molecules/app_choice_group.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/providers/preferences_provider.dart';
import 'package:spark/src/features/settings/ui/pages/moderation_page.dart';
import 'package:spark/src/features/settings/ui/widgets/label_setting_tile.dart';

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<LogService>(LogService());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('shows adult content and labeling controls', (tester) async {
    await _pumpPage(tester, _UserPreferences.new);

    expect(find.text('Moderation'), findsOneWidget);
    expect(find.text('Show adult content'), findsOneWidget);
    expect(find.text('Labelers'), findsOneWidget);
  });

  testWidgets('adult content update failures show localized feedback', (
    tester,
  ) async {
    await _pumpPage(tester, _FailingUserPreferences.new);

    await tester.tap(find.text('Show adult content'));
    await tester.pumpAndSettle();

    expect(find.text('An error occurred'), findsOneWidget);
    expect(
      tester.widget<AppToggle>(find.byType(AppToggle)).onChanged,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('adult content row and toggle save once with merged semantics', (
    tester,
  ) async {
    final preferences = _PendingAdultPreferences();
    await _pumpPage(tester, () => preferences);

    final adultContent = find.bySemanticsLabel(RegExp('Show adult content'));
    expect(adultContent, findsOneWidget);
    expect(
      tester
          .getSemantics(adultContent)
          .getSemanticsData()
          .flagsCollection
          .isToggled
          .toBoolOrNull(),
      isTrue,
    );

    await tester.tap(find.text('Show adult content'));
    await tester.pump();
    expect(preferences.adultUpdates, [false]);
    expect(
      tester
          .getSemantics(adultContent)
          .getSemanticsData()
          .flagsCollection
          .isEnabled
          .toBoolOrNull(),
      isFalse,
    );

    await tester.tap(find.text('Show adult content'));
    await tester.tap(find.byType(AppToggle));
    await tester.pump();
    expect(preferences.adultUpdates, [false]);

    preferences.save.complete();
    await tester.pumpAndSettle();
    expect(
      tester
          .getSemantics(adultContent)
          .getSemanticsData()
          .flagsCollection
          .isToggled
          .toBoolOrNull(),
      isFalse,
    );

    await tester.tap(find.byType(AppToggle));
    await tester.pumpAndSettle();
    expect(preferences.adultUpdates, [false, true]);
    expect(adultContent, findsOneWidget);
    expect(
      tester
          .getSemantics(adultContent)
          .getSemanticsData()
          .flagsCollection
          .isToggled
          .toBoolOrNull(),
      isTrue,
    );
  });

  testWidgets('shows built-in global adult filters without loading labelers', (
    tester,
  ) async {
    final preferences = _AdultPreferences();
    await _pumpPage(tester, () => preferences);

    expect(find.text('Content filters'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    final adultSettingsGroup = find.byKey(
      const Key('adult-content-settings-group'),
    );
    expect(
      find.descendant(of: adultSettingsGroup, matching: find.byType(AppToggle)),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: adultSettingsGroup,
        matching: find.byType(LabelSettingTile),
      ),
      findsNWidgets(4),
    );

    final sexualControl = find.byKey(const Key('global-label-sexual'));
    final sexualActions = tester.widget<AppChoiceGroup<ModerationSetting>>(
      find.descendant(
        of: sexualControl,
        matching: find.byType(AppChoiceGroup<ModerationSetting>),
      ),
    );
    expect(sexualActions.options, hasLength(3));
    expect(sexualActions.value, ModerationSetting.hide);

    final pornControl = find.byKey(const Key('global-label-porn'));
    expect(tester.widget(pornControl), isA<LabelSettingTile>());
    await tester.tap(
      find
          .descendant(
            of: pornControl,
            matching: find.byType(InteractivePressable),
          )
          .first,
    );
    await tester.pump();

    expect(preferences.lastLabel, 'porn');
    expect(preferences.lastSetting, ModerationSetting.ignore);

    for (final strings in {
      'Adult Content': 'Explicit sexual images.',
      'Sexually Suggestive': 'Does not include nudity.',
      'Graphic Media': 'Explicit or potentially disturbing media.',
      'Non-sexual Nudity': 'For example, artistic nudes.',
    }.entries) {
      await tester.scrollUntilVisible(
        find.text(strings.key),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(strings.key), findsOneWidget);
      expect(find.text(strings.value), findsOneWidget);
    }
  });

  testWidgets('disables all moderation controls while a save is pending', (
    tester,
  ) async {
    final preferences = _PendingAdultPreferences();
    await _pumpPage(tester, () => preferences);

    final pornControl = find.byKey(const Key('global-label-porn'));
    await tester.tap(
      find
          .descendant(
            of: pornControl,
            matching: find.byType(InteractivePressable),
          )
          .first,
    );
    final sexualControl = find.byKey(const Key('global-label-sexual'));
    await tester.tap(
      find
          .descendant(
            of: sexualControl,
            matching: find.byType(InteractivePressable),
          )
          .last,
    );
    expect(preferences.updateCount, 1);

    await tester.pump();

    expect(preferences.updateCount, 1);
    expect(
      tester
          .widgetList<AppChoiceGroup<ModerationSetting>>(
            find.byType(AppChoiceGroup<ModerationSetting>),
          )
          .every((group) => !group.enabled),
      isTrue,
    );
    expect(tester.widget<AppToggle>(find.byType(AppToggle)).onChanged, isNull);

    await tester.tap(
      find
          .descendant(
            of: sexualControl,
            matching: find.byType(InteractivePressable),
          )
          .last,
    );
    expect(preferences.updateCount, 1);

    preferences.save.complete();
    await tester.pumpAndSettle();

    expect(
      tester
          .widgetList<AppChoiceGroup<ModerationSetting>>(
            find.byType(AppChoiceGroup<ModerationSetting>),
          )
          .every((group) => group.enabled),
      isTrue,
    );
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  UserPreferences Function() createPreferences,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [userPreferencesProvider.overrideWith(createPreferences)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ModerationPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _UserPreferences extends UserPreferences {
  @override
  Future<Preferences> build() async => Preferences(preferences: []);
}

class _FailingUserPreferences extends _UserPreferences {
  @override
  Future<void> setAdultContentEnabled(bool enabled) async {
    throw StateError('update failed');
  }
}

class _AdultPreferences extends UserPreferences {
  String? lastLabel;
  ModerationSetting? lastSetting;

  @override
  Future<Preferences> build() async => Preferences(
    preferences: [
      adultContentPreference(enabled: true),
      contentLabelPreference(
        labelerDid: null,
        label: 'sexual',
        visibility: 'hide',
      ),
    ],
  );

  @override
  Future<void> setGlobalLabelPreference(
    String label,
    ModerationSetting setting,
  ) async {
    lastLabel = label;
    lastSetting = setting;
  }
}

class _PendingAdultPreferences extends UserPreferences {
  final save = Completer<void>();
  final adultUpdates = <bool>[];
  int updateCount = 0;

  @override
  Future<Preferences> build() async =>
      Preferences(preferences: [adultContentPreference(enabled: true)]);

  @override
  Future<void> setAdultContentEnabled(bool enabled) async {
    adultUpdates.add(enabled);
    await save.future;
    state = AsyncData(
      Preferences(preferences: [adultContentPreference(enabled: enabled)]),
    );
  }

  @override
  Future<void> setGlobalLabelPreference(
    String label,
    ModerationSetting setting,
  ) async {
    updateCount++;
    await save.future;
  }
}
