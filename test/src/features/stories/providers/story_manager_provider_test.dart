import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/stories/providers/story_auto_delete_provider.dart';
import 'package:spark/src/features/stories/providers/story_manager_provider.dart';
import 'package:spark/src/features/stories/providers/story_repository_provider.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

final _testCurrentDidProvider = StateProvider<String?>((ref) => null);
final _testAtprotoProvider = StateProvider<PoptartClient?>((ref) => null);

void main() {
  test('reloads records when the authenticated user changes', () async {
    final repository = _FakeStoryRepository();
    final loadedDids = <String>[];
    repository.recordPageLoader = ({required did, cursor}) async {
      loadedDids.add(did);
      return const StoryRecordPage(records: []);
    };
    final container = ProviderContainer(
      overrides: [
        currentDidProvider.overrideWith(
          (ref) => ref.watch(_testCurrentDidProvider),
        ),
        atprotoProvider.overrideWith((ref) => ref.watch(_testAtprotoProvider)),
        storyRepositoryProvider.overrideWithValue(repository),
        storyManagerLoggerProvider.overrideWithValue(
          SparkLogger(name: 'StoryManager'),
        ),
        storyAutoDeleteExecutorProvider.overrideWith((ref) async {}),
      ],
    );
    addTearDown(container.dispose);

    container.read(_testCurrentDidProvider.notifier).state = 'did:plc:first';
    container.read(_testAtprotoProvider.notifier).state =
        PoptartClient.anonymous();
    await container.read(storyManagerProvider.future);

    container.read(_testCurrentDidProvider.notifier).state = 'did:plc:second';
    await container.read(storyManagerProvider.future);

    expect(loadedDids, ['did:plc:first', 'did:plc:second']);
  });

  group('StoryManager', () {
    test('returns an authentication error without loading records', () async {
      var pageCalls = 0;
      final repository = _FakeStoryRepository();
      final container = _managerContainer(
        did: null,
        atprotoAvailable: true,
        repository: repository,
        loadRecordPage: ({required did, cursor}) async {
          pageCalls += 1;
          return const StoryRecordPage(records: []);
        },
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
        did: 'did:plc:me',
        atprotoAvailable: false,
        repository: repository,
        loadRecordPage: ({required did, cursor}) async {
          pageCalls += 1;
          return const StoryRecordPage(records: []);
        },
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
        did: 'did:plc:me',
        atprotoAvailable: true,
        repository: _FakeStoryRepository(),
        loadRecordPage: ({required did, cursor}) async {
          throw StateError('records unavailable');
        },
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
        );
        await container.read(storyManagerProvider.future);

        await container.read(storyManagerProvider.notifier).deleteStory(story);

        expect(container.read(storyManagerProvider).value?.stories, [story]);
        expect(pageCalls, 2);
        expect(repository.storyViewCalls, hasLength(2));
      },
    );
  });
}

ProviderContainer _managerContainer({
  required String? did,
  required bool atprotoAvailable,
  required _FakeStoryRepository repository,
  Future<StoryRecordPage> Function({required String did, String? cursor})?
  loadRecordPage,
  Future<void> Function(AtUri uri)? deleteRecord,
}) {
  repository.recordPageLoader =
      loadRecordPage ??
      ({required did, cursor}) async => const StoryRecordPage(records: []);
  repository.deleteRecord = deleteRecord ?? (_) async {};

  final container = ProviderContainer(
    overrides: [
      currentDidProvider.overrideWith((ref) => did),
      atprotoProvider.overrideWith(
        (ref) => atprotoAvailable ? PoptartClient.anonymous() : null,
      ),
      storyRepositoryProvider.overrideWithValue(repository),
      storyManagerLoggerProvider.overrideWithValue(
        SparkLogger(name: 'StoryManager'),
      ),
      storyAutoDeleteExecutorProvider.overrideWith((ref) async {}),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

StoryView _story(String id, {required int hour}) {
  return StoryView(
    uri: AtUri('at://did:plc:me/so.sprk.story.post/$id'),
    cid: 'cid-$id',
    author: ProfileViewBasic(did: 'did:plc:me', handle: 'me.sprk.so'),
    record: const {},
    indexedAt: DateTime.utc(2026, 7, 22, hour),
  );
}

class _FakeStoryRepository implements StoryRepository {
  Future<StoryRecordPage> Function({required String did, String? cursor})?
  recordPageLoader;
  Future<void> Function(AtUri uri)? deleteRecord;
  List<StoryView> storyViews = [];
  final List<List<AtUri>> storyViewCalls = [];

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
  Future<List<StoryView>> getStoryViews(List<AtUri> storyUris) async {
    storyViewCalls.add(List<AtUri>.of(storyUris));
    return List<StoryView>.of(storyViews);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
