import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:poptart/poptart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/story_embed_models.dart';
import 'package:sprk_poptart/so/sprk/embed/defs.dart' as sprk_embed_defs;
import 'package:sprk_poptart/so/sprk/story/post.dart' as sprk_story;
import 'package:sprk_poptart/so/sprk/sound/audio.dart' as sprk_audio;
import 'package:plyr_poptart/fm/plyr/track.dart' as plyr_track;

part 'record_models.freezed.dart';
part 'record_models.g.dart';

typedef StoryRecord = sprk_story.StoryPostRecord;
typedef AudioRecord = sprk_audio.SoundAudioRecord;
typedef PlyrTrackRecord = plyr_track.TrackRecord;
typedef PlyrSupportGate = plyr_track.SupportGate;
typedef PlyrFeaturedArtist = plyr_track.FeaturedArtist;

@Freezed(unionKey: r'$type')
abstract class Record with _$Record {
  factory Record.fromJson(Map<String, dynamic> json) => _$RecordFromJson(json);
  const Record._();

  @FreezedUnionValue('so.sprk.feed.post')
  const factory Record.post({
    required CaptionRef caption,
    DateTime? createdAt,
    RecordReplyRef? reply,
    List<String>? langs,
    List<String>? tags,
    List<SelfLabel>? selfLabels,
    List<RepoStrongRef>? crossposts,
    Media? media,
    RepoStrongRef? sound,
  }) = PostRecord;

  @FreezedUnionValue('so.sprk.feed.reply')
  const factory Record.reply({
    required CaptionRef caption,
    required RecordReplyRef reply,
    DateTime? createdAt,
    List<String>? langs,
    List<SelfLabel>? labels,
    Media? media,
  }) = ReplyRecord;

  @FreezedUnionValue('app.bsky.feed.post')
  const factory Record.bskyPost({
    DateTime? createdAt,
    @JsonKey(defaultValue: '') String? text,
    @JsonKey(defaultValue: []) List<Facet>? facets,
    RecordReplyRef? reply,
    List<String>? langs,
    List<String>? tags,
    List<SelfLabel>? selfLabels,
    Media? embed, // blob
    // threadgate
  }) = BskyPostRecord;

  List<String> get hashtags {
    switch (this) {
      case PostRecord(:final tags, :final caption):
        return tags ?? _extractHashtags(caption.text);
      case ReplyRecord(:final caption):
        return _extractHashtags(caption.text);
      default:
        return [];
    }
  }

  List<String> _extractHashtags(String text) {
    final regex = RegExp(r'#(\w+)');
    return regex.allMatches(text).map((match) => match.group(1)!).toList();
  }
}

extension StoryRecordConvenience on StoryRecord {
  List<StoryEmbed> get localEmbeds =>
      embeds
          ?.map(
            (embed) => switch (embed) {
              sprk_embed_defs.UEmbedsEmbedMention(:final data) => data,
              _ => null,
            },
          )
          .whereType<StoryEmbed>()
          .toList() ??
      const [];
}

/// Skeleton of a ReplyRef. Needs to be hydrated.
@freezed
abstract class RecordReplyRef with _$RecordReplyRef {
  const factory RecordReplyRef({
    required RepoStrongRef root,
    required RepoStrongRef parent,
  }) = _RecordReplyRef;
  const RecordReplyRef._();

  factory RecordReplyRef.fromJson(Map<String, dynamic> json) =>
      _$RecordReplyRefFromJson(json);
}

@Freezed(unionKey: r'$type')
sealed class Media with _$Media {
  const Media._();

  // Spark media types (new schema)
  @FreezedUnionValue('so.sprk.media.video')
  const factory Media.video({
    required Blob video,
    String? alt,
    MediaAspectRatio? aspectRatio,
  }) = MediaVideo;

  @FreezedUnionValue('so.sprk.media.image')
  const factory Media.image({required Blob image, String? alt}) = MediaImage;

  @FreezedUnionValue('so.sprk.media.images')
  const factory Media.images({required List<Image> images}) = MediaImages;

  // Bluesky embed types
  @FreezedUnionValue('app.bsky.embed.video')
  const factory Media.bskyVideo({required Blob video, String? alt}) =
      MediaBskyVideo;

  @FreezedUnionValue('app.bsky.embed.images')
  const factory Media.bskyImages({required List<Image> images}) =
      MediaBskyImages;

  @FreezedUnionValue('app.bsky.embed.record')
  const factory Media.bskyRecord({required RepoStrongRef record}) =
      MediaBskyRecord;

  @FreezedUnionValue('app.bsky.embed.recordWithMedia')
  const factory Media.bskyRecordWithMedia({
    required MediaBskyRecord record,
    required Media media,
  }) = MediaBskyRecordWithMedia;

  @FreezedUnionValue('app.bsky.embed.external')
  const factory Media.bskyExternal({required EmbedExternal external}) =
      MediaBskyExternal;

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
}

final class MediaAspectRatio {
  const MediaAspectRatio({required this.width, required this.height});

  factory MediaAspectRatio.fromJson(Map<String, dynamic> json) {
    return MediaAspectRatio(
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
    );
  }

  static MediaAspectRatio? fromDimensions({
    required num? width,
    required num? height,
  }) {
    if (width == null || height == null || width <= 0 || height <= 0) {
      return null;
    }

    final normalizedWidth = width.round();
    final normalizedHeight = height.round();
    if (normalizedWidth <= 0 || normalizedHeight <= 0) return null;

    final divisor = _greatestCommonDivisor(normalizedWidth, normalizedHeight);
    return MediaAspectRatio(
      width: normalizedWidth ~/ divisor,
      height: normalizedHeight ~/ divisor,
    );
  }

  final int width;
  final int height;

  double? get value {
    if (width <= 0 || height <= 0) return null;
    return width / height;
  }

  Map<String, dynamic> toJson() => {'width': width, 'height': height};

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MediaAspectRatio &&
            runtimeType == other.runtimeType &&
            width == other.width &&
            height == other.height;
  }

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() => 'MediaAspectRatio(width: $width, height: $height)';

  static int _greatestCommonDivisor(int a, int b) {
    var x = a.abs();
    var y = b.abs();
    while (y != 0) {
      final next = x % y;
      x = y;
      y = next;
    }
    return x == 0 ? 1 : x;
  }
}

@freezed
abstract class EmbedExternal with _$EmbedExternal {
  const factory EmbedExternal({
    required String uri,
    @Default('') String title,
    @Default('') String description,
    Blob? thumb,
  }) = _EmbedExternal;
  const EmbedExternal._();

  factory EmbedExternal.fromJson(Map<String, dynamic> json) =>
      _$EmbedExternalFromJson(json);
}

@freezed
abstract class Image with _$Image {
  const factory Image({
    required Blob image,
    String? alt,
    // aspectRatio: {width: int, height: int}
  }) = _Image;
  const Image._();

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
}
