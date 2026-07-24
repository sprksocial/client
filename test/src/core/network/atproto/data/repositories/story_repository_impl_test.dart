import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/story_repository_impl.dart';

import 'repository_test_support.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 7, 22, 12, 30);

  group('StoryRepositoryImpl', () {
    test('timeline maps an empty authors page and cursor', () async {
      final harness = RepositoryHarness(
        getResponse: {'cursor': 'next', 'storiesByAuthor': <dynamic>[]},
      );
      final repository = StoryRepositoryImpl(harness.sprk, now: () => fixedNow);

      final result = await repository.getStoriesTimeline(
        limit: 5,
        cursor: 'page',
      );

      expect(result.storiesByAuthor, isEmpty);
      expect(result.cursor, 'next');
      expect(harness.transport.singleRequest.uri.queryParameters, {
        'limit': '5',
        'cursor': 'page',
      });
    });

    test('getStoryViews maps an empty story list', () async {
      final harness = RepositoryHarness(
        getResponse: const {'stories': <dynamic>[]},
      );
      final repository = StoryRepositoryImpl(harness.sprk);
      final uri = AtUri('at://did:plc:author/so.sprk.story.post/story');

      final result = await repository.getStoryViews([uri]);

      expect(result, isEmpty);
      expect(harness.transport.singleRequest.uri.queryParametersAll['uris'], [
        uri.toString(),
      ]);
    });

    test(
      'postStory normalizes empty optionals and uses injected time',
      () async {
        final harness = RepositoryHarness();
        final repository = StoryRepositoryImpl(
          harness.sprk,
          now: () => fixedNow,
        );

        await repository.postStory(
          Media.image(image: testBlob('image/jpeg'), alt: 'cover'),
          selfLabels: const [],
          embeds: const [],
        );

        final call = harness.repo.createCalls.single;
        expect(call.collection, 'so.sprk.story.post');
        expect(call.record[r'$type'], 'so.sprk.story.post');
        expect(call.record['createdAt'], fixedNow.toIso8601String());
        expect(call.record, isNot(contains('labels')));
        expect(call.record, isNot(contains('embeds')));
      },
    );

    test('rejects requests when AtProto is unavailable', () async {
      final harness = RepositoryHarness(atprotoInitialized: false);
      final repository = StoryRepositoryImpl(harness.sprk);

      await expectLater(
        repository.getStoryViews(const []),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('AtProto not initialized'),
          ),
        ),
      );
    });
  });
}
