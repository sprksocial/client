import 'package:atproto/com_atproto_label_defs.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';

part 'notification_models.freezed.dart';
part 'notification_models.g.dart';

@freezed
abstract class Notification with _$Notification {
  @JsonSerializable(explicitToJson: true)
  const factory Notification({
    @AtUriConverter() required AtUri uri,
    required String cid,
    required ProfileViewBasic author,
    required String reason,
    required Map<String, dynamic> record,
    required bool isRead,
    required DateTime indexedAt,
    @JsonKey(name: r'$type') String? type,
    @AtUriConverter() AtUri? reasonSubject,
    @Default(null) List<Label>? labels,
  }) = _Notification;
  const Notification._();

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
}

@freezed
abstract class ListNotificationsResponse with _$ListNotificationsResponse {
  @JsonSerializable(explicitToJson: true)
  const factory ListNotificationsResponse({
    required List<Notification> notifications,
    String? cursor,
    bool? priority,
    DateTime? seenAt,
  }) = _ListNotificationsResponse;
  const ListNotificationsResponse._();

  factory ListNotificationsResponse.fromJson(Map<String, dynamic> json) =>
      _$ListNotificationsResponseFromJson(json);
}

@freezed
abstract class UnreadCountResponse with _$UnreadCountResponse {
  @JsonSerializable(explicitToJson: true)
  const factory UnreadCountResponse({required int count}) =
      _UnreadCountResponse;
  const UnreadCountResponse._();

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountResponseFromJson(json);
}

@freezed
abstract class UpdateSeenRequest with _$UpdateSeenRequest {
  @JsonSerializable(explicitToJson: true)
  const factory UpdateSeenRequest({required DateTime seenAt}) =
      _UpdateSeenRequest;
  const UpdateSeenRequest._();

  factory UpdateSeenRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSeenRequestFromJson(json);
}
