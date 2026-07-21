import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/pro_video_editor/services/audio_helper_service.dart';
import 'package:spark/src/core/pro_video_editor/ui/controllers/audio_audition_playback.dart';
import 'package:spark/src/core/pro_video_editor/ui/controllers/video_editor_media_session.dart';
import 'package:video_player/video_player.dart';

void main() {
  group('VideoEditorAudioPlaybackCoordinator', () {
    late _ControlledVideoPlayerController videoController;
    late _FakeAudioHelperService audioService;
    late VideoEditorMediaSession media;
    late ProVideoController editorController;
    late VideoEditorAudioPlaybackCoordinator playback;
    late VideoEditorAudioAuditionPlayback auditionPlayback;

    setUp(() {
      videoController = _ControlledVideoPlayerController();
      audioService = _FakeAudioHelperService(videoController: videoController);
      media = VideoEditorMediaSession(
        videoController: videoController,
        videoDuration: const Duration(seconds: 20),
        onSeekError: (_, _) {},
        audioService: audioService,
      );
      editorController = ProVideoController(
        videoPlayer: const SizedBox(),
        videoDuration: const Duration(seconds: 20),
        initialResolution: const Size(1080, 1920),
        fileSize: 0,
      );
      editorController.initialize(
        callbacksAudioFunction: () => const AudioEditorCallbacks(),
        callbacksFunction: VideoEditorCallbacks.new,
        configsFunction: () => const VideoEditorConfigs(),
      );
      playback = VideoEditorAudioPlaybackCoordinator(media, editorController);
      auditionPlayback = VideoEditorAudioAuditionPlayback(playback);
    });

    tearDown(() => media.dispose());

    test('forwards host spans for candidate preview and restoration', () async {
      final track = _track();
      final hostSpan = _span(3, 13);

      await auditionPlayback.previewCandidate(
        track,
        hostSpan,
        isCurrent: () => true,
      );
      await auditionPlayback.restorePrevious(
        track,
        hostSpan,
        isCurrent: () => true,
      );

      expect(audioService.playSpans, [hostSpan]);
      expect(audioService.prepareSpans, [hostSpan]);
      expect(audioService.audioModes, [true, true]);
    });

    test('maps neutral snapshots into editor audio synchronization', () async {
      final track = _track();
      final playbackSpan = _span(2, 12);
      const snapshot = AudioAuditionPlaybackSnapshot(
        position: Duration(seconds: 7),
        isPlaying: true,
        isCompleted: false,
      );

      await playback.synchronize(
        track,
        playbackSpan,
        snapshot,
        isCurrent: () => true,
      );

      expect(audioService.synchronizedPositions, [snapshot.position]);
      expect(audioService.synchronizedSpans, [playbackSpan]);
      expect(audioService.synchronizedPlaying, [true]);
    });

    test('pauses audio before preparing a range preview', () async {
      final preparation = auditionPlayback.prepareRangePreview(
        _track(),
        _span(2, 12),
        isCurrent: () => true,
      );
      await Future<void>.delayed(Duration.zero);

      expect(audioService.operations, ['pause']);
      expect(videoController.pauseCount, 1);
      videoController.completeNextSeek();
      await preparation;

      expect(audioService.operations, ['pause', 'prepare', 'mode']);
    });

    test('starts only a current range preview with its exact span', () async {
      final track = _track();
      final playbackSpan = _span(2, 12);

      await auditionPlayback.startRangePreview(
        track,
        playbackSpan,
        isCurrent: () => false,
      );
      expect(audioService.playSpans, isEmpty);

      videoController.value = const VideoPlayerValue(
        duration: Duration(seconds: 20),
        position: Duration(seconds: 2),
        isPlaying: true,
      );
      final start = auditionPlayback.startRangePreview(
        track,
        playbackSpan,
        isCurrent: () => true,
      );
      await Future<void>.delayed(Duration.zero);
      videoController.value = videoController.value.copyWith(
        position: const Duration(seconds: 3),
      );
      await start;

      expect(audioService.playSpans, [playbackSpan]);
      expect(audioService.playForceSeeks, [isTrue]);
    });

    test('rejects host play while an audition owns playback', () {
      editorController.isPlayingNotifier.value = true;
      media.timelineState.setPlaying(isPlaying: true);

      expect(playback.rejectPlayRequest(auditionActive: true), isTrue);

      expect(editorController.isPlayingNotifier.value, isFalse);
      expect(media.timelineState.isPlaying, isFalse);
    });

    test('leaves host play state alone without an active audition', () {
      editorController.isPlayingNotifier.value = true;
      media.timelineState.setPlaying(isPlaying: true);

      expect(playback.rejectPlayRequest(auditionActive: false), isFalse);

      expect(editorController.isPlayingNotifier.value, isTrue);
      expect(media.timelineState.isPlaying, isTrue);
    });
  });

  group('VideoEditorTimelineSeekCoordinator', () {
    test('latest seek supersedes a pending timeline seek safely', () async {
      final controller = _ControlledVideoPlayerController();
      final coordinator = VideoEditorTimelineSeekCoordinator(
        videoController: controller,
        onError: (_, _) {},
      );

      final first = coordinator.seekLatest(const Duration(seconds: 1));
      final superseded = coordinator.seekLatest(const Duration(seconds: 2));
      final trim = coordinator.seekLatest(const Duration(seconds: 3));

      await superseded;
      expect(controller.targets, [const Duration(seconds: 1)]);

      controller.completeNextSeek();
      await first;
      await Future<void>.delayed(Duration.zero);
      expect(controller.targets, [
        const Duration(seconds: 1),
        const Duration(seconds: 3),
      ]);

      controller.completeNextSeek();
      await trim;
      await coordinator.dispose();
    });

    test(
      'dispose waits for an active seek and suppresses its late error',
      () async {
        final controller = _ControlledVideoPlayerController();
        final errors = <Object>[];
        final coordinator = VideoEditorTimelineSeekCoordinator(
          videoController: controller,
          onError: (error, _) => errors.add(error),
        );
        final seek = coordinator.seekLatest(const Duration(seconds: 1));
        var disposed = false;

        final disposal = coordinator.dispose().then((_) => disposed = true);
        await Future<void>.delayed(Duration.zero);
        expect(disposed, isFalse);

        controller.failNextSeek(StateError('late seek failure'));
        await disposal;
        await seek;
        expect(errors, isEmpty);
      },
    );
  });
}

