import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/profile/providers/profile_feed_provider.dart';

void main() {
  late _FakeFeedRepository feedRepository;

  setUp(() async {
    await GetIt.I.reset();
    feedRepository = _FakeFeedRepository();
    GetIt.I
      ..registerSingleton<SprkRepository>(_FakeSprkRepository(feedRepository))
      ..registerSingleton<LogService>(LogService());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  ProviderContainer createContainer() =>
      ProviderContainer.test(retry: (retryCount, error) => null);

  test(
    'loads the requested source and keeps an empty cursor page open',
    () async {
      feedRepository.responses.add(
        Future.value((posts: <FeedViewPost>[], cursor: 'next')),
      );
      final container = createContainer();
      final provider = profileFeedProvider(_profileUri, true, true);

      final state = await container.read(provider.future);

      expect(state.allPosts, isEmpty);
      expect(state.cursor, 'next');
      expect(state.isEndOfNetwork, isFalse);
      expect(feedRepository.calls.single, (
        profileUri: _profileUri,
        cursor: null,
        videosOnly: true,
        bluesky: true,
      ));
    },
  );

  test(
    'loadMore ignores concurrent calls and stops at a null cursor',
    () async {
      final nextPage =
          Completer<({List<FeedViewPost> posts, String? cursor})>();
      feedRepository.responses
        ..add(Future.value((posts: <FeedViewPost>[], cursor: 'next')))
        ..add(nextPage.future);
      final container = createContainer();
      final provider = profileFeedProvider(_profileUri, false, false);
      await container.read(provider.future);
      final notifier = container.read(provider.notifier);

      final firstLoad = notifier.loadMore();
      final duplicateLoad = notifier.loadMore();
      expect(feedRepository.calls, hasLength(2));
      nextPage.complete((posts: <FeedViewPost>[], cursor: null));
      await Future.wait([firstLoad, duplicateLoad]);
      await notifier.loadMore();

      expect(feedRepository.calls, hasLength(2));
      expect(container.read(provider).value?.isEndOfNetwork, isTrue);
      expect(container.read(provider).value?.cursor, isNull);
    },
  );

  test(
    'refresh starts from the first page and replaces pagination state',
    () async {
      feedRepository.responses
        ..add(Future.value((posts: <FeedViewPost>[], cursor: 'next')))
        ..add(Future.value((posts: <FeedViewPost>[], cursor: null)));
      final container = createContainer();
      final provider = profileFeedProvider(_profileUri, false, false);
      await container.read(provider.future);

      await container.read(provider.notifier).refresh();

      expect(feedRepository.calls.map((call) => call.cursor), [null, null]);
      expect(container.read(provider).value?.cursor, isNull);
      expect(container.read(provider).value?.isEndOfNetwork, isTrue);
    },
  );

  test('network failure resolves to an empty terminal page', () async {
    feedRepository.responses.add(Future.error(StateError('network failed')));
    final container = createContainer();
    final provider = profileFeedProvider(_profileUri, false, false);

    final state = await container.read(provider.future);

    expect(state.allPosts, isEmpty);
    expect(state.cursor, isNull);
    expect(state.isEndOfNetwork, isTrue);
  });
}

final AtUri _profileUri = AtUri.parse('at://did:plc:profile');

class _FakeFeedRepository implements FeedRepository {
  final Queue<Future<({List<FeedViewPost> posts, String? cursor})>> responses =
      Queue<Future<({List<FeedViewPost> posts, String? cursor})>>();
  final List<
    ({AtUri profileUri, String? cursor, bool videosOnly, bool bluesky})
  >
  calls = [];

  @override
  Future<({List<FeedViewPost> posts, String? cursor})> getAuthorFeed(
    AtUri actorUri, {
    int limit = 20,
    String? cursor,
    bool videosOnly = false,
    bool bluesky = false,
  }) {
    calls.add((
      profileUri: actorUri,
      cursor: cursor,
      videosOnly: videosOnly,
      bluesky: bluesky,
    ));
    return responses.removeFirst();
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not used');
}

class _FakeSprkRepository implements SprkRepository {
  _FakeSprkRepository(this.feed);

  @override
  final FeedRepository feed;

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not used');
}
