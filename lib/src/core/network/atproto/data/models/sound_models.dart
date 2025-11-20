import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';
import 'package:sparksocial/src/core/utils/uri_converter.dart';

part 'sound_models.freezed.dart';
part 'sound_models.g.dart';

@freezed
class AudioDetails with _$AudioDetails {
  @JsonSerializable(explicitToJson: true)
  const factory AudioDetails({
    String? artist,
    String? title,
  }) = _AudioDetails;

  factory AudioDetails.fromJson(Map<String, dynamic> json) => _$AudioDetailsFromJson(json);
}

@freezed
class AudioView with _$AudioView {
  @JsonSerializable(explicitToJson: true)
  const factory AudioView({
    @AtUriConverter() required AtUri uri,
    required String cid,
    required ProfileViewBasic author,
    required AudioRecord record,
    required String title,
    @UriConverter() required Uri coverArt,
    required DateTime indexedAt,
    @UriConverter() Uri? audio,
    @Default(0) int useCount,
    AudioDetails? details,
    @Default([]) List<Label> labels,
  }) = _AudioView;
  const AudioView._();

  factory AudioView.fromJson(Map<String, dynamic> json) => _$AudioViewFromJson(json);
}

@freezed
class AudioPostsResponse with _$AudioPostsResponse {
  @JsonSerializable(explicitToJson: true)
  const factory AudioPostsResponse({
    required List<PostView> posts,
    required AudioView audio,
    String? cursor,
  }) = _AudioPostsResponse;

  factory AudioPostsResponse.fromJson(Map<String, dynamic> json) => _$AudioPostsResponseFromJson(json);
}
