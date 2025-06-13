import 'dart:async';
import 'package:sparksocial/src/core/network/messages/data/models/message.dart';

abstract class ChatRepository {
  /// Stream of conversations updates
  Stream<List<Conversation>> get conversationsStream;

  /// Stream of messages updates
  Stream<List<ChatMessage>> get messagesStream;

  /// Initialize the chat repository
  Future<void> initialize();

  /// Get all conversations for the current user
  Future<List<Conversation>> getConversations();

  /// Get messages for a specific conversation
  Future<List<ChatMessage>> getMessages(String conversationId);

  /// Get a specific conversation by ID
  Future<Conversation?> getConversation(String conversationId);

  /// Send a message to a conversation
  Future<void> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
  });

  /// Mark a conversation as read
  Future<void> markAsRead(String conversationId);

  /// Create or get an existing conversation
  Future<Conversation> createOrGetConversation(Conversation newConversation);

  /// Dispose resources
  void dispose();
}