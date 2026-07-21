import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/pro_video_editor/ui/controllers/audio_audition_controller.dart';
import 'package:spark/src/core/pro_video_editor/ui/controllers/audio_audition_playback.dart';

void main() {
  test(
    'owns the picker, range, and commit phases as one transaction',
    () async {
      final playback = _FakeAudioPlayback();
      final waveform = Completer<List<double>>();
      final commits = <AudioAuditionResult>[];
      final controller = AudioAuditionController(
        playback,
        (_) => waveform.future,
        commits.add,
        (_, _, _) {},
      );
      addTearDown(controller.dispose);
      final hostSpan = _span(2, 12);
      final track = _track('selected');

      await controller.beginPicker(previousTrack: null, hostSpan: hostSpan);
      expect(controller.state, isA<AudioPickerAuditionState>());
      expect(await controller.selectPickerTrack(track), isTrue);
      expect(controller.confirmPicker(), isTrue);
      expect(controller.rangeState?.draft.audioStartTime, Duration.zero);
      expect(
        controller.rangeState?.draft.audioEndTime,
        const Duration(seconds: 10),
      );
      await Future<void>.delayed(Duration.zero);
      expect(playback.preparedSpans, [hostSpan]);
      expect(playback.startCount, 1);

      waveform.complete([0.2, 0.8]);
      await Future<void>.delayed(Duration.zero);
      expect(controller.rangeState?.waveform, [0.2, 0.8]);

      expect(controller.finish(const Duration(seconds: 4)), isTrue);

      expect(commits.single.track.audioStartTime, const Duration(seconds: 4));
      expect(commits.single.waveform, [0.2, 0.8]);
      expect(controller.state, isNull);
    },
  );

  test('does not replace an active audition session', () async {
    final playback = _FakeAudioPlayback();
    final waveforms = <String, Completer<List<double>>>{};
    final controller = AudioAuditionController(
      playback,
      (track) => (waveforms[track.id] = Completer<List<double>>()).future,
      (_) {},
      (_, _, _) {},
    );
    addTearDown(controller.dispose);
    final span = _span(0, 10);

    expect(
      controller.beginAdjustment(
        track: _track('first'),
        hostSpan: span,
        waveform: const [],
      ),
      isTrue,
    );
    expect(
      controller.beginAdjustment(
        track: _track('second'),
        hostSpan: span,
        waveform: const [],
      ),
      isFalse,
    );

    expect(controller.rangeState?.draft.id, 'first');
    expect(waveforms, contains('first'));
    expect(waveforms, isNot(contains('second')));

    waveforms['first']!.complete([0.1]);
    await Future<void>.delayed(Duration.zero);
    expect(controller.rangeState?.waveform, [0.1]);
  });

  test('does not start a second picker while the first is pausing', () async {
    final pause = Completer<void>();
    final playback = _FakeAudioPlayback(onPause: () => pause.future);
    final controller = AudioAuditionController(
      playback,
      (_) async => [0.5],
      (_) {},
      (_, _, _) {},
    );
    addTearDown(controller.dispose);
    final first = controller.beginPicker(
      previousTrack: null,
      hostSpan: _span(0, 10),
    );

    expect(
      await controller.beginPicker(previousTrack: null, hostSpan: _span(1, 11)),
      isFalse,
    );
    pause.complete();
    expect(await first, isTrue);
    expect(controller.state?.hostSpan, _span(0, 10));
  });

  test('keeps cancellation restoring until the prior track is ready', () async {
    final restore = Completer<void>();
    final playback = _FakeAudioPlayback(onRestore: () => restore.future);
    final controller = AudioAuditionController(
      playback,
      (_) async => [0.5],
      (_) {},
      (_, _, _) {},
    );
    addTearDown(controller.dispose);
    final previousTrack = _track('previous');
    final hostSpan = _span(0, 12);
    controller.beginAdjustment(
      track: previousTrack,
      hostSpan: hostSpan,
      waveform: const [0.5],
    );

    final cancellation = controller.cancel();
    expect(controller.state, isA<AudioAuditionRestoringState>());
    expect(controller.state?.blocksHostInteraction, isTrue);

    restore.complete();
    await cancellation;
    expect(controller.state, isNull);
    expect(playback.restoredTracks, [same(previousTrack)]);
  });

  test(
    'stale preview preparation cannot start playback after cancel',
    () async {
      final prepare = Completer<void>();
      final playback = _FakeAudioPlayback(onPrepare: () => prepare.future);
      final controller = AudioAuditionController(
        playback,
        (_) async => [0.5],
        (_) {},
        (_, _, _) {},
      );
      addTearDown(controller.dispose);
      controller.beginAdjustment(
        track: _track('selected'),
        hostSpan: _span(0, 10),
        waveform: const [0.5],
      );
      await Future<void>.delayed(Duration.zero);

      final cancellation = controller.cancel();
      prepare.complete();
      await cancellation;
      await Future<void>.delayed(Duration.zero);

      expect(playback.startCount, 0);
      expect(controller.state, isNull);
    },
  );

  test('waveform completion does not cancel current preparation', () async {
    final prepare = Completer<void>();
    final waveform = Completer<List<double>>();
    final playback = _FakeAudioPlayback(onPrepare: () => prepare.future);
    final controller = AudioAuditionController(
      playback,
      (_) => waveform.future,
      (_) {},
      (_, _, _) {},
    );
    addTearDown(controller.dispose);
    controller.beginAdjustment(
      track: _track('selected'),
      hostSpan: _span(0, 10),
      waveform: const [],
    );
    await Future<void>.delayed(Duration.zero);

    waveform.complete([0.4]);
    await Future<void>.delayed(Duration.zero);
    prepare.complete();
    await Future<void>.delayed(Duration.zero);

    expect(playback.startCount, 1);
    expect(controller.rangeState?.waveform, [0.4]);
  });

  test('waveform completion keeps in-flight playback current', () async {
    final play = Completer<void>();
    final waveform = Completer<List<double>>();
    final playback = _FakeAudioPlayback(onPlay: () => play.future);
    final controller = AudioAuditionController(
      playback,
      (_) => waveform.future,
      (_) {},
      (_, _, _) {},
    );
    addTearDown(controller.dispose);
    controller.beginAdjustment(
      track: _track('selected'),
      hostSpan: _span(0, 10),
      waveform: const [],
    );
    await Future<void>.delayed(Duration.zero);
    waveform.complete([0.4]);
    await Future<void>.delayed(Duration.zero);
    play.complete();
    await Future<void>.delayed(Duration.zero);

    expect(playback.playWasCurrent, isTrue);
  });

  test('preview failure invalidates the failed transport request', () async {
    final playback = _FakeAudioPlayback(
      onPlay: () async => throw StateError('play failed'),
    );
    final controller = AudioAuditionController(
      playback,
      (_) async => [0.5],
      (_) {},
      (_, _, _) {},
    );
    addTearDown(controller.dispose);

    controller.beginAdjustment(
      track: _track('selected'),
      hostSpan: _span(0, 10),
      waveform: const [0.5],
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(controller.rangeState?.isScrubbing, isTrue);
    expect(playback.lastPlayIsCurrent?.call(), isFalse);
  });

  test('picker phase ignores host playback snapshots', () async {
    final playback = _FakeAudioPlayback();
    final controller = AudioAuditionController(
      playback,
      (_) async => [0.5],
      (_) {},
      (_, _, _) {},
    );
    addTearDown(controller.dispose);
    await controller.beginPicker(previousTrack: null, hostSpan: _span(0, 10));

    expect(
      controller.handlePlaybackSnapshot(
        const AudioAuditionPlaybackSnapshot(
          position: Duration.zero,
          isPlaying: false,
          isCompleted: false,
        ),
      ),
      isNull,
    );
  });

  test('host snapshot updates progress and exposes the active range', () async {
    final playback = _FakeAudioPlayback();
    final controller = AudioAuditionController(
      playback,
      (_) async => [0.5],
      (_) {},
      (_, _, _) {},
    );
    addTearDown(controller.dispose);
    controller.beginAdjustment(
      track: _track('selected'),
      hostSpan: _span(2, 10),
      waveform: const [0.5],
    );
    await Future<void>.delayed(Duration.zero);
    const snapshot = AudioAuditionPlaybackSnapshot(
      position: Duration(seconds: 6),
      isPlaying: true,
      isCompleted: false,
    );

    expect(
      controller.handlePlaybackSnapshot(snapshot),
      same(controller.rangeState),
    );

    expect(controller.playbackProgress.value, 0.5);
  });

  test('range preview waits for an asynchronous scrub pause', () async {
    final pause = Completer<void>();
    final playback = _FakeAudioPlayback(onPause: () => pause.future);
    final controller = AudioAuditionController(
      playback,
      (_) async => [0.5],
      (_) {},
      (_, _, _) {},
    );
    addTearDown(controller.dispose);
    controller.beginAdjustment(
      track: _track('selected'),
      hostSpan: _span(0, 10),
      waveform: const [0.5],
    );
    await Future<void>.delayed(Duration.zero);
    expect(playback.startCount, 1);

    final pauseFuture = controller.pauseForScrub();
    final previewFuture = controller.previewRange(const Duration(seconds: 5));
    await Future<void>.delayed(Duration.zero);
    expect(playback.startCount, 1);

    pause.complete();
    await Future.wait([pauseFuture, previewFuture]);
    await Future<void>.delayed(Duration.zero);

    expect(playback.startCount, 2);
    expect(
      controller.rangeState?.draft.audioStartTime,
      const Duration(seconds: 5),
    );
  });

  test('only the latest overlapping scrub can restart playback', () async {
    final pauses = [Completer<void>(), Completer<void>()];
    var pauseIndex = 0;
    final playback = _FakeAudioPlayback(
      onPause: () => pauses[pauseIndex++].future,
    );
    final controller = AudioAuditionController(
      playback,
      (_) async => [0.5],
      (_) {},
      (_, _, _) {},
    );
    addTearDown(controller.dispose);
    controller.beginAdjustment(
      track: _track('selected'),
      hostSpan: _span(0, 10),
      waveform: const [0.5],
    );
    await Future<void>.delayed(Duration.zero);
    expect(playback.startCount, 1);

    final firstPause = controller.pauseForScrub();
    final firstPreview = controller.previewRange(const Duration(seconds: 3));
    final secondPause = controller.pauseForScrub();
    final secondPreview = controller.previewRange(const Duration(seconds: 5));

    pauses.last.complete();
    await Future<void>.delayed(Duration.zero);
    expect(playback.startCount, 1);

    pauses.first.complete();
    await Future.wait([firstPause, firstPreview, secondPause, secondPreview]);
    await Future<void>.delayed(Duration.zero);

    expect(playback.startCount, 2);
    expect(
      controller.rangeState?.draft.audioStartTime,
      const Duration(seconds: 5),
    );
  });

  test('range boundary restarts without exposing a stale range', () async {
    final playback = _FakeAudioPlayback();
    final controller = AudioAuditionController(
      playback,
      (_) async => [0.5],
      (_) {},
      (_, _, _) {},
    );
    addTearDown(controller.dispose);
    controller.beginAdjustment(
      track: _track('selected'),
      hostSpan: _span(2, 10),
      waveform: const [0.5],
    );
    await Future<void>.delayed(Duration.zero);
    expect(
      controller.handlePlaybackSnapshot(
        const AudioAuditionPlaybackSnapshot(
          position: Duration(seconds: 10),
          isPlaying: false,
          isCompleted: true,
        ),
      ),
      isNull,
    );
    await Future<void>.delayed(Duration.zero);

    expect(playback.preparedSpans, hasLength(2));
  });
}

class _FakeAudioPlayback implements AudioAuditionPlayback {
  _FakeAudioPlayback({
    this.onPause,
    this.onPrepare,
    this.onPlay,
    this.onRestore,
  });

  final Future<void> Function()? onPause;
  final Future<void> Function()? onPrepare;
  final Future<void> Function()? onPlay;
  final Future<void> Function()? onRestore;
  final preparedSpans = <TrimDurationSpan>[];
  final restoredTracks = <AudioTrack?>[];
  var startCount = 0;
  bool? playWasCurrent;
  bool Function()? lastPlayIsCurrent;

  @override
  Future<void> pausePreview() async {
    await onPause?.call();
  }

  @override
  Future<void> previewCandidate(
    AudioTrack track,
    TrimDurationSpan hostSpan, {
    required bool Function() isCurrent,
  }) async {}

  @override
  Future<void> prepareRangePreview(
    AudioTrack track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  }) async {
    preparedSpans.add(playbackSpan);
    await onPrepare?.call();
  }

  @override
  Future<void> startRangePreview(
    AudioTrack track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  }) async {
    startCount++;
    lastPlayIsCurrent = isCurrent;
    await onPlay?.call();
    playWasCurrent = isCurrent();
  }

  @override
  Future<void> restorePrevious(
    AudioTrack? track,
    TrimDurationSpan hostSpan, {
    required bool Function() isCurrent,
  }) async {
    restoredTracks.add(track);
    await onRestore?.call();
  }
}

AudioTrack _track(String id) {
  return AudioTrack(
    id: id,
    title: 'Sound $id',
    subtitle: 'artist.sprk.so',
    duration: const Duration(seconds: 30),
    audio: EditorAudio(networkUrl: 'https://example.com/$id.mp3'),
  );
}

TrimDurationSpan _span(int startSeconds, int endSeconds) {
  return TrimDurationSpan(
    start: Duration(seconds: startSeconds),
    end: Duration(seconds: endSeconds),
  );
}
