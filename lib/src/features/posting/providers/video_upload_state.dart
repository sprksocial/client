import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_upload_state.freezed.dart';

@freezed
class VideoUploadState with _$VideoUploadState {
  const VideoUploadState._();

  /// Initial state
  const factory VideoUploadState.initial({required String videoPath}) = VideoUploadStateInitial;

  /// Processing video file
  const factory VideoUploadState.processingVideo({required String videoPath}) = VideoUploadStateProcessingVideo;

  /// Video processed successfully
  const factory VideoUploadState.videoProcessed({required String videoPath, required Blob blob}) = VideoUploadStateVideoProcessed;

  /// Posting video to feed
  const factory VideoUploadState.postingVideo({
    required String videoPath,
    required Blob blob,
    required String description,
    required String altText,
  }) = VideoUploadStatePostingVideo;

  /// Video posted successfully
  const factory VideoUploadState.posted({required String videoPath, required Blob blob, required StrongRef postRef}) =
      VideoUploadStatePosted;

  /// Error occurred
  const factory VideoUploadState.error({required String message, String? videoPath, Blob? blob}) = VideoUploadStateError;

  /// Whether the service is currently busy
  bool get isBusy => when(
    initial: (_) => false,
    processingVideo: (_) => true,
    videoProcessed: (_, _) => false,
    postingVideo: (_, _, _, _) => true,
    posted: (_, _, _) => false,
    error: (_, _, _) => false,
  );

  /// Whether there's an error
  bool get hasError => when(
    initial: (_) => false,
    processingVideo: (_) => false,
    videoProcessed: (_, _) => false,
    postingVideo: (_, _, _, _) => false,
    posted: (_, _, _) => false,
    error: (_, _, _) => true,
  );

  /// Get current video path if available
  String? get currentVideoPath => when(
    initial: (path) => path,
    processingVideo: (path) => path,
    videoProcessed: (path, _) => path,
    postingVideo: (path, _, _, _) => path,
    posted: (path, _, _) => path,
    error: (_, path, _) => path,
  );

  /// Get current blob reference if available
  Blob? get currentBlob => when(
    initial: (_) => null,
    processingVideo: (_) => null,
    videoProcessed: (_, blob) => blob,
    postingVideo: (_, blob, _, _) => blob,
    posted: (_, blob, _) => blob,
    error: (_, _, blob) => blob,
  );
}
