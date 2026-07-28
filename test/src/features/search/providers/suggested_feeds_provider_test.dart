import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/search/providers/suggested_feeds_provider.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

import 'search_provider_test_support.dart';

void main() {
  late _FakeFeedRepository feedRepository;

  setUp(() async {
    await GetIt.I.reset();
    feedRepository = _FakeFeedRepository();
    GetIt.I
      ..registerSingleton<LogService>(TestLogService())
      ..registerSingleton<SprkRepository>(_FakeSprkRepository(feedRepository));
  });

  tearDown(() async => GetIt.I.reset());

  ProviderContainer container() {
    final result = ProviderContainer.test(retry: (retryCount, error) => null);
    addTearDown(result.dispose);
    return result;
  }

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

ProfileView _profile(String id) =>
    ProfileView(did: 'did:plc:$id', handle: '$id.sprk.so');

final _indexedAt = DateTime.utc(2026, 7, 1);

GeneratorView _generator(String id) => GeneratorView(
  uri: AtUri('at://did:plc:feed/so.sprk.feed.generator/$id'),
  cid: 'cid-$id',
  did: 'did:plc:feed',
  creator: _profile('creator'),
  displayName: id,
  indexedAt: _indexedAt,
);
