import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/search/data/repositories/post_search_repository.dart';

import '../../../../core/network/atproto/data/repositories/repository_test_support.dart';

void main() {
  test(
    'Bluesky search uses its appview proxy and subscribed labelers',
    () async {
      final harness = RepositoryHarness(
        getResponse: const {'posts': <dynamic>[], 'cursor': 'next'},
      );
      harness.sprk.configureLabelers(const ['did:plc:custom']);
      final repository = PostSearchRepositoryImpl(
        _UnusedFeedRepository(),
        harness.sprk,
        SparkLogger(),
      );

      final result = await repository.searchBsky('cats', cursor: 'page');

      final request = harness.transport.singleRequest;
      expect(request.uri.path, '/xrpc/app.bsky.feed.searchPosts');
      expect(request.uri.queryParameters['q'], 'cats');
      expect(request.uri.queryParameters['sort'], 'latest');
      expect(request.uri.queryParameters['cursor'], 'page');
      expect(request.headers['atproto-proxy'], FakeSprkRepository.testBskyDid);
      expect(request.headers['atproto-accept-labelers'], 'did:plc:custom');
      expect(result.posts, isEmpty);
      expect(result.cursor, 'next');
    },
  );
}

class _UnusedFeedRepository implements FeedRepository {
  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not used');
}
