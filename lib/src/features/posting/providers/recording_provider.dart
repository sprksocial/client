import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/features/posting/providers/recording_state.dart';

part 'recording_provider.g.dart';

@riverpod
class Recording extends _$Recording {
  Timer? _timer;

  @override
  RecordingState build() {
    ref.onDispose(_dispose);
    return const RecordingState();
  }

  void startRecording() {
    if (state.isRecording || state.hasReachedMaxDuration) {
      return;
    }

    state = state.copyWith(isRecording: true, error: null);

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // Guard against accessing state after provider disposal
      if (!ref.mounted) {
        timer.cancel();
        return;
      }

      final newDuration =
          state.elapsedDuration + const Duration(milliseconds: 100);

      if (newDuration >= state.maxDuration) {
        stopTimer();
        state = state.copyWith(elapsedDuration: state.maxDuration);
        return;
      }

      state = state.copyWith(elapsedDuration: newDuration);
    });
  }

  void stopRecording() {
    if (!state.isRecording) {
      return;
    }

    stopTimer();
    state = state.copyWith(isRecording: false);
  }

  void addSegment(XFile file) {
    state = state.copyWith(
      segmentPaths: [...state.segmentPaths, file.path],
      error: null,
    );
  }

  void selectSound(AudioTrack sound) {
    state = state.copyWith(
      selectedSound: sound,
      soundGuideOffset: sound.startTime ?? Duration.zero,
      error: null,
    );
  }

  void setSelectedSoundStartTime(Duration offset) {
    final sound = state.selectedSound;
    if (sound == null) return;

    state = state.copyWith(
      selectedSound: sound.copyWith(startTime: offset),
      soundGuideOffset: offset,
      error: null,
    );
  }

  void clearSound() {
    state = state.copyWith(
      selectedSound: null,
      soundGuideOffset: Duration.zero,
      error: null,
    );
  }

  void setSoundGuideOffset(Duration offset) {
    state = state.copyWith(soundGuideOffset: offset, error: null);
  }

  Future<void> discardSession({Iterable<String> keepPaths = const []}) async {
    stopTimer();

    final keepSet = keepPaths.toSet();
    final pathsToDelete = state.segmentPaths.where(
      (path) => !keepSet.contains(path),
    );

    for (final path in pathsToDelete) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Best-effort cleanup for temporary session files.
      }
    }

    state = const RecordingState();
  }

  void reset() {
    stopTimer();
    state = const RecordingState();
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _dispose() {
    stopTimer();
  }
}
