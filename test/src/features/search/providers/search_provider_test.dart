import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/graph_repository.dart';
import 'package:spark/src/core/providers/debounce_scheduler.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/search/providers/search_provider.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';
import 'package:sprk_poptart/so/sprk/actor/search_actors/output.dart';

import 'search_provider_test_support.dart';

void main() {
  late _FakeActorRepository actorRepository;
  late _FakeGraphRepository graphRepository;
  late TestDebounceScheduler scheduler;
  late RecordingLogOutput logOutput;

  setUp(() async {
    await GetIt.I.reset();
    actorRepository = _FakeActorRepository();
    graphRepository = _FakeGraphRepository();
    scheduler = TestDebounceScheduler();
    logOutput = RecordingLogOutput();
    GetIt.I
      ..registerSingleton<LogService>(TestLogService(logOutput))
      ..registerSingleton<ActorRepository>(actorRepository)
      ..registerSingleton<GraphRepository>(graphRepository)
      ..registerSingleton<AuthRepository>(_FakeAuthRepository());
  });

  tearDown(() async => GetIt.I.reset());

  ProviderContainer container() {
    final result = ProviderContainer.test(
      retry: (retryCount, error) => null,
      overrides: [
        debounceSchedulerProvider.overrideWithValue(scheduler.schedule),
      ],
    );
    addTearDown(result.dispose);
    return result;
  }

  test('submit trims query, publishes success, and clears on empty', () async {
    actorRepository.actorResponses.add(
      () async =>
          ActorSearchActorsOutput(actors: [_profile('alice')], cursor: 'next'),
    );
    final scope = container();
    final subscription = scope.listen(searchProvider, (previous, next) {});
    addTearDown(subscription.close);
    final notifier = scope.read(searchProvider.notifier);

    await notifier.submitQuery(' alice ');
    expect(scope.read(searchProvider).query, 'alice');
    expect(scope.read(searchProvider).nextCursor, 'next');
    expect(scope.read(searchProvider).searchResults.map((actor) => actor.did), [
      'did:plc:alice',
    ]);

    await notifier.submitQuery('  ');
    expect(scope.read(searchProvider).searchResults, isEmpty);
    expect(scope.read(searchProvider).isLoading, isFalse);
    expect(actorRepository.actorCalls, [(query: 'alice', cursor: null)]);
  });

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
      () async =>
          ActorSearchActorsOutput(actors: [_profile('first')], cursor: 'next'),
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
    expect(scope.read(searchProvider).searchResults.map((actor) => actor.did), [
      'did:plc:first',
      'did:plc:second',
    ]);
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

  test('follow completion ignores a result removed by a newer query', () async {
    final followUri = AtUri('at://did:plc:me/so.sprk.graph.follow/alice');
    actorRepository.actorResponses
      ..add(() async => ActorSearchActorsOutput(actors: [_profile('alice')]))
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
    expect(scope.read(searchProvider).searchResults.map((actor) => actor.did), [
      'did:plc:bob',
    ]);
    expect(
      logOutput.entries.where(
        (entry) => entry.message.contains('Failed to follow user'),
      ),
      isEmpty,
    );
  });
}

class _FakeActorRepository implements ActorRepository {
  final List<Future<ActorSearchActorsOutput> Function()> actorResponses = [];
  final List<({String query, String? cursor})> actorCalls = [];

  @override
  Future<ActorSearchActorsOutput> searchActors(String query, {String? cursor}) {
    actorCalls.add((query: query, cursor: cursor));
    return actorResponses.removeAt(0)();
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

ProfileView _profile(String id, {AtUri? following}) => ProfileView(
  did: 'did:plc:$id',
  handle: '$id.sprk.so',
  viewer: ViewerState(following: following),
);
