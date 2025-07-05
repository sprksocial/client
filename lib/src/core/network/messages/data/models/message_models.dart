import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_models.freezed.dart';
part 'message_models.g.dart';

@freezed
class Embed with _$Embed {
  @JsonSerializable(explicitToJson: true)
  const factory Embed({String? url, String? type, String? preview}) = _Embed;
  const Embed._();

  factory Embed.fromJson(Map<String, dynamic> json) => _$EmbedFromJson(json);

  bool get isEmpty => url == null && type == null && preview == null;
  bool get isNotEmpty => !isEmpty;
}

@freezed
class Message with _$Message {
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
