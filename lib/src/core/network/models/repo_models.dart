import 'package:freezed_annotation/freezed_annotation.dart';

part 'repo_models.freezed.dart';
part 'repo_models.g.dart';

@freezed
class RecordResponse with _$RecordResponse {
  const factory RecordResponse({
    required String uri,
    required String cid,
    required Map<String, dynamic> value,
  }) = _RecordResponse;

  factory RecordResponse.fromJson(Map<String, dynamic> json) => _$RecordResponseFromJson(json);
}

@freezed
class BlobResponse with _$BlobResponse {
  const factory BlobResponse({
    required String blob,
    required Map<String, dynamic> blobRef,
  }) = _BlobResponse;

  factory BlobResponse.fromJson(Map<String, dynamic> json) => _$BlobResponseFromJson(json);
}

@freezed
class RecordsListResponse with _$RecordsListResponse {
  const factory RecordsListResponse({
    required List<RecordItem> records,
    String? cursor,
  }) = _RecordsListResponse;

  factory RecordsListResponse.fromJson(Map<String, dynamic> json) => _$RecordsListResponseFromJson(json);
}

@freezed
class RecordItem with _$RecordItem {
  const factory RecordItem({
    required String uri,
    required String cid,
    required Map<String, dynamic> value,
  }) = _RecordItem;

  factory RecordItem.fromJson(Map<String, dynamic> json) => _$RecordItemFromJson(json);
} 