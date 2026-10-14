import 'dart:async';
import 'dart:io';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/services.dart';
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
  group('video availability UI', () {
    final nativeCalls = <String>[];
    const playerChannel = MethodChannel('better_player_channel');

    setUp(() async {
      await GetIt.I.reset();
      GetIt.I.registerSingleton<LogService>(LogService());
      nativeCalls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(playerChannel, (call) async {
            nativeCalls.add(call.method);
            return null;
          });
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(playerChannel, null);
      await GetIt.I.reset();
    });

    testWidgets('shows preparing until ready and cancels on disposal', (
      tester,
    ) async {
      var requests = 0;
      late _VideoHttpClient client;
      await _withVideoClient(
        () async {
          await tester.pumpWidget(_videoApp());
          await tester.pump();

          expect(find.text('Preparing video…'), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(nativeCalls, isEmpty);
          expect(requests, 1);

          await tester.pump(const Duration(seconds: 2));
          expect(requests, 2);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 10));

          expect(requests, 2);
          expect(client.closed, isTrue);
          expect(nativeCalls, isEmpty);
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
      await _withVideoClient(
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
          expect(nativeCalls, isEmpty);
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
      await _withVideoClient(
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
          expect(nativeCalls, isEmpty);
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
      await _withVideoClient(
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
          expect(nativeCalls, isEmpty);
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
        const events = MethodChannel('better_player_channel/videoEvents3');
        final messenger = tester.binding.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(events, (_) async => null);
        messenger.setMockMethodCallHandler(playerChannel, (call) async {
          nativeCalls.add(call.method);
          if (call.method == 'create') return {'textureId': 3};
          if (call.method == 'position') return 0;
          if (call.method == 'setDataSource') {
            tester.binding.channelBuffers.push(
              events.name,
              const StandardMethodCodec().encodeSuccessEnvelope({
                'event': 'initialized',
                'duration': 10000,
                'width': 1080,
                'height': 1920,
              }),
              (_) {},
            );
          }
          return null;
        });
        addTearDown(() => messenger.setMockMethodCallHandler(events, null));
        var ready = false;
        var fail = false;
        await _withVideoClient(
          () async {
            await tester.pumpWidget(_videoApp());
            await tester.pump();
            tester
                .state<PostVideoPlayerState>(find.byType(PostVideoPlayer))
                .pauseVideo();
            await tester.pump();
            expect(nativeCalls, isEmpty);

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
            expect(find.byType(BetterPlayer), findsOneWidget);
            expect(tester.takeException(), isNull);
            if (transition == 'new video') {
              expect(nativeCalls, contains('play'));
            } else {
              expect(nativeCalls, isNot(contains('play')));
              await tester.tapAt(
                tester.getCenter(find.byType(PostVideoPlayer)),
              );
              await tester.pump();
              expect(nativeCalls, contains('play'));
            }
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.runAsync(() => Future<void>.delayed(Duration.zero));
            await tester.pump();
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
        const events = MethodChannel('better_player_channel/videoEvents1');
        final messenger = tester.binding.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(events, (_) async => null);
        messenger.setMockMethodCallHandler(playerChannel, (call) async {
          nativeCalls.add(call.method);
          if (call.method == 'create') return {'textureId': 1};
          if (call.method == 'position') return 0;
          if (call.method == 'setDataSource') {
            tester.binding.channelBuffers.push(
              events.name,
              const StandardMethodCodec().encodeSuccessEnvelope({
                'event': 'initialized',
                'duration': 10000,
                'width': 1080,
                'height': 1920,
              }),
              (_) {},
            );
          }
          return null;
        });
        addTearDown(() => messenger.setMockMethodCallHandler(events, null));
        var requests = 0;
        await _withVideoClient(
          () async {
            await tester.pumpWidget(_videoApp());
            await tester.pump();
            expect(nativeCalls, isEmpty);

            await tester.pump(const Duration(seconds: 2));
            await tester.pump();

            expect(nativeCalls, contains('create'));
            expect(nativeCalls, contains('setDataSource'));
            expect(nativeCalls, contains('play'));
            expect(find.byType(BetterPlayer), findsOneWidget);
            expect(find.text('Preparing video…'), findsNothing);
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
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
    const playerChannel = MethodChannel('better_player_channel');
    const events = MethodChannel('better_player_channel/videoEvents2');
    final messenger = tester.binding.defaultBinaryMessenger;
    final nativeCalls = <String>[];
    messenger.setMockMethodCallHandler(events, (call) async {
      nativeCalls.add('event:${call.method}');
      return null;
    });
    messenger.setMockMethodCallHandler(playerChannel, (call) async {
      nativeCalls.add(call.method);
      return call.method == 'create' ? {'textureId': 2} : null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(events, null);
      messenger.setMockMethodCallHandler(playerChannel, null);
    });

    await _withVideoClient(() async {
      await tester.pumpWidget(_videoApp());
      await tester.pump();
      expect(nativeCalls, contains('setDataSource'));
      expect(find.text('Preparing video…'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(nativeCalls, contains('event:cancel'));
      expect(nativeCalls, isNot(contains('play')));
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

Future<void> _withVideoClient(
  Future<void> Function() body,
  http.Client Function() createClient,
) {
  return HttpOverrides.runZoned(
    () => http.runWithClient(body, createClient),
    createHttpClient: (_) => _UnavailableMetadataClient(),
  );
}

class _UnavailableMetadataClient extends Fake implements HttpClient {
  @override
  set connectionTimeout(Duration? value) {}

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    throw const HttpException('Optional playlist metadata unavailable in test');
  }
}
