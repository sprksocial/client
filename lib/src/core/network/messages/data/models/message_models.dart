import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_models.freezed.dart';
part 'message_models.g.dart';

@freezed
abstract class Embed with _$Embed {
  @JsonSerializable(explicitToJson: true)
  const factory Embed({String? url, String? type, String? preview}) = _Embed;
  const Embed._();

  factory Embed.fromJson(Map<String, dynamic> json) => _$EmbedFromJson(json);

  bool get isEmpty => url == null && type == null && preview == null;
  bool get isNotEmpty => !isEmpty;
}

@freezed
abstract class Message with _$Message {
  @JsonSerializable(explicitToJson: true)
  const factory Message({
    required int id,
    @JsonKey(name: 'sender_did') required String senderDid,
    @JsonKey(name: 'receiver_did') required String receiverDid,
    required String message,
    @JsonKey(name: 'timestampz') required DateTime timestamp,
    List<Embed>? embed,
  }) = _Message;
  const Message._();

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}

// XRPC Models for chat service

@freezed
abstract class SenderView with _$SenderView {
  @JsonSerializable(explicitToJson: true)
  const factory SenderView({
    required String did,
  }) = _SenderView;
  const SenderView._();

  factory SenderView.fromJson(Map<String, dynamic> json) => _$SenderViewFromJson(json);
}

@freezed
abstract class ReactionView with _$ReactionView {
  @JsonSerializable(explicitToJson: true)
  const factory ReactionView({
    required String value,
    required SenderView sender,
    required String createdAt,
  }) = _ReactionView;
  const ReactionView._();

  factory ReactionView.fromJson(Map<String, dynamic> json) => _$ReactionViewFromJson(json);
}

@freezed
abstract class MessageView with _$MessageView {
  @JsonSerializable(explicitToJson: true)
  const factory MessageView({
    required String id,
    required String rev,
    required String text,
    required SenderView sender,
    required String sentAt,
    required List<ReactionView> reactions,
    String? embed, // Optional at:// URI for first embed
  }) = _MessageView;
  const MessageView._();

  factory MessageView.fromJson(Map<String, dynamic> json) => _$MessageViewFromJson(json);
}

@freezed
abstract class DeletedMessageView with _$DeletedMessageView {
  @JsonSerializable(explicitToJson: true)
  const factory DeletedMessageView({
    required String id,
    required String rev,
    required SenderView sender,
    required String sentAt,
  }) = _DeletedMessageView;
  const DeletedMessageView._();

  factory DeletedMessageView.fromJson(Map<String, dynamic> json) => _$DeletedMessageViewFromJson(json);
}

@freezed
abstract class ConvoView with _$ConvoView {
  @JsonSerializable(explicitToJson: true)
  const factory ConvoView({
    required String id,
    required String rev,
    required List<String> members,
    MessageView? lastMessage,
    @Default('accepted') String status,
    @Default(false) bool muted,
    @Default(0) int unreadCount,
  }) = _ConvoView;
  const ConvoView._();

  factory ConvoView.fromJson(Map<String, dynamic> json) => _$ConvoViewFromJson(json);
}
