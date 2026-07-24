import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/storage/preferences/local_storage_interface.dart';
import 'package:spark/src/core/storage/preferences/storage_constants.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/stories/providers/stories_by_author.dart';
import 'package:spark/src/features/stories/providers/story_auto_delete_provider.dart';
import 'package:spark/src/features/stories/providers/story_manager_provider.dart';
import 'package:spark/src/features/stories/providers/story_provider_dependencies.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

import '../../../../support/in_memory_storage.dart';

void main() {
  group('StoryManager', () {
    test('returns an authentication error without loading records', () async {
      var pageCalls = 0;
      final repository = _FakeStoryRepository();
      final container = _managerContainer(
        _dependencies(
          did: null,
          atprotoAvailable: true,
          repository: repository,
          loadRecordPage: ({required did, cursor}) async {
            pageCalls += 1;
            return const StoryRecordPage(records: []);
          },
        ),
      );

      final state = await container.read(storyManagerProvider.future);

      expect(state.stories, isEmpty);
      expect(state.error, 'Not authenticated');
      expect(pageCalls, 0);
      expect(repository.storyViewCalls, isEmpty);
    });

    test('returns an AtProto error when the client is unavailable', () async {
      var pageCalls = 0;
      final repository = _FakeStoryRepository();
      final container = _managerContainer(
        _dependencies(
          did: 'did:plc:me',
          atprotoAvailable: false,
          repository: repository,
          loadRecordPage: ({required did, cursor}) async {
            pageCalls += 1;
            return const StoryRecordPage(records: []);
          },
        ),
      );

      final state = await container.read(storyManagerProvider.future);

      expect(state.error, 'AtProto not initialized');
      expect(pageCalls, 0);
      expect(repository.storyViewCalls, isEmpty);
    });

    test(
      'paginates records, hydrates their URIs, and sorts newest first',
      () async {
        final older = _story('older', hour: 8);
        final newer = _story('newer', hour: 10);
        final repository = _FakeStoryRepository()..storyViews = [older, newer];
        final cursors = <String?>[];
        final container = _managerContainer(
          _dependencies(
            did: 'did:plc:me',
            atprotoAvailable: true,
            repository: repository,
            loadRecordPage: ({required did, cursor}) async {
              expect(did, 'did:plc:me');
              cursors.add(cursor);
              return cursor == null
                  ? StoryRecordPage(
                      records: [
                        StoryRecordEntry(uri: older.uri, value: const {}),
                      ],
                      cursor: 'page-2',
                    )
                  : StoryRecordPage(
                      records: [
                        StoryRecordEntry(uri: newer.uri, value: const {}),
                      ],
                    );
            },
          ),
        );

        final state = await container.read(storyManagerProvider.future);

        expect(cursors, [null, 'page-2']);
        expect(repository.storyViewCalls.single, [older.uri, newer.uri]);
        expect(state.stories, [newer, older]);
        expect(state.error, isNull);
      },
    );

    test('returns a state error when loading records fails', () async {
      final container = _managerContainer(
        _dependencies(
          did: 'did:plc:me',
          atprotoAvailable: true,
          repository: _FakeStoryRepository(),
          loadRecordPage: ({required did, cursor}) async {
            throw StateError('records unavailable');
          },
        ),
      );

      final state = await container.read(storyManagerProvider.future);

      expect(state.stories, isEmpty);
      expect(state.error, contains('records unavailable'));
    });

    test('deleteStory removes optimistically and keeps success', () async {
      final story = _story('delete-me', hour: 10);
      final repository = _FakeStoryRepository()..storyViews = [story];
      final deletion = Completer<void>();
      final deletedUris = <AtUri>[];
      final container = _managerContainer(
        _dependencies(
          did: 'did:plc:me',
          atprotoAvailable: true,
          repository: repository,
          loadRecordPage: ({required did, cursor}) async => StoryRecordPage(
            records: [StoryRecordEntry(uri: story.uri, value: const {})],
          ),
          deleteRecord: (uri) {
            deletedUris.add(uri);
            return deletion.future;
          },
        ),
      );
      await container.read(storyManagerProvider.future);

      final delete = container
          .read(storyManagerProvider.notifier)
          .deleteStory(story);

      expect(container.read(storyManagerProvider).value?.stories, isEmpty);
      deletion.complete();
      await delete;
      expect(deletedUris, [story.uri]);
      expect(container.read(storyManagerProvider).value?.stories, isEmpty);
      expect(repository.storyViewCalls, hasLength(1));
    });

    test(
      'deleteStory refreshes and restores the story after failure',
      () async {
        final story = _story('restore-me', hour: 10);
        final repository = _FakeStoryRepository()..storyViews = [story];
        var pageCalls = 0;
        final container = _managerContainer(
          _dependencies(
            did: 'did:plc:me',
            atprotoAvailable: true,
            repository: repository,
            loadRecordPage: ({required did, cursor}) async {
              pageCalls += 1;
              return StoryRecordPage(
                records: [StoryRecordEntry(uri: story.uri, value: const {})],
              );
            },
            deleteRecord: (_) async => throw StateError('delete failed'),
          ),
        );
        await container.read(storyManagerProvider.future);

        await container.read(storyManagerProvider.notifier).deleteStory(story);

        expect(container.read(storyManagerProvider).value?.stories, [story]);
        expect(pageCalls, 2);
        expect(repository.storyViewCalls, hasLength(2));
      },
    );
  });

  group('StoryAutoDeletePref', () {
    test('defaults to enabled and persists later changes', () async {
      final storage = _InMemoryStorage();
      final container = ProviderContainer(
        overrides: [
          storyAutoDeletePreferencesProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      expect(await container.read(storyAutoDeletePrefProvider.future), isTrue);
      expect(await storage.getBool(StorageKeys.storyAutoDeleteEnabled), isTrue);

      await container
          .read(storyAutoDeletePrefProvider.notifier)
          .setEnabled(false);

      expect(container.read(storyAutoDeletePrefProvider).value, isFalse);
      expect(
        await storage.getBool(StorageKeys.storyAutoDeleteEnabled),
        isFalse,
      );
    });

    test(
      'loads an existing disabled preference without overwriting it',
      () async {
        final storage = _InMemoryStorage();
        await storage.setBool(StorageKeys.storyAutoDeleteEnabled, false);
        storage.setBoolCalls = 0;
        final container = ProviderContainer(
          overrides: [
            storyAutoDeletePreferencesProvider.overrideWithValue(storage),
          ],
        );
        addTearDown(container.dispose);

        expect(
          await container.read(storyAutoDeletePrefProvider.future),
          isFalse,
        );
        expect(storage.setBoolCalls, 0);
      },
    );
  });

  group('storyAutoDeleteExecutor', () {
    test('does not inspect or delete stories when disabled', () async {
      final storage = _InMemoryStorage();
      await storage.setBool(StorageKeys.storyAutoDeleteEnabled, false);
      var pageCalls = 0;
      var deleteCalls = 0;
      var refreshCalls = 0;
      final container = _autoDeleteContainer(
        storage: storage,
        dependencies: _dependencies(
          did: 'did:plc:me',
          atprotoAvailable: true,
          repository: _FakeStoryRepository(),
          loadRecordPage: ({required did, cursor}) async {
            pageCalls += 1;
            return const StoryRecordPage(records: []);
          },
          deleteRecord: (_) async {
            deleteCalls += 1;
          },
        ),
        refresh: () async => refreshCalls += 1,
      );

      await container.read(storyAutoDeleteExecutorProvider.future);

      expect(pageCalls, 0);
      expect(deleteCalls, 0);
      expect(refreshCalls, 0);
    });

    test('does nothing without an authenticated AtProto client', () async {
      final storage = _InMemoryStorage();
      await storage.setBool(StorageKeys.storyAutoDeleteEnabled, true);

      for (final auth in <({String? did, bool atprotoAvailable})>[
        (did: null, atprotoAvailable: true),
        (did: 'did:plc:me', atprotoAvailable: false),
      ]) {
        var pageCalls = 0;
        final container = _autoDeleteContainer(
          storage: storage,
          dependencies: _dependencies(
            did: auth.did,
            atprotoAvailable: auth.atprotoAvailable,
            repository: _FakeStoryRepository(),
            loadRecordPage: ({required did, cursor}) async {
              pageCalls += 1;
              return const StoryRecordPage(records: []);
            },
          ),
        );

        await container.read(storyAutoDeleteExecutorProvider.future);

        expect(pageCalls, 0);
        container.dispose();
      }
    });

    test(
      'uses a strict 24h boundary and continues after delete failures',
      () async {
        final storage = _InMemoryStorage();
        await storage.setBool(StorageKeys.storyAutoDeleteEnabled, true);
        final now = DateTime.utc(2026, 7, 22, 12);
        final boundary = _record(
          'boundary',
          createdAt: now.subtract(const Duration(hours: 24)),
        );
        final expiredFailure = _record(
          'expired-failure',
          createdAt: now.subtract(const Duration(hours: 24, seconds: 1)),
        );
        final expiredSuccess = _record(
          'expired-success',
          createdAt: now.subtract(const Duration(days: 2)),
        );
        final malformed = StoryRecordEntry(
          uri: AtUri('at://did:plc:me/so.sprk.story.post/malformed'),
          value: const {'createdAt': 'not-a-date'},
        );
        final pageCursors = <String?>[];
        final deletedUris = <AtUri>[];
        var refreshCalls = 0;
        final container = _autoDeleteContainer(
          storage: storage,
          now: now,
          dependencies: _dependencies(
            did: 'did:plc:me',
            atprotoAvailable: true,
            repository: _FakeStoryRepository(),
            loadRecordPage: ({required did, cursor}) async {
              pageCursors.add(cursor);
              return cursor == null
                  ? StoryRecordPage(
                      records: [boundary, expiredFailure],
                      cursor: 'page-2',
                    )
                  : StoryRecordPage(records: [expiredSuccess, malformed]);
            },
            deleteRecord: (uri) async {
              deletedUris.add(uri);
              if (uri == expiredFailure.uri) {
                throw StateError('individual delete failed');
              }
            },
          ),
          refresh: () async => refreshCalls += 1,
        );

        await container.read(storyAutoDeleteExecutorProvider.future);

        expect(pageCursors, [null, 'page-2']);
        expect(deletedUris, [expiredFailure.uri, expiredSuccess.uri]);
        expect(deletedUris, isNot(contains(boundary.uri)));
        expect(refreshCalls, 1);
      },
    );

    test('does not refresh the manager when no stories are expired', () async {
      final storage = _InMemoryStorage();
      await storage.setBool(StorageKeys.storyAutoDeleteEnabled, true);
      final now = DateTime.utc(2026, 7, 22, 12);
      var refreshCalls = 0;
      final container = _autoDeleteContainer(
        storage: storage,
        now: now,
        dependencies: _dependencies(
          did: 'did:plc:me',
          atprotoAvailable: true,
          repository: _FakeStoryRepository(),
          loadRecordPage: ({required did, cursor}) async => StoryRecordPage(
            records: [
              _record(
                'recent',
                createdAt: now.subtract(const Duration(hours: 2)),
              ),
            ],
          ),
        ),
        refresh: () async => refreshCalls += 1,
      );

      await container.read(storyAutoDeleteExecutorProvider.future);

      expect(refreshCalls, 0);
    });
  });

  test('storiesByAuthor delegates limit and cursor to the timeline', () async {
    final author = ProfileViewBasic(
      did: 'did:plc:author',
      handle: 'author.sprk.so',
    );
    final story = _story('timeline', hour: 10, author: author);
    final repository = _FakeStoryRepository()
      ..timelineResult = (
        storiesByAuthor: {
          author: [story],
        },
        cursor: 'next-page',
      );
    final container = ProviderContainer(
      overrides: [
        storyProviderDependenciesProvider.overrideWithValue(
          _dependencies(
            did: 'did:plc:me',
            atprotoAvailable: true,
            repository: repository,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      storiesByAuthorProvider(limit: 12, cursor: 'cursor-1').future,
    );

    expect(repository.timelineCalls.single, (limit: 12, cursor: 'cursor-1'));
    expect(result.storiesByAuthor, {
      author: [story],
    });
    expect(result.cursor, 'next-page');
  });
}

ProviderContainer _managerContainer(StoryProviderDependencies dependencies) {
  final container = ProviderContainer(
    overrides: [
      storyProviderDependenciesProvider.overrideWithValue(dependencies),
      storyAutoDeleteExecutorProvider.overrideWith((ref) async {}),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

ProviderContainer _autoDeleteContainer({
  required LocalStorageInterface storage,
  required StoryProviderDependencies dependencies,
  DateTime? now,
  Future<void> Function()? refresh,
}) {
  final container = ProviderContainer(
    overrides: [
      storyAutoDeletePreferencesProvider.overrideWithValue(storage),
      storyProviderDependenciesProvider.overrideWithValue(dependencies),
      storyClockProvider.overrideWithValue(
        () => now ?? DateTime.utc(2026, 7, 22, 12),
      ),
      storyManagerRefresherProvider.overrideWithValue(refresh ?? () async {}),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

StoryProviderDependencies _dependencies({
  required String? did,
  required bool atprotoAvailable,
  required _FakeStoryRepository repository,
  StoryRecordPageLoader? loadRecordPage,
  Future<void> Function(AtUri uri)? deleteRecord,
}) {
  return StoryProviderDependencies(
    readDid: () => did,
    readAtprotoAvailable: () => atprotoAvailable,
    loadRecordPage:
        loadRecordPage ??
        ({required did, cursor}) async => const StoryRecordPage(records: []),
    storyRepository: repository,
    deleteRecord: deleteRecord ?? (_) async {},
    loggerFor: (name) => SparkLogger(name: name),
  );
}

StoryRecordEntry _record(String id, {required DateTime createdAt}) {
  return StoryRecordEntry(
    uri: AtUri('at://did:plc:me/so.sprk.story.post/$id'),
    value: {'createdAt': createdAt.toIso8601String()},
  );
}

StoryView _story(String id, {required int hour, ProfileViewBasic? author}) {
  return StoryView(
    uri: AtUri('at://did:plc:me/so.sprk.story.post/$id'),
    cid: 'cid-$id',
    author: author ?? ProfileViewBasic(did: 'did:plc:me', handle: 'me.sprk.so'),
    record: const {},
    indexedAt: DateTime.utc(2026, 7, 22, hour),
  );
}

class _FakeStoryRepository implements StoryRepository {
  List<StoryView> storyViews = [];
  final List<List<AtUri>> storyViewCalls = [];
  ({Map<ProfileViewBasic, List<StoryView>> storiesByAuthor, String? cursor})
  timelineResult = (
    storiesByAuthor: const <ProfileViewBasic, List<StoryView>>{},
    cursor: null,
  );
  final List<({int limit, String? cursor})> timelineCalls = [];

  @override
  Future<List<StoryView>> getStoryViews(List<AtUri> storyUris) async {
    storyViewCalls.add(List<AtUri>.of(storyUris));
    return List<StoryView>.of(storyViews);
  }

  @override
  Future<
    ({String? cursor, Map<ProfileViewBasic, List<StoryView>> storiesByAuthor})
  >
  getStoriesTimeline({int limit = 30, String? cursor}) async {
    timelineCalls.add((limit: limit, cursor: cursor));
    return timelineResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _InMemoryStorage extends InMemoryStorage {
  int setBoolCalls = 0;

  @override
  Future<void> setBool(String key, bool value) async {
    setBoolCalls += 1;
    await super.setBool(key, value);
  }
}
