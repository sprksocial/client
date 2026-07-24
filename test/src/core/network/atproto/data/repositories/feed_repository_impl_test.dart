import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository_impl.dart';
import 'package:spark/src/core/network/atproto/data/repositories/repo_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/core/utils/video_upload_exception.dart';
import 'package:sprk_poptart/so/sprk/actor/defs/profile_view_basic.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 7, 22, 12, 34, 56);

  group('FeedRepositoryImpl feed requests', () {
    test('getFeed routes timeline requests and maps hydrated posts', () async {
      final post = _postView();
      final harness = _Harness(
        now: fixedNow,
        response: <String, dynamic>{
          'cursor': 'timeline-next',
          'feed': [
            {'post': post.toJson()},
          ],
        },
      );
      final feed = Feed(
        type: 'timeline',
        config: makeSavedFeed(
          id: 'timeline',
          type: 'timeline',
          value: 'timeline',
          pinned: true,
        ),
      );

      final result = await harness.repository.getFeed(
        feed,
        limit: 12,
        cursor: 'timeline-cursor',
        labelerDids: const ['did:plc:one', 'did:plc:two'],
      );

      final request = harness.transport.singleRequest;
      expect(request.uri.path, '/xrpc/so.sprk.feed.getTimeline');
      expect(request.uri.queryParameters['limit'], '12');
      expect(request.uri.queryParameters['cursor'], 'timeline-cursor');
      expect(request.headers['atproto-proxy'], _Harness.sprkDid);
      expect(
        request.headers['atproto-accept-labelers'],
        'did:plc:one,did:plc:two',
      );
      expect(result.cursor, 'timeline-next');
      expect(result.feed.single.post.uri, post.uri);
    });

    test(
      'getFeedView sends Spark feed requests to the Spark service',
      () async {
        final post = _postView();
        final harness = _Harness(
          now: fixedNow,
          response: <String, dynamic>{
            'cursor': 'spark-next',
            'feed': [
              {'post': post.toJson()},
            ],
          },
        );
        final feedUri = AtUri(
          'at://did:plc:generator/so.sprk.feed.generator/spark-feed',
        );

        final result = await harness.repository.getFeedView(
          feedUri,
          limit: 8,
          cursor: 'spark-cursor',
          labelerDids: const ['did:plc:labeler'],
        );

        final request = harness.transport.singleRequest;
        expect(request.uri.path, '/xrpc/so.sprk.feed.getFeed');
        expect(request.uri.queryParameters['feed'], feedUri.toString());
        expect(request.uri.queryParameters['limit'], '8');
        expect(request.uri.queryParameters['cursor'], 'spark-cursor');
        expect(request.headers['atproto-proxy'], _Harness.sprkDid);
        expect(request.headers['atproto-accept-labelers'], 'did:plc:labeler');
        expect(result.cursor, 'spark-next');
        expect(result.feed.single.post.uri, post.uri);
      },
    );

    test(
      'getFeedView selects Bluesky and omits Spark labeler headers',
      () async {
        final harness = _Harness(
          now: fixedNow,
          response: <String, dynamic>{
            'cursor': 'bsky-next',
            'feed': <dynamic>[],
          },
        );
        final feedUri = AtUri(
          'at://did:plc:generator/app.bsky.feed.generator/bsky-feed',
        );

        final result = await harness.repository.getFeedView(
          feedUri,
          limit: 6,
          cursor: 'bsky-cursor',
          labelerDids: const ['did:plc:labeler'],
        );

        final request = harness.transport.singleRequest;
        expect(request.uri.path, '/xrpc/app.bsky.feed.getFeed');
        expect(request.uri.queryParameters['feed'], feedUri.toString());
        expect(request.uri.queryParameters['limit'], '6');
        expect(request.uri.queryParameters['cursor'], 'bsky-cursor');
        expect(request.headers['atproto-proxy'], _Harness.bskyDid);
        expect(request.headers, isNot(contains('atproto-accept-labelers')));
        expect(result.cursor, 'bsky-next');
        expect(result.feed, isEmpty);
      },
    );

    test('getFeedView rejects unauthenticated requests before transport', () {
      final harness = _Harness(
        now: fixedNow,
        response: <String, dynamic>{'feed': <dynamic>[]},
        authenticated: false,
      );

      expect(
        harness.repository.getFeedView(
          AtUri('at://did:plc:generator/so.sprk.feed.generator/feed'),
        ),
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

    test('getFeedView propagates the transport 500 response', () async {
      final harness = _Harness(
        now: fixedNow,
        statusCode: 500,
        response: <String, dynamic>{
          'error': 'InternalServerError',
          'message': 'feed unavailable',
        },
      );

      await expectLater(
        harness.repository.getFeedView(
          AtUri('at://did:plc:generator/so.sprk.feed.generator/feed'),
        ),
        throwsA(
          isA<InternalServerErrorException>().having(
            (error) => error.toString(),
            'message',
            allOf(
              contains('InternalServerError'),
              contains('feed unavailable'),
            ),
          ),
        ),
      );
      expect(harness.transport.requests, hasLength(1));
      expect(
        harness.transport.singleRequest.uri.path,
        '/xrpc/so.sprk.feed.getFeed',
      );
    });
  });

  group('FeedRepositoryImpl records', () {
    test(
      'likePost selects the record collection and uses the injected clock',
      () async {
        final harness = _Harness(now: fixedNow);
        final sparkPost = AtUri(
          'at://did:plc:author/so.sprk.feed.post/spark-post',
        );
        final bskyPost = AtUri(
          'at://did:plc:author/app.bsky.feed.post/bsky-post',
        );

        await harness.repository.likePost('spark-cid', sparkPost);
        await harness.repository.likePost('bsky-cid', bskyPost);

        expect(harness.repo.createCalls, hasLength(2));
        final sparkCall = harness.repo.createCalls[0];
        expect(sparkCall.collection, 'so.sprk.feed.like');
        expect(sparkCall.record[r'$type'], 'so.sprk.feed.like');
        final sparkSubject =
            sparkCall.record['subject'] as Map<String, dynamic>;
        expect(sparkSubject[r'$type'], 'com.atproto.repo.strongRef');
        expect(sparkSubject['uri'], sparkPost.toString());
        expect(sparkSubject['cid'], 'spark-cid');
        expect(sparkCall.record['createdAt'], fixedNow.toIso8601String());

        final bskyCall = harness.repo.createCalls[1];
        expect(bskyCall.collection, 'app.bsky.feed.like');
        expect(bskyCall.record[r'$type'], 'app.bsky.feed.like');
        final bskySubject = bskyCall.record['subject'] as Map<String, dynamic>;
        expect(bskySubject[r'$type'], 'com.atproto.repo.strongRef');
        expect(bskySubject['uri'], bskyPost.toString());
        expect(bskySubject['cid'], 'bsky-cid');
        expect(bskyCall.record['createdAt'], fixedNow.toIso8601String());
      },
    );

    test(
      'unlikePost deletes the interaction without crosspost cleanup',
      () async {
        final harness = _Harness(now: fixedNow);
        final likeUri = AtUri(
          'at://did:plc:viewer/so.sprk.feed.like/interaction',
        );

        await harness.repository.unlikePost(likeUri);

        expect(harness.repo.deleteCalls, hasLength(1));
        expect(harness.repo.deleteCalls.single.uri, likeUri);
        expect(
          harness.repo.deleteCalls.single.skipBskyCrosspostCleanup,
          isTrue,
        );
      },
    );

    test('postComment writes Spark reply roots and parents', () async {
      final harness = _Harness(now: fixedNow);
      final parentUri = AtUri('at://did:plc:author/so.sprk.feed.post/parent');
      final rootUri = AtUri('at://did:plc:author/so.sprk.feed.post/root');

      await harness.repository.postComment(
        'A Spark reply',
        'parent-cid',
        parentUri,
        rootCid: 'root-cid',
        rootUri: rootUri,
      );

      final call = harness.repo.createCalls.single;
      expect(call.collection, 'so.sprk.feed.reply');
      expect(call.record[r'$type'], 'so.sprk.feed.reply');
      expect(call.record['text'], 'A Spark reply');
      expect(call.record, isNot(contains('facets')));
      expect(call.record['createdAt'], fixedNow.toIso8601String());
      final reply = call.record['reply'] as Map<String, dynamic>;
      expect(reply[r'$type'], 'so.sprk.feed.reply#replyRef');
      _expectStrongRef(reply['root'], uri: rootUri, cid: 'root-cid');
      _expectStrongRef(reply['parent'], uri: parentUri, cid: 'parent-cid');
    });

    test(
      'postComment writes Bluesky posts and defaults root to parent',
      () async {
        final harness = _Harness(now: fixedNow);
        final parentUri = AtUri(
          'at://did:web:sprk.so/app.bsky.feed.post/parent',
        );

        await harness.repository.postComment(
          'A Bluesky reply',
          'parent-cid',
          parentUri,
        );

        final call = harness.repo.createCalls.single;
        expect(call.collection, 'app.bsky.feed.post');
        expect(call.record[r'$type'], 'app.bsky.feed.post');
        expect(call.record['text'], 'A Bluesky reply');
        expect(call.record['createdAt'], fixedNow.toIso8601String());
        final reply = call.record['reply'] as Map<String, dynamic>;
        expect(reply[r'$type'], 'app.bsky.feed.post#replyRef');
        _expectStrongRef(reply['root'], uri: parentUri, cid: 'parent-cid');
        _expectStrongRef(reply['parent'], uri: parentUri, cid: 'parent-cid');
      },
    );

    test('record creation errors propagate through the repository', () {
      final harness = _Harness(now: fixedNow)
        ..repo.createError = StateError('record write failed');

      expect(
        harness.repository.likePost(
          'cid',
          AtUri('at://did:plc:author/so.sprk.feed.post/post'),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'record write failed',
          ),
        ),
      );
    });
  });

  group('FeedRepositoryImpl threads', () {
    test(
      'getThread sends Spark thread parameters and maps not-found posts',
      () async {
        final threadUri = AtUri(
          'at://did:plc:author/so.sprk.feed.post/missing',
        );
        final harness = _Harness(
          now: fixedNow,
          response: <String, dynamic>{
            'thread': [
              {
                r'$type': 'so.sprk.feed.getPostThread#threadItem',
                'uri': threadUri.toString(),
                'depth': 0,
                'value': {
                  r'$type': 'so.sprk.feed.defs#notFoundPost',
                  'uri': threadUri.toString(),
                  'notFound': true,
                },
              },
            ],
          },
        );

        final result = await harness.repository.getThread(
          threadUri,
          depth: 4,
          parentHeight: 2,
        );

        final request = harness.transport.singleRequest;
        expect(request.uri.path, '/xrpc/so.sprk.feed.getPostThread');
        expect(request.uri.queryParameters['anchor'], threadUri.toString());
        expect(request.uri.queryParameters['depth'], '4');
        expect(request.uri.queryParameters['parentHeight'], '2');
        expect(request.headers['atproto-proxy'], _Harness.sprkDid);
        expect(result, isA<NotFoundPost>());
        expect((result as NotFoundPost).uri, threadUri);
        expect(result.notFound, isTrue);
      },
    );

    test('getThread rejects an uninitialized AtProto client', () {
      final harness = _Harness(now: fixedNow, atprotoInitialized: false);

      expect(
        harness.repository.getThread(
          AtUri('at://did:plc:author/so.sprk.feed.post/post'),
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('AtProto not initialized'),
          ),
        ),
      );
      expect(harness.transport.requests, isEmpty);
    });
  });

  group('FeedRepositoryImpl video upload', () {
    test('rejects missing, empty, and oversized files before HTTP', () async {
      final videoClient = _VideoClient();
      final files = <String, _FakeFile>{
        '/missing.mp4': _FakeFile('/missing.mp4', exists: false),
        '/empty.mp4': _FakeFile('/empty.mp4'),
        '/huge.mp4': _FakeFile(
          '/huge.mp4',
          lengthOverride: 2 * 1024 * 1024 * 1024 + 1,
        ),
      };
      final harness = _Harness(
        now: fixedNow,
        oauth: true,
        videoHttpClient: videoClient,
        videoFile: (path) => files[path]!,
        videoServiceAuthTokenRequest: (_) async => 'service-token',
      );

      await expectLater(
        harness.repository.uploadVideo('/missing.mp4'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Video file not found'),
          ),
        ),
      );
      await expectLater(
        harness.repository.uploadVideo('/empty.mp4'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Video file is empty'),
          ),
        ),
      );
      await expectLater(
        harness.repository.uploadVideo('/huge.mp4'),
        throwsA(
          isA<VideoUploadException>()
              .having((error) => error.statusCode, 'statusCode', 413)
              .having(
                (error) => error.uploadSizeBytes,
                'uploadSizeBytes',
                2 * 1024 * 1024 * 1024 + 1,
              )
              .having(
                (error) => error.limitBytes,
                'limitBytes',
                2 * 1024 * 1024 * 1024,
              ),
        ),
      );
      expect(videoClient.requests, isEmpty);
    });

    test(
      'streams bytes, reports progress, and parses an immediate blob',
      () async {
        final videoClient = _VideoClient()
          ..enqueueJson(200, {
            'blobRef': _blobJson(mimeType: 'video/quicktime', size: 6),
          });
        final progress = <double>[];
        final harness = _Harness(
          now: fixedNow,
          oauth: true,
          videoHttpClient: videoClient,
          videoFile: (_) => _FakeFile(
            '/clip.mov',
            chunks: const [
              [1, 2],
              [3, 4, 5, 6],
            ],
          ),
          videoServiceAuthTokenRequest: (_) async => 'service-token',
        );

        final result = await harness.repository.uploadVideo(
          'file:///clip.mov',
          onUploadProgress: progress.add,
        );

        final request = videoClient.requests.single;
        expect(request.method, 'POST');
        expect(request.url.path, '/xrpc/so.sprk.video.uploadVideo');
        expect(request.headers['Authorization'], 'Bearer service-token');
        expect(request.headers['Content-Type'], 'video/quicktime');
        expect(request.bodyBytes, [1, 2, 3, 4, 5, 6]);
        expect(progress, [0, closeTo(1 / 3, 0.0001), 1, 1]);
        expect(result.videoBlob.mimeType, 'video/quicktime');
        expect(result.videoBlob.size, 6);
        expect(result.audioBlob, isNull);
        expect(result.audioDetails, isNull);
      },
    );

    test('maps upload rejection details and size metadata', () async {
      final videoClient = _VideoClient()
        ..enqueueJson(413, {
          'error': 'PayloadTooLarge',
          'message': 'limit is 100 MB',
        });
      final harness = _Harness(
        now: fixedNow,
        oauth: true,
        videoHttpClient: videoClient,
        videoFile: (_) => _FakeFile(
          '/clip.mp4',
          chunks: const [
            [1, 2, 3],
          ],
        ),
        videoServiceAuthTokenRequest: (_) async => 'service-token',
      );

      await expectLater(
        harness.repository.uploadVideo('/clip.mp4'),
        throwsA(
          isA<VideoUploadException>()
              .having((error) => error.statusCode, 'statusCode', 413)
              .having((error) => error.uploadSizeBytes, 'uploadSizeBytes', 3)
              .having((error) => error.isPayloadTooLarge, 'too large', isTrue)
              .having(
                (error) => error.message,
                'message',
                contains('limit is 100 MB'),
              ),
        ),
      );
      expect(videoClient.requests, hasLength(1));
    });

    test(
      'polls deterministically and parses video plus audio output',
      () async {
        final videoClient = _VideoClient()
          ..enqueueJson(200, {
            'jobStatus': {'jobId': 'job-1', 'state': 'JOB_STATE_QUEUED'},
          })
          ..enqueueJson(200, {
            'jobStatus': {'jobId': 'job-1', 'state': 'JOB_STATE_PROCESSING'},
          })
          ..enqueueJson(200, {
            'jobStatus': {
              'jobId': 'job-1',
              'state': 'JOB_STATE_COMPLETED',
              'blob': _blobJson(mimeType: 'video/mp4', size: 3),
              'audio': {
                'blob': _blobJson(mimeType: 'audio/aac', size: 2),
                'details': {
                  r'$type': 'so.sprk.sound.defs#audioDetails',
                  'artist': 'Artist',
                  'title': 'Title',
                },
              },
            },
          });
        final delays = <Duration>[];
        final harness = _Harness(
          now: fixedNow,
          oauth: true,
          videoHttpClient: videoClient,
          videoFile: (_) => _FakeFile(
            '/clip.mp4',
            chunks: const [
              [1, 2, 3],
            ],
          ),
          videoProcessingDelay: (duration) async => delays.add(duration),
          videoServiceAuthTokenRequest: (_) async => 'service-token',
        );

        final result = await harness.repository.uploadVideo('/clip.mp4');

        expect(delays, const [Duration(seconds: 2), Duration(seconds: 2)]);
        expect(videoClient.requests, hasLength(3));
        for (final request in videoClient.requests.skip(1)) {
          expect(request.method, 'GET');
          expect(request.url.path, '/xrpc/so.sprk.video.getJobStatus');
          expect(request.url.queryParameters['jobId'], 'job-1');
          expect(request.headers['Authorization'], 'Bearer service-token');
        }
        expect(result.videoBlob.mimeType, 'video/mp4');
        expect(result.audioBlob?.mimeType, 'audio/aac');
        expect(result.audioDetails?.artist, 'Artist');
        expect(result.audioDetails?.title, 'Title');
      },
    );

    test(
      'refreshes an expired polling token and retries the request',
      () async {
        final videoClient = _VideoClient()
          ..enqueueJson(200, {
            'jobStatus': {'jobId': 'job-1', 'state': 'JOB_STATE_PROCESSING'},
          })
          ..enqueueJson(401, {'message': 'JWT has expired'})
          ..enqueueJson(200, {
            'jobStatus': {
              'jobId': 'job-1',
              'state': 'JOB_STATE_COMPLETED',
              'blob': _blobJson(mimeType: 'video/mp4', size: 3),
            },
          });
        var tokenRequests = 0;
        final harness = _Harness(
          now: fixedNow,
          oauth: true,
          videoHttpClient: videoClient,
          videoFile: (_) => _FakeFile(
            '/clip.mp4',
            chunks: const [
              [1, 2, 3],
            ],
          ),
          videoProcessingDelay: (_) async {},
          videoServiceAuthTokenRequest: (_) async {
            tokenRequests++;
            if (tokenRequests == 2) {
              throw StateError('PDS token expired');
            }
            return tokenRequests == 1 ? 'old-token' : 'new-token';
          },
        );

        await harness.repository.uploadVideo('/clip.mp4');

        expect(tokenRequests, 3);
        expect(harness.auth.refreshTokenCalls, 1);
        expect(videoClient.requests, hasLength(3));
        expect(
          videoClient.requests[1].headers['Authorization'],
          'Bearer old-token',
        );
        expect(
          videoClient.requests[2].headers['Authorization'],
          'Bearer new-token',
        );
      },
    );

    test('fails after three consecutive polling errors', () async {
      final videoClient = _VideoClient()
        ..enqueueJson(200, {
          'jobStatus': {'jobId': 'job-1', 'state': 'JOB_STATE_PROCESSING'},
        })
        ..enqueueJson(500, {'message': 'first'})
        ..enqueueJson(502, {'message': 'second'})
        ..enqueueJson(503, {'message': 'third'});
      var delays = 0;
      final harness = _Harness(
        now: fixedNow,
        oauth: true,
        videoHttpClient: videoClient,
        videoFile: (_) => _FakeFile(
          '/clip.mp4',
          chunks: const [
            [1],
          ],
        ),
        videoProcessingDelay: (_) async => delays++,
        videoServiceAuthTokenRequest: (_) async => 'service-token',
      );

      await expectLater(
        harness.repository.uploadVideo('/clip.mp4'),
        throwsA(
          isA<VideoUploadException>().having(
            (error) => error.message,
            'message',
            contains('third'),
          ),
        ),
      );
      expect(delays, 3);
      expect(videoClient.requests, hasLength(4));
    });

    test(
      'fails failed jobs and times out processing without wall-clock waits',
      () async {
        final failedClient = _VideoClient()
          ..enqueueJson(200, {
            'jobStatus': {
              'jobId': 'failed-job',
              'state': 'JOB_STATE_FAILED',
              'error': 'TranscodeFailed',
              'message': 'unsupported codec',
            },
          });
        final failedHarness = _Harness(
          now: fixedNow,
          oauth: true,
          videoHttpClient: failedClient,
          videoFile: (_) => _FakeFile(
            '/clip.mp4',
            chunks: const [
              [1],
            ],
          ),
          videoServiceAuthTokenRequest: (_) async => 'service-token',
        );
        await expectLater(
          failedHarness.repository.uploadVideo('/clip.mp4'),
          throwsA(
            isA<VideoUploadException>().having(
              (error) => error.message,
              'message',
              contains('unsupported codec'),
            ),
          ),
        );

        final timeoutClient = _VideoClient()
          ..enqueueJson(200, {
            'jobStatus': {'jobId': 'slow-job', 'state': 'JOB_STATE_PROCESSING'},
          });
        for (var i = 0; i < 120; i++) {
          timeoutClient.enqueueJson(200, {
            'jobStatus': {'jobId': 'slow-job', 'state': 'JOB_STATE_PROCESSING'},
          });
        }
        var delays = 0;
        final timeoutHarness = _Harness(
          now: fixedNow,
          oauth: true,
          videoHttpClient: timeoutClient,
          videoFile: (_) => _FakeFile(
            '/clip.mp4',
            chunks: const [
              [1],
            ],
          ),
          videoProcessingDelay: (_) async => delays++,
          videoServiceAuthTokenRequest: (_) async => 'service-token',
        );
        await expectLater(
          timeoutHarness.repository.uploadVideo('/clip.mp4'),
          throwsA(
            isA<VideoUploadException>().having(
              (error) => error.message,
              'message',
              contains('timed out'),
            ),
          ),
        );
        expect(delays, 121);
        expect(timeoutClient.requests, hasLength(121));
      },
    );
  });
}

