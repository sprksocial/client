import 'dart:async';

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
    if (state.isRecording) {
      return;
    }

    state = state.copyWith(
      isRecording: true,
      elapsedDuration: Duration.zero,
      error: null,
    );

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final newDuration =
          state.elapsedDuration + const Duration(milliseconds: 100);

      if (newDuration >= state.maxDuration) {
        stopTimer();
        state = state.copyWith(
          elapsedDuration: state.maxDuration,
          isRecording: false,
        );
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
