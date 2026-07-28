import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/providers/debounce_scheduler.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/search/providers/actor_typeahead_provider.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';
import 'package:sprk_poptart/so/sprk/actor/search_actors_typeahead/output.dart';

import 'search_provider_test_support.dart';

void main() {
  late _FakeActorRepository actorRepository;
  late TestDebounceScheduler scheduler;

  setUp(() async {
    await GetIt.I.reset();
    actorRepository = _FakeActorRepository();
    scheduler = TestDebounceScheduler();
    GetIt.I
      ..registerSingleton<LogService>(TestLogService())
      ..registerSingleton<ActorRepository>(actorRepository);
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
    first.complete(ActorSearchActorsTypeaheadOutput(actors: [_basic('first')]));
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
}

class _FakeActorRepository implements ActorRepository {
  final List<Future<ActorSearchActorsTypeaheadOutput> Function()>
  typeaheadResponses = [];
  final List<({String query, int limit})> typeaheadCalls = [];

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

ProfileViewBasic _basic(String id) =>
    ProfileViewBasic(did: 'did:plc:$id', handle: '$id.sprk.so');
