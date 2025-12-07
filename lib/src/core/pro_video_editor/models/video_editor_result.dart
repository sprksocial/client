import 'package:atproto/atproto.dart';
import 'package:image_picker/image_picker.dart';

/// Result returned from the video editor containing the edited video
/// and optional metadata about audio used.
class VideoEditorResult {
  const VideoEditorResult({
    required this.video,
    this.soundRef,
  });

  /// The edited video file.
  final XFile video;

  /// Reference to the audio track used, if any.
  final StrongRef? soundRef;
}