Map<String, dynamic> _blobJson({required String mimeType, required int size}) =>
    {
      r'$type': 'blob',
      'mimeType': mimeType,
      'size': size,
      'ref': {r'$link': 'bafkreigh2akiscaildc2'},
    };

PostView _postView() {
  return PostView(
    uri: AtUri('at://did:plc:author/so.sprk.feed.post/post'),
    cid: 'post-cid',
    author: const ProfileViewBasic(
      did: 'did:plc:author',
      handle: 'author.test',
    ),
    record: const <String, dynamic>{
      r'$type': 'so.sprk.feed.post',
      'caption': {'text': 'A post', 'facets': <dynamic>[]},
      'createdAt': '2026-07-22T12:00:00.000Z',
    },
    indexedAt: DateTime.utc(2026, 7, 22, 12),
  );
}

void _expectStrongRef(
  Object? value, {
  required AtUri uri,
  required String cid,
}) {
  final ref = value as Map<String, dynamic>;
  expect(ref[r'$type'], 'com.atproto.repo.strongRef');
  expect(ref['uri'], uri.toString());
  expect(ref['cid'], cid);
}

class _Harness {
  _Harness({
    required DateTime now,
    Map<String, dynamic> response = const <String, dynamic>{
      'feed': <dynamic>[],
    },
    int statusCode = 200,
    bool authenticated = true,
    bool atprotoInitialized = true,
    bool oauth = false,
    http.Client? videoHttpClient,
    Future<void> Function(Duration)? videoProcessingDelay,
    File Function(String)? videoFile,
    Future<String> Function(PoptartClient)? videoServiceAuthTokenRequest,
  }) : transport = _Transport(response: response, statusCode: statusCode),
       repo = _FakeRepoRepository() {
    final client = oauth
        ? PoptartClient.fromOAuthSession(
            restoreOAuthSession(
              accessToken: 'opaque-access-token',
              refreshToken: 'opaque-refresh-token',
              scope: 'atproto',
              expiresAt: DateTime.utc(2030),
              sub: 'did:plc:viewer',
              clientId: 'https://spark.test/client-metadata.json',
              pdsEndpoint: 'pds.test',
              publicKey: 'unused-public-key',
              privateKey: 'unused-private-key',
            ),
            service: 'pds.test',
            getClient: transport.get,
          )
        : PoptartClient.anonymous(
            service: 'pds.test',
            getClient: transport.get,
          );
    auth = _FakeAuthRepository(
      authenticated: authenticated,
      atproto: atprotoInitialized ? client : null,
    );
    sprk = _FakeSprkRepository(auth: auth, repo: repo);
    repository = FeedRepositoryImpl(
      sprk,
      logger: SparkLogger(),
      now: () => now,
      videoHttpClient: videoHttpClient,
      videoProcessingDelay: videoProcessingDelay,
      videoFile: videoFile,
      videoServiceAuthTokenRequest: videoServiceAuthTokenRequest,
    );
  }

