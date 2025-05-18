import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_player/video_player.dart';

part 'video_review_state.freezed.dart';

/// State for video review page
@freezed
class VideoReviewState with _$VideoReviewState {
  const factory VideoReviewState({
    /// Whether the upload is in progress
    @Default(false) bool isUploading,
    
    /// Description text
    @Default('') String description,
    
    /// Alt text for the video
    @Default('') String altText,
    
    /// Video player controller
    VideoPlayerController? controller,
    
    /// Path to the video file
    required String videoPath,
    
    /// Error message, if any
    String? error,
  }) = _VideoReviewState;
  
  /// Create initial state
  factory VideoReviewState.initial(String videoPath) => VideoReviewState(
    videoPath: videoPath,
  );
}

