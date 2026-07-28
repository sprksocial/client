import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sound_repository_impl.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

import 'repository_test_support.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 7, 22, 12, 30);

  group('SoundRepositoryImpl', () {
    test(
      'createSound writes a typed record using the injected clock',
      () async {
        final harness = RepositoryHarness();
        final repository = SoundRepositoryImpl(
          harness.sprk,
          logger: SparkLogger(),
          now: () => fixedNow,
        );

        final result = await repository.createSound(
          sound: testBlob('audio/mpeg'),
          title: 'Theme',
        );

        final call = harness.repo.createCalls.single;
        expect(call.collection, 'so.sprk.sound.audio');
        expect(call.record[r'$type'], 'so.sprk.sound.audio');
        expect(call.record['title'], 'Theme');
        expect(call.record['createdAt'], fixedNow.toIso8601String());
        expect(result.cid, 'result-cid');
      },
    );

    test('search trims the query and forwards pagination and proxy', () async {
      final harness = RepositoryHarness(
        getResponse: {'audios': <dynamic>[], 'cursor': 'next'},
      );
      final repository = SoundRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );

      final result = await repository.searchAudios(
        '  ambient  ',
        limit: 7,
        cursor: 'page',
      );

      final request = harness.transport.singleRequest;
      expect(request.uri.path, '/xrpc/so.sprk.sound.searchAudios');
      expect(request.uri.queryParameters, {
        'q': 'ambient',
        'limit': '7',
        'cursor': 'page',
      });
      expect(request.headers['atproto-proxy'], harness.sprk.sprkDid);
      expect(result.cursor, 'next');
    });

    test('getAudioPosts maps empty pages and defaults', () async {
      final harness = RepositoryHarness(
        getResponse: const {'posts': <dynamic>[]},
      );
      final repository = SoundRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );
      final uri = AtUri('at://did:plc:author/so.sprk.sound.audio/audio');

      final result = await repository.getAudioPosts(uri);

      expect(result.posts, isEmpty);
      expect(harness.transport.singleRequest.uri.queryParameters, {
        'uri': uri.toString(),
        'limit': '50',
      });
    });

    test('rejects unauthenticated requests before transport', () async {
      final harness = RepositoryHarness(authenticated: false);
      final repository = SoundRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );

      await expectLater(
        repository.getTrendingAudios(),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Not authenticated'),
          ),
        ),
      );
      expect(harness.transport.requests, isEmpty);
    });
  });
}