  static const sprkDid = 'did:web:sprk.test';
  static const bskyDid = 'did:web:bsky.test';

  final _Transport transport;
  final _FakeRepoRepository repo;
  late final _FakeAuthRepository auth;
  late final _FakeSprkRepository sprk;
  late final FeedRepositoryImpl repository;
}

class _Transport {
  _Transport({required this.response, required this.statusCode});

  final Map<String, dynamic> response;
  final int statusCode;
  final List<_Request> requests = [];

  _Request get singleRequest => requests.single;

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) async {
    requests.add(_Request(uri: uri, headers: headers ?? const {}));
    return http.Response(
      jsonEncode(response),
      statusCode,
      headers: const {'content-type': 'application/json'},
      request: http.Request('GET', uri),
    );
  }
}

class _Request {
  const _Request({required this.uri, required this.headers});

  final Uri uri;
  final Map<String, String> headers;
}

class _VideoClient extends http.BaseClient {
  final List<_QueuedResponse> _responses = [];
  final List<_VideoRequest> requests = [];

  void enqueueJson(int statusCode, Map<String, dynamic> body) {
    _responses.add(_QueuedResponse(statusCode, jsonEncode(body)));
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final bodyBytes = await request.finalize().toBytes();
    requests.add(
      _VideoRequest(
        method: request.method,
        url: request.url,
        headers: Map<String, String>.from(request.headers),
        bodyBytes: bodyBytes,
      ),
    );
    if (_responses.isEmpty) {
      throw StateError('No queued video response for ${request.method}');
    }
    final response = _responses.removeAt(0);
    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(response.body)),
      response.statusCode,
      headers: const {'content-type': 'application/json'},
      request: request,
    );
  }
}

