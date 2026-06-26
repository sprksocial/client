import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sprk_poptart/chat/sprk/actor/defs.dart';
import 'package:sprk_poptart/chat/sprk/convo/defs.dart' as chat_defs;

part 'message_models.freezed.dart';
part 'message_models.g.dart';

@freezed
abstract class Embed with _$Embed {
  const factory Embed({String? url, String? type, String? preview}) = _Embed;
  const Embed._();

  factory Embed.fromJson(Map<String, dynamic> json) => _$EmbedFromJson(json);

  bool get isEmpty => url == null && type == null && preview == null;
  bool get isNotEmpty => !isEmpty;
}

@freezed
abstract class Message with _$Message {
  const factory Message({
    required int id,
    @JsonKey(name: 'sender_did') required String senderDid,
    @JsonKey(name: 'receiver_did') required String receiverDid,
    required String message,
    @JsonKey(name: 'timestampz') required DateTime timestamp,
    List<Embed>? embed,
  }) = _Message;
  const Message._();

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

// XRPC Models for chat service

@freezed
abstract class SenderView with _$SenderView {
  const factory SenderView({required String did}) = _SenderView;
  const SenderView._();

  factory SenderView.fromJson(Map<String, dynamic> json) =>
      _$SenderViewFromJson(json);

  factory SenderView.fromChatMessageSender(
    chat_defs.MessageViewSender sender,
  ) => SenderView(did: sender.did);

  factory SenderView.fromChatReactionSender(
    chat_defs.ReactionViewSender sender,
  ) => SenderView(did: sender.did);
}

@freezed
abstract class ReactionView with _$ReactionView {
  const factory ReactionView({
    required String value,
    required SenderView sender,
    required String createdAt,
  }) = _ReactionView;
  const ReactionView._();

  factory ReactionView.fromJson(Map<String, dynamic> json) =>
      _$ReactionViewFromJson(json);

  factory ReactionView.fromChat(chat_defs.ReactionView reaction) =>
      ReactionView(
        value: reaction.value,
        sender: SenderView.fromChatReactionSender(reaction.sender),
        createdAt: reaction.createdAt.toUtc().toIso8601String(),
      );
}

@freezed
abstract class MessageView with _$MessageView {
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

  factory MessageView.fromJson(Map<String, dynamic> json) =>
      _$MessageViewFromJson(json);

  factory MessageView.fromChat(chat_defs.MessageView message) => MessageView(
    id: message.id,
    rev: message.rev,
    text: message.text,
    sender: SenderView.fromChatMessageSender(message.sender),
    sentAt: message.sentAt.toUtc().toIso8601String(),
    reactions:
        message.reactions?.map(ReactionView.fromChat).toList(growable: false) ??
        const [],
    embed: message.embed?.toString(),
  );
}

@freezed
abstract class DeletedMessageView with _$DeletedMessageView {
  const factory DeletedMessageView({
    required String id,
    required String rev,
    required SenderView sender,
    required String sentAt,
  }) = _DeletedMessageView;
  const DeletedMessageView._();

  factory DeletedMessageView.fromJson(Map<String, dynamic> json) =>
      _$DeletedMessageViewFromJson(json);

  factory DeletedMessageView.fromChat(chat_defs.DeletedMessageView message) =>
      DeletedMessageView(
        id: message.id,
        rev: message.rev,
        sender: SenderView.fromChatMessageSender(message.sender),
        sentAt: message.sentAt.toUtc().toIso8601String(),
      );
}

@freezed
abstract class UnsupportedMessageView with _$UnsupportedMessageView {
  const factory UnsupportedMessageView({
    required String id,
    required String rev,
    required SenderView sender,
    required String sentAt,
    required Map<String, dynamic> raw,
  }) = _UnsupportedMessageView;
  const UnsupportedMessageView._();

  factory UnsupportedMessageView.fromJson(Map<String, dynamic> json) =>
      _$UnsupportedMessageViewFromJson(json);

  factory UnsupportedMessageView.fromRaw(Map<String, dynamic> raw) {
    final message = tryFromRaw(raw);
    if (message != null) {
      return message;
    }

    throw FormatException(
      'Unsupported chat message is missing common fields: $raw',
    );
  }

