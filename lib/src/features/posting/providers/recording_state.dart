import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

part 'recording_state.freezed.dart';

@freezed
abstract class RecordingState with _$RecordingState {
  const factory RecordingState({
    @Default(false) bool isRecording,
    @Default(Duration.zero) Duration elapsedDuration,
    @Default(Duration(minutes: 3)) Duration maxDuration,
    @Default(<String>[]) List<String> segmentPaths,
    AudioTrack? selectedSound,
    @Default(Duration.zero) Duration soundGuideOffset,
    String? error,
  }) = _RecordingState;

  const RecordingState._();

  bool get hasReachedMaxDuration => elapsedDuration >= maxDuration;
  bool get hasSegments => segmentPaths.isNotEmpty;
  bool get hasSelectedSound => selectedSound != null;
  bool get canResume => hasSegments && !isRecording && !hasReachedMaxDuration;
  bool get canFinalize => hasSegments && !isRecording;
  int get segmentCount => segmentPaths.length;

  double get progress =>
      elapsedDuration.inMilliseconds / maxDuration.inMilliseconds;

  String get formattedDuration {
    final minutes = elapsedDuration.inMinutes;
    final seconds = elapsedDuration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
