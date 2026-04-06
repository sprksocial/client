import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';

part 'story_embed_models.freezed.dart';
part 'story_embed_models.g.dart';

const _storyMentionEmbedType = 'so.sprk.embed.mention';
const _storyMentionEmbedViewType = 'so.sprk.embed.mention#view';

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
      embeds.add(_storyEmbedFromJson(item));
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

  return embeds.map(_storyEmbedToJson).toList();
}

List<StoryEmbedView> storyEmbedViewsFromJson(dynamic json) {
  if (json is! List<dynamic>) {
    return const [];
  }

  final embeds = <StoryEmbedView>[];
  for (final item in json) {
    if (item is! Map<String, dynamic>) {
      continue;
    }

    try {
      embeds.add(_storyEmbedViewFromJson(item));
    } catch (_) {
      continue;
    }
  }

  return embeds;
}

List<Map<String, dynamic>>? storyEmbedViewsToJson(
  List<StoryEmbedView>? embeds,
) {
  if (embeds == null || embeds.isEmpty) {
    return null;
  }

  return embeds.map(_storyEmbedViewToJson).toList();
}

StoryEmbed _storyEmbedFromJson(Map<String, dynamic> json) {
  final type = json[r'$type'] as String?;
  if (type == null || type == _storyMentionEmbedType) {
    return StoryEmbed.fromJson(json);
  }

  throw FormatException('Unsupported story embed type: $type');
}

Map<String, dynamic> _storyEmbedToJson(StoryEmbed embed) {
  return embed.map(
    mention: (value) => <String, dynamic>{
      r'$type': _storyMentionEmbedType,
      ...value.toJson(),
    },
  );
}

StoryEmbedView _storyEmbedViewFromJson(Map<String, dynamic> json) {
  final type = json[r'$type'] as String?;
  if (type == null || type == _storyMentionEmbedViewType) {
    return StoryEmbedView.fromJson(json);
  }

  throw FormatException('Unsupported story embed view type: $type');
}

Map<String, dynamic> _storyEmbedViewToJson(StoryEmbedView embed) {
  return embed.map(
    mention: (value) => <String, dynamic>{
      r'$type': _storyMentionEmbedViewType,
      ...value.toJson(),
    },
  );
}

@freezed
abstract class StoryEmbedFrame with _$StoryEmbedFrame {
  @JsonSerializable(explicitToJson: true)
  const factory StoryEmbedFrame({
    required int x,
    required int y,
    required int w,
    required int h,
  }) = _StoryEmbedFrame;
  const StoryEmbedFrame._();

  factory StoryEmbedFrame.fromJson(Map<String, dynamic> json) =>
      _$StoryEmbedFrameFromJson(json);
}

@freezed
abstract class StoryEmbedMediaRef with _$StoryEmbedMediaRef {
  @JsonSerializable(explicitToJson: true)
  const factory StoryEmbedMediaRef({required int index}) = _StoryEmbedMediaRef;
  const StoryEmbedMediaRef._();

  factory StoryEmbedMediaRef.fromJson(Map<String, dynamic> json) =>
      _$StoryEmbedMediaRefFromJson(json);
}

@freezed
abstract class StoryEmbedPlacement with _$StoryEmbedPlacement {
  @JsonSerializable(explicitToJson: true)
  const factory StoryEmbedPlacement({
    required StoryEmbedFrame frame,
    StoryEmbedMediaRef? mediaRef,
    int? zIndex,
    int? rotation,
  }) = _StoryEmbedPlacement;
  const StoryEmbedPlacement._();

  factory StoryEmbedPlacement.fromJson(Map<String, dynamic> json) =>
      _$StoryEmbedPlacementFromJson(json);
}

@Freezed(unionKey: r'$type')
sealed class StoryEmbed with _$StoryEmbed {
  const StoryEmbed._();

  @FreezedUnionValue(_storyMentionEmbedType)
  @JsonSerializable(explicitToJson: true)
  const factory StoryEmbed.mention({
    required StoryEmbedPlacement placement,
    required String did,
  }) = StoryMentionEmbed;

  factory StoryEmbed.fromJson(Map<String, dynamic> json) =>
      _$StoryEmbedFromJson(json);
}

@Freezed(unionKey: r'$type')
sealed class StoryEmbedView with _$StoryEmbedView {
  const StoryEmbedView._();

  @FreezedUnionValue(_storyMentionEmbedViewType)
  @JsonSerializable(explicitToJson: true)
  const factory StoryEmbedView.mention({
    required StoryEmbedPlacement placement,
    required String did,
    ProfileViewBasic? actor,
  }) = StoryMentionEmbedView;

  factory StoryEmbedView.fromJson(Map<String, dynamic> json) =>
      _$StoryEmbedViewFromJson(json);
}
