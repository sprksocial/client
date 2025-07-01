import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_models.freezed.dart';
part 'message_models.g.dart';

@freezed
class Embed with _$Embed {
  const Embed._();

  @JsonSerializable(explicitToJson: true)
  const factory Embed({String? url, String? type, String? preview}) = _Embed;

  factory Embed.fromJson(Map<String, dynamic> json) => _$EmbedFromJson(json);

  bool get isEmpty => url == null && type == null && preview == null;
  bool get isNotEmpty => !isEmpty;
}

@freezed
class Message with _$Message {
  const Message._();
  @JsonSerializable(explicitToJson: true)
  const factory Message({
    required String id,
    required String senderDid,
    required String receiverDid,
    required String message,
    required DateTime timestamp,
    List<Embed>? embed,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}
