import 'package:atproto/com_atproto_label_defs.dart';
import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spark/src/core/utils/uri_converter.dart';

part 'actor_models.freezed.dart';
part 'actor_models.g.dart';

@freezed
abstract class ActorViewer with _$ActorViewer {
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

  factory ActorViewer.fromJson(Map<String, dynamic> json) =>
      _$ActorViewerFromJson(json);
}

@freezed
abstract class KnownFollowers with _$KnownFollowers {
  @JsonSerializable(explicitToJson: true)
  const factory KnownFollowers({
    required int count,
    required List<String> followersDids, // to avoid circular dependency
  }) = _KnownFollowers;
  const KnownFollowers._();

  factory KnownFollowers.fromJson(Map<String, dynamic> json) => switch (json) {
    {
      'followers': final List<ProfileViewBasic> profiles,
      'count': final int count,
    } =>
      _$KnownFollowersFromJson({
        'count': count,
        'followersDids': profiles.map((e) => e.did).toList(),
      }),
    _ => _$KnownFollowersFromJson(json),
  };
}

@freezed
abstract class ProfileViewBasic with _$ProfileViewBasic {
  @JsonSerializable(explicitToJson: true)
  const factory ProfileViewBasic({
    required String did,
    required String handle,
    String? displayName,
    @UriConverter() Uri? avatar,
    ActorViewer? viewer,
    List<RepoStrongRef>? stories,
  }) = _ProfileViewBasic;
  const ProfileViewBasic._();

  factory ProfileViewBasic.fromJson(Map<String, dynamic> json) =>
      _$ProfileViewBasicFromJson(json);
}

@freezed
abstract class ProfileView with _$ProfileView {
  @JsonSerializable(explicitToJson: true)
  const factory ProfileView({
    required String did,
    required String handle,
    String? displayName,
    String? description,
    @UriConverter() Uri? avatar,
    // indexedAt, createdAt
    ActorViewer? viewer,
    List<Label>? labels,
    // no stories here, for some reason
  }) = _ProfileView;
  const ProfileView._();

  factory ProfileView.fromJson(Map<String, dynamic> json) =>
      _$ProfileViewFromJson(json);
}

/// Response wrapper for paginated actor search.
class SearchActorsResponse {
  SearchActorsResponse({required this.actors, this.cursor});

  /// Create a [SearchActorsResponse] from JSON.
  factory SearchActorsResponse.fromJson(Map<String, dynamic> json) {
    final actorsJson = json['actors'] as List<dynamic>? ?? <dynamic>[];
    return SearchActorsResponse(
      actors: actorsJson
          .map((e) => ProfileView.fromJson(e as Map<String, dynamic>))
          .toList(),
      cursor: json['cursor'] as String?,
    );
  }

  /// List of returned actor profiles.
  final List<ProfileView> actors;

  /// Cursor indicating the next page of results, or null when no more pages.
  final String? cursor;

  /// Convert the object back to JSON.
  Map<String, dynamic> toJson() => {
    'actors': actors.map((e) => e.toJson()).toList(),
    if (cursor != null) 'cursor': cursor,
  };
}

/// Response wrapper for actor typeahead suggestions.
class SearchActorsTypeaheadResponse {
  SearchActorsTypeaheadResponse({required this.actors});

  /// Create a [SearchActorsTypeaheadResponse] from JSON.
  factory SearchActorsTypeaheadResponse.fromJson(Map<String, dynamic> json) {
    final actorsJson = json['actors'] as List<dynamic>? ?? <dynamic>[];
    return SearchActorsTypeaheadResponse(
      actors: actorsJson
          .map((e) => ProfileViewBasic.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// List of returned actor suggestions.
  final List<ProfileViewBasic> actors;

  /// Convert the object back to JSON.
  Map<String, dynamic> toJson() => {
    'actors': actors.map((e) => e.toJson()).toList(),
  };
}

@freezed
abstract class ProfileViewDetailed with _$ProfileViewDetailed {
  @JsonSerializable(explicitToJson: true)
  const factory ProfileViewDetailed({
    required String did,
    required String handle,
    String? displayName,
    String? description,
    @UriConverter() Uri? avatar,
    @UriConverter() Uri? banner,
    int? followersCount,
    int? followsCount,
    int? postsCount,
    // indexedAt and createdAt
    ActorViewer? viewer,
    List<Label>? labels,
    RepoStrongRef?
    pinnedPost, // this is a list if the backend implements https://github.com/sprksocial/spark-back-end/issues/13
    List<RepoStrongRef>? stories,
  }) = _ProfileViewDetailed;
  const ProfileViewDetailed._();

  factory ProfileViewDetailed.fromJson(Map<String, dynamic> json) =>
      _$ProfileViewDetailedFromJson(json);
}
