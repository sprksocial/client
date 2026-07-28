import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository_impl.dart';
import 'package:spark/src/core/network/atproto/data/services/video_upload_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/core/utils/video_upload_exception.dart';

import '../repositories/repository_test_support.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 7, 22, 12, 34, 56);

  FeedRepositoryImpl repository({
    required RepositoryHarness harness,
    required _VideoClient videoClient,
    required File Function(String) file,
    Future<void> Function(Duration)? processingDelay,
    Future<String> Function(PoptartClient)? serviceAuthTokenRequest,
  }) {
    return FeedRepositoryImpl(
      harness.sprk,
      logger: SparkLogger(),
      now: () => fixedNow,
      videoUploadService: VideoUploadClient(
        harness.auth,
        logger: SparkLogger(),
        now: () => fixedNow,
        httpClientFactory: () => videoClient,
        file: file,
        processingDelay: processingDelay,
        serviceAuthTokenRequest: serviceAuthTokenRequest,
      ),
    );
  }

  group('VideoUploadClient', () {
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
      final harness = RepositoryHarness(oauth: true);
      final feedRepository = repository(
        harness: harness,
        videoClient: videoClient,
        file: (path) => files[path]!,
        serviceAuthTokenRequest: (_) async => 'service-token',
      );

      await expectLater(
        feedRepository.uploadVideo('/missing.mp4'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Video file not found'),
          ),
        ),
      );
      await expectLater(
        feedRepository.uploadVideo('/empty.mp4'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Video file is empty'),
          ),
        ),
      );
      await expectLater(
        feedRepository.uploadVideo('/huge.mp4'),
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
      expect(videoClient.closed, isFalse);
    });

    test(
      'streams bytes, reports progress, parses a blob, and closes HTTP',
      () async {
        final videoClient = _VideoClient()
          ..enqueueJson(200, {
            'blobRef': _blobJson(mimeType: 'video/quicktime', size: 6),
          });
        final progress = <double>[];
        final harness = RepositoryHarness(oauth: true);
        final feedRepository = repository(
          harness: harness,
          videoClient: videoClient,
          file: (_) => _FakeFile(
            '/clip.mov',
            chunks: const [
              [1, 2],
              [3, 4, 5, 6],
            ],
          ),
          serviceAuthTokenRequest: (_) async => 'service-token',
        );

        final result = await feedRepository.uploadVideo(
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
        expect(videoClient.closed, isTrue);
      },
    );

    test('maps upload rejection details and closes HTTP', () async {
      final videoClient = _VideoClient()
        ..enqueueJson(413, {
          'error': 'PayloadTooLarge',
          'message': 'limit is 100 MB',
        });
      final harness = RepositoryHarness(oauth: true);
      final feedRepository = repository(
        harness: harness,
        videoClient: videoClient,
        file: (_) => _FakeFile(
          '/clip.mp4',
          chunks: const [
            [1, 2, 3],
          ],
        ),
        serviceAuthTokenRequest: (_) async => 'service-token',
      );

      await expectLater(
        feedRepository.uploadVideo('/clip.mp4'),
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
      expect(videoClient.closed, isTrue);
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
        final harness = RepositoryHarness(oauth: true);
        final feedRepository = repository(
          harness: harness,
          videoClient: videoClient,
          file: (_) => _FakeFile(
            '/clip.mp4',
            chunks: const [
              [1, 2, 3],
            ],
          ),
          processingDelay: (duration) async => delays.add(duration),
          serviceAuthTokenRequest: (_) async => 'service-token',
        );

        final result = await feedRepository.uploadVideo('/clip.mp4');

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
        expect(videoClient.closed, isTrue);
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
        final harness = RepositoryHarness(oauth: true);
        final feedRepository = repository(
          harness: harness,
          videoClient: videoClient,
          file: (_) => _FakeFile(
            '/clip.mp4',
            chunks: const [
              [1, 2, 3],
            ],
          ),
          processingDelay: (_) async {},
          serviceAuthTokenRequest: (_) async {
            tokenRequests++;
            if (tokenRequests == 2) {
              throw StateError('PDS token expired');
            }
            return tokenRequests == 1 ? 'old-token' : 'new-token';
          },
        );

        await feedRepository.uploadVideo('/clip.mp4');

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
        expect(videoClient.closed, isTrue);
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
      final harness = RepositoryHarness(oauth: true);
      final feedRepository = repository(
        harness: harness,
        videoClient: videoClient,
        file: (_) => _FakeFile(
          '/clip.mp4',
          chunks: const [
            [1],
          ],
        ),
        processingDelay: (_) async => delays++,
        serviceAuthTokenRequest: (_) async => 'service-token',
      );

      await expectLater(
        feedRepository.uploadVideo('/clip.mp4'),
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
      expect(videoClient.closed, isTrue);
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
        final failedHarness = RepositoryHarness(oauth: true);
        final failedRepository = repository(
          harness: failedHarness,
          videoClient: failedClient,
          file: (_) => _FakeFile(
            '/clip.mp4',
            chunks: const [
              [1],
            ],
          ),
          serviceAuthTokenRequest: (_) async => 'service-token',
        );
        await expectLater(
          failedRepository.uploadVideo('/clip.mp4'),
          throwsA(
            isA<VideoUploadException>().having(
              (error) => error.message,
              'message',
              contains('unsupported codec'),
            ),
          ),
        );
        expect(failedClient.closed, isTrue);

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
        final timeoutHarness = RepositoryHarness(oauth: true);
        final timeoutRepository = repository(
          harness: timeoutHarness,
          videoClient: timeoutClient,
          file: (_) => _FakeFile(
            '/clip.mp4',
            chunks: const [
              [1],
            ],
          ),
          processingDelay: (_) async => delays++,
          serviceAuthTokenRequest: (_) async => 'service-token',
        );
        await expectLater(
          timeoutRepository.uploadVideo('/clip.mp4'),
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
        expect(timeoutClient.closed, isTrue);
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

class _VideoClient extends http.BaseClient {
  final List<_QueuedResponse> _responses = [];
  final List<_VideoRequest> requests = [];
  bool closed = false;

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

  @override
  void close() {
    closed = true;
    super.close();
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
