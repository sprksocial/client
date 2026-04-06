import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spark/src/core/network/atproto/data/models/story_embed_models.dart';

/// Result returned from the video editor containing the edited video
/// and optional metadata about audio used.
class VideoEditorResult {
  const VideoEditorResult({
    required this.video,
    this.soundRef,
    this.embeds = const [],
  });

  /// The edited video file.
  final XFile video;

  /// Reference to the audio track used, if any.
  final RepoStrongRef? soundRef;

  /// Story embeds extracted alongside the exported video.
  final List<StoryEmbed> embeds;
}
