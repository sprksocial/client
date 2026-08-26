import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/auth/data/models/login_result.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/pref_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/providers/preferences_provider.dart';
import 'package:spark/src/features/settings/providers/labeler_settings_controller.dart';

void main() {
  late _FakeAuthRepository authRepository;
  late _FakePrefRepository prefRepository;
  late _FakeSprkRepository sprkRepository;

  setUp(() async {
    await GetIt.I.reset();
    authRepository = _FakeAuthRepository();
    prefRepository = _FakePrefRepository();
    sprkRepository = _FakeSprkRepository(authRepository);
    GetIt.I
      ..registerSingleton<PrefRepository>(prefRepository)
      ..registerSingleton<SprkRepository>(sprkRepository)
      ..registerSingleton<LogService>(LogService());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  ProviderContainer createContainer() =>
      ProviderContainer.test(retry: (retryCount, error) => null);

  test('returns empty preferences when unauthenticated', () async {
    authRepository.isAuthenticated = false;
    final container = createContainer();

    final preferences = await container.read(userPreferencesProvider.future);

    expect(preferences.preferences, isEmpty);
    expect(prefRepository.getCalls, 0);
    expect(sprkRepository.labelerConfigurations, [<String>[]]);
  });

  test('loads preferences when authenticated', () async {
    final expected = _preferences('loaded');
    prefRepository.getResult = expected;
    final container = createContainer();

    final preferences = await container.read(userPreferencesProvider.future);

    expect(preferences, expected);
    expect(prefRepository.getCalls, 1);
    expect(
      container.read(userPreferencesProvider.notifier).currentPreferences,
      expected,
    );
    expect(sprkRepository.labelerConfigurations, [
      ['did:plc:labeler'],
    ]);
  });

  test('exposes an error when initial loading fails', () async {
    final error = StateError('load failed');
    prefRepository.getError = error;
    final container = createContainer();

    await expectLater(
      container.read(userPreferencesProvider.future),
      throwsA(same(error)),
    );

    expect(container.read(userPreferencesProvider).error, same(error));
    expect(
      container.read(userPreferencesProvider.notifier).currentPreferences,
      isNull,
    );
  });

  test('refresh replaces loaded preferences', () async {
    prefRepository.getResult = _preferences('initial');
    final container = createContainer();
    await container.read(userPreferencesProvider.future);
    final notifier = container.read(userPreferencesProvider.notifier);
    final refreshed = _preferences('refreshed');
    prefRepository.getResult = refreshed;

    await notifier.refresh();

    expect(container.read(userPreferencesProvider).value, refreshed);
    expect(prefRepository.getCalls, 2);
    expect(sprkRepository.labelerConfigurations, [
      ['did:plc:labeler'],
      ['did:plc:labeler'],
    ]);
  });

  test('refresh rethrows errors without discarding committed data', () async {
    final initial = _preferences('initial');
    prefRepository.getResult = initial;
    final container = createContainer();
    await container.read(userPreferencesProvider.future);
    final notifier = container.read(userPreferencesProvider.notifier);
    final error = StateError('refresh failed');
    prefRepository.getError = error;

    await expectLater(notifier.refresh(), throwsA(same(error)));

    expect(container.read(userPreferencesProvider).requireValue, initial);
    expect(notifier.currentPreferences, initial);
  });

  test('update persists and publishes preferences', () async {
    prefRepository.getResult = _preferences('initial');
    final container = createContainer();
    await container.read(userPreferencesProvider.future);
    final notifier = container.read(userPreferencesProvider.notifier);
    final updated = _preferences('updated');

    final committed = await notifier.updatePreferences(updated);

    expect(committed, updated);
    expect(prefRepository.putCalls, [updated]);
    expect(container.read(userPreferencesProvider).value, updated);
    expect(sprkRepository.labelerConfigurations, [
      ['did:plc:labeler'],
      ['did:plc:labeler'],
    ]);
  });

  test(
    'adult content updates preserve other preferences and replace prior state',
    () async {
      final initial = Preferences(
        preferences: [
          ..._preferences('preserved').preferences,
          adultContentPreference(enabled: false),
        ],
      );
      prefRepository.getResult = initial;
      final container = createContainer();
      await container.read(userPreferencesProvider.future);
      final notifier = container.read(userPreferencesProvider.notifier);

      await notifier.setAdultContentEnabled(true);

      final updated = container.read(userPreferencesProvider).value!;
      expect(updated.adultContentEnabled, isTrue);
      expect(updated.contentLabelPrefs?.single.label, 'preserved');
      expect(
        updated.preferences.where(
          (preference) => preference.isAdultContentPref,
        ),
        hasLength(1),
      );
      expect(prefRepository.putCalls.single, updated);
    },
  );

  test('global adult label update replaces every scoped copy', () async {
    final initial = Preferences(
      preferences: [
        contentLabelPreference(
          labelerDid: 'did:plc:one',
          label: 'porn',
          visibility: 'warn',
        ),
        contentLabelPreference(
          labelerDid: 'did:plc:two',
          label: 'porn',
          visibility: 'ignore',
        ),
        contentLabelPreference(
          labelerDid: 'did:plc:one',
          label: 'sexual',
          visibility: 'warn',
        ),
      ],
    );
    prefRepository.getResult = initial;
    final container = createContainer();
    await container.read(userPreferencesProvider.future);

    await container
        .read(userPreferencesProvider.notifier)
        .setGlobalLabelPreference('porn', ModerationSetting.hide);

    final prefs = container
        .read(userPreferencesProvider)
        .requireValue
        .contentLabelPrefs!;
    expect(
      prefs.where((preference) => preference.label == 'porn'),
      hasLength(1),
    );
    final porn = prefs.singleWhere((preference) => preference.label == 'porn');
    expect(porn.labelerDid, isNull);
    expect(porn.visibility.toJson(), 'hide');
    expect(
      prefs
          .singleWhere((preference) => preference.label == 'sexual')
          .labelerDid,
      'did:plc:one',
    );
  });

  test('update rethrows errors without discarding committed data', () async {
    final initial = _preferences('initial');
    prefRepository.getResult = initial;
    final container = createContainer();
    await container.read(userPreferencesProvider.future);
    final notifier = container.read(userPreferencesProvider.notifier);
    final updated = _preferences('updated');
    final error = StateError('update failed');
    prefRepository.putError = error;

    await expectLater(
      notifier.updatePreferences(updated),
      throwsA(same(error)),
    );

    expect(prefRepository.putCalls, [updated]);
    expect(container.read(userPreferencesProvider).requireValue, initial);
    expect(notifier.currentPreferences, initial);
  });

  test(
    'updatePreferencesWithFn transforms and persists loaded state',
    () async {
      final initial = _preferences('initial');
      final updated = _preferences('updated');
      prefRepository.getResult = initial;
      final container = createContainer();
      await container.read(userPreferencesProvider.future);
      final notifier = container.read(userPreferencesProvider.notifier);
      Preferences? updaterInput;

      final committed = await notifier.updatePreferencesWithFn((current) {
        updaterInput = current;
        return updated;
      });

      expect(committed, updated);
      expect(updaterInput, initial);
      expect(prefRepository.putCalls, [updated]);
      expect(container.read(userPreferencesProvider).value, updated);
    },
  );

  test(
    'serializes a rapid labeler setting against the latest document',
    () async {
      final initial = Preferences(
        preferences: [
          labelersPreference([LabelerPrefItem(did: 'did:plc:labeler')]),
        ],
      );
      prefRepository.getResult = initial;
      final firstWriteGate = Completer<void>();
      prefRepository.putHandler = (call, preferences) async {
        if (call == 1) await firstWriteGate.future;
      };
      final container = createContainer();
      await container.read(userPreferencesProvider.future);
      final notifier = container.read(userPreferencesProvider.notifier);

      final adultUpdate = notifier.setAdultContentEnabled(true);
      await pumpEventQueue();
      final labelUpdate = container
          .read(labelerSettingsControllerProvider)
          .setLabelPreference('did:plc:labeler', 'custom', Setting.hide);
      await pumpEventQueue();

      expect(prefRepository.putCalls, hasLength(1));
      firstWriteGate.complete();
      await Future.wait([adultUpdate, labelUpdate]);

      expect(prefRepository.putCalls, hasLength(2));
      final persisted = prefRepository.putCalls.last;
      expect(persisted.adultContentEnabled, isTrue);
      final labelPreference = persisted.contentLabelPrefs?.single;
      expect(labelPreference?.labelerDid, 'did:plc:labeler');
      expect(labelPreference?.label, 'custom');
      expect(labelPreference?.visibility.toJson(), 'hide');
    },
  );

  test('continues queued transformations after a failed write', () async {
    final initial = _preferences('initial');
    prefRepository.getResult = initial;
    final firstWriteGate = Completer<void>();
    final error = StateError('first write failed');
    prefRepository.putHandler = (call, preferences) async {
      if (call == 1) {
        await firstWriteGate.future;
        throw error;
      }
    };
    final container = createContainer();
    await container.read(userPreferencesProvider.future);
    final notifier = container.read(userPreferencesProvider.notifier);

    final failedUpdate = notifier.setAdultContentEnabled(true);
    await pumpEventQueue();
    final succeedingUpdate = notifier.setGlobalLabelPreference(
      'porn',
      ModerationSetting.warn,
    );
    firstWriteGate.complete();

    await expectLater(failedUpdate, throwsA(same(error)));
    await succeedingUpdate;

    expect(prefRepository.putCalls, hasLength(2));
    final persisted = prefRepository.putCalls.last;
    expect(persisted.adultContentEnabled, isFalse);
    expect(
      persisted.contentLabelPrefs
          ?.singleWhere((preference) => preference.label == 'porn')
          .visibility
          .toJson(),
      'warn',
    );
    expect(container.read(userPreferencesProvider).requireValue, persisted);
  });

  test('updatePreferencesWithFn rejects unloaded state', () async {
    final initialization = Completer<void>();
    authRepository.initializationComplete = initialization.future;
    authRepository.isAuthenticated = false;
    final container = createContainer();
    final loading = container.read(userPreferencesProvider.future);
    final notifier = container.read(userPreferencesProvider.notifier);

    await expectLater(
      notifier.updatePreferencesWithFn((current) => current),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('not loaded yet'),
        ),
      ),
    );
    expect(prefRepository.putCalls, isEmpty);

    initialization.complete();
    await loading;
  });
}

