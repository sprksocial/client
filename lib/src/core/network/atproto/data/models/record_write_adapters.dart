import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart'
    as local;
import 'package:spark/src/core/network/atproto/data/models/models.dart'
    as local;
import 'package:sprk_poptart/so/sprk/feed/post.dart' as sprk_post;
import 'package:sprk_poptart/so/sprk/feed/reply.dart' as sprk_reply;
import 'package:sprk_poptart/so/sprk/embed/defs.dart' as sprk_embed_defs;

import 'package:sprk_poptart/so/sprk/media/image.dart' as sprk_image;
import 'package:sprk_poptart/so/sprk/media/images.dart' as sprk_images;
import 'package:sprk_poptart/so/sprk/media/defs/aspect_ratio.dart'
    as sprk_media_defs;
import 'package:sprk_poptart/so/sprk/media/video.dart' as sprk_video;
import 'package:sprk_poptart/so/sprk/richtext/facet.dart' as sprk_facet;
import 'package:sprk_poptart/so/sprk/story/post.dart' as sprk_story;

sprk_post.FeedPostRecord sprkPostRecordFromLocal(local.PostRecord record) {
  final media = record.media;
  if (media == null) {
    throw ArgumentError('Spark feed posts require media');
  }

  return sprk_post.FeedPostRecord(
    caption: _sprkCaptionRef(record.caption),
    media: _sprkPostMedia(media),
    sound: record.sound,
    langs: record.langs,
    labels: _sprkPostLabels(record.selfLabels),
    tags: record.tags,
    crossposts: record.crossposts,
    createdAt: record.createdAt ?? DateTime.now().toUtc(),
  );
}

sprk_reply.FeedReplyRecord sprkReplyRecordFromLocal(local.ReplyRecord record) {
  return sprk_reply.FeedReplyRecord(
    text: record.caption.text,
    facets: _sprkFacets(record.caption.facets),
    reply: sprk_reply.ReplyRef(
      root: record.reply.root,
      parent: record.reply.parent,
    ),
    media: record.media == null ? null : _sprkReplyMedia(record.media!),
    langs: record.langs,
    labels: _sprkReplyLabels(record.labels),
    createdAt: record.createdAt ?? DateTime.now().toUtc(),
  );
}

sprk_story.StoryPostRecord sprkStoryRecordFromLocal({
  required local.Media media,
  required DateTime createdAt,
  RepoStrongRef? sound,
  List<SelfLabel>? labels,
  List<local.StoryEmbed>? embeds,
}) {
  return sprk_story.StoryPostRecord(
    media: _sprkStoryMedia(media),
    sound: sound,
    embeds: _sprkStoryEmbeds(embeds),
    labels: _sprkStoryLabels(labels),
    createdAt: createdAt,
  );
}

sprk_post.CaptionRef _sprkCaptionRef(local.CaptionRef caption) {
  return sprk_post.CaptionRef(
    text: caption.text,
    facets: _sprkFacets(caption.facets),
  );
}

List<sprk_facet.RichtextFacet>? _sprkFacets(List<local.Facet> facets) {
  if (facets.isEmpty) return null;
  return facets
      .map((facet) => sprk_facet.RichtextFacet.fromJson(facet.toJson()))
      .toList();
}

sprk_post.UFeedPostMedia _sprkPostMedia(local.Media media) {
  return switch (media) {
    local.MediaVideo(:final video, :final alt, :final aspectRatio) =>
      sprk_post.UFeedPostMedia.mediaVideo(
        data: sprk_video.MediaVideo(
          video: video,
          alt: alt,
          aspectRatio: _sprkAspectRatio(aspectRatio),
        ),
      ),
    local.MediaImages(:final images) => sprk_post.UFeedPostMedia.mediaImages(
      data: sprk_images.MediaImages(
        images: images.map(_sprkMediaImage).toList(),
      ),
    ),
    local.MediaImage(:final image, :final alt) =>
      sprk_post.UFeedPostMedia.mediaImages(
        data: sprk_images.MediaImages(
          images: [sprk_image.MediaImage(image: image, alt: alt ?? '')],
        ),
      ),
    _ => sprk_post.UFeedPostMedia.unknown(data: media.toJson()),
  };
}

sprk_reply.UFeedReplyMedia _sprkReplyMedia(local.Media media) {
  return switch (media) {
    local.MediaImage(:final image, :final alt) =>
      sprk_reply.UFeedReplyMedia.mediaImage(
        data: sprk_image.MediaImage(image: image, alt: alt ?? ''),
      ),
    _ => sprk_reply.UFeedReplyMedia.unknown(data: media.toJson()),
  };
}

sprk_story.UStoryPostMedia _sprkStoryMedia(local.Media media) {
  return switch (media) {
    local.MediaImage(:final image, :final alt) =>
      sprk_story.UStoryPostMedia.mediaImage(
        data: sprk_image.MediaImage(image: image, alt: alt ?? ''),
      ),
    local.MediaVideo(:final video, :final alt, :final aspectRatio) =>
      sprk_story.UStoryPostMedia.mediaVideo(
        data: sprk_video.MediaVideo(
          video: video,
          alt: alt,
          aspectRatio: _sprkAspectRatio(aspectRatio),
        ),
      ),
    _ => sprk_story.UStoryPostMedia.unknown(data: media.toJson()),
  };
}

sprk_image.MediaImage _sprkMediaImage(local.Image image) {
  return sprk_image.MediaImage(image: image.image, alt: image.alt ?? '');
}

sprk_media_defs.AspectRatio? _sprkAspectRatio(
  local.MediaAspectRatio? aspectRatio,
) {
  if (aspectRatio == null) return null;
  return sprk_media_defs.AspectRatio(
    width: aspectRatio.width,
    height: aspectRatio.height,
  );
}

sprk_post.UFeedPostLabels? _sprkPostLabels(List<SelfLabel>? labels) {
  if (labels == null || labels.isEmpty) return null;
  return sprk_post.UFeedPostLabels.selfLabels(data: SelfLabels(values: labels));
}

sprk_reply.UFeedReplyLabels? _sprkReplyLabels(List<SelfLabel>? labels) {
  if (labels == null || labels.isEmpty) return null;
  return sprk_reply.UFeedReplyLabels.selfLabels(
    data: SelfLabels(values: labels),
  );
}

sprk_story.UStoryPostLabels? _sprkStoryLabels(List<SelfLabel>? labels) {
  if (labels == null || labels.isEmpty) return null;
  return sprk_story.UStoryPostLabels.selfLabels(
    data: SelfLabels(values: labels),
  );
}

List<sprk_embed_defs.UEmbeds>? _sprkStoryEmbeds(
  List<local.StoryEmbed>? embeds,
) {
  if (embeds == null || embeds.isEmpty) return null;
  return embeds.map(_sprkStoryEmbed).toList();
}

sprk_embed_defs.UEmbeds _sprkStoryEmbed(local.StoryEmbed embed) {
  return sprk_embed_defs.UEmbeds.embedMention(data: embed);
}