  static UnsupportedMessageView? tryFromRaw(Map<String, dynamic> raw) {
    final id = raw['id'];
    final rev = raw['rev'];
    final sender = raw['sender'];
    final sentAt = raw['sentAt'];
    final senderDid = sender is Map<String, dynamic> ? sender['did'] : null;
    if (id is! String ||
        rev is! String ||
        senderDid is! String ||
        sentAt is! String) {
      return null;
    }

    return UnsupportedMessageView(
      id: id,
      rev: rev,
      sender: SenderView(did: senderDid),
      sentAt: sentAt,
      raw: raw,
    );
  }
}

@freezed
sealed class ChatMessageView with _$ChatMessageView {
  const factory ChatMessageView.message({required MessageView data}) =
      ChatMessageViewMessage;
  const factory ChatMessageView.deleted({required DeletedMessageView data}) =
      ChatMessageViewDeleted;
  const factory ChatMessageView.unsupported({
    required UnsupportedMessageView data,
  }) = ChatMessageViewUnsupported;
  const ChatMessageView._();

  factory ChatMessageView.unsupportedFromRaw(Map<String, dynamic> raw) =>
      ChatMessageView.unsupported(data: UnsupportedMessageView.fromRaw(raw));

  String get id => switch (this) {
    ChatMessageViewMessage(:final data) => data.id,
    ChatMessageViewDeleted(:final data) => data.id,
    ChatMessageViewUnsupported(:final data) => data.id,
  };

  String get rev => switch (this) {
    ChatMessageViewMessage(:final data) => data.rev,
    ChatMessageViewDeleted(:final data) => data.rev,
    ChatMessageViewUnsupported(:final data) => data.rev,
  };

  SenderView get sender => switch (this) {
    ChatMessageViewMessage(:final data) => data.sender,
    ChatMessageViewDeleted(:final data) => data.sender,
    ChatMessageViewUnsupported(:final data) => data.sender,
  };

  String get sentAt => switch (this) {
    ChatMessageViewMessage(:final data) => data.sentAt,
    ChatMessageViewDeleted(:final data) => data.sentAt,
    ChatMessageViewUnsupported(:final data) => data.sentAt,
  };
}

class ChatMessageViewConverter
    implements JsonConverter<ChatMessageView, Map<String, dynamic>> {
  const ChatMessageViewConverter();

  @override
  ChatMessageView fromJson(Map<String, dynamic> json) {
    final type = json[r'$type'] as String?;
    if (type == 'chat.sprk.convo.defs#messageView' || json['text'] is String) {
      return ChatMessageView.message(data: MessageView.fromJson(json));
    }

    if (type == 'chat.sprk.convo.defs#deletedMessageView' ||
        type == null && !json.containsKey('text')) {
      return ChatMessageView.deleted(data: DeletedMessageView.fromJson(json));
    }

    return ChatMessageView.unsupported(
      data: UnsupportedMessageView.fromRaw(json),
    );
  }

  @override
  Map<String, dynamic> toJson(ChatMessageView object) => switch (object) {
    ChatMessageViewMessage(:final data) => data.toJson(),
    ChatMessageViewDeleted(:final data) => data.toJson(),
    ChatMessageViewUnsupported(:final data) => data.raw,
  };
}

@freezed
abstract class ConvoView with _$ConvoView {
  const factory ConvoView({
    required String id,
    required String rev,
    required List<ProfileViewBasic> members,
    @ChatMessageViewConverter() ChatMessageView? lastMessage,
    @Default('accepted') String status,
    @Default(false) bool muted,
    @Default(0) int unreadCount,
  }) = _ConvoView;
  const ConvoView._();

  factory ConvoView.fromJson(Map<String, dynamic> json) =>
      _$ConvoViewFromJson(json);

  factory ConvoView.fromChat(chat_defs.ConvoView convo) => ConvoView(
    id: convo.id,
    rev: convo.rev,
    members: convo.members,
    lastMessage: _chatLastMessageFromChat(convo.lastMessage),
    status: convo.status?.toJson() ?? 'accepted',
    muted: convo.muted,
    unreadCount: convo.unreadCount,
  );
}

ChatMessageView? _chatLastMessageFromChat(
  chat_defs.UConvoViewLastMessage? message,
) {
  return switch (message) {
    null => null,
    chat_defs.UConvoViewLastMessageMessageView(:final data) =>
      ChatMessageView.message(data: MessageView.fromChat(data)),
    chat_defs.UConvoViewLastMessageDeletedMessageView(:final data) =>
      ChatMessageView.deleted(data: DeletedMessageView.fromChat(data)),
    chat_defs.UConvoViewLastMessageUnknown(:final data) =>
      ChatMessageView.unsupportedFromRaw(data),
  };
}
