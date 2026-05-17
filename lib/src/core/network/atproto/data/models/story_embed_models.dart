import 'package:sprk_poptart/so/sprk/embed/defs.dart' as sprk_embed_defs;
import 'package:sprk_poptart/so/sprk/embed/mention.dart' as sprk_mention;

typedef StoryEmbedFrame = sprk_embed_defs.Frame;
typedef StoryEmbedMediaRef = sprk_embed_defs.MediaRef;
typedef StoryEmbedPlacement = sprk_embed_defs.Placement;
typedef StoryEmbed = sprk_mention.EmbedMention;
typedef StoryMentionEmbed = sprk_mention.EmbedMention;
typedef StoryEmbedView = sprk_mention.EmbedMentionView;
typedef StoryMentionEmbedView = sprk_mention.EmbedMentionView;

List<StoryEmbed> storyEmbedsFromJson(dynamic json) {
  if (json is! List<dynamic>) {
    return const [];
  }

  final embeds = <StoryEmbed>[];
  for (final item in json) {
    if (item is! Map<String, dynamic>) {
      continue;
    }

    try {
      embeds.add(StoryEmbed.fromJson(item));
    } catch (_) {
      continue;
    }
  }

  return embeds;
}

List<Map<String, dynamic>>? storyEmbedsToJson(List<StoryEmbed>? embeds) {
  if (embeds == null || embeds.isEmpty) {
    return null;
  }

  return embeds.map((embed) => embed.toJson()).toList();
}
