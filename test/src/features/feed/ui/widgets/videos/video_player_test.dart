import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/l10n/app_localization_delegates.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_player.dart';

void main() {
  late _FakeVideoPlatform platform;
  late BetterPlayerPlatform previousPlatform;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<LogService>(LogService());
    previousPlatform = BetterPlayerPlatform.instance;
    platform = _FakeVideoPlatform();
    BetterPlayerPlatform.instance = platform;
  });

  tearDown(() async {
    await platform.close();
    BetterPlayerPlatform.instance = previousPlatform;
    await GetIt.I.reset();
  });

  group('video availability UI', () {
    for (final status in [200, 202, 503]) {
      testWidgets('only HTTP 202 shows processing (initial HTTP $status)', (
        tester,
      ) async {
        final firstResponse = Completer<http.Response>();
        var requests = 0;

        await http.runWithClient(
          () async {
            await tester.pumpWidget(_videoApp());
            await tester.pump();
            expect(find.text('Preparing video…'), findsNothing);
            expect(find.byType(CircularProgressIndicator), findsNothing);
            expect(platform.calls, isEmpty);

            firstResponse.complete(http.Response('', status));
            await tester.pump();
            await tester.pump();
            expect(
              find.text('Preparing video…'),
              status == 202 ? findsOneWidget : findsNothing,
            );
            expect(
              find.byType(CircularProgressIndicator),
              status == 202 ? findsOneWidget : findsNothing,
            );

            await tester.pump(const Duration(seconds: 2));
            await tester.pump();
            expect(platform.calls, contains('setDataSource'));
            expect(find.text('Preparing video…'), findsNothing);
            expect(find.byType(CircularProgressIndicator), findsNothing);
            expect(find.text('Video couldn’t load'), findsNothing);

            await tester.pumpWidget(const SizedBox.shrink());
            await _flushPlayer(tester);
            expect(tester.takeException(), isNull);
          },
          () => _VideoHttpClient((_) {
            requests++;
            return requests == 1
                ? firstResponse.future
                : Future.value(http.Response('', 200));
          }),
        );
      });
    }

    testWidgets('ignores a stale processing response after replacing the URL', (
      tester,
    ) async {
      final oldResponse = Completer<http.Response>();
      final newResponse = Completer<http.Response>();
      await http.runWithClient(
        () async {
          await tester.pumpWidget(_videoApp());
          await tester.pump();
          await tester.pumpWidget(_videoApp(videoUrl: '$_videoUrl?new'));
          await tester.pump();

          oldResponse.complete(http.Response('', 202));
          await tester.pump();
          await tester.pump();
          expect(find.text('Preparing video…'), findsNothing);
          expect(platform.calls, isEmpty);

          newResponse.complete(http.Response('', 202));
          await tester.pump();
          await tester.pump();
          expect(find.text('Preparing video…'), findsOneWidget);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          expect(tester.takeException(), isNull);
        },
        () => _VideoHttpClient((request) {
          return request.url.query.isEmpty
              ? oldResponse.future
              : newResponse.future;
        }),
      );
    });

    testWidgets('shows preparing until ready and cancels on disposal', (
      tester,
    ) async {
      var requests = 0;
      late _VideoHttpClient client;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(_videoApp());
          await tester.pump();

          expect(find.text('Preparing video…'), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(platform.calls, isEmpty);
          expect(requests, 1);

          await tester.pump(const Duration(seconds: 2));
          expect(requests, 2);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 10));

          expect(requests, 2);
          expect(client.closed, isTrue);
          expect(platform.calls, isEmpty);
          expect(tester.takeException(), isNull);
        },
        () {
          return client = _VideoHttpClient((_) async {
            requests++;
            return http.Response('', 202);
          });
        },
      );
    });

    testWidgets('pauses readiness polling while inactive and resumes', (
      tester,
    ) async {
      var requests = 0;
      final clients = <_VideoHttpClient>[];
      await http.runWithClient(
        () async {
          await tester.pumpWidget(_videoApp());
          await tester.pump();
          expect(requests, 1);

          await tester.pumpWidget(_videoApp(isActive: false));
          await tester.pump(const Duration(seconds: 10));
          expect(requests, 1);
          expect(clients.single.closed, isTrue);
          expect(find.text('Preparing video…'), findsNothing);

          await tester.pumpWidget(_videoApp());
          await tester.pump();
          expect(requests, 2);
          expect(clients, hasLength(2));
          expect(find.text('Preparing video…'), findsOneWidget);
          expect(platform.calls, isEmpty);
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () {
          final client = _VideoHttpClient((_) async {
            requests++;
            return http.Response('', 202);
          });
          clients.add(client);
          return client;
        },
      );
    });

    testWidgets('ignores stale readiness after replacing the video URL', (
      tester,
    ) async {
      final oldResponse = Completer<http.Response>();
      final requestedUrls = <Uri>[];
      await http.runWithClient(
        () async {
          await tester.pumpWidget(_videoApp());
          await tester.pump();
          await tester.pumpWidget(_videoApp(videoUrl: '$_videoUrl?new'));
          await tester.pump();
          oldResponse.complete(http.Response('', 200));
          await tester.pump();

          expect(requestedUrls, [
            Uri.parse(_videoUrl),
            Uri.parse('$_videoUrl?new'),
          ]);
          expect(find.text('Preparing video…'), findsOneWidget);
          expect(platform.calls, isEmpty);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => _VideoHttpClient((request) {
          requestedUrls.add(request.url);
          return request.url.query.isEmpty
              ? oldResponse.future
              : Future.value(http.Response('', 202));
        }),
      );
    });

    testWidgets('a terminal failure offers retry and returns to preparing', (
      tester,
    ) async {
      var requests = 0;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(_videoApp());
          await tester.pump();

          expect(find.text('Video couldn’t load'), findsOneWidget);
          expect(find.text('Retry'), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsNothing);
          await tester.tap(find.byType(AppButton));
          await tester.pump();

          expect(requests, 2);
          expect(find.text('Preparing video…'), findsOneWidget);
          expect(find.text('Retry'), findsNothing);
          expect(platform.calls, isEmpty);
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => _VideoHttpClient((_) async {
          requests++;
          return http.Response('', requests == 1 ? 404 : 202);
        }),
      );
    });

    for (final transition in ['ready', 'reactivate', 'retry', 'new video']) {
      testWidgets('preserves preparation pause through $transition', (
        tester,
      ) async {
        platform.autoInitialize = true;
        var ready = false;
        var fail = false;
        await http.runWithClient(
          () async {
            await tester.pumpWidget(_videoApp());
            await tester.pump();
            tester
                .state<PostVideoPlayerState>(find.byType(PostVideoPlayer))
                .pauseVideo();
            await tester.pump();
            expect(platform.calls, isEmpty);

            switch (transition) {
              case 'reactivate':
                await tester.pumpWidget(_videoApp(isActive: false));
                await tester.pumpWidget(_videoApp());
              case 'retry':
                fail = true;
                await tester.pump(const Duration(seconds: 2));
                expect(find.text('Video couldn’t load'), findsOneWidget);
                fail = false;
                await tester.tap(find.byType(AppButton));
                await tester.pump();
              case 'new video':
                await tester.pumpWidget(_videoApp(videoUrl: '$_videoUrl?new'));
              case 'ready':
                break;
            }
            ready = true;
            await tester.pump(const Duration(seconds: 2));
            await tester.pump();
            await _flushPlayer(tester);
            expect(find.byType(BetterPlayer), findsOneWidget);
            expect(tester.takeException(), isNull);
            if (transition == 'new video') {
              expect(platform.calls, contains('play'));
            } else {
              expect(platform.calls, isNot(contains('play')));
              await tester.tapAt(
                tester.getCenter(find.byType(PostVideoPlayer)),
              );
              await tester.pump();
              expect(platform.calls, contains('play'));
            }
            await tester.pumpWidget(const SizedBox.shrink());
            await _flushPlayer(tester);
          },
          () => _VideoHttpClient((_) async {
            return http.Response(
              '#EXTM3U\n',
              fail
                  ? 404
                  : ready
                  ? 200
                  : 202,
            );
          }),
        );
      });
    }

    testWidgets(
      'starts native playback once a pending playlist becomes ready',
      (tester) async {
        platform.autoInitialize = true;
        var requests = 0;
        await http.runWithClient(
          () async {
            await tester.pumpWidget(_videoApp());
            await tester.pump();
            expect(platform.calls, isEmpty);

            await tester.pump(const Duration(seconds: 2));
            await tester.pump();

            await _flushPlayer(tester);
            expect(platform.calls, contains('create'));
            expect(platform.calls, contains('setDataSource'));
            expect(platform.calls, contains('play'));
            expect(find.byType(BetterPlayer), findsOneWidget);
            expect(find.text('Preparing video…'), findsNothing);
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
            await _flushPlayer(tester);
            await tester.pump(const Duration(seconds: 1));
          },
          () => _VideoHttpClient((_) async {
            requests++;
            return http.Response('#EXTM3U\n', requests == 1 ? 202 : 200);
          }),
        );
      },
    );
  });

  testWidgets('disposal cancels an unfinished native initialization', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await tester.pumpWidget(_videoApp());
      await tester.pump();
      expect(platform.calls, contains('setDataSource'));
      expect(find.text('Preparing video…'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await _flushPlayer(tester);

      expect(platform.calls, contains('dispose'));
      expect(platform.activePlayers, isEmpty);
      expect(platform.calls, isNot(contains('play')));
      expect(tester.takeException(), isNull);
    }, () => _VideoHttpClient((_) async => http.Response('', 200)));
  });

  testWidgets('native setup failure offers retry and recovers playback', (
    tester,
  ) async {
    platform
      ..autoInitialize = true
      ..setupFailuresRemaining = 1;
    await http.runWithClient(() async {
      await tester.pumpWidget(_videoApp());
      await _flushPlayer(tester);

      expect(find.text('Video couldn’t load'), findsOneWidget);
      expect(platform.calls, isNot(contains('play')));
      await tester.tap(find.byType(AppButton));
      await _flushPlayer(tester);

      expect(find.byType(BetterPlayer), findsOneWidget);
      expect(platform.calls, contains('play'));
      expect(platform.calls.where((call) => call == 'create'), hasLength(2));
      await tester.pumpWidget(const SizedBox.shrink());
      await _flushPlayer(tester);
      expect(tester.takeException(), isNull);
    }, () => _VideoHttpClient((_) async => http.Response('', 200)));
  });

  testWidgets('pause during native initialization prevents delayed autoplay', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await tester.pumpWidget(_videoApp());
      await tester.pump();
      expect(platform.calls, contains('setDataSource'));
      tester
          .state<PostVideoPlayerState>(find.byType(PostVideoPlayer))
          .pauseVideo();

      platform.initialize(platform.activePlayers.single);
      await _flushPlayer(tester);

      expect(find.byType(BetterPlayer), findsOneWidget);
      expect(platform.calls, isNot(contains('play')));
      await tester.tapAt(tester.getCenter(find.byType(PostVideoPlayer)));
      await tester.pump();
      expect(platform.calls, contains('play'));
      await tester.pumpWidget(const SizedBox.shrink());
      await _flushPlayer(tester);
      expect(tester.takeException(), isNull);
    }, () => _VideoHttpClient((_) async => http.Response('', 200)));
  });

  testWidgets('leaving during native initialization releases the player', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await tester.pumpWidget(_videoApp());
      await tester.pump();
      expect(platform.calls, contains('setDataSource'));

      await tester.pumpWidget(_videoApp(isActive: false));
      await _flushPlayer(tester);
      expect(platform.activePlayers, isEmpty);
      expect(platform.calls, isNot(contains('play')));

      platform.autoInitialize = true;
      await tester.pumpWidget(_videoApp());
      await _flushPlayer(tester);
      expect(platform.calls.where((call) => call == 'create'), hasLength(2));
      expect(platform.calls, contains('play'));
      await tester.pumpWidget(const SizedBox.shrink());
      await _flushPlayer(tester);
      expect(tester.takeException(), isNull);
    }, () => _VideoHttpClient((_) async => http.Response('', 200)));
  });

  group('hasRenderableFeedVideoPlaybackFrame', () {
    test('requires initialized playing video beyond the first position', () {
      final readyValue = VideoPlayerValue(
        duration: Duration(seconds: 3),
        isPlaying: true,
        position: Duration(milliseconds: 1),
        size: Size(1080, 1920),
      );

      expect(hasRenderableFeedVideoPlaybackFrame(readyValue), isTrue);
      expect(
        hasRenderableFeedVideoPlaybackFrame(
          readyValue.copyWith(position: Duration.zero),
        ),
        isFalse,
      );
      expect(
        hasRenderableFeedVideoPlaybackFrame(
          readyValue.copyWith(isPlaying: false),
        ),
        isFalse,
      );
      expect(
        hasRenderableFeedVideoPlaybackFrame(
          VideoPlayerValue.uninitialized().copyWith(
            isPlaying: true,
            position: const Duration(milliseconds: 1),
            size: const Size(1080, 1920),
          ),
        ),
        isFalse,
      );
    });

    test('requires a non-zero rendered size', () {
      final readyValue = VideoPlayerValue(
        duration: Duration(seconds: 3),
        isPlaying: true,
        position: Duration(milliseconds: 1),
        size: Size(1080, 1920),
      );

      expect(
        hasRenderableFeedVideoPlaybackFrame(
          readyValue.copyWith(size: Size.zero),
        ),
        isFalse,
      );
      expect(
        hasRenderableFeedVideoPlaybackFrame(
          readyValue.copyWith(size: const Size(1080, 0)),
        ),
        isFalse,
      );
    });
  });
}