Preferences _preferences(String label) => Preferences(
  preferences: [
    labelersPreference([LabelerPrefItem(did: 'did:plc:labeler')]),
    contentLabelPreference(
      labelerDid: 'did:plc:labeler',
      label: label,
      visibility: 'warn',
    ),
  ],
);

class _FakePrefRepository implements PrefRepository {
  Preferences getResult = Preferences(preferences: []);
  Object? getError;
  Object? putError;
  Future<void> Function(int call, Preferences preferences)? putHandler;
  int getCalls = 0;
  final List<Preferences> putCalls = [];

  @override
  Future<Preferences> getPreferences() async {
    getCalls++;
    final error = getError;
    if (error != null) throw error;
    return getResult;
  }

  @override
  Future<void> putPreferences(Preferences preferences) async {
    putCalls.add(preferences);
    await putHandler?.call(putCalls.length, preferences);
    final error = putError;
    if (error != null) throw error;
  }
}

class _FakeSprkRepository implements SprkRepository {
  _FakeSprkRepository(this.authRepository);

  @override
  final AuthRepository authRepository;

  final List<List<String>> labelerConfigurations = [];

  @override
  List<String> get labelerDids => const [];

  @override
  void configureLabelers(Iterable<String> labelerDids) {
    labelerConfigurations.add(labelerDids.toList(growable: false));
  }

