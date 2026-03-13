import 'package:atproto/com_atproto_label_defs.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/utils/uri_converter.dart';

part 'sound_models.freezed.dart';
part 'sound_models.g.dart';

AudioRecord _audioRecordFromJson(dynamic json) {
  if (json is! Map<String, dynamic>) {
    throw Exception(
      'Expected Map<String, dynamic> but got ${json.runtimeType}',
    );
  }

  final jsonWithType = json.containsKey(r'$type')
      ? json
      : {...json, r'$type': 'so.sprk.sound.audio'};

  final record = Record.fromJson(jsonWithType);
  if (record is AudioRecord) {
    return record;
  }
  throw Exception('Expected AudioRecord but got ${record.runtimeType}');
}

Map<String, dynamic> _audioRecordToJson(AudioRecord record) => record.toJson();

@freezed
abstract class AudioDetails with _$AudioDetails {
  @JsonSerializable(explicitToJson: true)
  const factory AudioDetails({String? artist, String? title}) = _AudioDetails;

  factory AudioDetails.fromJson(Map<String, dynamic> json) =>
      _$AudioDetailsFromJson(json);
}

@freezed
abstract class AudioView with _$AudioView {
  @JsonSerializable(explicitToJson: true)
  const factory AudioView({
    @AtUriConverter() required AtUri uri,
    required String cid,
    required ProfileViewBasic author,
    @JsonKey(fromJson: _audioRecordFromJson, toJson: _audioRecordToJson)
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

  factory AudioView.fromJson(Map<String, dynamic> json) =>
      _$AudioViewFromJson(json);
}

@freezed
abstract class AudioPostsResponse with _$AudioPostsResponse {
  @JsonSerializable(explicitToJson: true)
  const factory AudioPostsResponse({
    required List<PostView> posts,
    required AudioView audio,
    String? cursor,
  }) = _AudioPostsResponse;

  factory AudioPostsResponse.fromJson(Map<String, dynamic> json) =>
      _$AudioPostsResponseFromJson(json);
}

@freezed
abstract class TrendingAudiosResponse with _$TrendingAudiosResponse {
  @JsonSerializable(explicitToJson: true)
  const factory TrendingAudiosResponse({
    required List<AudioView> audios,
    String? cursor,
  }) = _TrendingAudiosResponse;

  factory TrendingAudiosResponse.fromJson(Map<String, dynamic> json) =>
      _$TrendingAudiosResponseFromJson(json);
}

class VideoUploadResult {
  VideoUploadResult({
    required this.videoBlob,
    this.audioBlob,
    this.audioDetails,
  });

  final Blob videoBlob;
  final Blob? audioBlob;
  final AudioDetails? audioDetails;
}
