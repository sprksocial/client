import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/pro_video_editor/models/sound_audio_track.dart';
import 'package:spark/src/core/pro_video_editor/services/audio_helper_service.dart';
import 'package:spark/src/core/pro_video_editor/services/audio_source_resolver.dart';
import 'package:video_player/video_player.dart';

void main() {
  group('resolveCustomAudioTiming', () {
    test('separates source offset from video placement', () {
      final timing = resolveCustomAudioTiming(
        audioStartTime: const Duration(seconds: 4),
        audioEndTime: const Duration(seconds: 14),
        audioDuration: const Duration(seconds: 30),
        trackStartTime: const Duration(seconds: 6),
        trackEndTime: const Duration(seconds: 16),
        loop: false,
        videoPosition: const Duration(seconds: 9),
        videoStart: Duration.zero,
        videoEnd: const Duration(seconds: 20),
      );

      expect(timing.isActive, isTrue);
      expect(timing.position, const Duration(seconds: 7));
    });

    test('anchors implicit placement to the full video timeline', () {
      final timing = resolveCustomAudioTiming(
        audioStartTime: const Duration(seconds: 2),
        audioEndTime: const Duration(seconds: 12),
        audioDuration: const Duration(seconds: 20),
        trackStartTime: null,
        trackEndTime: null,
        loop: true,
        videoPosition: const Duration(seconds: 13),
        videoStart: const Duration(seconds: 10),
        videoEnd: const Duration(seconds: 18),
      );

      expect(timing.isActive, isTrue);
      expect(timing.position, const Duration(seconds: 5));
    });

    test('is inactive before and after the video placement range', () {
      AudioPlaybackTiming timingAt(Duration position) {
        return resolveCustomAudioTiming(
          audioStartTime: const Duration(seconds: 4),
          audioEndTime: null,
          audioDuration: const Duration(seconds: 30),
          trackStartTime: const Duration(seconds: 6),
          trackEndTime: const Duration(seconds: 16),
          loop: false,
          videoPosition: position,
          videoStart: Duration.zero,
          videoEnd: const Duration(seconds: 20),
        );
      }

      expect(timingAt(const Duration(seconds: 5)).isActive, isFalse);
      expect(timingAt(const Duration(seconds: 16)).isActive, isFalse);
    });

    test('loops only inside the selected source range', () {
      final timing = resolveCustomAudioTiming(
        audioStartTime: const Duration(seconds: 4),
        audioEndTime: const Duration(seconds: 9),
        audioDuration: const Duration(seconds: 30),
        trackStartTime: Duration.zero,
        trackEndTime: const Duration(seconds: 20),
        loop: true,
        videoPosition: const Duration(seconds: 12),
        videoStart: Duration.zero,
        videoEnd: const Duration(seconds: 20),
      );

      expect(timing.isActive, isTrue);
      expect(timing.position, const Duration(seconds: 6));
    });

    test('stops when a non-looping source range is exhausted', () {
      final timing = resolveCustomAudioTiming(
        audioStartTime: const Duration(seconds: 4),
        audioEndTime: const Duration(seconds: 9),
        audioDuration: const Duration(seconds: 30),
        trackStartTime: Duration.zero,
        trackEndTime: const Duration(seconds: 20),
        loop: false,
        videoPosition: const Duration(seconds: 6),
        videoStart: Duration.zero,
        videoEnd: const Duration(seconds: 20),
      );

      expect(timing.isActive, isFalse);
      expect(timing.position, const Duration(seconds: 9));
    });
  });

  group('shouldSeekCustomAudioOnResume', () {
    test('seeks when current position is unavailable', () {
      expect(
        shouldSeekCustomAudioOnResume(
          currentPosition: null,
          targetPosition: const Duration(seconds: 3),
        ),
        isTrue,
      );
    });

    test('does not seek when already close to the target position', () {
      expect(
        shouldSeekCustomAudioOnResume(
          currentPosition: const Duration(milliseconds: 3100),
          targetPosition: const Duration(seconds: 3),
        ),
        isFalse,
      );
    });

    test('seeks when current position is far from the target position', () {
      expect(
        shouldSeekCustomAudioOnResume(
          currentPosition: const Duration(seconds: 5),
          targetPosition: const Duration(seconds: 3),
        ),
        isTrue,
      );
    });
  });

  group('AudioHelperService synchronization', () {
    late _FakeAudioPlayer audioPlayer;
    late AudioHelperService service;

    setUp(() {
      audioPlayer = _FakeAudioPlayer();
      service = AudioHelperService(
        videoController: VideoPlayerController.asset('unused'),
        audioPlayer: audioPlayer,
      );
    });

    tearDown(() => service.pause());

    test('never throttles pause and resume state changes', () async {
      final track = _track('track', 'https://example.com/track.mp3');

      await service.synchronizePlayback(
        track,
        videoPosition: const Duration(seconds: 1),
        videoStart: Duration.zero,
        videoEnd: const Duration(seconds: 10),
        isVideoPlaying: true,
      );
      await service.synchronizePlayback(
        track,
        videoPosition: const Duration(seconds: 1),
        videoStart: Duration.zero,
        videoEnd: const Duration(seconds: 10),
        isVideoPlaying: false,
      );
      await service.synchronizePlayback(
        track,
        videoPosition: const Duration(seconds: 1),
        videoStart: Duration.zero,
        videoEnd: const Duration(seconds: 10),
        isVideoPlaying: true,
      );

      expect(audioPlayer.pauseCount, 1);
      expect(audioPlayer.resumeCount, 2);
      expect(audioPlayer.state, PlayerState.playing);
    });

    test(
      'records a source that finishes loading after becoming stale',
      () async {
        final trackA = _track('a', 'https://example.com/a.mp3');
        final trackB = _track('b', 'https://example.com/b.mp3');
        await service.play(trackA, videoEnd: const Duration(seconds: 10));

        final sourceStarted = Completer<void>();
        final allowSourceToFinish = Completer<void>();
        audioPlayer
          ..sourceStarted = sourceStarted
          ..sourceGate = allowSourceToFinish;

        final playB = service.play(
          trackB,
          videoEnd: const Duration(seconds: 10),
        );
        await sourceStarted.future;
        final pause = service.pause();
        final playA = service.play(
          trackA,
          videoEnd: const Duration(seconds: 10),
        );
        audioPlayer.sourceGate = null;
        allowSourceToFinish.complete();

        await Future.wait([playB, pause, playA]);

        expect(audioPlayer.sourceUrls, [
          'https://example.com/a.mp3',
          'https://example.com/b.mp3',
          'https://example.com/a.mp3',
        ]);
        expect(audioPlayer.currentSourceUrl, 'https://example.com/a.mp3');
        expect(audioPlayer.state, PlayerState.playing);
      },
    );

    test('reports boundary synchronization failures', () async {
      final errorReported = Completer<(Object, StackTrace)>();
      final videoController = VideoPlayerController.asset('unused');
      await videoController.play();
      service = AudioHelperService(
        videoController: videoController,
        audioPlayer: audioPlayer,
        onPlaybackError: (error, stackTrace) {
          errorReported.complete((error, stackTrace));
        },
      );
      final track = AudioTrack(
        id: 'short',
        title: 'short',
        subtitle: 'artist',
        duration: const Duration(milliseconds: 5),
        audio: EditorAudio(networkUrl: 'https://example.com/short.mp3'),
      );

      await service.synchronizePlayback(
        track,
        videoPosition: Duration.zero,
        videoStart: Duration.zero,
        videoEnd: const Duration(seconds: 1),
        isVideoPlaying: true,
      );
      audioPlayer.currentPositionError = StateError('boundary failed');

      final (error, stackTrace) = await errorReported.future.timeout(
        const Duration(seconds: 1),
      );
      expect(error, isA<StateError>());
      expect(stackTrace, isNot(StackTrace.empty));
    });
  });

  group('AudioHelperService assets and mode', () {
    late _FakeAudioPlayer audioPlayer;
    late VideoPlayerController videoController;
    late AudioHelperService service;

    setUp(() {
      audioPlayer = _FakeAudioPlayer();
      videoController = VideoPlayerController.asset('unused');
      service = AudioHelperService(
        videoController: videoController,
        audioPlayer: audioPlayer,
      );
    });

    tearDown(() => service.pause());

    test(
      'strips exactly one assets prefix for the default audio cache',
      () async {
        final track = _assetTrack('assets/assets/audio/track.mp3');

        await service.play(track, videoEnd: const Duration(seconds: 10));

        expect(audioPlayer.currentSource, isA<AssetSource>());
        expect(
          (audioPlayer.currentSource! as AssetSource).path,
          'assets/audio/track.mp3',
        );
      },
    );

    test('leaves asset keys without an assets prefix unchanged', () async {
      final track = _assetTrack('packages/sounds/audio/track.mp3');

      await service.play(track, videoEnd: const Duration(seconds: 10));

      expect(
        (audioPlayer.currentSource! as AssetSource).path,
        'packages/sounds/audio/track.mp3',
      );
    });

    test('preserves negative track balance through play and enable', () async {
      final track = _track(
        'track',
        'https://example.com/track.mp3',
        volume: 0.8,
        volumeBalance: -0.5,
      );

      await service.play(track, videoEnd: const Duration(seconds: 10));
      await service.setAudioMode(useCustom: true);

      expect(audioPlayer.volume, closeTo(0.4, 0.0001));
      expect(videoController.value.volume, 1);
    });

    test(
      'starts in original-only mode and restores the stored custom mix',
      () async {
        final track = _track(
          'track',
          'https://example.com/track.mp3',
          volume: 0.8,
          volumeBalance: 0.25,
        );

        await service.prepare(track, videoEnd: const Duration(seconds: 10));
        expect(audioPlayer.volume, 0);
        expect(videoController.value.volume, 1);

        await service.setAudioMode(useCustom: true);
        expect(audioPlayer.volume, 0.8);
        expect(videoController.value.volume, 0.75);

        await service.setAudioMode(useCustom: false);
        expect(audioPlayer.volume, 0);
        expect(videoController.value.volume, 1);

        await service.setAudioMode(useCustom: true);
        expect(audioPlayer.volume, 0.8);
        expect(videoController.value.volume, 0.75);
      },
    );
  });

  group('resolveAudioMixVolumes', () {
    test('applies track volume before reducing overlay balance', () {
      final volumes = resolveAudioMixVolumes(
        trackVolume: 0.6,
        volumeBalance: -0.5,
      );

      expect(volumes.overlayVolume, closeTo(0.3, 0.0001));
      expect(volumes.originalVolume, 1);
    });

    test('preserves track volume while reducing original balance', () {
      final volumes = resolveAudioMixVolumes(
        trackVolume: 0.6,
        volumeBalance: 0.25,
      );

      expect(volumes.overlayVolume, 0.6);
      expect(volumes.originalVolume, 0.75);
    });

    test('keeps both sources silent while muted after mix updates', () {
      final preparedTrackVolumes = resolveAudioMixVolumes(
        trackVolume: 0.6,
        volumeBalance: 0.25,
        isMuted: true,
      );
      final updatedBalanceVolumes = resolveAudioMixVolumes(
        trackVolume: 0.6,
        volumeBalance: -0.5,
        isMuted: true,
      );

      expect(preparedTrackVolumes.overlayVolume, 0);
      expect(preparedTrackVolumes.originalVolume, 0);
      expect(updatedBalanceVolumes.overlayVolume, 0);
      expect(updatedBalanceVolumes.originalVolume, 0);
    });

    test('restores the latest mix after unmuting', () {
      final volumes = resolveAudioMixVolumes(
        trackVolume: 0.6,
        volumeBalance: -0.5,
      );

      expect(volumes.overlayVolume, closeTo(0.3, 0.0001));
      expect(volumes.originalVolume, 1);
    });

    test('can mute the original and overlay sources independently', () {
      final originalMuted = resolveAudioMixVolumes(
        trackVolume: 0.6,
        volumeBalance: 0.25,
        isOriginalMuted: true,
      );
      final overlayMuted = resolveAudioMixVolumes(
        trackVolume: 0.6,
        volumeBalance: 0.25,
        isOverlayMuted: true,
      );

      expect(originalMuted.originalVolume, 0);
      expect(originalMuted.overlayVolume, 0.6);
      expect(overlayMuted.originalVolume, 0.75);
      expect(overlayMuted.overlayVolume, 0);
    });
  });

  group('customAudioTempFilename', () {
    test('uses the encoded sound audio extension', () {
      final track = AudioTrack(
        id: encodeSoundTrackId(
          'at://did:plc:test/fm.plyr.track/track',
          'cid',
          audioFileExtension: 'm4a',
          audioMimeType: 'audio/mp4',
        ),
        title: 'M4A',
        subtitle: 'artist',
        duration: const Duration(seconds: 9),
        audio: EditorAudio(networkUrl: 'https://example.com/audio'),
      );

      expect(
        customAudioTempFilename(track, taskId: 'export-one'),
        'temp-audio-export-one-0.m4a',
      );
      expect(decodeSoundTrackAudioMimeType(track.id), 'audio/mp4');
    });

    test('falls back to mp3 for legacy track ids', () {
      final track = AudioTrack(
        id: encodeSoundTrackId(
          'at://did:plc:test/so.sprk.sound.audio/track',
          'cid',
        ),
        title: 'Legacy',
        subtitle: 'artist',
        duration: const Duration(seconds: 9),
        audio: EditorAudio(networkUrl: 'https://example.com/audio'),
      );

      expect(
        customAudioTempFilename(track, taskId: 'export/two'),
        'temp-audio-export%2Ftwo-0.mp3',
      );
    });
  });

  group('AudioSourceResolver assets', () {
    test('exports using the full Flutter asset key directly', () async {
      final temporaryDirectory = await Directory.systemTemp.createTemp(
        'audio-source-resolver-test-',
      );
      addTearDown(() async {
        if (await temporaryDirectory.exists()) {
          await temporaryDirectory.delete(recursive: true);
        }
      });
      String? resolvedAssetKey;
      final resolver = AudioSourceResolver(
        temporaryDirectoryProvider: () async => temporaryDirectory,
        assetAudioPathWriter: (source, target) async {
          resolvedAssetKey = source;
          final file = File(target);
          await file.parent.create(recursive: true);
          await file.writeAsString('audio');
          return file.path;
        },
      );
      final track = _assetTrack('assets/audio/track.mp3');

      final source = await resolver.resolve(track, taskId: 'asset-export');

      expect(resolvedAssetKey, 'assets/audio/track.mp3');
      await (source as OwnedAudioArtifact).dispose();
    });
  });
}

