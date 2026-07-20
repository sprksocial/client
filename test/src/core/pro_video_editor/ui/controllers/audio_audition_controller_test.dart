import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/pro_video_editor/ui/controllers/audio_audition_controller.dart';
import 'package:spark/src/core/pro_video_editor/ui/controllers/video_editor_media_session.dart';
import 'package:video_player/video_player.dart';

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
      final editorSpan = _span(2, 12);
      final track = _track('selected');

      controller.beginPicker(previousTrack: null, editorSpan: editorSpan);
      expect(controller.state, isA<AudioPickerAuditionState>());
      expect(await controller.selectPickerTrack(track), isTrue);
      expect(controller.confirmPicker(), isTrue);
      expect(controller.rangeState?.draft.audioStartTime, Duration.zero);
      expect(
        controller.rangeState?.draft.audioEndTime,
        const Duration(seconds: 10),
      );
      await Future<void>.delayed(Duration.zero);
      expect(playback.preparedSpans, [editorSpan]);
      expect(playback.playRequestCount, 1);

      waveform.complete([0.2, 0.8]);
      await Future<void>.delayed(Duration.zero);
      expect(controller.rangeState?.waveform, [0.2, 0.8]);

      expect(controller.finish(const Duration(seconds: 4)), isTrue);

      expect(commits.single.track.audioStartTime, const Duration(seconds: 4));
      expect(commits.single.waveform, [0.2, 0.8]);
      expect(controller.state, isNull);
    },
  );

  test('ignores waveform results from an obsolete audition', () async {
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

    controller.beginAdjustment(
      track: _track('first'),
      editorSpan: span,
      waveform: const [],
    );
    controller.beginAdjustment(
      track: _track('second'),
      editorSpan: span,
      waveform: const [],
    );

    waveforms['first']!.complete([0.1]);
    await Future<void>.delayed(Duration.zero);
    expect(controller.rangeState?.draft.id, 'second');
    expect(controller.rangeState?.waveform, isEmpty);

    waveforms['second']!.complete([0.9]);
    await Future<void>.delayed(Duration.zero);
    expect(controller.rangeState?.waveform, [0.9]);
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
    final editorSpan = _span(0, 12);
    controller.beginAdjustment(
      track: previousTrack,
      editorSpan: editorSpan,
      waveform: const [0.5],
    );

    final cancellation = controller.cancel();
    expect(controller.state, isA<AudioAuditionRestoringState>());
    expect(controller.state?.suspendsChrome, isTrue);
    expect(playback.assignedTrack, same(previousTrack));

    restore.complete();
    await cancellation;
    expect(controller.state, isNull);
    expect(playback.restoredTracks, [same(previousTrack)]);
  });

  test(
    'stale preview preparation cannot request playback after cancel',
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
        editorSpan: _span(0, 10),
        waveform: const [0.5],
      );
      await Future<void>.delayed(Duration.zero);

      final cancellation = controller.cancel();
      prepare.complete();
      await cancellation;
      await Future<void>.delayed(Duration.zero);

      expect(playback.playRequestCount, 0);
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
      editorSpan: _span(0, 10),
      waveform: const [],
    );
    await Future<void>.delayed(Duration.zero);

    waveform.complete([0.4]);
    await Future<void>.delayed(Duration.zero);
    prepare.complete();
    await Future<void>.delayed(Duration.zero);

    expect(playback.playRequestCount, 1);
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
      editorSpan: _span(0, 10),
      waveform: const [],
    );
    await Future<void>.delayed(Duration.zero);
    expect(controller.handlePlayRequested(), isTrue);

    waveform.complete([0.4]);
    await Future<void>.delayed(Duration.zero);
    play.complete();
    await Future<void>.delayed(Duration.zero);

    expect(playback.playWasCurrent, isTrue);
  });

  test('picker phase consumes video updates without synchronization', () {
    final playback = _FakeAudioPlayback();
    final controller = AudioAuditionController(
      playback,
      (_) async => [0.5],
      (_) {},
      (_, _, _) {},
    );
    addTearDown(controller.dispose);
    controller.beginPicker(previousTrack: null, editorSpan: _span(0, 10));

    expect(
      controller.handleVideoValue(VideoPlayerValue.uninitialized()),
      isTrue,
    );
    expect(playback.synchronizeCount, 0);
  });

  test('range boundary restarts before scheduling synchronization', () async {
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
      editorSpan: _span(2, 10),
      waveform: const [0.5],
    );
    await Future<void>.delayed(Duration.zero);
    expect(controller.handlePlayRequested(), isTrue);

    controller.handleVideoValue(
      VideoPlayerValue(
        duration: const Duration(seconds: 10),
        position: const Duration(seconds: 10),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(playback.preparedSpans, hasLength(2));
    expect(playback.synchronizeCount, 0);
  });
}

class _FakeAudioPlayback implements VideoEditorAudioPlayback {
  _FakeAudioPlayback({this.onPrepare, this.onPlay, this.onRestore});

  final Future<void> Function()? onPrepare;
  final Future<void> Function()? onPlay;
  final Future<void> Function()? onRestore;
  AudioTrack? assignedTrack;
  final preparedSpans = <TrimDurationSpan>[];
  final restoredTracks = <AudioTrack?>[];
  var playRequestCount = 0;
  var synchronizeCount = 0;
  bool? playWasCurrent;

  @override
  void setTrack(AudioTrack? track) => assignedTrack = track;

  @override
  void pauseEditor() {}

  @override
  void requestEditorPlay() => playRequestCount++;

  @override
  Future<void> previewPickerTrack(
    AudioTrack track,
    TrimDurationSpan editorSpan, {
    required bool Function() isCurrent,
  }) async {}

  @override
  Future<void> stopAudio() async {}

  @override
  Future<void> preparePreview(
    AudioTrack track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  }) async {
    preparedSpans.add(playbackSpan);
    await onPrepare?.call();
  }

  @override
  Future<void> playTrack(
    AudioTrack track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  }) async {
    await onPlay?.call();
    playWasCurrent = isCurrent();
  }

  @override
  Future<void> restore(
    AudioTrack? track,
    TrimDurationSpan editorSpan, {
    required bool Function() isCurrent,
  }) async {
    restoredTracks.add(track);
    await onRestore?.call();
  }

  @override
  Future<void> synchronize(
    AudioTrack track,
    TrimDurationSpan playbackSpan,
    VideoPlayerValue videoValue,
  ) async {
    synchronizeCount++;
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
