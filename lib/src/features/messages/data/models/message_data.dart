import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_data.freezed.dart';
part 'message_data.g.dart';

/// Data model for message items in message lists
@freezed
class MessageData with _$MessageData {
  const factory MessageData({
    required String id,
    required String username,
    required String messagePreview,
    required String timeString,
    int? unreadCount,
    String? avatarUrl,
  }) = _MessageData;

  factory MessageData.fromJson(Map<String, dynamic> json) => _$MessageDataFromJson(json);
} 