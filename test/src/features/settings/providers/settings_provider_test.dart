import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spark/src/core/auth/data/models/login_result.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/storage/preferences/storage_manager.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/settings/providers/preferences_provider.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

void main() {
  late _FakeAuthRepository authRepository;
  late _FakeFeedRepository feedRepository;
  late _PreferencesController preferencesController;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await StorageManager.instance.init();
  });

  setUp(() async {
    await GetIt.I.reset();
    await StorageManager.instance.preferences.clear();
    authRepository = _FakeAuthRepository();
    feedRepository = _FakeFeedRepository();
    preferencesController = _PreferencesController();
    GetIt.I
      ..registerSingleton<SprkRepository>(
        _FakeSprkRepository(authRepository, feedRepository),
      )
      ..registerSingleton<StorageManager>(StorageManager.instance)
      ..registerSingleton<LogService>(LogService());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  ProviderContainer createContainer() => ProviderContainer.test(
    overrides: [
      userPreferencesProvider.overrideWith(
        () => _FakeUserPreferences(preferencesController),
      ),
    ],
    retry: (retryCount, error) => null,
  );

  Future<Settings> loadSettings(ProviderContainer container) async {
    final notifier = container.read(settingsProvider.notifier);
    await notifier.loadSettings();
    return notifier;
  }

  group('loading', () {
    test('guards concurrent and repeated loads', () async {
      final initialization = Completer<void>();
      authRepository.initializationComplete = initialization.future;
      preferencesController.current = _feedPreferences([
        _savedFeed('following', type: 'timeline', value: 'following'),
        _savedFeed('discover'),
      ]);
      final container = createContainer();
      final notifier = container.read(settingsProvider.notifier);

      final firstLoad = notifier.loadSettings();
      final duplicateLoad = notifier.loadSettings();
      initialization.complete();
      await Future.wait([firstLoad, duplicateLoad]);
      await notifier.loadSettings();

      expect(feedRepository.loadCalls, hasLength(1));
      expect(container.read(settingsProvider).feeds, hasLength(2));
    });

    test('leaves temporary defaults when unauthenticated', () async {
      authRepository.isAuthenticated = false;
      preferencesController.current = _feedPreferences([
        _savedFeed('discover'),
      ]);
      final container = createContainer();

      await loadSettings(container);

      final state = container.read(settingsProvider);
      expect(state.activeFeed.config.value, 'following');
      expect(state.feeds, isEmpty);
      expect(feedRepository.loadCalls, isEmpty);
      expect(preferencesController.writes, isEmpty);
    });

    test('creates and persists defaults when no feeds are saved', () async {
      preferencesController.current = Preferences(preferences: []);
      final container = createContainer();

      await loadSettings(container);

      final written = preferencesController.writes.single;
      expect(written.savedFeeds, hasLength(3));
      expect(written.labelers?.map((labeler) => labeler.did), ['did:plc:mod']);
      final state = container.read(settingsProvider);
      expect(state.feeds, hasLength(3));
      expect(state.activeFeed.config.value, 'following');
      final stored = await StorageManager.instance.preferences
          .getObject<Map<String, dynamic>>('active_feed_did:plc:me');
      expect(Feed.fromJson(stored!).config.value, 'following');
    });

    test('restores a still-pinned active feed from storage', () async {
      final following = _savedFeed(
        'following',
        type: 'timeline',
        value: 'following',
      );
      final discover = _savedFeed('discover');
      preferencesController.current = _feedPreferences([following, discover]);
      await StorageManager.instance.preferences.setObject(
        'active_feed_did:plc:me',
        Feed(type: 'feed', config: discover).toJson(),
      );
      final container = createContainer();

      await loadSettings(container);

      expect(container.read(settingsProvider).activeFeed.config.id, 'discover');
    });

    test(
      'falls back to the first pinned feed when saved active is stale',
      () async {
        final following = _savedFeed(
          'following',
          type: 'timeline',
          value: 'following',
        );
        preferencesController.current = _feedPreferences([
          following,
          _savedFeed('discover'),
        ]);
        await StorageManager.instance.preferences.setObject(
          'active_feed_did:plc:me',
          Feed(type: 'feed', config: _savedFeed('removed')).toJson(),
        );
        final container = createContainer();

        await loadSettings(container);

        expect(
          container.read(settingsProvider).activeFeed.config.id,
          'following',
        );
      },
    );
  });

  group('saved feed mutations', () {
    test('addFeed pins, persists, and publishes the added feed', () async {
      final following = _savedFeed(
        'following',
        type: 'timeline',
        value: 'following',
      );
      preferencesController.current = _feedPreferences([following]);
      final container = createContainer();
      final notifier = await loadSettings(container);
      final added = Feed(
        type: 'feed',
        config: _savedFeed('discover', pinned: false),
      );

      await notifier.addFeed(added);

      final savedFeeds = preferencesController.writes.single.savedFeeds!;
      expect(savedFeeds.map((feed) => feed.id), ['following', 'discover']);
      expect(savedFeeds.last.pinned, isTrue);
      expect(
        container.read(settingsProvider).feeds.map((feed) => feed.config.id),
        ['following', 'discover'],
      );
    });

    test('removeFeed persists removal and protects Following', () async {
      final following = _savedFeed(
        'following',
        type: 'timeline',
        value: 'following',
      );
      final discover = _savedFeed('discover');
      preferencesController.current = _feedPreferences([following, discover]);
      final container = createContainer();
      final notifier = await loadSettings(container);

      await notifier.removeFeed(Feed(type: 'feed', config: discover));

      expect(
        preferencesController.writes.single.savedFeeds?.map((feed) => feed.id),
        ['following'],
      );
      expect(container.read(settingsProvider).feeds, hasLength(1));
      await expectLater(
        notifier.removeFeed(Feed(type: 'timeline', config: following)),
        throwsA(isA<Exception>()),
      );
      expect(preferencesController.writes, hasLength(1));
    });

    test('reorderFeed persists and publishes the requested order', () async {
      preferencesController.current = _feedPreferences([
        _savedFeed('a'),
        _savedFeed('b'),
        _savedFeed('c'),
      ]);
      final container = createContainer();
      final notifier = await loadSettings(container);

      await notifier.reorderFeed(movedFeedId: 'c', beforeFeedId: 'a');

      expect(
        preferencesController.writes.single.savedFeeds?.map((feed) => feed.id),
        ['c', 'a', 'b'],
      );
      expect(
        container.read(settingsProvider).feeds.map((feed) => feed.config.id),
        ['c', 'a', 'b'],
      );
    });

    test('reorderFeed rejects unknown feed ids without persisting', () async {
      preferencesController.current = _feedPreferences([
        _savedFeed('a'),
        _savedFeed('b'),
      ]);
      final container = createContainer();
      final notifier = await loadSettings(container);

      await expectLater(
        notifier.reorderFeed(movedFeedId: 'missing', beforeFeedId: 'a'),
        throwsA(isA<StateError>()),
      );

      expect(preferencesController.writes, isEmpty);
      expect(
        container.read(settingsProvider).feeds.map((feed) => feed.config.id),
        ['a', 'b'],
      );
    });

    test('setFeedPinned persists and publishes the new pin state', () async {
      final first = _savedFeed('a');
      final second = _savedFeed('b');
      preferencesController.current = _feedPreferences([first, second]);
      final container = createContainer();
      final notifier = await loadSettings(container);

      await notifier.setFeedPinned(
        Feed(type: 'feed', config: second),
        pinned: false,
      );

      final savedFeeds = preferencesController.writes.single.savedFeeds!;
      expect(savedFeeds.first.pinned, isTrue);
      expect(savedFeeds.last.pinned, isFalse);
      expect(
        container.read(settingsProvider).feeds.last.config.pinned,
        isFalse,
      );
    });

    test('does not change feed state when refresh fails', () async {
      preferencesController.current = _feedPreferences([_savedFeed('a')]);
      final container = createContainer();
      final notifier = await loadSettings(container);
      final before = container.read(settingsProvider);
      preferencesController.refreshError = StateError('refresh failed');

      await expectLater(
        notifier.addFeed(Feed(type: 'feed', config: _savedFeed('b'))),
        throwsA(isA<SavedFeedsUnavailableException>()),
      );

      expect(container.read(settingsProvider), before);
      expect(preferencesController.writes, isEmpty);
    });

    test('does not change feed state when persistence fails', () async {
      preferencesController.current = _feedPreferences([_savedFeed('a')]);
      final container = createContainer();
      final notifier = await loadSettings(container);
      final before = container.read(settingsProvider);
      final error = StateError('write failed');
      preferencesController.updateError = error;

      await expectLater(
        notifier.addFeed(Feed(type: 'feed', config: _savedFeed('b'))),
        throwsA(same(error)),
      );

      expect(container.read(settingsProvider), before);
      expect(preferencesController.writes, hasLength(1));
    });
  });

  test('setActiveFeed updates state and per-user storage', () async {
    final following = _savedFeed(
      'following',
      type: 'timeline',
      value: 'following',
    );
    final discover = _savedFeed('discover');
    preferencesController.current = _feedPreferences([following, discover]);
    final container = createContainer();
    final notifier = await loadSettings(container);
    final selected = Feed(type: 'feed', config: discover);

    await notifier.setActiveFeed(selected);

    expect(container.read(settingsProvider).activeFeed, selected);
    final stored = await StorageManager.instance.preferences
        .getObject<Map<String, dynamic>>('active_feed_did:plc:me');
    expect(Feed.fromJson(stored!), selected);
  });

  group('labeler preferences', () {
    test('maps stored visibility into label policy state', () async {
      preferencesController.current = Preferences(
        preferences: [
          savedFeedsPreference([_savedFeed('following')]),
          contentLabelPreference(
            labelerDid: 'did:plc:labeler',
            label: 'nsfl',
            visibility: 'warn',
          ),
        ],
      );
      final container = createContainer();
      final notifier = await loadSettings(container);

      final preference = await notifier.getLabelPreference('nsfl');

      expect(preference.setting, Setting.warn);
      expect(preference.blurs, Blurs.media);
      expect(preference.severity, Severity.alert);
      expect(preference.adultOnly, isTrue);
    });

    test(
      'setLabelPreference updates the target and preserves others',
      () async {
        preferencesController.current = Preferences(
          preferences: [
            savedFeedsPreference([_savedFeed('following')]),
            contentLabelPreference(
              labelerDid: 'did:plc:labeler',
              label: 'gore',
              visibility: 'warn',
            ),
            contentLabelPreference(
              labelerDid: 'did:plc:labeler',
              label: 'nudity',
              visibility: 'ignore',
            ),
          ],
        );
        final container = createContainer();
        final notifier = await loadSettings(container);

        await notifier.setLabelPreference(
          'gore',
          Blurs.content,
          Severity.alert,
          false,
          Setting.hide,
        );

        final written = preferencesController.writes.single.contentLabelPrefs!;
        expect(
          written.firstWhere((pref) => pref.label == 'gore').visibilityValue,
          'hide',
        );
        expect(
          written.firstWhere((pref) => pref.label == 'nudity').visibilityValue,
          'ignore',
        );
      },
    );

    test('labeler-specific update changes only the matching policy', () async {
      preferencesController.current = Preferences(
        preferences: [
          savedFeedsPreference([_savedFeed('following')]),
          contentLabelPreference(
            labelerDid: 'did:plc:a',
            label: 'custom',
            visibility: 'warn',
          ),
          contentLabelPreference(
            labelerDid: 'did:plc:b',
            label: 'custom',
            visibility: 'ignore',
          ),
        ],
      );
      final container = createContainer();
      final notifier = await loadSettings(container);

      await notifier.setLabelPreferenceForLabeler(
        'did:plc:a',
        'custom',
        Blurs.content,
        Severity.alert,
        false,
        Setting.hide,
      );

      final written = preferencesController.writes.single.contentLabelPrefs!;
      expect(
        written
            .firstWhere((pref) => pref.labelerDid == 'did:plc:a')
            .visibilityValue,
        'hide',
      );
      expect(
        written
            .firstWhere((pref) => pref.labelerDid == 'did:plc:b')
            .visibilityValue,
        'ignore',
      );
    });

    test(
      'adds and removes labelers but protects the default labeler',
      () async {
        preferencesController.current = Preferences(
          preferences: [
            savedFeedsPreference([_savedFeed('following')]),
            labelersPreference([LabelerPrefItem(did: 'did:plc:mod')]),
          ],
        );
        final container = createContainer();
        final notifier = await loadSettings(container);

        await notifier.addLabeler('did:plc:other');
        expect(
          preferencesController.current.labelers?.map((item) => item.did),
          ['did:plc:mod', 'did:plc:other'],
        );

        await notifier.removeLabeler('did:plc:other');
        expect(
          preferencesController.current.labelers?.map((item) => item.did),
          ['did:plc:mod'],
        );
        await expectLater(
          notifier.removeLabeler('did:plc:mod'),
          throwsA(isA<Exception>()),
        );
        expect(preferencesController.writes, hasLength(2));
      },
    );
  });
}

SavedFeed _savedFeed(
  String id, {
  String type = 'feed',
  String? value,
  bool pinned = true,
}) => makeSavedFeed(
  id: id,
  type: type,
  value: value ?? 'at://did:plc:$id/app.bsky.feed.generator/$id',
  pinned: pinned,
);

Preferences _feedPreferences(List<SavedFeed> feeds) =>
    Preferences(preferences: [savedFeedsPreference(feeds)]);

class _PreferencesController {
  Preferences current = Preferences(preferences: []);
  Preferences? refreshResult;
  Object? refreshError;
  Object? updateError;
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
    final error = controller.refreshError;
    if (error != null) {
      state = AsyncValue.error(error, StackTrace.current);
      throw error;
    }
    final refreshed = controller.refreshResult ?? controller.current;
    controller.current = refreshed;
    state = AsyncValue.data(refreshed);
  }

  @override
  Future<void> updatePreferences(Preferences preferences) async {
    controller.writes.add(preferences);
    final error = controller.updateError;
    if (error != null) {
      state = AsyncValue.error(error, StackTrace.current);
      throw error;
    }
    controller.current = preferences;
    state = AsyncValue.data(preferences);
  }
}

class _FakeFeedRepository implements FeedRepository {
  final List<List<SavedFeed>> loadCalls = [];
  Object? loadError;

  @override
  Future<List<Feed>> getFeedsFromSavedFeeds(List<SavedFeed> savedFeeds) async {
    loadCalls.add(List<SavedFeed>.of(savedFeeds));
    final error = loadError;
    if (error != null) throw error;
    return savedFeeds
        .map((savedFeed) => Feed(type: savedFeed.typeValue, config: savedFeed))
        .toList();
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not used');
}

class _FakeSprkRepository implements SprkRepository {
  _FakeSprkRepository(this.authRepository, this.feed);

  @override
  final AuthRepository authRepository;

  @override
  final FeedRepository feed;

  @override
  String get modDid => 'did:plc:mod#spark-labeler';

  @override
  String get sprkDid => 'did:web:sprk.so#spark-appview';

  @override
  Future<T> executeWithRetry<T>(Future<T> Function() apiCall) => apiCall();

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not used');
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
