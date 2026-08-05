import 'package:image_picker/image_picker.dart';
import 'package:spark/src/core/network/atproto/data/models/story_embed_models.dart';

class StoryImageEditorResult {
  const StoryImageEditorResult({required this.image, this.embeds = const []});

  final XFile image;
  final List<StoryEmbed> embeds;
}
