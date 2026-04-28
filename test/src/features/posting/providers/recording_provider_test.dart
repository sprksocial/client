import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/features/posting/providers/recording_provider.dart';

void main() {
  group('RecordingProvider', () {
    AudioTrack createTrack(String id) {
      return AudioTrack(
        id: id,
        title: 'Test sound',
        subtitle: 'tester',
        duration: const Duration(seconds: 9),
        audio: EditorAudio(networkUrl: 'https://example.com/sound.mp3'),
      );
    }

    test('accumulates elapsed time across resumed segments', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(
        recordingProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      final notifier = container.read(recordingProvider.notifier);

      notifier.startRecording();
      await Future<void>.delayed(const Duration(milliseconds: 350));
      notifier.stopRecording();
      notifier.addSegment(XFile('/tmp/segment-1.mp4'));

      final pausedState = container.read(recordingProvider);
      expect(pausedState.isRecording, isFalse);
      expect(
        pausedState.elapsedDuration,
        greaterThanOrEqualTo(const Duration(milliseconds: 300)),
      );
      expect(pausedState.canFinalize, isTrue);

      notifier.startRecording();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      notifier.stopRecording();
      notifier.addSegment(XFile('/tmp/segment-2.mp4'));

      final resumedState = container.read(recordingProvider);
      expect(resumedState.isRecording, isFalse);
      expect(
        resumedState.elapsedDuration,
        greaterThanOrEqualTo(const Duration(milliseconds: 500)),
      );
      expect(resumedState.segmentPaths, [
        '/tmp/segment-1.mp4',
        '/tmp/segment-2.mp4',
      ]);
      expect(resumedState.canFinalize, isTrue);
    });

    test('stores selected sound and preserves guide offset', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(
        recordingProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      final notifier = container.read(recordingProvider.notifier);
      final track = createTrack('sound-1');

      notifier.selectSound(track);
      notifier.setSoundGuideOffset(const Duration(seconds: 3));

      final state = container.read(recordingProvider);
      expect(state.selectedSound, same(track));
      expect(state.hasSelectedSound, isTrue);
      expect(state.soundGuideOffset, const Duration(seconds: 3));
    });

    test('clearSound removes selected sound and resets guide offset', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(
        recordingProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      final notifier = container.read(recordingProvider.notifier);
      notifier.selectSound(createTrack('sound-1'));
      notifier.setSoundGuideOffset(const Duration(seconds: 3));

      notifier.clearSound();

      final state = container.read(recordingProvider);
      expect(state.selectedSound, isNull);
      expect(state.hasSelectedSound, isFalse);
      expect(state.soundGuideOffset, Duration.zero);
    });

    test(
      'discardSession deletes temporary files while preserving keepPaths',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final subscription = container.listen(
          recordingProvider,
          (previous, next) {},
        );
        addTearDown(subscription.close);

        final tempDir = await Directory.systemTemp.createTemp(
          'recording-provider-test',
        );
        addTearDown(() async {
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        });

        final firstFile = File('${tempDir.path}/segment-1.mp4')
          ..writeAsStringSync('segment-1');
        final secondFile = File('${tempDir.path}/segment-2.mp4')
          ..writeAsStringSync('segment-2');

        final notifier = container.read(recordingProvider.notifier);
        final track = createTrack('sound-1');
        notifier.selectSound(track);
        notifier.setSoundGuideOffset(const Duration(seconds: 2));
        notifier.addSegment(XFile(firstFile.path));
        notifier.addSegment(XFile(secondFile.path));

        await notifier.discardSession(keepPaths: {secondFile.path});

        expect(await firstFile.exists(), isFalse);
        expect(await secondFile.exists(), isTrue);
        expect(container.read(recordingProvider).segmentPaths, isEmpty);
        expect(container.read(recordingProvider).selectedSound, isNull);
        expect(
          container.read(recordingProvider).soundGuideOffset,
          Duration.zero,
        );
      },
    );
  });
}