class _ControlledVideoPlayerController extends VideoPlayerController {
  _ControlledVideoPlayerController() : super.asset('unused');

  final List<Duration> targets = [];
  final List<Completer<void>> _seeks = [];
  var pauseCount = 0;

  @override
  Future<void> pause() async {
    pauseCount++;
    value = value.copyWith(isPlaying: false);
  }

  @override
  Future<void> seekTo(Duration position) {
    targets.add(position);
    final completer = Completer<void>();
    _seeks.add(completer);
    return completer.future;
  }

  void completeNextSeek() => _seeks.removeAt(0).complete();

  void failNextSeek(Object error) => _seeks.removeAt(0).completeError(error);
}

class _FakeAudioHelperService extends AudioHelperService {
  _FakeAudioHelperService({required super.videoController})
    : super(audioPlayer: _NoopAudioPlayer());

  final playSpans = <TrimDurationSpan>[];
  final playForceSeeks = <bool>[];
  final prepareSpans = <TrimDurationSpan>[];
  final audioModes = <bool>[];
  final synchronizedPositions = <Duration>[];
  final synchronizedSpans = <TrimDurationSpan>[];
  final synchronizedPlaying = <bool>[];
  final operations = <String>[];

  @override
  bool get useCustomAudio => false;

  @override
  Future<void> pause() async {
    operations.add('pause');
  }

  @override
  Future<void> play(
    AudioTrack track, {
    Duration videoPosition = Duration.zero,
    Duration videoStart = Duration.zero,
    Duration? videoEnd,
    bool forceSeek = false,
  }) async {
    playForceSeeks.add(forceSeek);
    playSpans.add(
      TrimDurationSpan(start: videoStart, end: videoEnd ?? Duration.zero),
    );
  }

  @override
  Future<void> prepare(
    AudioTrack track, {
    Duration videoPosition = Duration.zero,
    Duration videoStart = Duration.zero,
    Duration? videoEnd,
  }) async {
    operations.add('prepare');
    prepareSpans.add(
      TrimDurationSpan(start: videoStart, end: videoEnd ?? Duration.zero),
    );
  }

  @override
  Future<void> setAudioMode({required bool useCustom}) async {
    operations.add('mode');
    audioModes.add(useCustom);
  }

  @override
  Future<void> synchronizePlayback(
    AudioTrack track, {
    required Duration videoPosition,
    required Duration videoStart,
    required Duration videoEnd,
    required bool isVideoPlaying,
    bool forceSeek = false,
  }) async {
    synchronizedPositions.add(videoPosition);
    synchronizedSpans.add(TrimDurationSpan(start: videoStart, end: videoEnd));
    synchronizedPlaying.add(isVideoPlaying);
  }

  @override
  Future<void> dispose() async {}
}

class _NoopAudioPlayer implements AudioPlayer {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AudioTrack _track() {
  return AudioTrack(
    id: 'track',
    title: 'Track',
    subtitle: 'Artist',
    duration: const Duration(seconds: 30),
    audio: EditorAudio(networkUrl: 'https://example.com/track.mp3'),
  );
}

TrimDurationSpan _span(int startSeconds, int endSeconds) {
  return TrimDurationSpan(
    start: Duration(seconds: startSeconds),
    end: Duration(seconds: endSeconds),
  );
}
