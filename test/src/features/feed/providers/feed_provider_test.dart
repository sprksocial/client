import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/storage/cache/download_manager_interface.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/feed/providers/feed_provider.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';
import 'package:spark/src/features/settings/providers/settings_state.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

void main() {
  late _FakeFeedRepository feedRepository;
  late _FakeDownloadManager downloadManager;
  late _FakeFeedSettingsGateway settingsGateway;
  late Feed feed;

  setUp(() async {
    await GetIt.I.reset();
    feedRepository = _FakeFeedRepository();
    downloadManager = _FakeDownloadManager();
    settingsGateway = _FakeFeedSettingsGateway();
    feed = _feed('main');
    GetIt.I
      ..registerSingleton<SprkRepository>(_FakeSprkRepository(feedRepository))
      ..registerSingleton<DownloadManagerInterface>(downloadManager)
      ..registerSingleton<LogService>(LogService());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  ProviderContainer createContainer({Feed? activeFeed}) {
    final container = ProviderContainer.test(
      retry: (retryCount, error) => null,
      overrides: [
        settingsProvider.overrideWithValue(
          SettingsState(activeFeed: activeFeed ?? feed),
        ),
        feedSettingsGatewayProvider.overrideWithValue(settingsGateway),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  FeedNotifier readNotifier(ProviderContainer container) {
    container.read(feedProvider(feed));
    return container.read(feedProvider(feed).notifier);
  }

  test(
    'first load publishes posts, cursor state, and download tasks',
    () async {
      final post = _post('first');
      feedRepository.enqueue(_page([post], cursor: 'next'));
      final container = createContainer();
      final notifier = readNotifier(container);

      await notifier.loadAndUpdateFirstLoad();

      final state = container.read(feedProvider(feed));
      expect(state.loadedPosts.map((loadedPost) => loadedPost.uri), [post.uri]);
      expect(state.cursor, 'next');
      expect(state.loadingFirstLoad, isFalse);
      expect(state.error, isFalse);
      expect(state.isEndOfNetworkFeed, isFalse);
      expect(feedRepository.calls, [
        _GetFeedCall(
          feed: feed,
          limit: 10,
          cursor: null,
          labelerDids: const ['did:plc:moderator'],
        ),
      ]);
      expect(downloadManager.tasks.map((task) => task.uri), [post.uri]);
      expect(downloadManager.tasks.single.feed, feed);
    },
  );

  test(
    'first load exposes repository errors and clears loading state',
    () async {
      feedRepository.enqueueError(StateError('feed unavailable'));
      final container = createContainer();
      final notifier = readNotifier(container);

      await notifier.loadAndUpdateFirstLoad();

      final state = container.read(feedProvider(feed));
      expect(state.loadedPosts, isEmpty);
      expect(state.loadingFirstLoad, isFalse);
      expect(state.error, isTrue);
      expect(feedRepository.calls, hasLength(1));
    },
  );

  test('duplicate first-load requests share one network request', () async {
    final response = Completer<FeedView>();
    feedRepository.enqueueFuture(response.future);
    final container = createContainer();
    final notifier = readNotifier(container);

    final firstLoad = notifier.loadAndUpdateFirstLoad();
    await feedRepository.waitForCallCount(1);
    final duplicateLoad = notifier.loadAndUpdateFirstLoad();

    expect(feedRepository.calls, hasLength(1));
    response.complete(_page([_post('only')], cursor: 'next'));
    await Future.wait([firstLoad, duplicateLoad]);
    expect(feedRepository.calls, hasLength(1));
  });

  test(
    'refresh discards stale pagination and starts a fresh request',
    () async {
      final initialPost = _post('initial');
      final stalePost = _post('stale');
      final freshPost = _post('fresh');
      feedRepository.enqueue(_page([initialPost], cursor: 'more'));
      final staleResponse = Completer<FeedView>();
      feedRepository.enqueueFuture(staleResponse.future);
      feedRepository.enqueue(_page([freshPost]));
      final container = createContainer();
      final notifier = readNotifier(container);
      await notifier.loadAndUpdateFirstLoad();

      final pagination = notifier.scrollDown();
      await feedRepository.waitForCallCount(2);
      final refresh = notifier.loadAndUpdateFirstLoad();
      staleResponse.complete(_page([stalePost], cursor: 'stale-next'));
      await Future.wait([pagination, refresh]);

      final state = container.read(feedProvider(feed));
      expect(state.loadedPosts.map((loadedPost) => loadedPost.uri), [
        freshPost.uri,
      ]);
      expect(state.isEndOfNetworkFeed, isTrue);
      expect(feedRepository.calls.map((call) => call.cursor), [
        null,
        'more',
        null,
      ]);
      expect(downloadManager.tasks.map((task) => task.uri), [
        initialPost.uri,
        freshPost.uri,
      ]);
    },
  );

  test('continues past a fully moderated page and marks network end', () async {
    settingsGateway.hiddenLabels.add('blocked');
    final hiddenPost = _post('hidden', label: 'blocked');
    final visiblePost = _post('visible');
    feedRepository
      ..enqueue(_page([hiddenPost], cursor: 'after-hidden'))
      ..enqueue(_page([visiblePost]));
    final container = createContainer();
    final notifier = readNotifier(container);

    await notifier.loadAndUpdateFirstLoad();

    final state = container.read(feedProvider(feed));
    expect(state.loadedPosts.map((loadedPost) => loadedPost.uri), [
      visiblePost.uri,
    ]);
    expect(state.cursor, isNull);
    expect(state.isEndOfNetworkFeed, isTrue);
    expect(feedRepository.calls.map((call) => call.cursor), [
      null,
      'after-hidden',
    ]);
    expect(downloadManager.tasks.map((task) => task.uri), [visiblePost.uri]);
  });

  test(
    'moderation removes hidden posts while retaining label metadata',
    () async {
      settingsGateway.hiddenLabels.add('blocked');
      final hiddenPost = _post('hidden', label: 'blocked');
      final visiblePost = _post('visible', label: 'allowed');
      feedRepository.enqueue(_page([hiddenPost, visiblePost]));
      final container = createContainer();
      final notifier = readNotifier(container);

      await notifier.loadAndUpdateFirstLoad();

      final state = container.read(feedProvider(feed));
      expect(state.loadedPosts, [visiblePost]);
      expect(state.extraInfo.keys, [hiddenPost.uri, visiblePost.uri]);
      expect(
        state.extraInfo[hiddenPost.uri]!.postLabels.map((label) => label.val),
        ['blocked'],
      );
      expect(downloadManager.tasks.map((task) => task.uri), [visiblePost.uri]);
    },
  );

  test('an empty network page ends the feed', () async {
    feedRepository.enqueue(_page(const []));
    final container = createContainer();
    final notifier = readNotifier(container);

    await notifier.loadAndUpdateFirstLoad();

    final state = container.read(feedProvider(feed));
    expect(state.loadedPosts, isEmpty);
    expect(state.isEndOfNetworkFeed, isTrue);
    expect(state.loadingFirstLoad, isFalse);
  });

  test(
    'replace and remove preserve post order, metadata, and valid index',
    () async {
      final first = _post('first', label: 'allowed');
      final second = _post('second', label: 'allowed');
      final third = _post('third', label: 'allowed');
      feedRepository.enqueue(_page([first, second, third]));
      final container = createContainer();
      final notifier = readNotifier(container);
      await notifier.loadAndUpdateFirstLoad();
      await notifier.setIndex(2);
      final updatedSecond = second.copyWith(
        record: const {r'$type': 'so.sprk.feed.post', 'text': 'updated'},
      );

      notifier.replacePost(updatedSecond);

      var state = container.read(feedProvider(feed));
      expect(state.loadedPosts, [first, updatedSecond, third]);
      expect(state.index, 2);

      notifier.removePostAtIndex(0);
      state = container.read(feedProvider(feed));
      expect(state.loadedPosts, [updatedSecond, third]);
      expect(state.index, 1);
      expect(state.extraInfo.containsKey(first.uri), isFalse);

      notifier.removePostAtIndex(1);
      state = container.read(feedProvider(feed));
      expect(state.loadedPosts, [updatedSecond]);
      expect(state.index, 0);
      expect(state.extraInfo.containsKey(third.uri), isFalse);

      notifier.removePostAtIndex(0);
      state = container.read(feedProvider(feed));
      expect(state.loadedPosts, isEmpty);
      expect(state.index, 0);
      expect(state.extraInfo, isEmpty);
    },
  );

  test('activating a feed updates state and the download manager', () async {
    final container = createContainer(activeFeed: _feed('other'));
    final notifier = readNotifier(container);
    expect(container.read(feedProvider(feed)).active, isFalse);

    await notifier.setActive(false);
    expect(downloadManager.activeFeeds, isEmpty);

    await notifier.setActive(true);
    expect(container.read(feedProvider(feed)).active, isTrue);
    expect(downloadManager.activeFeeds, [feed]);
  });
}

final _author = ProfileViewBasic(
  did: 'did:plc:author',
  handle: 'author.sprk.so',
);
final _indexedAt = DateTime.utc(2026, 7, 1, 12);

Feed _feed(String id) => Feed(
  type: 'feed',
  config: makeSavedFeed(
    type: 'feed',
    value: 'at://did:plc:feed/so.sprk.feed.generator/$id',
    pinned: true,
    id: id,
  ),
);

PostView _post(String id, {String? label}) {
  final uri = AtUri.parse('at://did:plc:author/so.sprk.feed.post/$id');
  return PostView(
    uri: uri,
    cid: 'cid-$id',
    author: _author,
    record: {r'$type': 'so.sprk.feed.post', 'text': id},
    indexedAt: _indexedAt,
    labels: label == null
        ? null
        : [
            Label(
              src: 'did:plc:moderator',
              uri: uri.toString(),
              val: label,
              cts: _indexedAt,
            ),
          ],
  );
}

FeedView _page(List<PostView> posts, {String? cursor}) {
  return FeedView(
    cursor: cursor,
    feed: posts.map((post) => FeedViewPost(post: post)).toList(),
  );
}

class _FakeFeedRepository implements FeedRepository {
  final List<Future<FeedView> Function()> _responses = [];
  final List<_GetFeedCall> calls = [];
  final List<Completer<void>> _callWaiters = [];

  void enqueue(FeedView response) {
    _responses.add(() async => response);
  }

  void enqueueFuture(Future<FeedView> response) {
    _responses.add(() => response);
  }

  void enqueueError(Object error) {
    _responses.add(() async => throw error);
  }

  Future<void> waitForCallCount(int count) async {
    while (calls.length < count) {
      final waiter = Completer<void>();
      _callWaiters.add(waiter);
      await waiter.future;
    }
  }

  @override
  Future<FeedView> getFeed(
    Feed feed, {
    int limit = 20,
    String? cursor,
    List<String>? labelerDids,
  }) {
    calls.add(
      _GetFeedCall(
        feed: feed,
        limit: limit,
        cursor: cursor,
        labelerDids: labelerDids,
      ),
    );
    for (final waiter in _callWaiters) {
      if (!waiter.isCompleted) waiter.complete();
    }
    _callWaiters.clear();
    if (_responses.isEmpty) {
      throw StateError('No feed response queued');
    }
    return _responses.removeAt(0)();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFeedSettingsGateway implements FeedSettingsGateway {
  final Set<String> hiddenLabels = {};

  @override
  Future<List<String>> getLabelers() async => const ['did:plc:moderator'];

  @override
  Future<LabelPreference> getLabelPreference(String value) async {
    return LabelPreference(
      value: value,
      blurs: Blurs.none,
      severity: Severity.none,
      defaultSetting: Setting.ignore,
      setting: hiddenLabels.contains(value) ? Setting.hide : Setting.ignore,
      adultOnly: false,
    );
  }
}

class _FakeSprkRepository implements SprkRepository {
  _FakeSprkRepository(this.feedRepository);

  final FeedRepository feedRepository;

  @override
  FeedRepository get feed => feedRepository;

  @override
  String get modDid => 'did:plc:moderator#service';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDownloadManager implements DownloadManagerInterface {
  final List<DownloadTask> tasks = [];
  final List<Feed> activeFeeds = [];

  @override
  bool get poolFull => false;

  @override
  void setActiveFeed(Feed feed) => activeFeeds.add(feed);

  @override
  void submitTask(DownloadTask task) => tasks.add(task);

  @override
  Future<void> dispose() async {}
}

class _GetFeedCall {
  const _GetFeedCall({
    required this.feed,
    required this.limit,
    required this.cursor,
    required this.labelerDids,
  });

  final Feed feed;
  final int limit;
  final String? cursor;
  final List<String>? labelerDids;

  @override
  bool operator ==(Object other) {
    return other is _GetFeedCall &&
        other.feed == feed &&
        other.limit == limit &&
        other.cursor == cursor &&
        _listEquals(other.labelerDids, labelerDids);
  }

  @override
  int get hashCode =>
      Object.hash(feed, limit, cursor, Object.hashAll(labelerDids ?? []));
}

bool _listEquals(List<String>? first, List<String>? second) {
  if (identical(first, second)) return true;
  if (first == null || second == null || first.length != second.length) {
    return false;
  }
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}