class _QueuedResponse {
  const _QueuedResponse(this.statusCode, this.body);

  final int statusCode;
  final String body;
}

class _VideoRequest {
  const _VideoRequest({
    required this.method,
    required this.url,
    required this.headers,
    required this.bodyBytes,
  });

  final String method;
  final Uri url;
  final Map<String, String> headers;
  final Uint8List bodyBytes;
}

class _FakeFile implements File {
  _FakeFile(
    this.path, {
    bool exists = true,
    this.chunks = const <List<int>>[],
    this.lengthOverride,
  }) : _shouldExist = exists;

  @override
  final String path;
  final bool _shouldExist;
  final List<List<int>> chunks;
  final int? lengthOverride;

  @override
  bool existsSync() => _shouldExist;

  @override
  Future<int> length() async =>
      lengthOverride ??
      chunks.fold<int>(0, (total, chunk) => total + chunk.length);

  @override
  Stream<List<int>> openRead([int? start, int? end]) =>
      Stream<List<int>>.fromIterable(chunks);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.authenticated, required this.atproto});

  final bool authenticated;
  int refreshTokenCalls = 0;

  @override
  final PoptartClient? atproto;

  @override
  bool get isAuthenticated => authenticated;

  @override
  Future<bool> refreshToken() async {
    refreshTokenCalls++;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSprkRepository implements SprkRepository {
  _FakeSprkRepository({required this.auth, required this.repo});

  final _FakeAuthRepository auth;

  @override
  final RepoRepository repo;

  @override
  AuthRepository get authRepository => auth;

  @override
  String get sprkDid => _Harness.sprkDid;

  @override
  String get bskyDid => _Harness.bskyDid;

  @override
  Future<T> executeWithRetry<T>(Future<T> Function() apiCall) => apiCall();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRepoRepository implements RepoRepository {
  final List<_CreateCall> createCalls = [];
  final List<_DeleteCall> deleteCalls = [];
  Object? createError;

  @override
  Future<RepoStrongRef> createRecord({
    required String collection,
    required Map<String, dynamic> record,
    String? rkey,
    String? repo,
  }) async {
    createCalls.add(_CreateCall(collection: collection, record: record));
    if (createError case final Object error) {
      throw error;
    }
    return RepoStrongRef(
      uri: AtUri('at://did:plc:viewer/$collection/result'),
      cid: 'result-cid',
    );
  }

  @override
  Future<void> deleteRecord({
    required AtUri uri,
    bool skipBskyCrosspostCleanup = false,
  }) async {
    deleteCalls.add(
      _DeleteCall(uri: uri, skipBskyCrosspostCleanup: skipBskyCrosspostCleanup),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CreateCall {
  const _CreateCall({required this.collection, required this.record});

  final String collection;
  final Map<String, dynamic> record;
}

class _DeleteCall {
  const _DeleteCall({
    required this.uri,
    required this.skipBskyCrosspostCleanup,
  });

  final AtUri uri;
  final bool skipBskyCrosspostCleanup;
}
