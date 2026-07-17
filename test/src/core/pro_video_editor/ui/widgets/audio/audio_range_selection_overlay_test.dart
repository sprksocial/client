import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_range_selection_overlay.dart';

void main() {
  test(
    'selection duration uses the video length without exceeding the sound',
    () {
      expect(
        audioSelectionDuration(
          audioDuration: const Duration(seconds: 30),
          videoDuration: const Duration(seconds: 12),
        ),
        const Duration(seconds: 12),
      );
      expect(
        audioSelectionDuration(
          audioDuration: const Duration(seconds: 8),
          videoDuration: const Duration(seconds: 12),
        ),
        const Duration(seconds: 8),
      );
    },
  );

  test('preview range follows the sound placement inside the edited video', () {
    final track = AudioTrack(
      id: 'sound',
      title: 'Summer Loop',
      subtitle: 'artist.sprk.so',
      duration: const Duration(seconds: 30),
      audio: EditorAudio(networkUrl: 'https://example.com/sound.mp3'),
      startTime: const Duration(seconds: 3),
      endTime: const Duration(seconds: 8),
    );

    final placedRange = audioTrackPreviewRange(
      track: track,
      videoStart: Duration.zero,
      videoEnd: const Duration(seconds: 10),
    );
    expect(placedRange.start, const Duration(seconds: 3));
    expect(placedRange.end, const Duration(seconds: 8));

    final trimmedRange = audioTrackPreviewRange(
      track: track,
      videoStart: const Duration(seconds: 4),
      videoEnd: const Duration(seconds: 6),
    );
    expect(trimmedRange.start, const Duration(seconds: 4));
    expect(trimmedRange.end, const Duration(seconds: 6));
  });

  test('playback progress is relative to the active video range', () {
    expect(
      audioRangePlaybackProgress(
        position: const Duration(seconds: 5),
        rangeStart: const Duration(seconds: 5),
        rangeEnd: const Duration(seconds: 15),
      ),
      0,
    );
    expect(
      audioRangePlaybackProgress(
        position: const Duration(seconds: 9),
        rangeStart: const Duration(seconds: 5),
        rangeEnd: const Duration(seconds: 15),
      ),
      0.4,
    );
    expect(
      audioRangePlaybackProgress(
        position: const Duration(seconds: 20),
        rangeStart: const Duration(seconds: 5),
        rangeEnd: const Duration(seconds: 15),
      ),
      1,
    );
  });

  test('preview loops from the end to the start of its placed range', () {
    final range = TrimDurationSpan(
      start: const Duration(seconds: 3),
      end: const Duration(seconds: 8),
    );
    expect(
      audioRangeLoopTarget(
        isPreviewActive: true,
        isPlaybackArmed: true,
        isVideoCompleted: false,
        position: const Duration(seconds: 8),
        range: range,
      ),
      const Duration(seconds: 3),
    );
    expect(
      audioRangeLoopTarget(
        isPreviewActive: true,
        isPlaybackArmed: true,
        isVideoCompleted: false,
        position: const Duration(seconds: 7),
        range: range,
      ),
      isNull,
    );
    expect(
      audioRangeLoopTarget(
        isPreviewActive: false,
        isPlaybackArmed: true,
        isVideoCompleted: false,
        position: const Duration(seconds: 8),
        range: range,
      ),
      isNull,
    );
    expect(
      audioRangeLoopTarget(
        isPreviewActive: true,
        isPlaybackArmed: false,
        isVideoCompleted: false,
        position: const Duration(seconds: 8),
        range: range,
      ),
      isNull,
    );
  });

  test('completed video loops to the start of a middle-to-end range', () {
    final range = TrimDurationSpan(
      start: const Duration(seconds: 5),
      end: const Duration(seconds: 10),
    );

    expect(
      audioRangeLoopTarget(
        isPreviewActive: true,
        isPlaybackArmed: true,
        isVideoCompleted: true,
        position: Duration.zero,
        range: range,
      ),
      const Duration(seconds: 5),
    );
    expect(
      audioRangeLoopTarget(
        isPreviewActive: true,
        isPlaybackArmed: true,
        isVideoCompleted: false,
        position: Duration.zero,
        range: range,
      ),
      const Duration(seconds: 5),
    );
  });

  testWidgets('dragging the waveform previews and confirms a fixed range', (
    tester,
  ) async {
    var scrubStartCount = 0;
    var cancelCount = 0;
    AudioTrack? previewedTrack;
    AudioTrack? confirmedTrack;
    final playbackProgress = ValueNotifier(0.0);
    addTearDown(playbackProgress.dispose);
    final track = AudioTrack(
      id: 'sound',
      title: 'Summer Loop',
      subtitle: 'artist.sprk.so',
      duration: const Duration(seconds: 30),
      audio: EditorAudio(networkUrl: 'https://example.com/sound.mp3'),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AudioRangeSelectionOverlay(
            track: track,
            videoDuration: const Duration(seconds: 10),
            waveformData: List<double>.generate(
              90,
              (index) => (index % 10 + 1) / 10,
            ),
            isWaveformLoading: false,
            playbackProgress: playbackProgress,
            onScrubStarted: () => scrubStartCount++,
            onPreviewRequested: (value) => previewedTrack = value,
            onCancel: () => cancelCount++,
            onDone: (value) => confirmedTrack = value,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('audio-range-selection-frame')),
      findsOneWidget,
    );
    expect(find.text('Select sound clip'), findsOneWidget);
    expect(find.text('Summer Loop'), findsOneWidget);

    final waveformStack = tester.widget<Stack>(
      find.byKey(const ValueKey('audio-range-waveform-stack')),
    );
    expect(waveformStack.children.map((child) => child.key).take(3), const [
      ValueKey('audio-range-playback-layer'),
      ValueKey('audio-range-waveform-layer'),
      ValueKey('audio-range-selection-border-layer'),
    ]);
    expect(
      tester
          .widget<ColoredBox>(
            find.byKey(const ValueKey('audio-range-playback-fill')),
          )
          .color,
      AppColors.primary500,
    );

    final cancelButton = tester.widget<AppButton>(
      find.byKey(const ValueKey('audio-range-cancel')),
    );
    final doneButton = tester.widget<AppButton>(
      find.byKey(const ValueKey('audio-range-done')),
    );
    expect(cancelButton.variant, AppButtonVariant.neutral);
    expect(doneButton.variant, AppButtonVariant.primary);
    expect(cancelButton.size, doneButton.size);
    expect(cancelButton.minWidth, doneButton.minWidth);
    expect(cancelButton.minHeight, doneButton.minHeight);
    expect(cancelButton.padding, doneButton.padding);

    await tester.tap(find.byKey(const ValueKey('audio-range-cancel')));
    await tester.pump();
    expect(cancelCount, 1);

    double playbackScale() => tester
        .widget<Transform>(
          find.byKey(const ValueKey('audio-range-playback-progress')),
        )
        .transform
        .storage[0];

    expect(playbackScale(), 0);
    playbackProgress.value = 0.5;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(playbackScale(), allOf(greaterThan(0), lessThan(0.5)));
    await tester.pumpAndSettle();
    expect(playbackScale(), closeTo(0.5, 0.001));

    playbackProgress.value = 0;
    await tester.pump();
    expect(playbackScale(), 0);

    await tester.drag(
      find.byKey(const ValueKey('audio-range-waveform-scroller')),
      const Offset(-240, 0),
    );
    await tester.pumpAndSettle();

    expect(scrubStartCount, 1);
    expect(previewedTrack, isNotNull);
    expect(previewedTrack!.audioStartTime, greaterThan(Duration.zero));
    expect(
      previewedTrack!.audioEndTime! - previewedTrack!.audioStartTime!,
      const Duration(seconds: 10),
    );

    await tester.tap(find.byKey(const ValueKey('audio-range-done')));
    await tester.pump();

    expect(confirmedTrack, isNotNull);
    expect(confirmedTrack!.audioStartTime, previewedTrack!.audioStartTime);
    expect(confirmedTrack!.audioEndTime, previewedTrack!.audioEndTime);
  });
}