AudioTrack _track(
  String id,
  String url, {
  double volume = 1,
  double volumeBalance = 0,
}) {
  return AudioTrack(
    id: id,
    title: id,
    subtitle: 'artist',
    duration: const Duration(seconds: 10),
    audio: EditorAudio(networkUrl: url),
    volume: volume,
    volumeBalance: volumeBalance,
  );
}

AudioTrack _assetTrack(String assetKey) {
  return AudioTrack(
    id: assetKey,
    title: 'asset',
    subtitle: 'artist',
    duration: const Duration(seconds: 10),
    audio: EditorAudio(assetPath: assetKey),
  );
}

class _FakeAudioPlayer implements AudioPlayer {
  PlayerState _state = PlayerState.stopped;
  Duration? _position;

  Completer<void>? sourceStarted;
  Completer<void>? sourceGate;
  final List<String> sourceUrls = [];
  String? currentSourceUrl;
  Source? currentSource;
  Object? currentPositionError;
  @override
  double volume = 1;
  int pauseCount = 0;
  int resumeCount = 0;

  @override
  PlayerState get state => _state;

  @override
  Future<void> setSource(Source source) async {
    sourceStarted?.complete();
    sourceStarted = null;
    await sourceGate?.future;
    currentSource = source;
    if (source case UrlSource(:final url)) {
      sourceUrls.add(url);
      currentSourceUrl = url;
    }
  }

  @override
  Future<void> setReleaseMode(ReleaseMode releaseMode) async {}

  @override
  Future<Duration?> getCurrentPosition() async {
    if (currentPositionError case final error?) throw error;
    return _position;
  }

  @override
  Future<void> setVolume(double volume) async {
    this.volume = volume;
  }

  @override
  Future<void> seek(Duration position) async {
    _position = position;
  }

  @override
  Future<void> pause() async {
    pauseCount++;
    _state = PlayerState.paused;
  }

  @override
  Future<void> resume() async {
    resumeCount++;
    _state = PlayerState.playing;
  }

  @override
  Future<void> dispose() async {
    _state = PlayerState.disposed;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