const _videoUrl = 'https://video.example/watch/did/cid/playlist.m3u8';

Widget _videoApp({bool isActive = true, String videoUrl = _videoUrl}) {
  return MaterialApp(
    localizationsDelegates: appLocalizationDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: PostVideoPlayer(
        videoUrl: videoUrl,
        thumbnail: '',
        isActive: isActive,
      ),
    ),
  );
}

class _VideoHttpClient extends MockClient {
  _VideoHttpClient(super.fn);

  bool closed = false;

  @override
  void close() {
    closed = true;
    super.close();
  }
}

Future<void> _flushPlayer(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pump();
  await tester.pump();
}

class _FakeVideoPlatform extends BetterPlayerPlatform {
  final calls = <String>[];
  final _events = <int, StreamController<VideoEvent>>{};
  final _sources = <int, DataSource>{};
  var _nextId = 0;
  bool autoInitialize = false;
  int setupFailuresRemaining = 0;

  Iterable<int> get activePlayers => _events.keys;

  @override
  Future<int?> create({BufferingConfiguration? bufferingConfiguration}) async {
    calls.add('create');
    final id = ++_nextId;
    _events[id] = StreamController<VideoEvent>.broadcast();
    return id;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int? textureId) =>
      _events[textureId]!.stream;

  @override
  Future<void> setDataSource(int? textureId, DataSource dataSource) async {
    calls.add('setDataSource');
    if (setupFailuresRemaining > 0) {
      setupFailuresRemaining--;
      throw StateError('Native video setup failed');
    }
    _sources[textureId!] = dataSource;
    if (autoInitialize) initialize(textureId);
  }

