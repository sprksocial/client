import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_data.freezed.dart';
part 'activity_data.g.dart';

enum ActivityType { like, comment, follow }

@freezed
class ActivityData with _$ActivityData {
  const factory ActivityData({
    required String id,
    required String username,
    required ActivityType type,
    required String timeString,
    String? additionalInfo,
    String? targetContentId,
    String? avatarUrl,
  }) = _ActivityData;

  factory ActivityData.fromJson(Map<String, dynamic> json) => 
      _$ActivityDataFromJson(json);
} 