  @override
  Map<String, String> appViewHeaders(
    String? proxyDid, {
    Iterable<String>? labelerDids,
  }) => const {};

  @override
  Future<T> executeWithRetry<T>(Future<T> Function() apiCall) => apiCall();

  @override
  Never get actor => throw UnsupportedError('actor is not used');

  @override
  String get bskyDid => throw UnsupportedError('bskyDid is not used');

  @override
  String get bskyModDid => throw UnsupportedError('bskyModDid is not used');

  @override
  Never get feed => throw UnsupportedError('feed is not used');

  @override
  Never get graph => throw UnsupportedError('graph is not used');

  @override
  Never get labeler => throw UnsupportedError('labeler is not used');

  @override
  String get modDid => throw UnsupportedError('modDid is not used');

  @override
  Never get notification => throw UnsupportedError('notification is not used');

  @override
  Never get repo => throw UnsupportedError('repo is not used');

  @override
  Never get sound => throw UnsupportedError('sound is not used');

  @override
  String get sprkDid => throw UnsupportedError('sprkDid is not used');

  @override
  Never get story => throw UnsupportedError('story is not used');
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<void> initializationComplete = Future<void>.value();

  @override
  bool isAuthenticated = true;

  @override
  PoptartClient? get atproto => null;

  @override
  String? get did => isAuthenticated ? 'did:plc:me' : null;

  @override
  String? get handle => isAuthenticated ? 'me.test' : null;

  @override
  String? get lastKnownHandle => handle;

  @override
  String? get pdsEndpoint => null;

  @override
  Future<LoginResult> completeOAuth(String callbackUrl) =>
      throw UnsupportedError('completeOAuth is not used');

  @override
  Future<String> initiateOAuth(String handle) =>
      throw UnsupportedError('initiateOAuth is not used');

  @override
  Future<String> initiateOAuthWithoutLoginHint() =>
      throw UnsupportedError('initiateOAuthWithoutLoginHint is not used');

  @override
  Future<void> logout() async {}

  @override
  Future<bool> refreshToken() async => false;

  @override
  Future<bool> validateSession() async => isAuthenticated;
}
