import 'package:freezed_annotation/freezed_annotation.dart';

part 'bsky_follows.freezed.dart';
part 'bsky_follows.g.dart';

/// Model for a single follow entry from Bluesky
@freezed
class BskyFollow with _$BskyFollow {
  const factory BskyFollow({
    required String did,
    required String handle,
    String? displayName,
    String? avatar,
    String? description,
    DateTime? indexedAt,
  }) = _BskyFollow;

  factory BskyFollow.fromJson(Map<String, dynamic> json) => _$BskyFollowFromJson(json);
}

/// Model for a collection of follows from Bluesky with pagination
@freezed
class BskyFollows with _$BskyFollows {
  const factory BskyFollows({
    required List<BskyFollow> follows,
    String? cursor,
  }) = _BskyFollows;

  factory BskyFollows.fromJson(Map<String, dynamic> json) => _$BskyFollowsFromJson(json);
} 