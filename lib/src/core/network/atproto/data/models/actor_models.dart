import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'actor_models.freezed.dart';
part 'actor_models.g.dart';

@freezed
class ActorViewer with _$ActorViewer {
  @JsonSerializable(explicitToJson: true)
  const factory ActorViewer({
    bool? muted,
    // muted by list: when we add lists add this field
    bool? blockedBy,
    @AtUriConverter() AtUri? blocking,
    // blocked by list: when we add lists add this field
    @AtUriConverter() AtUri? following,
    @AtUriConverter() AtUri? followedBy,
    KnownFollowers? followers,
  }) = _ActorViewer;
  const ActorViewer._();

  factory ActorViewer.fromJson(Map<String, dynamic> json) => _$ActorViewerFromJson(json);
}

@freezed
class KnownFollowers with _$KnownFollowers {
  @JsonSerializable(explicitToJson: true)
  const factory KnownFollowers({
    required int count,
    required List<String> followersDids, // to avoid circular dependency
  }) = _KnownFollowers;
  const KnownFollowers._();

  factory KnownFollowers.fromJson(Map<String, dynamic> json) => switch (json) {
    {'followers': final List<ProfileViewBasic> profiles, 'count': final int count} => _$KnownFollowersFromJson({
      'count': count,
      'followersDids': profiles.map((e) => e.did).toList(),
    }),
    _ => _$KnownFollowersFromJson(json),
  };
}

@freezed
class ProfileViewBasic with _$ProfileViewBasic {
  @JsonSerializable(explicitToJson: true)
  const factory ProfileViewBasic({
    required String did,
    required String handle,
    String? displayName,
    @AtUriConverter() AtUri? avatar,
    // associated: lists, feedgens, starterpacks, labelers, chat?? not needed for now
    ActorViewer? viewer,
    List<StrongRef>? stories,
  }) = _ProfileViewBasic;
  const ProfileViewBasic._();

  factory ProfileViewBasic.fromJson(Map<String, dynamic> json) => _$ProfileViewBasicFromJson(json);
}

@freezed
class ProfileView with _$ProfileView {
  @JsonSerializable(explicitToJson: true)
  const factory ProfileView({
    required String did,
    required String handle,
    String? displayName,
    String? description,
    @AtUriConverter() AtUri? avatar,
    // associated: lists, feedgens, starterpacks, labelers, chat?? not needed for now
    // indexedAt and createdAt
    ActorViewer? viewer,
    List<Label>? labels,
    // no stories here for some reason
  }) = _ProfileView;
  const ProfileView._();

  factory ProfileView.fromJson(Map<String, dynamic> json) => _$ProfileViewFromJson(json);
}

/// Response wrapper for paginated actor search.
class SearchActorsResponse {
  SearchActorsResponse({required this.actors, this.cursor});

  /// Create a [SearchActorsResponse] from JSON.
  factory SearchActorsResponse.fromJson(Map<String, dynamic> json) {
    final actorsJson = json['actors'] as List<dynamic>? ?? <dynamic>[];
    return SearchActorsResponse(
      actors: actorsJson.map((e) => ProfileView.fromJson(e as Map<String, dynamic>)).toList(),
      cursor: json['cursor'] as String?,
    );
  }

  /// List of returned actor profiles.
  final List<ProfileView> actors;

  /// Cursor indicating the next page of results, or null when no more pages.
  final String? cursor;

  /// Convert the object back to JSON.
  Map<String, dynamic> toJson() => {'actors': actors.map((e) => e.toJson()).toList(), if (cursor != null) 'cursor': cursor};
}

@freezed
class ProfileViewDetailed with _$ProfileViewDetailed {
  @JsonSerializable(explicitToJson: true)
  const factory ProfileViewDetailed({
    required String did,
    required String handle,
    String? displayName,
    String? description,
    @AtUriConverter() AtUri? avatar,
    @AtUriConverter() AtUri? banner,
    int? followersCount,
    int? followsCount,
    int? postsCount,
    // joinedViaStarterPack ?????
    // associated: lists, feedgens, starterpacks, labelers, chat?? not needed for now
    // indexedAt and createdAt
    ActorViewer? viewer,
    List<Label>? labels,
    StrongRef? pinnedPost, // this is a list if the backend implements https://github.com/sprksocial/spark-back-end/issues/13
    List<StrongRef>? stories,
  }) = _ProfileViewDetailed;
  const ProfileViewDetailed._();

  factory ProfileViewDetailed.fromJson(Map<String, dynamic> json) => _$ProfileViewDetailedFromJson(json);
}

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({required String followMode}) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
}
