import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/providers/debounce_scheduler.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/search/data/repositories/post_search_repository.dart';
import 'package:spark/src/features/search/providers/post_search_provider.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

import 'search_provider_test_support.dart';

void main() {
  late TestDebounceScheduler scheduler;

  setUp(() async {
    await GetIt.I.reset();
    scheduler = TestDebounceScheduler();
    GetIt.I.registerSingleton<LogService>(TestLogService());
  });

  tearDown(() async => GetIt.I.reset());

  ProviderContainer container({List<Override> overrides = const []}) {
    final result = ProviderContainer.test(
      retry: (retryCount, error) => null,
      overrides: [
        debounceSchedulerProvider.overrideWithValue(scheduler.schedule),
        ...overrides,
      ],
    );
    addTearDown(result.dispose);
    return result;
  }

  test('trims query, filters moderation, and combines sources', () async {
    final repository = _FakePostSearchRepository();
    repository.initialResponses.add(
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
        postSearchRepositoryProvider.overrideWithValue(repository),
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
    final subscription = scope.listen(postSearchProvider, (previous, next) {});
    addTearDown(subscription.close);

    await scope.read(postSearchProvider.notifier).submitQuery(' clips ');

    final state = scope.read(postSearchProvider);
    expect(state.query, 'clips');
    expect(state.searchResults.map((post) => post.uri.rkey), ['spark', 'bsky']);
    expect(state.isLoading, isFalse);
    expect(state.sprkNextCursor, isNull);
    expect(state.bskyNextCursor, isNull);
  });

  test('debounce cancellation and stale completion suppression', () async {
    final repository = _FakePostSearchRepository();
    final first = Completer<InitialPostSearchResult>();
    final second = Completer<InitialPostSearchResult>();
    repository.initialResponses
      ..add(() => first.future)
      ..add(() => second.future);
    final scope = container(
      overrides: [postSearchRepositoryProvider.overrideWithValue(repository)],
    );
    final subscription = scope.listen(postSearchProvider, (previous, next) {});
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
      final repository = _FakePostSearchRepository();
      repository.initialResponses.add(
        () async => (
          sprk: (
            posts: List.generate(10, (i) => _post('initial-$i')),
            cursor: 'next',
          ),
          bsky: (posts: const <PostView>[], cursor: null),
        ),
      );
      final next = Completer<PostSearchPage>();
      repository.sprkResponses.add(() => next.future);
      final scope = container(
        overrides: [postSearchRepositoryProvider.overrideWithValue(repository)],
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

      expect(repository.sprkCalls, [(query: 'clips', cursor: 'next')]);
      expect(
        scope.read(postSearchProvider).searchResults.last.uri.rkey,
        'next-post',
      );
      expect(scope.read(postSearchProvider).isLoadingMore, isFalse);
    },
  );

  test('current errors clear loading and empty query resets state', () async {
    final repository = _FakePostSearchRepository();
    repository.initialResponses.add(() async => throw StateError('offline'));
    final scope = container(
      overrides: [postSearchRepositoryProvider.overrideWithValue(repository)],
    );
    final subscription = scope.listen(postSearchProvider, (previous, next) {});
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
}

class _FakePostSearchRepository implements PostSearchRepository {
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
