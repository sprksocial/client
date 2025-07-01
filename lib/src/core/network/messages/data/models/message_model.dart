import 'package:freezed_annotation/freezed_annotation.dart';

@freezed
class EmbedModel with _$EmbedModel {
    const EmbedModel._();
    @JsonSerializable(explicitToJson: true)
    const factory EmbedModel({
        String? url,
        String? type,
        String? preview
    }) = _EmbedModel;
    factory EmbedModel.fromJson(Map<String, dynamic> json) => _$EmbedModelFromJson(json);
}

@freezed
class MessageModel with _$MessageModel {
    const MessageModel._();
    @JsonSerializable(explicitToJson: true)
    const factory MessageModel({
        required String id,
        required String senderDid,
        required String receiverDid,
        required String message,
        required DateTime timestampz,
        EmbedModel? embed,
}) = _MessageModel;
    factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);
}