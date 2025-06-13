import 'package:sparksocial/src/core/network/chat/data/models/models.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Interface for Spark Chat API endpoints
abstract class ChatRepository {
  /// Send a message to another user
  ///
  /// [message] The message content to send
  /// [receiverDid] The DID of the user to send the message to
  Future<SendMessageResponse> sendMessage(String message, String receiverDid);

  /// Get messages for a conversation with another user
  ///
  /// [otherDid] The DID of the other user in the conversation
  /// [limit] Maximum number of messages to retrieve (default 50)
  Future<GetMessagesResponse> getMessages(String otherDid, {int limit = 50});

  /// Get list of all chats (conversations) for the current user
  Future<GetChatsResponse> getChats();

  /// Connect to WebSocket for real-time messaging
  ///
  /// Returns a WebSocketChannel for receiving real-time messages
  WebSocketChannel connectWebSocket();

  /// Check the health status of the chat service
  Future<HealthCheckResponse> healthCheck();

  /// Set the JWT token for authentication
  ///
  /// [token] The JWT token from ATProtocol authentication
  void setAuthToken(String token);

  /// Close any open WebSocket connections
  void closeWebSocket();
}