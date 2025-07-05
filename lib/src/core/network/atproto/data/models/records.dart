import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';

part 'records.freezed.dart';
part 'records.g.dart';

@Freezed(unionKey: r'$type')
class Record with _$Record {
  factory Record.fromJson(Map<String, dynamic> json) => _$RecordFromJson(json);
  const Record._();
  @JsonSerializable(explicitToJson: true)
  @FreezedUnionValue('so.sprk.feed.post')
  const factory Record.post({
    DateTime? createdAt,
    @JsonKey(defaultValue: '') String? text,
    @JsonKey(defaultValue: []) List<Facet>? facets,
    RecordReplyRef? reply,
    List<String>? langs,
    List<String>? tags,
    List<SelfLabel>? selfLabels,
    Embed? embed, // blob
    // threadgate
  }) = PostRecord;

  @JsonSerializable(explicitToJson: true)
  @FreezedUnionValue('so.sprk.feed.story')
  const factory Record.story({
    required Embed media,
    required DateTime createdAt,
    StrongRef? sound,
    List<SelfLabel>? selfLabels,
    List<String>? tags,
  }) = StoryRecord;

  @JsonSerializable(explicitToJson: true)
  @FreezedUnionValue('so.sprk.actor.profile')
  const factory Record.profile({
    String? displayName,
    String? description,
    Blob? avatar,
    Blob? banner,
    List<SelfLabel>? selfLabels,
    StrongRef? joinedViaStarterPack,
    StrongRef? pinnedPost,
    DateTime? createdAt,
  }) = ProfileRecord;

  @JsonSerializable(explicitToJson: true)
  @FreezedUnionValue('app.bsky.feed.post')
  const factory Record.bskyPost({
    DateTime? createdAt,
    @JsonKey(defaultValue: '') String? text,
    @JsonKey(defaultValue: []) List<Facet>? facets,
    RecordReplyRef? reply,
    List<String>? langs,
    List<String>? tags,
    List<SelfLabel>? selfLabels,
    Embed? embed, // blob
    // threadgate
  }) = BskyPostRecord;

  List<String> get hashtags {
    switch (this) {
      case PostRecord(:final tags, :final text):
        return tags ?? _extractHashtags(text ?? '');
      case StoryRecord(:final tags):
        return tags ?? [];
      default:
        return [];
    }
  }

  List<String> _extractHashtags(String text) {
    final regex = RegExp(r'#(\w+)');
    return regex.allMatches(text).map((match) => match.group(1)!).toList();
  }
}

/// Skeleton of a ReplyRef. Needs to be hydrated.
@freezed
class RecordReplyRef with _$RecordReplyRef {
  @JsonSerializable(explicitToJson: true)
  const factory RecordReplyRef({required StrongRef root, required StrongRef parent}) = _RecordReplyRef;
  const RecordReplyRef._();

  factory RecordReplyRef.fromJson(Map<String, dynamic> json) => _$RecordReplyRefFromJson(json);
}

@Freezed(unionKey: r'$type')
sealed class Embed with _$Embed {
  const Embed._();

  // Spark embed types
  @FreezedUnionValue('so.sprk.embed.video')
  @JsonSerializable(explicitToJson: true)
  const factory Embed.video({
    required Blob video,

    // remaining fields that are in the json
    // List<Caption> captions,
    // AspectRatio aspectRatio, {width: int, height: int}
    String? alt,
  }) = EmbedVideo;

  @FreezedUnionValue('so.sprk.embed.images')
  @JsonSerializable(explicitToJson: true)
  const factory Embed.image({required List<Image> images}) = EmbedImage;

  // Bluesky embed types
  @FreezedUnionValue('app.bsky.embed.video')
  @JsonSerializable(explicitToJson: true)
  const factory Embed.bskyVideo({
    required Blob video,
    String? alt,
  }) = EmbedBskyVideo;

  @FreezedUnionValue('app.bsky.embed.images')
  @JsonSerializable(explicitToJson: true)
  const factory Embed.bskyImages({required List<Image> images}) = EmbedBskyImages;

  @FreezedUnionValue('app.bsky.embed.record')
  @JsonSerializable(explicitToJson: true)
  const factory Embed.bskyRecord({required StrongRef record}) = EmbedBskyRecord;

  @FreezedUnionValue('app.bsky.embed.recordWithMedia')
  @JsonSerializable(explicitToJson: true)
  const factory Embed.bskyRecordWithMedia({
    required StrongRef record,
    required Embed media,
  }) = EmbedBskyRecordWithMedia;

  @FreezedUnionValue('app.bsky.embed.external')
  @JsonSerializable(explicitToJson: true)
  const factory Embed.bskyExternal({
    required EmbedExternal external,
  }) = EmbedBskyExternal;

  factory Embed.fromJson(Map<String, dynamic> json) => _$EmbedFromJson(json);
}

@freezed
class EmbedExternal with _$EmbedExternal {
  @JsonSerializable(explicitToJson: true)
  const factory EmbedExternal({
    required String uri,
    @Default('') String title,
    @Default('') String description,
    Blob? thumb,
  }) = _EmbedExternal;
  const EmbedExternal._();

  factory EmbedExternal.fromJson(Map<String, dynamic> json) => _$EmbedExternalFromJson(json);
}

@freezed
class Image with _$Image {
  @JsonSerializable(explicitToJson: true)
  const factory Image({
    required Blob image,
    String? alt,
    // aspectRatio: {width: int, height: int}
  }) = _Image;
  const Image._();

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
}
