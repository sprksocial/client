import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'actor_models.freezed.dart';
part 'actor_models.g.dart';

@freezed
class ActorViewer with _$ActorViewer {
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

  factory ActorViewer.fromJson(Map<String, dynamic> json) => _$ActorViewerFromJson(json);
}

@freezed
class KnownFollowers with _$KnownFollowers {
  const factory KnownFollowers({
    required int count,
    required List<String> followersDids, // to avoid circular dependency
  }) = _KnownFollowers;

  factory KnownFollowers.fromJson(Map<String, dynamic> json) => _$KnownFollowersFromJson(json);
}

@freezed
class ProfileViewBasic with _$ProfileViewBasic {
  const factory ProfileViewBasic({
    required String did,
    required String handle,
    String? displayName,
    @AtUriConverter() AtUri? avatar,
    // associated: lists, feedgens, starterpacks, labelers, chat?? not needed for now
    ActorViewer? viewer,
  }) = _ProfileViewBasic;

  factory ProfileViewBasic.fromJson(Map<String, dynamic> json) => _$ProfileViewBasicFromJson(json);
}

@freezed
class ProfileView with _$ProfileView {
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
  }) = _ProfileView;

  factory ProfileView.fromJson(Map<String, dynamic> json) => _$ProfileViewFromJson(json);
}

@freezed
class ProfileViewDetailed with _$ProfileViewDetailed {
  const factory ProfileViewDetailed({
    required String did,
    required String handle,
    String? displayName,
    String? description,
    @AtUriConverter() AtUri? avatar,
    @AtUriConverter() AtUri? banner,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    // joinedViaStarterPack ?????
    // associated: lists, feedgens, starterpacks, labelers, chat?? not needed for now
    // indexedAt and createdAt
    ActorViewer? viewer,
    List<Label>? labels,
    StrongRef? pinnedPost, // this is a list if the backend implements https://github.com/sprksocial/spark-back-end/issues/13
  }) = _ProfileViewDetailed;

  factory ProfileViewDetailed.fromJson(Map<String, dynamic> json) => _$ProfileViewDetailedFromJson(json);
}
