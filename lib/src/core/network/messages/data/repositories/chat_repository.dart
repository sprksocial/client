import 'package:sparksocial/src/core/network/messages/data/models/message.dart';

/// Repository interface for chat operations
abstract class ChatRepository {
  /// Stream messages for a specific conversation
  ///
  /// [conversationId] The ID of the conversation to stream messages from
  /// [limit] Optional limit for the number of messages to fetch
  /// [cursor] Optional cursor for pagination
  ///
  /// Returns a stream of messages for the conversation
  Stream<List<ChatMessage>> streamMessages({
    required String conversationId,
    int? limit,
    String? cursor,
  });

  /// Sends a message in a conversation
  ///
  /// [conversationId] The ID of the conversation
  /// [content] The message content
  /// [type] The type of message (defaults to text)
  ///
  /// Returns the sent message with updated status
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    List<String>? attachments,
  });

  /// Marks a conversation as read
  ///
  /// [conversationId] The ID of the conversation to mark as read
  Future<void> markAsRead(String conversationId);

  /// Gets all conversations for the current user
  ///
  /// [limit] Optional limit for the number of conversations to fetch
  /// [cursor] Optional cursor for pagination
  ///
  /// Returns a list of conversations
  Future<List<Conversation>> getConversations({
    int? limit,
    String? cursor,
  });

  /// Gets a specific conversation by ID
  ///
  /// [conversationId] The ID of the conversation to fetch
  ///
  /// Returns the conversation if found, null otherwise
  Future<Conversation?> getConversation(String conversationId);

  /// Creates a new conversation
  ///
  /// [conversation] The conversation to create
  ///
  /// Returns the created conversation
  Future<Conversation> createConversation(Conversation conversation);
}
