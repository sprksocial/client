import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart'
    hide ViewerState;
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/graph_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_level.dart';
import 'package:spark/src/core/utils/logging/log_output.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/search/providers/actor_typeahead_provider.dart';
import 'package:spark/src/features/search/providers/post_search_provider.dart';
import 'package:spark/src/features/search/providers/search_debounce_scheduler.dart';
import 'package:spark/src/features/search/providers/search_provider.dart';
import 'package:spark/src/features/search/providers/suggested_feeds_provider.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';
import 'package:sprk_poptart/so/sprk/actor/search_actors/output.dart';
import 'package:sprk_poptart/so/sprk/actor/search_actors_typeahead/output.dart';

void main() {
  late _FakeActorRepository actorRepository;
  late _FakeGraphRepository graphRepository;
  late _FakeAuthRepository authRepository;
  late _FakeFeedRepository feedRepository;
  late _FakeScheduler scheduler;
  late _RecordingLogOutput logOutput;

  setUp(() async {
    await GetIt.I.reset();
    actorRepository = _FakeActorRepository();
    graphRepository = _FakeGraphRepository();
    authRepository = _FakeAuthRepository();
    feedRepository = _FakeFeedRepository();
    scheduler = _FakeScheduler();
    logOutput = _RecordingLogOutput();
    GetIt.I
      ..registerSingleton<LogService>(_TestLogService(logOutput))
      ..registerSingleton<ActorRepository>(actorRepository)
      ..registerSingleton<GraphRepository>(graphRepository)
      ..registerSingleton<AuthRepository>(authRepository)
      ..registerSingleton<SprkRepository>(_FakeSprkRepository(feedRepository));
  });

  tearDown(() async => GetIt.I.reset());

  ProviderContainer container({List<Override> overrides = const []}) {
    final result = ProviderContainer.test(
      retry: (retryCount, error) => null,
      overrides: [
        searchDebounceSchedulerProvider.overrideWithValue(scheduler.schedule),
        ...overrides,
      ],
    );
    addTearDown(result.dispose);
    return result;
  }

  group('ActorTypeahead', () {
    test('trims queries, cancels debounce, and publishes success', () async {
      actorRepository.typeaheadResponses.add(
        () async => ActorSearchActorsTypeaheadOutput(actors: [_basic('bob')]),
      );
      final scope = container();
      final subscription = scope.listen(
        actorTypeaheadProvider,
        (previous, next) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final notifier = scope.read(actorTypeaheadProvider.notifier);

      notifier.updateQuery(' alice ');
      notifier.updateQuery(' bob ', limit: 4);
      await scheduler.runActive();

      final state = scope.read(actorTypeaheadProvider);
      expect(state.query, 'bob');
      expect(state.results.map((actor) => actor.did), ['did:plc:bob']);
      expect(state.isLoading, isFalse);
      expect(actorRepository.typeaheadCalls, [(query: 'bob', limit: 4)]);
      expect(scheduler.entries.first.cancelled, isTrue);
    });

    test('empty query clears state and stale completion is ignored', () async {
      final first = Completer<ActorSearchActorsTypeaheadOutput>();
      final second = Completer<ActorSearchActorsTypeaheadOutput>();
      actorRepository.typeaheadResponses
        ..add(() => first.future)
        ..add(() => second.future);
      final scope = container();
      final subscription = scope.listen(
        actorTypeaheadProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      final notifier = scope.read(actorTypeaheadProvider.notifier);

      notifier.updateQuery('first');
      final firstRequest = scheduler.startNextActive();
      notifier.updateQuery('second');
      final secondRequest = scheduler.startNextActive();
      second.complete(
        ActorSearchActorsTypeaheadOutput(actors: [_basic('second')]),
      );
      await secondRequest;
      first.complete(
        ActorSearchActorsTypeaheadOutput(actors: [_basic('first')]),
      );
      await firstRequest;

      expect(scope.read(actorTypeaheadProvider).query, 'second');
      expect(
        scope.read(actorTypeaheadProvider).results.single.did,
        'did:plc:second',
      );

      notifier.updateQuery('   ');

      expect(scope.read(actorTypeaheadProvider).query, isEmpty);
      expect(scope.read(actorTypeaheadProvider).results, isEmpty);
      expect(scope.read(actorTypeaheadProvider).isLoading, isFalse);
    });

    test('current request exposes a stable error', () async {
      actorRepository.typeaheadResponses.add(
        () async => throw StateError('offline'),
      );
      final scope = container();
      final subscription = scope.listen(
        actorTypeaheadProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      scope.read(actorTypeaheadProvider.notifier).updateQuery('alice');
      await scheduler.runActive();

      final state = scope.read(actorTypeaheadProvider);
      expect(state.error, 'Failed to fetch suggestions');
      expect(state.isLoading, isFalse);
    });
  });

  group('Search', () {
    test(
      'submit trims query, publishes success, and clears on empty',
      () async {
        actorRepository.actorResponses.add(
          () async => ActorSearchActorsOutput(
            actors: [_profile('alice')],
            cursor: 'next',
          ),
        );
        final scope = container();
        final subscription = scope.listen(searchProvider, (previous, next) {});
        addTearDown(subscription.close);
        final notifier = scope.read(searchProvider.notifier);

        await notifier.submitQuery(' alice ');
        expect(scope.read(searchProvider).query, 'alice');
        expect(scope.read(searchProvider).nextCursor, 'next');
        expect(
          scope.read(searchProvider).searchResults.map((actor) => actor.did),
          ['did:plc:alice'],
        );

        await notifier.submitQuery('  ');
        expect(scope.read(searchProvider).searchResults, isEmpty);
        expect(scope.read(searchProvider).isLoading, isFalse);
        expect(actorRepository.actorCalls, [(query: 'alice', cursor: null)]);
      },
    );

    test('debounce cancellation and stale out-of-order suppression', () async {
      final first = Completer<ActorSearchActorsOutput>();
      final second = Completer<ActorSearchActorsOutput>();
      actorRepository.actorResponses
        ..add(() => first.future)
        ..add(() => second.future);
      final scope = container();
      final subscription = scope.listen(searchProvider, (previous, next) {});
      addTearDown(subscription.close);
      final notifier = scope.read(searchProvider.notifier);

      notifier.updateQuery('cancelled');
      notifier.updateQuery('first');
      final firstRequest = scheduler.startNextActive();
      final secondRequest = notifier.submitQuery('second');
      second.complete(ActorSearchActorsOutput(actors: [_profile('second')]));
      await secondRequest;
      first.complete(ActorSearchActorsOutput(actors: [_profile('first')]));
      await firstRequest;

      expect(scope.read(searchProvider).query, 'second');
      expect(
        scope.read(searchProvider).searchResults.single.did,
        'did:plc:second',
      );
      expect(actorRepository.actorCalls.map((call) => call.query), [
        'first',
        'second',
      ]);
    });

    test('pagination guards duplicates and stops at end', () async {
      actorRepository.actorResponses.add(
        () async => ActorSearchActorsOutput(
          actors: [_profile('first')],
          cursor: 'next',
        ),
      );
      final next = Completer<ActorSearchActorsOutput>();
      actorRepository.actorResponses.add(() => next.future);
      final scope = container();
      final subscription = scope.listen(searchProvider, (previous, next) {});
      addTearDown(subscription.close);
      final notifier = scope.read(searchProvider.notifier);
      await notifier.submitQuery('people');

      final firstLoadMore = notifier.loadMoreUsers();
      final duplicate = notifier.loadMoreUsers();
      next.complete(ActorSearchActorsOutput(actors: [_profile('second')]));
      await Future.wait([firstLoadMore, duplicate]);
      await notifier.loadMoreUsers();

      expect(actorRepository.actorCalls, [
        (query: 'people', cursor: null),
        (query: 'people', cursor: 'next'),
      ]);
      expect(
        scope.read(searchProvider).searchResults.map((actor) => actor.did),
        ['did:plc:first', 'did:plc:second'],
      );
      expect(scope.read(searchProvider).isLoadingMore, isFalse);
    });

    test('search error clears loading', () async {
      actorRepository.actorResponses.add(() async => throw StateError('bad'));
      final scope = container();
      final subscription = scope.listen(searchProvider, (previous, next) {});
      addTearDown(subscription.close);

      await scope.read(searchProvider.notifier).submitQuery('bad');

      expect(scope.read(searchProvider).error, 'Failed to search users');
      expect(scope.read(searchProvider).isLoading, isFalse);
    });

    test('follow applies confirmed URI; unfollow rolls back errors', () async {
      final followUri = AtUri('at://did:plc:me/so.sprk.graph.follow/alice');
      actorRepository.actorResponses.add(
        () async => ActorSearchActorsOutput(actors: [_profile('alice')]),
      );
      final follow = Completer<RepoStrongRef>();
      graphRepository.followResponses.add(() => follow.future);
      final scope = container();
      final subscription = scope.listen(searchProvider, (previous, next) {});
      addTearDown(subscription.close);
      final notifier = scope.read(searchProvider.notifier);
      await notifier.submitQuery('alice');

      final following = notifier.followUser('did:plc:alice');
      expect(
        scope.read(searchProvider).searchResults.single.viewer?.following,
        isNull,
      );
      follow.complete(RepoStrongRef(uri: followUri, cid: 'follow-cid'));
      await following;
      expect(
        scope.read(searchProvider).searchResults.single.viewer?.following,
        followUri,
      );

      graphRepository.unfollowResponses.add(
        () async => throw StateError('cannot unfollow'),
      );
      final unfollowing = notifier.unfollowUser('did:plc:alice', followUri);
      expect(
        scope.read(searchProvider).searchResults.single.viewer?.following,
        isNull,
      );
      await unfollowing;
      expect(
        scope.read(searchProvider).searchResults.single.viewer?.following,
        followUri,
      );

      graphRepository.followResponses.add(
        () async => throw StateError('cannot follow'),
      );
      graphRepository.unfollowResponses.add(() async {});
      await notifier.unfollowUser('did:plc:alice', followUri);
      final failedFollow = notifier.followUser('did:plc:alice');
      expect(
        scope.read(searchProvider).searchResults.single.viewer?.following,
        isNull,
      );
      await failedFollow;
      expect(
        scope.read(searchProvider).searchResults.single.viewer?.following,
        isNull,
      );
    });

    test(
      'follow completion ignores a result removed by a newer query',
      () async {
        final followUri = AtUri('at://did:plc:me/so.sprk.graph.follow/alice');
        actorRepository.actorResponses
          ..add(
            () async => ActorSearchActorsOutput(actors: [_profile('alice')]),
          )
          ..add(() async => ActorSearchActorsOutput(actors: [_profile('bob')]));
        final follow = Completer<RepoStrongRef>();
        graphRepository.followResponses.add(() => follow.future);
        final scope = container();
        final subscription = scope.listen(searchProvider, (previous, next) {});
        addTearDown(subscription.close);
        final notifier = scope.read(searchProvider.notifier);
        await notifier.submitQuery('alice');

        final pendingFollow = notifier.followUser('did:plc:alice');
        await notifier.submitQuery('bob');
        follow.complete(RepoStrongRef(uri: followUri, cid: 'follow-cid'));
        await pendingFollow;

        expect(scope.read(searchProvider).query, 'bob');
        expect(
          scope.read(searchProvider).searchResults.map((actor) => actor.did),
          ['did:plc:bob'],
        );
        expect(
          logOutput.entries.where(
            (entry) => entry.message.contains('Failed to follow user'),
          ),
          isEmpty,
        );
      },
    );
  });

  group('PostSearch', () {
    test('trims query, filters moderation, and combines sources', () async {
      final backend = _FakePostSearchBackend();
      backend.initialResponses.add(
        () async => (
          sprk: (
            posts: [
              _post('hidden', label: 'blocked'),
              _post('spark'),
            ],
            cursor: null,
          ),
          bsky: (posts: [_post('bsky')], cursor: null),
        ),
      );
      final scope = container(
        overrides: [
          postSearchBackendProvider.overrideWithValue(backend),
          postSearchPreferencesProvider.overrideWithValue(
            Preferences(
              preferences: [
                contentLabelPreference(
                  labelerDid: 'did:plc:mod',
                  label: 'blocked',
                  visibility: 'hide',
                ),
              ],
            ),
          ),
        ],
      );
      final subscription = scope.listen(
        postSearchProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      await scope.read(postSearchProvider.notifier).submitQuery(' clips ');

      final state = scope.read(postSearchProvider);
      expect(state.query, 'clips');
      expect(state.searchResults.map((post) => post.uri.rkey), [
        'spark',
        'bsky',
      ]);
      expect(state.isLoading, isFalse);
      expect(state.sprkNextCursor, isNull);
      expect(state.bskyNextCursor, isNull);
    });

    test('debounce cancellation and stale completion suppression', () async {
      final backend = _FakePostSearchBackend();
      final first = Completer<InitialPostSearchResult>();
      final second = Completer<InitialPostSearchResult>();
      backend.initialResponses
        ..add(() => first.future)
        ..add(() => second.future);
      final scope = container(
        overrides: [postSearchBackendProvider.overrideWithValue(backend)],
      );
      final subscription = scope.listen(
        postSearchProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      final notifier = scope.read(postSearchProvider.notifier);

      notifier.updateQuery('cancelled');
      notifier.updateQuery('first');
      final firstRequest = scheduler.startNextActive();
      final secondRequest = notifier.submitQuery('second');
      second.complete(_initial([_post('second')]));
      await secondRequest;
      first.complete(_initial([_post('first')]));
      await firstRequest;

      expect(scope.read(postSearchProvider).query, 'second');
      expect(
        scope.read(postSearchProvider).searchResults.single.uri.rkey,
        'second',
      );
    });

    test(
      'pagination suppresses duplicates and stops after cursors end',
      () async {
        final backend = _FakePostSearchBackend();
        backend.initialResponses.add(
          () async => (
            sprk: (
              posts: List.generate(10, (i) => _post('initial-$i')),
              cursor: 'next',
            ),
            bsky: (posts: const <PostView>[], cursor: null),
          ),
        );
        final next = Completer<PostSearchPage>();
        backend.sprkResponses.add(() => next.future);
        final scope = container(
          overrides: [postSearchBackendProvider.overrideWithValue(backend)],
        );
        final subscription = scope.listen(
          postSearchProvider,
          (previous, next) {},
        );
        addTearDown(subscription.close);
        final notifier = scope.read(postSearchProvider.notifier);
        await notifier.submitQuery('clips');

        final loadMore = notifier.loadMorePosts();
        final duplicate = notifier.loadMorePosts();
        next.complete((posts: [_post('next-post')], cursor: null));
        await Future.wait([loadMore, duplicate]);
        await notifier.loadMorePosts();

        expect(backend.sprkCalls, [(query: 'clips', cursor: 'next')]);
        expect(
          scope.read(postSearchProvider).searchResults.last.uri.rkey,
          'next-post',
        );
        expect(scope.read(postSearchProvider).isLoadingMore, isFalse);
      },
    );

    test('current errors clear loading and empty query resets state', () async {
      final backend = _FakePostSearchBackend();
      backend.initialResponses.add(() async => throw StateError('offline'));
      final scope = container(
        overrides: [postSearchBackendProvider.overrideWithValue(backend)],
      );
      final subscription = scope.listen(
        postSearchProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      final notifier = scope.read(postSearchProvider.notifier);

      await notifier.submitQuery('broken');
      expect(scope.read(postSearchProvider).error, contains('offline'));
      expect(scope.read(postSearchProvider).isLoading, isFalse);

      await notifier.submitQuery('   ');
      expect(scope.read(postSearchProvider).query, isEmpty);
      expect(scope.read(postSearchProvider).searchResults, isEmpty);
      expect(scope.read(postSearchProvider).error, isNull);
    });
  });

  group('SuggestedFeeds', () {
    test('loads and refreshes suggested feeds', () async {
      feedRepository.suggestedResponses
        ..add(() async => [_generator('first')])
        ..add(() async => [_generator('refreshed')]);
      final scope = container();
      final subscription = scope.listen(
        suggestedFeedsProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      expect(
        (await scope.read(suggestedFeedsProvider.future)).single.displayName,
        'first',
      );
      await scope.read(suggestedFeedsProvider.notifier).refresh();
      expect(
        scope.read(suggestedFeedsProvider).value!.single.displayName,
        'refreshed',
      );
      expect(feedRepository.suggestedCalls, 2);
    });

    test('load and refresh expose repository errors', () async {
      feedRepository.suggestedResponses.add(
        () async => throw StateError('load failed'),
      );
      final scope = container();
      final subscription = scope.listen(
        suggestedFeedsProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await expectLater(
        scope.read(suggestedFeedsProvider.future),
        throwsStateError,
      );

      feedRepository.suggestedResponses.add(
        () async => throw StateError('refresh failed'),
      );
      await scope.read(suggestedFeedsProvider.notifier).refresh();
      expect(scope.read(suggestedFeedsProvider).hasError, isTrue);
    });
  });
}

class _FakeScheduler {
  final List<_ScheduledAction> entries = [];

  void Function() schedule(Duration delay, Future<void> Function() action) {
    final entry = _ScheduledAction(delay, action);
    entries.add(entry);
    return () => entry.cancelled = true;
  }

  Future<void> runActive() async {
    for (final entry in entries.where(
      (entry) => !entry.cancelled && !entry.started,
    )) {
      await entry.start();
    }
  }

  Future<void> startNextActive() {
    return entries
        .firstWhere((entry) => !entry.cancelled && !entry.started)
        .start();
  }
}

class _ScheduledAction {
  _ScheduledAction(this.delay, this.action);
  final Duration delay;
  final Future<void> Function() action;
  bool cancelled = false;
  bool started = false;

  Future<void> start() {
    started = true;
    return action();
  }
}

class _TestLogService extends LogService {
  _TestLogService(this.output);

  final LogOutput output;

  @override
  SparkLogger getLogger(String name) {
    return SparkLogger(outputs: [output]);
  }
}

class _RecordingLogOutput implements LogOutput {
  final List<({String message, Object? error})> entries = [];

  @override
  void output(
    LogLevel level,
    String message,
    DateTime timestamp,
    Object? error,
    StackTrace? stackTrace,
  ) {
    entries.add((message: message, error: error));
  }
}

class _FakeActorRepository implements ActorRepository {
  final List<Future<ActorSearchActorsOutput> Function()> actorResponses = [];
  final List<Future<ActorSearchActorsTypeaheadOutput> Function()>
  typeaheadResponses = [];
  final List<({String query, String? cursor})> actorCalls = [];
  final List<({String query, int limit})> typeaheadCalls = [];

  @override
  Future<ActorSearchActorsOutput> searchActors(String query, {String? cursor}) {
    actorCalls.add((query: query, cursor: cursor));
    return actorResponses.removeAt(0)();
  }

  @override
  Future<ActorSearchActorsTypeaheadOutput> searchActorsTypeahead(
    String query, {
    int limit = 10,
  }) {
    typeaheadCalls.add((query: query, limit: limit));
    return typeaheadResponses.removeAt(0)();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGraphRepository implements GraphRepository {
  final List<Future<RepoStrongRef> Function()> followResponses = [];
  final List<Future<void> Function()> unfollowResponses = [];

  @override
  Future<RepoStrongRef> followUser(String did, {bool bsky = false}) =>
      followResponses.removeAt(0)();

  @override
  Future<void> unfollowUser(AtUri followUri) => unfollowResponses.removeAt(0)();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  @override
  bool isAuthenticated = true;
  @override
  String? did = 'did:plc:me';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFeedRepository implements FeedRepository {
  final List<Future<List<GeneratorView>> Function()> suggestedResponses = [];
  int suggestedCalls = 0;

  @override
  Future<List<GeneratorView>> getSuggestedFeeds({bool bluesky = false}) {
    suggestedCalls++;
    return suggestedResponses.removeAt(0)();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSprkRepository implements SprkRepository {
  _FakeSprkRepository(this.repository);
  final FeedRepository repository;
  @override
  FeedRepository get feed => repository;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePostSearchBackend implements PostSearchBackend {
  final List<Future<InitialPostSearchResult> Function()> initialResponses = [];
  final List<Future<PostSearchPage> Function()> sprkResponses = [];
  final List<Future<PostSearchPage> Function()> bskyResponses = [];
  final List<String> initialCalls = [];
  final List<({String query, String cursor})> sprkCalls = [];

  @override
  Future<InitialPostSearchResult> search(String query) {
    initialCalls.add(query);
    return initialResponses.removeAt(0)();
  }

  @override
  Future<PostSearchPage> searchSprk(String query, {required String cursor}) {
    sprkCalls.add((query: query, cursor: cursor));
    return sprkResponses.removeAt(0)();
  }

  @override
  Future<PostSearchPage> searchBsky(String query, {required String cursor}) =>
      bskyResponses.removeAt(0)();
}

ProfileViewBasic _basic(String id) =>
    ProfileViewBasic(did: 'did:plc:$id', handle: '$id.sprk.so');

ProfileView _profile(String id, {AtUri? following}) => ProfileView(
  did: 'did:plc:$id',
  handle: '$id.sprk.so',
  viewer: ViewerState(following: following),
);

final _postAuthor = ProfileViewBasic(
  did: 'did:plc:author',
  handle: 'author.sprk.so',
);
final _indexedAt = DateTime.utc(2026, 7, 1);

PostView _post(String id, {String? label}) {
  final uri = AtUri('at://did:plc:author/so.sprk.feed.post/$id');
  return PostView(
    uri: uri,
    cid: 'cid-$id',
    author: _postAuthor,
    record: {r'$type': 'so.sprk.feed.post', 'text': id},
    indexedAt: _indexedAt,
    labels: label == null
        ? null
        : [
            Label(
              src: 'did:plc:mod',
              uri: uri.toString(),
              val: label,
              cts: _indexedAt,
            ),
          ],
  );
}

InitialPostSearchResult _initial(List<PostView> posts) =>
    (sprk: (posts: posts, cursor: null), bsky: (posts: const [], cursor: null));

GeneratorView _generator(String id) => GeneratorView(
  uri: AtUri('at://did:plc:feed/so.sprk.feed.generator/$id'),
  cid: 'cid-$id',
  did: 'did:plc:feed',
  creator: _profile('creator'),
  displayName: id,
  indexedAt: _indexedAt,
);
