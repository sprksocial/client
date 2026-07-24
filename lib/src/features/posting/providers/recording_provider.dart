import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/features/posting/providers/recording_state.dart';

part 'recording_provider.g.dart';

typedef RecordingTickScheduler =
    void Function() Function(Duration interval, void Function() onTick);

final recordingTickSchedulerProvider = Provider<RecordingTickScheduler>((ref) {
  return (interval, onTick) {
    final timer = Timer.periodic(interval, (_) => onTick());
    return timer.cancel;
  };
});

@riverpod
class Recording extends _$Recording {
  void Function()? _cancelTimer;
  final List<String> _segmentPaths = [];
  final Completer<void> _disposalCleanupCompleter = Completer<void>();

  Future<void> get disposalCleanupComplete => _disposalCleanupCompleter.future;

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

    _cancelTimer = ref.read(recordingTickSchedulerProvider)(
      const Duration(milliseconds: 100),
      () {
        // Guard against accessing state after provider disposal
        if (!ref.mounted) {
          stopTimer();
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
      },
    );
  }

  void stopRecording() {
    if (!state.isRecording) {
      return;
    }

    stopTimer();
    state = state.copyWith(isRecording: false);
  }

  void addSegment(XFile file) {
    _segmentPaths.add(file.path);
    state = state.copyWith(
      segmentPaths: List.unmodifiable(_segmentPaths),
      error: null,
    );
  }

  void selectSound(AudioTrack sound) {
    state = state.copyWith(
      selectedSound: sound,
      soundGuideOffset: sound.audioStartTime ?? Duration.zero,
      error: null,
    );
  }

  void setSelectedSoundAudioStartTime(Duration offset) {
    final sound = state.selectedSound;
    if (sound == null) return;

    state = state.copyWith(
      selectedSound: sound.copyWith(audioStartTime: offset),
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
    final pathsToDelete = _segmentPaths
        .where((path) => !keepSet.contains(path))
        .toList();

    await _deleteTemporaryFiles(pathsToDelete);
    _segmentPaths.clear();

    if (!ref.mounted) return;

    state = const RecordingState();
  }

  Future<void> _deleteTemporaryFiles(Iterable<String> paths) async {
    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Best-effort cleanup for temporary session files.
      }
    }
  }

  void reset() {
    stopTimer();
    _segmentPaths.clear();
    state = const RecordingState();
  }

  void stopTimer() {
    _cancelTimer?.call();
    _cancelTimer = null;
  }

  void _dispose() {
    final pathsToDelete = List<String>.of(_segmentPaths);
    _segmentPaths.clear();
    stopTimer();
    unawaited(
      _deleteTemporaryFiles(
        pathsToDelete,
      ).whenComplete(_disposalCleanupCompleter.complete),
    );
  }
}
