import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/design_system/components/molecules/app_choice_group.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/labeler_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/settings/providers/preferences_provider.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';
import 'package:spark/src/features/settings/providers/settings_state.dart';
import 'package:spark/src/features/settings/ui/pages/labeler_label_settings_page.dart';
import 'package:spark/src/features/settings/ui/widgets/label_setting_tile.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

void main() {
  const labelerDid = 'did:plc:labeler';

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I
      ..registerSingleton<ActorRepository>(_FakeActorRepository())
      ..registerSingleton<SprkRepository>(
        _FakeSprkRepository(_service(labelerDid)),
      )
      ..registerSingleton<LogService>(LogService());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('uses built-in policy when a labeler omits definitions', (
    tester,
  ) async {
    await _pumpPage(tester, labelerDid);

    expect(find.text('Adult Content'), findsOneWidget);
    expect(find.text('Explicit sexual images.'), findsOneWidget);
    expect(find.text('Configured in Moderation settings.'), findsOneWidget);
    expect(find.byType(LabelSettingTile), findsOneWidget);
    for (final action in ['Off', 'Warn', 'Hide']) {
      expect(find.text(action), findsOneWidget);
    }
    expect(find.text('Show'), findsNothing);
    final actions = tester.widget<AppChoiceGroup<ModerationSetting>>(
      find.byType(AppChoiceGroup<ModerationSetting>),
    );
    expect(actions.enabled, isFalse);
  });

  testWidgets('uses Badge for a labeler-defined inform label', (tester) async {
    await GetIt.I.unregister<SprkRepository>();
    GetIt.I.registerSingleton<SprkRepository>(
      _FakeSprkRepository(_informService(labelerDid)),
    );

    await _pumpPage(tester, labelerDid);

    expect(find.text('context'), findsOneWidget);
    for (final action in ['Off', 'Badge', 'Hide']) {
      expect(find.text(action), findsOneWidget);
    }
    expect(find.text('Warn'), findsNothing);
  });
}

Future<void> _pumpPage(WidgetTester tester, String labelerDid) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsProvider.overrideWith(_FakeSettings.new),
        userPreferencesProvider.overrideWith(_FakePreferences.new),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LabelerLabelSettingsPage(did: labelerDid),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

LabelerViewDetailed _service(String did) => LabelerViewDetailed(
  uri: AtUri.parse('at://$did/app.bsky.labeler.service/self'),
  cid: 'cid',
  creator: ProfileView(did: did, handle: 'labeler.test'),
  policies: LabelerPolicies(
    labelValues: const [LabelValue.knownValue(data: KnownLabelValue.porn)],
  ),
  indexedAt: DateTime.utc(2026),
);

LabelerViewDetailed _informService(String did) => LabelerViewDetailed(
  uri: AtUri.parse('at://$did/app.bsky.labeler.service/self'),
  cid: 'cid',
  creator: ProfileView(did: did, handle: 'labeler.test'),
  policies: LabelerPolicies(
    labelValues: const [LabelValue.unknown(data: 'context')],
    labelValueDefinitions: [
      LabelValueDefinition(
        identifier: 'context',
        severity: LabelValueDefinitionSeverity.valueOf('inform')!,
        blurs: LabelValueDefinitionBlurs.valueOf('none')!,
        locales: const [],
      ),
    ],
  ),
  indexedAt: DateTime.utc(2026),
);

class _FakeActorRepository implements ActorRepository {
  @override
  Future<List<ProfileViewDetailed>> getProfiles(
    List<String> dids, {
    bool useBluesky = false,
  }) async => const [];

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not used');
}

class _FakeSprkRepository implements SprkRepository {
  _FakeSprkRepository(this.service);

  final LabelerViewDetailed service;

  @override
  String get modDid => 'did:plc:mod#spark-labeler';

  @override
  LabelerRepository get labeler => _FakeLabelerRepository(service);

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not used');
}

class _FakeLabelerRepository implements LabelerRepository {
  const _FakeLabelerRepository(this.service);

  final LabelerViewDetailed service;

  @override
  Future<LabelerViewDetailed> getServicesDetailed(List<String> dids) async =>
      service;

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not used');
}

class _FakeSettings extends Settings {
  @override
  SettingsState build() => SettingsState(
    activeFeed: Feed(
      type: 'timeline',
      config: makeSavedFeed(
        id: 'following',
        type: 'timeline',
        value: 'following',
        pinned: true,
      ),
    ),
  );

  @override
  Future<Map<String, Setting>> getLabelSettingsForLabeler(
    String labelerDid,
  ) async => const {};
}

class _FakePreferences extends UserPreferences {
  @override
  Future<Preferences> build() async => Preferences(preferences: []);
}
