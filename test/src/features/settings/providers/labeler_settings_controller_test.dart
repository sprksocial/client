import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/labeler_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/providers/preferences_provider.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/settings/providers/labeler_settings_controller.dart';
import 'package:sprk_poptart/so/sprk/labeler/defs/labeler_view_detailed.dart';

void main() {
  late _PreferencesController preferencesController;
  late _FakeLabelerRepository labelerRepository;
  late ProviderContainer container;

  setUp(() async {
    await GetIt.I.reset();
    preferencesController = _PreferencesController();
    labelerRepository = _FakeLabelerRepository();
    GetIt.I
      ..registerSingleton<SprkRepository>(
        _FakeSprkRepository(labelerRepository),
      )
      ..registerSingleton<LogService>(LogService());
    container = ProviderContainer.test(
      overrides: [
        userPreferencesProvider.overrideWith(
          () => _FakeUserPreferences(preferencesController),
        ),
      ],
      retry: (retryCount, error) => null,
    );
  });

  tearDown(() async {
    container.dispose();
    await GetIt.I.reset();
  });

  group('label policy defaults', () {
    test(
      'startup labeler lookup does not persist definition defaults',
      () async {
        preferencesController.current = _preferencesWithLabelers([
          'did:plc:mod',
          'did:plc:custom',
        ]);
        final controller = container.read(labelerSettingsControllerProvider);

        final labelers = await controller.getLabelers();
        await pumpEventQueue();

        expect(labelers, ['did:plc:mod', 'did:plc:custom']);
        expect(preferencesController.writes, isEmpty);
        expect(labelerRepository.detailedServiceCalls, isEmpty);
      },
    );

    test('adding a labeler persists only the subscription', () async {
      preferencesController.current = _preferencesWithLabelers(['did:plc:mod']);
      final controller = container.read(labelerSettingsControllerProvider);

      await controller.addLabeler('@labeler.test');

      expect(preferencesController.writes, hasLength(1));
      expect(preferencesController.current.labelers?.map((item) => item.did), [
        'did:plc:mod',
        'did:plc:resolved',
      ]);
      expect(preferencesController.current.contentLabelPrefs, isNull);
      expect(labelerRepository.detailedServiceCalls, isEmpty);
    });

    test('syncing labelers does not persist definition defaults', () async {
      preferencesController.current = _preferencesWithLabelers([
        'did:plc:mod',
        'did:plc:custom',
      ]);
      final controller = container.read(labelerSettingsControllerProvider);

      await controller.syncLabelers();

      expect(preferencesController.refreshCalls, 1);
      expect(preferencesController.writes, isEmpty);
      expect(labelerRepository.detailedServiceCalls, isEmpty);
    });
  });
}

Preferences _preferencesWithLabelers(List<String> dids) => Preferences(
  preferences: [
    labelersPreference([for (final did in dids) LabelerPrefItem(did: did)]),
  ],
);

class _PreferencesController {
  Preferences current = Preferences(preferences: []);
  int refreshCalls = 0;
  final List<Preferences> writes = [];
}

class _FakeUserPreferences extends UserPreferences {
  _FakeUserPreferences(this.controller);

  final _PreferencesController controller;

  @override
  Future<Preferences> build() async => controller.current;

  @override
  Future<void> refresh() async {
    controller.refreshCalls++;
    state = AsyncValue.data(controller.current);
  }

  @override
  Future<Preferences> updatePreferences(Preferences preferences) async {
    controller.writes.add(preferences);
    controller.current = preferences;
    state = AsyncValue.data(preferences);
    return preferences;
  }

  @override
  Future<Preferences> updatePreferencesWithFn(
    Preferences Function(Preferences current) updater,
  ) async {
    final current = controller.current;
    final updated = updater(current);
    if (identical(updated, current)) return current;
    return updatePreferences(updated);
  }
}

class _FakeSprkRepository implements SprkRepository {
  _FakeSprkRepository(this.labeler);

  @override
  final LabelerRepository labeler;

  List<String> _labelerDids = ['did:plc:mod'];

  @override
  List<String> get labelerDids => List.unmodifiable(_labelerDids);

  @override
  void configureLabelers(Iterable<String> labelerDids) {
    _labelerDids = {'did:plc:mod', ...labelerDids}.take(20).toList();
  }

  @override
  String get modDid => 'did:plc:mod#spark-labeler';

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not used');
}

class _FakeLabelerRepository implements LabelerRepository {
  final List<List<String>> detailedServiceCalls = [];

  @override
  Future<String> resolveIdentifier(String identifier) async {
    return identifier == '@labeler.test' ? 'did:plc:resolved' : identifier;
  }

  @override
  Future<void> validateService(String did) async {}

  @override
  Future<LabelerViewDetailed> getServicesDetailed(List<String> dids) async {
    detailedServiceCalls.add(List.of(dids));
    throw UnsupportedError('Detailed label policies must not be fetched');
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not used');
}
