import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart'
    show Feed;
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/bluesky_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/graph_repository.dart';
import 'package:spark/src/features/feed/providers/feed_provider.dart';
import 'package:spark/src/features/feed/providers/feed_state.dart';
import 'package:spark/src/features/follow_import/providers/follow_import_provider.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';
import 'package:spark/src/features/settings/providers/settings_state.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';
import 'package:sprk_poptart/so/sprk/graph/get_follows/output.dart';

void main() {
  test(
    'follow discovery paginates, deduplicates, and keeps only new Spark profiles',
    () async {
      final repository = _FollowDiscoveryRepository();
      final actorRepository = _FakeActorRepository();
      final container = ProviderContainer.test(
        overrides: [
          followImportBlueskyRepositoryProvider.overrideWithValue(repository),
          followImportActorRepositoryProvider.overrideWithValue(
            actorRepository,
          ),
        ],
      );
      addTearDown(container.dispose);

      final matches = await container.read(followImportMatchesProvider.future);

      expect(repository.requestedCursors, [null, 'next']);
      expect(actorRepository.requests, [
        ['did:plc:alex', 'did:plc:blair', 'did:plc:missing'],
      ]);
      expect(matches.map((profile) => profile.did), ['did:plc:alex']);
    },
  );

  test('follow import retains successful writes before a failure', () async {
    final repository = _PartialGraphRepository();
    final container = ProviderContainer.test(
      overrides: [
        followImportGraphRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(followImportControllerProvider.notifier);
    notifier.initializeSelection([
      'did:plc:alex',
      'did:plc:blair',
      'did:plc:later',
    ]);

    expect(await notifier.importSelected(), isFalse);

    expect(repository.batchCalls, [
      ['did:plc:alex', 'did:plc:blair', 'did:plc:later'],
    ]);
    expect(container.read(followImportControllerProvider).importedDids, {
      'did:plc:alex',
    });
    expect(
      container.read(followImportControllerProvider).remainingSelectedDids,
      {'did:plc:blair', 'did:plc:later'},
    );
    expect(
      container.read(followImportControllerProvider).hasPartialFailure,
      isTrue,
    );
  });

  test('follow import owns its lifecycle until the batch completes', () async {
    final repository = _BlockingGraphRepository();
    final controller = _LifecycleFollowImportController();
    final container = ProviderContainer.test(
      overrides: [
        followImportGraphRepositoryProvider.overrideWithValue(repository),
        followImportControllerProvider.overrideWith(() => controller),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(followImportControllerProvider.notifier)
      ..initializeSelection(['did:plc:alex', 'did:plc:blair']);
    final import = notifier.importSelected();
    await repository.started.future;
    await container.pump();

    expect(controller.disposed.isCompleted, isFalse);

    repository.complete();
    expect(await import, isTrue);
    await container.pump();

    expect(repository.batchCalls, [
      ['did:plc:alex', 'did:plc:blair'],
    ]);
    expect(controller.disposed.isCompleted, isTrue);
  });

  test('refreshFollowingFeed reloads the canonical timeline', () async {
    final following = Feed(
      type: 'timeline',
      config: makeSavedFeed(
        id: 'following',
        type: 'timeline',
        value: 'following',
        pinned: true,
      ),
    );
    final discover = Feed(
      type: 'feed',
      config: makeSavedFeed(
        id: 'discover',
        type: 'feed',
        value: 'at://did:plc:spark/so.sprk.feed.generator/discover',
        pinned: true,
      ),
    );
    final feedNotifiers = <String, _RecordingFeedNotifier>{};
    final container = ProviderContainer.test(
      overrides: [
        settingsProvider.overrideWith(
          () => _FakeSettings(
            SettingsState(activeFeed: discover, feeds: [discover, following]),
          ),
        ),
        feedProvider.overrideWith2((feed) {
          final notifier = _RecordingFeedNotifier();
          feedNotifiers[feed.config.id] = notifier;
          return notifier;
        }),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(followImportControllerProvider.notifier)
        .refreshFollowingFeed();

    expect(feedNotifiers['following']?.loadCalls, 1);
    expect(feedNotifiers['discover'], isNull);
  });
}

class _FollowDiscoveryRepository implements BlueskyRepository {
  final List<String?> requestedCursors = [];

  @override
  Future<GraphGetFollowsOutput> getFollows({String? cursor}) async {
    requestedCursors.add(cursor);
    const viewer = ProfileView(did: 'did:plc:viewer', handle: 'viewer.test');
    if (cursor == null) {
      return const GraphGetFollowsOutput(
        subject: viewer,
        cursor: 'next',
        follows: [
          ProfileView(did: 'did:plc:alex', handle: 'alex.test'),
          ProfileView(did: 'did:plc:blair', handle: 'blair.test'),
        ],
      );
    }
    return const GraphGetFollowsOutput(
      subject: viewer,
      follows: [
        ProfileView(did: 'did:plc:blair', handle: 'blair.test'),
        ProfileView(did: 'did:plc:missing', handle: 'missing.test'),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeActorRepository implements ActorRepository {
  final List<List<String>> requests = [];

  @override
  Future<List<ProfileViewDetailed>> getProfiles(
    List<String> dids, {
    bool useBluesky = false,
  }) async {
    requests.add(dids);
    return [
      ProfileViewDetailed(
        did: 'did:plc:alex',
        handle: 'alex.sprk.so',
        displayName: 'Alex',
        indexedAt: DateTime.utc(2026, 8, 31),
      ),
      ProfileViewDetailed(
        did: 'did:plc:blair',
        handle: 'blair.sprk.so',
        displayName: 'Blair',
        indexedAt: DateTime.utc(2026, 8, 31),
        viewer: ViewerState(
          following: AtUri('at://did:plc:viewer/so.sprk.graph.follow/one'),
        ),
      ),
      const ProfileViewDetailed(
        did: 'did:plc:missing',
        handle: 'missing.bsky.social',
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PartialGraphRepository implements GraphRepository {
  final List<List<String>> batchCalls = [];

  @override
  Future<void> ensureFollowingBatch(
    Iterable<String> dids, {
    bool bsky = false,
  }) async {
    batchCalls.add(dids.toList());
    throw const EnsureFollowingBatchException(
      ensuredDids: {'did:plc:alex'},
      failedDid: 'did:plc:blair',
      cause: 'Follow failed',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _BlockingGraphRepository implements GraphRepository {
  final started = Completer<void>();
  final _completion = Completer<void>();
  final List<List<String>> batchCalls = [];

  @override
  Future<void> ensureFollowingBatch(
    Iterable<String> dids, {
    bool bsky = false,
  }) async {
    batchCalls.add(dids.toList());
    started.complete();
    await _completion.future;
  }

  void complete() => _completion.complete();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _LifecycleFollowImportController extends FollowImportController {
  final disposed = Completer<void>();

  @override
  FollowImportSessionState build() {
    ref.onDispose(disposed.complete);
    return const FollowImportSessionState();
  }
}

class _FakeSettings extends Settings {
  _FakeSettings(this.initialState);

  final SettingsState initialState;

  @override
  SettingsState build() => initialState;
}

class _RecordingFeedNotifier extends FeedNotifier {
  int loadCalls = 0;

  @override
  FeedState build(Feed feed) => FeedState(
    active: false,
    loadedPosts: const [],
    index: 0,
    isEndOfNetworkFeed: false,
    cursor: null,
    loadingFirstLoad: false,
    error: false,
    extraInfo: LinkedHashMap(),
  );

  @override
  Future<void> loadAndUpdateFirstLoad() async {
    loadCalls++;
  }
}