  void initialize(int textureId) {
    _events[textureId]?.add(
      VideoEvent(
        eventType: VideoEventType.initialized,
        duration: const Duration(seconds: 10),
        size: const Size(1080, 1920),
        key: _sources[textureId]!.key,
      ),
    );
  }

  @override
  Future<void> dispose(int? textureId) async {
    calls.add('dispose');
    _sources.remove(textureId);
    await _events.remove(textureId)?.close();
  }

  Future<void> close() async {
    for (final id in activePlayers.toList()) {
      await dispose(id);
    }
  }

  @override
  Future<void> play(int? textureId) async => calls.add('play');

  @override
  Future<void> pause(int? textureId) async => calls.add('pause');

  @override
  Future<void> setLooping(int? textureId, bool looping) async {}

  @override
  Future<void> setVolume(int? textureId, double volume) async {}

  @override
  Future<void> setSpeed(int? textureId, double speed) async {}

  @override
  Future<void> setTrackParameters(
    int? textureId,
    int? width,
    int? height,
    int? bitrate,
  ) async {}

  @override
  Future<Duration> getPosition(int? textureId) async => Duration.zero;

  @override
  Future<DateTime?> getAbsolutePosition(int? textureId) async => null;

  @override
  Future<void> seekTo(int? textureId, Duration? position) async {}

  @override
  Future<void> setMixWithOthers(int? textureId, bool mixWithOthers) async {}

  @override
  Future<void> setTextTrack(int? textureId, String? name, int? index) async {}

  @override
  Future<void> setAudioTrack(int? textureId, String? name, int? index) async {}

  @override
  Future<void> setupLogCallback(
    void Function({required int levelIndex, required String message})? callback,
  ) async {}

  @override
  Widget buildView(int? textureId) => const SizedBox.expand();
}
