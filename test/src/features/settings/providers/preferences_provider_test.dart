import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/auth/data/models/login_result.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/pref_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/settings/providers/preferences_provider.dart';

void main() {
  late _FakeAuthRepository authRepository;
  late _FakePrefRepository prefRepository;

  setUp(() async {
    await GetIt.I.reset();
    authRepository = _FakeAuthRepository();
    prefRepository = _FakePrefRepository();
    GetIt.I
      ..registerSingleton<PrefRepository>(prefRepository)
      ..registerSingleton<SprkRepository>(_FakeSprkRepository(authRepository))
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
  });

  test('refresh exposes and rethrows repository errors', () async {
    prefRepository.getResult = _preferences('initial');
    final container = createContainer();
    await container.read(userPreferencesProvider.future);
    final notifier = container.read(userPreferencesProvider.notifier);
    final error = StateError('refresh failed');
    prefRepository.getError = error;

    await expectLater(notifier.refresh(), throwsA(same(error)));

    expect(container.read(userPreferencesProvider).error, same(error));
  });

  test('update persists and publishes preferences', () async {
    prefRepository.getResult = _preferences('initial');
    final container = createContainer();
    await container.read(userPreferencesProvider.future);
    final notifier = container.read(userPreferencesProvider.notifier);
    final updated = _preferences('updated');

    await notifier.updatePreferences(updated);

    expect(prefRepository.putCalls, [updated]);
    expect(container.read(userPreferencesProvider).value, updated);
  });

  test('update exposes and rethrows repository errors', () async {
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
    expect(container.read(userPreferencesProvider).error, same(error));
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

      await notifier.updatePreferencesWithFn((current) {
        updaterInput = current;
        return updated;
      });

      expect(updaterInput, initial);
      expect(prefRepository.putCalls, [updated]);
      expect(container.read(userPreferencesProvider).value, updated);
    },
  );

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
    final error = putError;
    if (error != null) throw error;
  }
}

class _FakeSprkRepository implements SprkRepository {
  _FakeSprkRepository(this.authRepository);

  @override
  final AuthRepository authRepository;

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
