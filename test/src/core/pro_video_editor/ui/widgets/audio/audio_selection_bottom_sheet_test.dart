import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/providers/sound_picker_search_provider.dart';
import 'package:spark/src/core/pro_video_editor/providers/sound_picker_search_state.dart';
import 'package:spark/src/core/pro_video_editor/ui/controllers/audio_audition_controller.dart';
import 'package:spark/src/core/pro_video_editor/ui/controllers/audio_audition_playback.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_selection_bottom_sheet.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_track_list_section.dart';

void main() {
  testWidgets('cancel while opening does not present a stale picker', (
    tester,
  ) async {
    final pause = Completer<void>();
    final playback = _FakeAudioPlayback(onPause: () => pause.future);
    final controller = _controller(playback);
    addTearDown(controller.dispose);
    await _pumpFlowHost(tester, controller: controller, autoOpen: false);

    await tester.tap(find.text('Open sounds'));
    await tester.pump();
    expect(controller.state, isA<AudioPickerAuditionState>());

    final cancellation = controller.cancel();
    pause.complete();
    await cancellation;
    await tester.pumpAndSettle();

    expect(find.byType(AudioSelectionBottomSheet), findsNothing);
    expect(controller.state, isNull);
  });

  testWidgets('an active picker ignores overlapping open requests', (
    tester,
  ) async {
    final pause = Completer<void>();
    final playback = _FakeAudioPlayback(onPause: () => pause.future);
    final controller = _controller(playback);
    addTearDown(controller.dispose);
    await _pumpFlowHost(tester, controller: controller, autoOpen: false);

    await tester.tap(find.text('Open sounds'));
    await tester.pump();
    await tester.tap(find.text('Open sounds'));
    await tester.pump();

    expect(playback.pauseCalls, 1);
    pause.complete();
    await tester.pumpAndSettle();
    expect(find.byType(AudioSelectionBottomSheet), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  });

  testWidgets('Continue stays disabled until the selected preview succeeds', (
    tester,
  ) async {
    final preview = Completer<void>();
    final playback = _FakeAudioPlayback(onPreview: (_) => preview.future);
    final controller = _controller(playback);
    addTearDown(controller.dispose);
    AudioTrack? result;
    await _pumpFlowHost(
      tester,
      controller: controller,
      onResult: (track) => result = track,
    );
    final track = _track('first');

    _selectTrack(tester, track);
    await tester.pump();

    expect(_continueButton(tester).onPressed, isNull);
    preview.complete();
    await tester.pump();
    await tester.pump();

    expect(_continueButton(tester).onPressed, isNotNull);
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    expect(result?.id, track.id);
    expect(controller.state, isA<AudioRangeAuditionState>());
  });

  testWidgets('failed preview cannot be continued', (tester) async {
    final preview = Completer<void>();
    final reportedErrors = <Object>[];
    final playback = _FakeAudioPlayback(
      onPreview: (_) => preview.future,
      failurePauseError: StateError('pause failed'),
    );
    final controller = _controller(playback, errors: reportedErrors);
    addTearDown(controller.dispose);
    AudioTrack? result;
    await _pumpFlowHost(
      tester,
      controller: controller,
      onResult: (track) => result = track,
    );

    _selectTrack(tester, _track('failed'));
    await tester.pump();
    preview.completeError(StateError('preview failed'));
    await tester.pump();
    await tester.pump();

    expect(_continueButton(tester).onPressed, isNull);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(reportedErrors, hasLength(2));
    expect(result, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stale preview success cannot confirm the newer selection', (
    tester,
  ) async {
    final firstPreview = Completer<void>();
    final secondPreview = Completer<void>();
    final playback = _FakeAudioPlayback(
      onPreview: (track) => switch (track.id) {
        'first' => firstPreview.future,
        'second' => secondPreview.future,
        _ => throw StateError('Unexpected track ${track.id}'),
      },
    );
    final controller = _controller(playback);
    addTearDown(controller.dispose);
    AudioTrack? result;
    await _pumpFlowHost(
      tester,
      controller: controller,
      onResult: (track) => result = track,
    );
    final firstTrack = _track('first');
    final secondTrack = _track('second');

    _selectTrack(tester, firstTrack);
    await tester.pump();
    _selectTrack(tester, secondTrack);
    await tester.pump();
    firstPreview.complete();
    await tester.pump();
    await tester.pump();

    expect(_continueButton(tester).onPressed, isNull);
    secondPreview.complete();
    await tester.pump();
    await tester.pump();
    expect(_continueButton(tester).onPressed, isNotNull);
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    expect(result?.id, secondTrack.id);
  });

  testWidgets('closing during a pending preview restores the prior track', (
    tester,
  ) async {
    final preview = Completer<void>();
    final playback = _FakeAudioPlayback(onPreview: (_) => preview.future);
    final controller = _controller(playback);
    addTearDown(controller.dispose);
    AudioTrack? result;
    await _pumpFlowHost(
      tester,
      controller: controller,
      onResult: (track) => result = track,
    );

    _selectTrack(tester, _track('pending'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(playback.restoredTracks, [null]);
    expect(controller.state, isNull);

    preview.complete();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

AudioAuditionController _controller(
  _FakeAudioPlayback playback, {
  List<Object>? errors,
}) {
  return AudioAuditionController(
    playback,
    (_) async => const [0.5],
    (_) {},
    (_, error, _) => errors?.add(error),
  );
}

Future<void> _pumpFlowHost(
  WidgetTester tester, {
  required AudioAuditionController controller,
  ValueChanged<AudioTrack?>? onResult,
  bool autoOpen = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        soundPickerSearchProvider.overrideWithValue(
          const SoundPickerSearchState(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                await showAudioSelectionFlow(
                  context: context,
                  initialTrack: null,
                  hostSpan: _span,
                  audition: controller,
                  isCurrent: () => true,
                  onError: (_, _, _) {},
                );
                onResult?.call(controller.rangeState?.draft);
              },
              child: const Text('Open sounds'),
            ),
          ),
        ),
      ),
    ),
  );
  if (autoOpen) {
    await tester.tap(find.text('Open sounds'));
    await tester.pumpAndSettle();
  }
}

void _selectTrack(WidgetTester tester, AudioTrack track) {
  tester
      .widget<AudioTrackListSection>(find.byType(AudioTrackListSection))
      .onTrackSelected(track);
}

AppButton _continueButton(WidgetTester tester) {
  return tester.widget<AppButton>(find.byType(AppButton));
}

class _FakeAudioPlayback implements AudioAuditionPlayback {
  _FakeAudioPlayback({this.onPreview, this.onPause, this.failurePauseError});

  final Future<void> Function(AudioTrack track)? onPreview;
  final Future<void> Function()? onPause;
  final Object? failurePauseError;
  final restoredTracks = <AudioTrack?>[];
  var pauseCalls = 0;

  @override
  Future<void> previewCandidate(
    AudioTrack track,
    TrimDurationSpan hostSpan, {
    required bool Function() isCurrent,
  }) {
    return onPreview?.call(track) ?? Future<void>.value();
  }

  @override
  Future<void> restorePrevious(
    AudioTrack? track,
    TrimDurationSpan hostSpan, {
    required bool Function() isCurrent,
  }) async {
    restoredTracks.add(track);
  }

  @override
  Future<void> pausePreview() async {
    pauseCalls++;
    await onPause?.call();
    if (pauseCalls > 1 && failurePauseError != null) {
      throw failurePauseError!;
    }
  }

  @override
  Future<void> prepareRangePreview(
    AudioTrack track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  }) async {}

  @override
  Future<void> startRangePreview(
    AudioTrack track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  }) async {}
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

final _span = TrimDurationSpan(
  start: Duration.zero,
  end: const Duration(seconds: 10),
);
