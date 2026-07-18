import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/providers/sound_picker_search_provider.dart';
import 'package:spark/src/core/pro_video_editor/providers/sound_picker_search_state.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_selection_bottom_sheet.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_track_list_section.dart';

void main() {
  testWidgets('Continue stays disabled until the selected preview succeeds', (
    tester,
  ) async {
    final preview = Completer<void>();
    AudioTrack? result;
    await _pumpSheetHost(
      tester,
      onResult: (track) => result = track,
      onTrackPlay: (_) => preview.future,
    );
    final track = _track('first');

    _selectTrack(tester, track);
    await tester.pump();

    expect(_continueButton(tester).onPressed, isNull);
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(result, isNull);
    expect(find.byType(AudioSelectionBottomSheet), findsOneWidget);

    preview.complete();
    await tester.pump();
    await tester.pump();

    expect(_continueButton(tester).onPressed, isNotNull);
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    expect(result, same(track));
  });

  testWidgets('failed preview cannot be continued', (tester) async {
    final preview = Completer<void>();
    final stoppedTracks = <AudioTrack>[];
    final reportedErrors = <Object>[];
    AudioTrack? result;
    await _pumpSheetHost(
      tester,
      onResult: (track) => result = track,
      onTrackPlay: (_) => preview.future,
      onTrackStop: (track) async {
        stoppedTracks.add(track);
        throw StateError('stop failed');
      },
      onPreviewError: (error, _) => reportedErrors.add(error),
    );

    final track = _track('failed');
    _selectTrack(tester, track);
    await tester.pump();
    preview.completeError(StateError('preview failed'));
    await tester.pump();
    await tester.pump();

    expect(_continueButton(tester).onPressed, isNull);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(stoppedTracks, [same(track)]);
    expect(reportedErrors, hasLength(2));
    expect(reportedErrors.first, isA<StateError>());
    expect(reportedErrors.last, isA<StateError>());
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(result, isNull);
    expect(find.byType(AudioSelectionBottomSheet), findsOneWidget);
  });

  testWidgets('stale preview success cannot confirm the newer selection', (
    tester,
  ) async {
    final firstPreview = Completer<void>();
    final secondPreview = Completer<void>();
    AudioTrack? result;
    await _pumpSheetHost(
      tester,
      onResult: (track) => result = track,
      onTrackPlay: (track) => switch (track.id) {
        'first' => firstPreview.future,
        'second' => secondPreview.future,
        _ => throw StateError('Unexpected track ${track.id}'),
      },
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
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(result, isNull);

    secondPreview.complete();
    await tester.pump();
    await tester.pump();
    expect(_continueButton(tester).onPressed, isNotNull);
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    expect(result, same(secondTrack));
  });

  testWidgets('closing during a pending preview stops the selected track', (
    tester,
  ) async {
    final preview = Completer<void>();
    final stoppedTracks = <AudioTrack>[];
    AudioTrack? result;
    await _pumpSheetHost(
      tester,
      onResult: (track) => result = track,
      onTrackPlay: (_) => preview.future,
      onTrackStop: (track) async => stoppedTracks.add(track),
    );
    final track = _track('pending');

    _selectTrack(tester, track);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(stoppedTracks, [same(track)]);

    preview.complete();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpSheetHost(
  WidgetTester tester, {
  required ValueChanged<AudioTrack?> onResult,
  required Future<void> Function(AudioTrack track) onTrackPlay,
  Future<void> Function(AudioTrack track)? onTrackStop,
  void Function(Object error, StackTrace stackTrace)? onPreviewError,
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
                final result = await showModalBottomSheet<AudioTrack>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => FractionallySizedBox(
                    heightFactor: 0.9,
                    child: AudioSelectionBottomSheet(
                      configs: const ProImageEditorConfigs(),
                      videoDuration: const Duration(seconds: 10),
                      onTrackPlay: onTrackPlay,
                      onTrackStop: onTrackStop ?? (_) async {},
                      onPreviewError: onPreviewError ?? (_, _) {},
                    ),
                  ),
                );
                onResult(result);
              },
              child: const Text('Open sounds'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open sounds'));
  await tester.pumpAndSettle();
}

void _selectTrack(WidgetTester tester, AudioTrack track) {
  tester
      .widget<AudioTrackListSection>(find.byType(AudioTrackListSection))
      .onTrackSelected(track);
}

AppButton _continueButton(WidgetTester tester) {
  return tester.widget<AppButton>(find.byType(AppButton));
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
