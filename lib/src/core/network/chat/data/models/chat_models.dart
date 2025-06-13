import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_models.freezed.dart';
part 'chat_models.g.dart';

/// Represents a chat message
@freezed
class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  @JsonSerializable(explicitToJson: true)
  const factory ChatMessage({
    required String id,
    required String message,
    required String senderDid,
    required String receiverDid,
    required DateTime timestamp,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
}

/// Request model for sending a message
@freezed
class SendMessageRequest with _$SendMessageRequest {
  const SendMessageRequest._();

  @JsonSerializable(explicitToJson: true)
  const factory SendMessageRequest({
    required String message,
    required String receiverDid,
  }) = _SendMessageRequest;

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) => _$SendMessageRequestFromJson(json);
}

/// Response model for sending a message
@freezed
class SendMessageResponse with _$SendMessageResponse {
  const SendMessageResponse._();

  @JsonSerializable(explicitToJson: true)
  const factory SendMessageResponse({
    required String messageId,
    required DateTime timestamp,
  }) = _SendMessageResponse;

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) => _$SendMessageResponseFromJson(json);
}

/// Response model for getting messages
@freezed
class GetMessagesResponse with _$GetMessagesResponse {
  const GetMessagesResponse._();

  @JsonSerializable(explicitToJson: true)
  const factory GetMessagesResponse({
    required List<ChatMessage> messages,
  }) = _GetMessagesResponse;

  factory GetMessagesResponse.fromJson(Map<String, dynamic> json) => _$GetMessagesResponseFromJson(json);
}

/// Response model for getting chats list
@freezed
class GetChatsResponse with _$GetChatsResponse {
  const GetChatsResponse._();

  @JsonSerializable(explicitToJson: true)
  const factory GetChatsResponse({
    required List<String> chats,
  }) = _GetChatsResponse;

  factory GetChatsResponse.fromJson(Map<String, dynamic> json) => _$GetChatsResponseFromJson(json);
}

/// WebSocket message types
enum WebSocketMessageType {
  @JsonValue('new_message')
  newMessage,
  @JsonValue('message_read')
  messageRead,
  @JsonValue('typing')
  typing,
  @JsonValue('error')
  error,
}

/// WebSocket message data for new message events
@freezed
class WebSocketMessageData with _$WebSocketMessageData {
  const WebSocketMessageData._();

  @JsonSerializable(explicitToJson: true)
  const factory WebSocketMessageData({
    required String id,
    required String message,
    @JsonKey(name: 'sender_did') required String senderDid,
    @JsonKey(name: 'receiver_did') required String receiverDid,
    required DateTime timestamp,
  }) = _WebSocketMessageData;

  factory WebSocketMessageData.fromJson(Map<String, dynamic> json) => _$WebSocketMessageDataFromJson(json);
}

/// WebSocket message wrapper
@freezed
class WebSocketMessage with _$WebSocketMessage {
  const WebSocketMessage._();

  @JsonSerializable(explicitToJson: true)
  const factory WebSocketMessage({
    required WebSocketMessageType type,
    WebSocketMessageData? data,
    String? error,
  }) = _WebSocketMessage;

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) => _$WebSocketMessageFromJson(json);
}

/// Health check response
@freezed
class HealthCheckResponse with _$HealthCheckResponse {
  const HealthCheckResponse._();

  @JsonSerializable(explicitToJson: true)
  const factory HealthCheckResponse({
    required String status,
    required DateTime timestamp,
    required int connectedClients,
  }) = _HealthCheckResponse;

  factory HealthCheckResponse.fromJson(Map<String, dynamic> json) => _$HealthCheckResponseFromJson(json);
}

/// Chat conversation model for UI purposes
@freezed
class ChatConversation with _$ChatConversation {
  const ChatConversation._();

  @JsonSerializable(explicitToJson: true)
  const factory ChatConversation({
    required String otherUserDid,
    String? otherUserHandle,
    String? otherUserDisplayName,
    String? otherUserAvatar,
    ChatMessage? lastMessage,
    @Default(0) int unreadCount,
    DateTime? lastActivity,
  }) = _ChatConversation;

  factory ChatConversation.fromJson(Map<String, dynamic> json) => _$ChatConversationFromJson(json);
}