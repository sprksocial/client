import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/storage/preferences/local_storage_interface.dart';
import 'package:spark/src/core/storage/preferences/storage_constants.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/stories/providers/story_auto_delete_provider.dart';
import 'package:spark/src/features/stories/providers/story_repository_provider.dart';

import '../../../../support/in_memory_storage.dart';

void main() {
  group('StoryAutoDeletePref', () {
    test('defaults to enabled and persists later changes', () async {
      final storage = _TrackingStorage();
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
        final storage = _TrackingStorage();
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
      final storage = _TrackingStorage();
      await storage.setBool(StorageKeys.storyAutoDeleteEnabled, false);
      var pageCalls = 0;
      var deleteCalls = 0;
      var refreshCalls = 0;
      final container = _autoDeleteContainer(
        storage: storage,
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
        refresh: () async => refreshCalls += 1,
      );

      await container.read(storyAutoDeleteExecutorProvider.future);

      expect(pageCalls, 0);
      expect(deleteCalls, 0);
      expect(refreshCalls, 0);
    });

    test('does nothing without an authenticated AtProto client', () async {
      final storage = _TrackingStorage();
      await storage.setBool(StorageKeys.storyAutoDeleteEnabled, true);

      for (final auth in <({String? did, bool atprotoAvailable})>[
        (did: null, atprotoAvailable: true),
        (did: 'did:plc:me', atprotoAvailable: false),
      ]) {
        var pageCalls = 0;
        final container = _autoDeleteContainer(
          storage: storage,
          did: auth.did,
          atprotoAvailable: auth.atprotoAvailable,
          repository: _FakeStoryRepository(),
          loadRecordPage: ({required did, cursor}) async {
            pageCalls += 1;
            return const StoryRecordPage(records: []);
          },
        );

        await container.read(storyAutoDeleteExecutorProvider.future);

        expect(pageCalls, 0);
        container.dispose();
      }
    });

    test(
      'uses a strict 24h boundary and continues after delete failures',
      () async {
        final storage = _TrackingStorage();
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
          did: 'did:plc:me',
          atprotoAvailable: true,
          repository: _FakeStoryRepository(),
          now: now,
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
      final storage = _TrackingStorage();
      await storage.setBool(StorageKeys.storyAutoDeleteEnabled, true);
      final now = DateTime.utc(2026, 7, 22, 12);
      var refreshCalls = 0;
      final container = _autoDeleteContainer(
        storage: storage,
        did: 'did:plc:me',
        atprotoAvailable: true,
        repository: _FakeStoryRepository(),
        now: now,
        loadRecordPage: ({required did, cursor}) async => StoryRecordPage(
          records: [
            _record(
              'recent',
              createdAt: now.subtract(const Duration(hours: 2)),
            ),
          ],
        ),
        refresh: () async => refreshCalls += 1,
      );

      await container.read(storyAutoDeleteExecutorProvider.future);

      expect(refreshCalls, 0);
    });
  });
}

ProviderContainer _autoDeleteContainer({
  required LocalStorageInterface storage,
  required String? did,
  required bool atprotoAvailable,
  required _FakeStoryRepository repository,
  Future<StoryRecordPage> Function({required String did, String? cursor})?
  loadRecordPage,
  Future<void> Function(AtUri uri)? deleteRecord,
  DateTime? now,
  Future<void> Function()? refresh,
}) {
  repository.recordPageLoader =
      loadRecordPage ??
      ({required did, cursor}) async => const StoryRecordPage(records: []);
  repository.deleteRecord = deleteRecord ?? (_) async {};

  final container = ProviderContainer(
    overrides: [
      storyAutoDeletePreferencesProvider.overrideWithValue(storage),
      currentDidProvider.overrideWith((ref) => did),
      atprotoProvider.overrideWith(
        (ref) => atprotoAvailable ? PoptartClient.anonymous() : null,
      ),
      storyRepositoryProvider.overrideWithValue(repository),
      storyAutoDeleteLoggerProvider.overrideWithValue(
        SparkLogger(name: 'StoryAutoDeleteExec'),
      ),
      storyAutoDeleteClockProvider.overrideWithValue(
        () => now ?? DateTime.utc(2026, 7, 22, 12),
      ),
      storyManagerRefresherProvider.overrideWithValue(refresh ?? () async {}),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

StoryRecordEntry _record(String id, {required DateTime createdAt}) {
  return StoryRecordEntry(
    uri: AtUri('at://did:plc:me/so.sprk.story.post/$id'),
    value: {'createdAt': createdAt.toIso8601String()},
  );
}

class _FakeStoryRepository implements StoryRepository {
  Future<StoryRecordPage> Function({required String did, String? cursor})?
  recordPageLoader;
  Future<void> Function(AtUri uri)? deleteRecord;

  @override
  Future<StoryRecordPage> listStoryRecords({
    required String did,
    String? cursor,
  }) {
    return recordPageLoader!(did: did, cursor: cursor);
  }

  @override
  Future<void> deleteStoryRecord(AtUri uri) {
    return deleteRecord!(uri);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TrackingStorage extends InMemoryStorage {
  int setBoolCalls = 0;

  @override
  Future<void> setBool(String key, bool value) async {
    setBoolCalls += 1;
    await super.setBool(key, value);
  }
}
