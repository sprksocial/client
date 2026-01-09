import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/utils/logging/logging.dart';
import 'package:spark/src/features/posting/providers/recording_state.dart';

part 'recording_provider.g.dart';

@riverpod
class Recording extends _$Recording {
  late final SparkLogger _logger;
  Timer? _timer;

  @override
  RecordingState build() {
    _logger = GetIt.instance<LogService>().getLogger('Recording');
    ref.onDispose(_dispose);
    return const RecordingState();
  }

  void startRecording() {
    if (state.isRecording) {
      _logger.w('Recording already started');
      return;
    }

    _logger.d('Starting recording timer');
    state = state.copyWith(
      isRecording: true,
      elapsedDuration: Duration.zero,
      error: null,
    );

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final newDuration =
          state.elapsedDuration + const Duration(milliseconds: 100);

      if (newDuration >= state.maxDuration) {
        _logger.i('Max duration reached, stopping timer');
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
      _logger.w('Not currently recording');
      return;
    }

    _logger.d('Stopping recording timer');
    stopTimer();
    state = state.copyWith(isRecording: false);
  }

  void reset() {
    _logger.d('Resetting recording state');
    stopTimer();
    state = const RecordingState();
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _dispose() {
    _logger.d('Disposing recording provider');
    stopTimer();
  }
}
