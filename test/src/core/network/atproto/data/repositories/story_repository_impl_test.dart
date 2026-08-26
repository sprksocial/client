import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/labeler_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/story_repository_impl.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

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
      expect(
        harness.transport.singleRequest.headers['atproto-accept-labelers'],
        'did:web:mod.sprk.test',
      );
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
      expect(
        harness.transport.singleRequest.headers['atproto-accept-labelers'],
        'did:web:mod.sprk.test',
      );
    });

    test(
      'getStoryViews enriches stories with queried moderation labels',
      () async {
        final story = StoryView(
          uri: AtUri('at://did:plc:author/so.sprk.story.post/story'),
          cid: 'story-cid',
          author: const ProfileViewBasic(
            did: 'did:plc:author',
            handle: 'author.sprk.so',
          ),
          record: const <String, dynamic>{},
          indexedAt: fixedNow,
        );
        final currentVersionLabel = Label(
          src: 'did:plc:moderator',
          uri: story.uri.toString(),
          cid: story.cid,
          val: 'sexual',
          cts: fixedNow,
        );
        final oldVersionLabel = Label(
          src: 'did:plc:moderator',
          uri: story.uri.toString(),
          cid: 'old-story-cid',
          val: 'gore',
          cts: fixedNow,
        );
        final unversionedLabel = Label(
          src: 'did:plc:moderator',
          uri: story.uri.toString(),
          val: 'nudity',
          cts: fixedNow,
        );
        final labeler = _LabelQueryRepository([
          (
            labels: [currentVersionLabel, oldVersionLabel, unversionedLabel],
            cursor: null,
          ),
        ]);
        final harness = RepositoryHarness(
          getResponse: {
            'stories': [story.toJson()],
          },
          labelerRepository: labeler,
        );
        final repository = StoryRepositoryImpl(harness.sprk);

        final result = await repository.getStoryViews([story.uri]);

        expect(result.single.moderationLabels, [
          currentVersionLabel,
          unversionedLabel,
        ]);
        expect(labeler.calls.single.uris, [story.uri]);
        expect(labeler.calls.single.limit, 250);
      },
    );

    test(
      'getStoryViews reconciles paged negations and newer assertions',
      () async {
        final story = StoryView(
          uri: AtUri('at://did:plc:author/so.sprk.story.post/story'),
          cid: 'story-cid',
          author: const ProfileViewBasic(
            did: 'did:plc:author',
            handle: 'author.sprk.so',
          ),
          record: const <String, dynamic>{},
          indexedAt: fixedNow,
        );
        Label label(String value, Duration age, {bool? neg, String? cid}) =>
            Label(
              src: 'did:plc:moderator',
              uri: story.uri.toString(),
              cid: cid ?? story.cid,
              val: value,
              neg: neg,
              cts: fixedNow.subtract(age),
            );

        final sexualAssertion = label('sexual', const Duration(minutes: 3));
        final sexualNegation = label(
          'sexual',
          const Duration(minutes: 2),
          neg: true,
        );
        final staleSexualAssertion = label(
          'sexual',
          const Duration(minutes: 4),
        );
        final goreAssertion = label('gore', const Duration(minutes: 3));
        final goreNegation = label(
          'gore',
          const Duration(minutes: 2),
          neg: true,
        );
        final reappliedGore = label('gore', const Duration(minutes: 1));
        final oldVersionGore = label(
          'gore',
          Duration.zero,
          cid: 'old-story-cid',
        );
        final labeler = _LabelQueryRepository([
          (labels: [sexualAssertion, goreAssertion], cursor: 'negations'),
          (labels: [sexualNegation, goreNegation], cursor: 'updates'),
          (
            labels: [staleSexualAssertion, reappliedGore, oldVersionGore],
            cursor: null,
          ),
        ]);
        final harness = RepositoryHarness(
          getResponse: {
            'stories': [story.toJson()],
          },
          labelerRepository: labeler,
        );
        final repository = StoryRepositoryImpl(
          harness.sprk,
          now: () => fixedNow,
        );

        final result = await repository.getStoryViews([story.uri]);

        expect(result.single.moderationLabels, [reappliedGore]);
        expect(labeler.calls.map((call) => call.cursor), [
          null,
          'negations',
          'updates',
        ]);
      },
    );

    test('listStoryRecords owns record paging parameters', () async {
      final harness = RepositoryHarness(
        getResponse: const {'records': <dynamic>[], 'cursor': 'next-page'},
      );
      final repository = StoryRepositoryImpl(harness.sprk);

      final result = await repository.listStoryRecords(
        did: 'did:plc:viewer',
        cursor: 'current-page',
      );

      expect(result.records, isEmpty);
      expect(result.cursor, 'next-page');
      final request = harness.transport.singleRequest;
      expect(request.uri.path, '/xrpc/com.atproto.repo.listRecords');
      expect(request.uri.queryParameters['repo'], 'did:plc:viewer');
      expect(request.uri.queryParameters['collection'], 'so.sprk.story.post');
      expect(request.uri.queryParameters['cursor'], 'current-page');
      expect(request.uri.queryParameters['limit'], '100');
    });

    test('deleteStoryRecord delegates to the record repository', () async {
      final harness = RepositoryHarness();
      final repository = StoryRepositoryImpl(harness.sprk);
      final uri = AtUri('at://did:plc:viewer/so.sprk.story.post/story');

      await repository.deleteStoryRecord(uri);

      expect(harness.repo.deleteCalls.single.uri, uri);
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

class _LabelQueryRepository implements LabelerRepository {
  _LabelQueryRepository(this.pages);

  final List<({List<Label> labels, String? cursor})> pages;
  final List<({List<AtUri> uris, int? limit, String? cursor})> calls = [];

  @override
  Future<({List<Label> labels, String? cursor})> queryLabels(
    List<AtUri> uris, {
    List<String>? sources,
    int? limit,
    String? cursor,
  }) async {
    calls.add((uris: uris, limit: limit, cursor: cursor));
    return pages.removeAt(0);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
