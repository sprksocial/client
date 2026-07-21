import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/models/audio_audition_timing.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_range_selection_overlay.dart';

void main() {
  test(
    'selection duration uses the window length without exceeding the sound',
    () {
      expect(
        audioSelectionDuration(
          audioDuration: const Duration(seconds: 30),
          selectionWindowDuration: const Duration(seconds: 12),
        ),
        const Duration(seconds: 12),
      );
      expect(
        audioSelectionDuration(
          audioDuration: const Duration(seconds: 8),
          selectionWindowDuration: const Duration(seconds: 12),
        ),
        const Duration(seconds: 8),
      );
    },
  );

  test('audition range normalizes source bounds and short-track looping', () {
    final span = TrimDurationSpan(
      start: const Duration(seconds: 2),
      end: const Duration(seconds: 12),
    );
    final track = _testTrack();

    final beforeStart = audioTrackForAuditionRange(
      track,
      playbackSpan: span,
      sourceStart: const Duration(seconds: -2),
    );
    expect(beforeStart.audioStartTime, Duration.zero);
    expect(beforeStart.audioEndTime, const Duration(seconds: 10));

    final afterEnd = audioTrackForAuditionRange(
      track,
      playbackSpan: span,
      sourceStart: const Duration(seconds: 40),
    );
    expect(afterEnd.audioStartTime, const Duration(seconds: 20));
    expect(afterEnd.audioEndTime, const Duration(seconds: 30));

    final shortTrack = audioTrackForAuditionRange(
      track.copyWith(duration: const Duration(seconds: 5)),
      playbackSpan: span,
      sourceStart: const Duration(seconds: 3),
    );
    expect(shortTrack.audioStartTime, Duration.zero);
    expect(shortTrack.audioEndTime, const Duration(seconds: 5));
    expect(shortTrack.loop, isTrue);
  });

  test('preview range follows the sound placement inside the host span', () {
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
      hostStart: Duration.zero,
      hostEnd: const Duration(seconds: 10),
    );
    expect(placedRange.start, const Duration(seconds: 3));
    expect(placedRange.end, const Duration(seconds: 8));

    final trimmedRange = audioTrackPreviewRange(
      track: track,
      hostStart: const Duration(seconds: 4),
      hostEnd: const Duration(seconds: 6),
    );
    expect(trimmedRange.start, const Duration(seconds: 4));
    expect(trimmedRange.end, const Duration(seconds: 6));
  });

  test('playback progress is relative to the active host range', () {
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
        isPlaybackArmed: true,
        isPlaybackCompleted: false,
        position: const Duration(seconds: 8),
        range: range,
      ),
      const Duration(seconds: 3),
    );
    expect(
      audioRangeLoopTarget(
        isPlaybackArmed: true,
        isPlaybackCompleted: false,
        position: const Duration(seconds: 7),
        range: range,
      ),
      isNull,
    );
    expect(
      audioRangeLoopTarget(
        isPlaybackArmed: false,
        isPlaybackCompleted: false,
        position: const Duration(seconds: 8),
        range: range,
      ),
      isNull,
    );
  });

  test('completed playback loops to the start of a middle-to-end range', () {
    final range = TrimDurationSpan(
      start: const Duration(seconds: 5),
      end: const Duration(seconds: 10),
    );

    expect(
      audioRangeLoopTarget(
        isPlaybackArmed: true,
        isPlaybackCompleted: true,
        position: Duration.zero,
        range: range,
      ),
      const Duration(seconds: 5),
    );
    expect(
      audioRangeLoopTarget(
        isPlaybackArmed: true,
        isPlaybackCompleted: false,
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
    Duration? previewedStart;
    Duration? confirmedStart;
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
            selectionWindowDuration: const Duration(seconds: 10),
            waveformData: List<double>.generate(
              90,
              (index) => (index % 10 + 1) / 10,
            ),
            isWaveformLoading: false,
            playbackProgress: playbackProgress,
            onScrubStarted: () => scrubStartCount++,
            onPreviewRequested: (value) => previewedStart = value,
            onCancel: () {},
            onDone: (value) => confirmedStart = value,
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
    expect(previewedStart, greaterThan(Duration.zero));

    await tester.tap(find.byKey(const ValueKey('audio-range-done')));
    await tester.pump();

    expect(confirmedStart, previewedStart);
  });

  testWidgets('cancel removes the range overlay', (tester) async {
    final playbackProgress = ValueNotifier(0.0);
    addTearDown(playbackProgress.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: _CancelHost(playbackProgress: playbackProgress),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('audio-range-cancel')));
    await tester.pump();

    expect(find.byType(AudioRangeSelectionOverlay), findsNothing);
  });

  testWidgets('blocks blank-area input and underlying editor semantics', (
    tester,
  ) async {
    var backgroundTapCount = 0;
    final playbackProgress = ValueNotifier(0.0);
    addTearDown(playbackProgress.dispose);

    await tester.pumpWidget(
      _overlayHarness(
        track: _testTrack(),
        playbackProgress: playbackProgress,
        background: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => backgroundTapCount++,
          child: Semantics(
            label: 'Underlying video editor',
            button: true,
            child: const ColoredBox(color: Colors.black),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(400, 300));
    await tester.pump();

    expect(backgroundTapCount, 0);
    expect(find.semantics.byLabel('Underlying video editor'), findsNothing);
  });

  testWidgets(
    'semantic scrolling re-previews without previewing initial positioning',
    (tester) async {
      var scrubStartCount = 0;
      final previewedStarts = <Duration>[];
      final playbackProgress = ValueNotifier(0.0);
      addTearDown(playbackProgress.dispose);
      final track = _testTrack().copyWith(
        audioStartTime: const Duration(seconds: 5),
        audioEndTime: const Duration(seconds: 15),
      );

      await tester.pumpWidget(
        _overlayHarness(
          track: track,
          playbackProgress: playbackProgress,
          onScrubStarted: () => scrubStartCount++,
          onPreviewRequested: previewedStarts.add,
        ),
      );
      await tester.pumpAndSettle();

      expect(scrubStartCount, 0);
      expect(previewedStarts, isEmpty);

      tester.semantics.scrollLeft(scrollable: find.semantics.scrollable());
      await tester.pumpAndSettle();

      expect(scrubStartCount, 1);
      expect(previewedStarts, hasLength(1));
      expect(previewedStarts.single, greaterThan(const Duration(seconds: 5)));
    },
  );
}

AudioTrack _testTrack() {
  return AudioTrack(
    id: 'sound',
    title: 'Summer Loop',
    subtitle: 'artist.sprk.so',
    duration: const Duration(seconds: 30),
    audio: EditorAudio(networkUrl: 'https://example.com/sound.mp3'),
  );
}

Widget _overlayHarness({
  required AudioTrack track,
  required ValueListenable<double> playbackProgress,
  Widget? background,
  VoidCallback? onScrubStarted,
  ValueChanged<Duration>? onPreviewRequested,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          background ?? const SizedBox.expand(),
          AudioRangeSelectionOverlay(
            track: track,
            selectionWindowDuration: const Duration(seconds: 10),
            waveformData: List<double>.generate(
              90,
              (index) => (index % 10 + 1) / 10,
            ),
            isWaveformLoading: false,
            playbackProgress: playbackProgress,
            onScrubStarted: onScrubStarted ?? () {},
            onPreviewRequested: onPreviewRequested ?? (_) {},
            onCancel: () {},
            onDone: (_) {},
          ),
        ],
      ),
    ),
  );
}

class _CancelHost extends StatefulWidget {
  const _CancelHost({required this.playbackProgress});

  final ValueListenable<double> playbackProgress;

  @override
  State<_CancelHost> createState() => _CancelHostState();
}

class _CancelHostState extends State<_CancelHost> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return AudioRangeSelectionOverlay(
      track: _testTrack(),
      selectionWindowDuration: const Duration(seconds: 10),
      waveformData: const [0.2, 0.8],
      isWaveformLoading: false,
      playbackProgress: widget.playbackProgress,
      onScrubStarted: () {},
      onPreviewRequested: (_) {},
      onCancel: () => setState(() => _visible = false),
      onDone: (_) {},
    );
  }
}
