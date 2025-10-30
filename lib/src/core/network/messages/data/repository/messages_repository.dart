import 'package:sparksocial/src/core/network/messages/data/models/message_models.dart';

/// Interface for Messages-related API endpoints using XRPC
abstract class MessagesRepository {
  /// List all conversations for the current user
  ///
  /// [limit] Optional limit for number of conversations to fetch
  /// [cursor] Optional cursor for pagination (offset as string)
  /// [readState] Optional filter for unread conversations ('unread')
  Future<({List<ConvoView> conversations, String? cursor})> listConversations({
    int? limit,
    String? cursor,
    String? readState,
  });

  /// Get a specific conversation by ID
  ///
  /// [convoId] The conversation ID
  Future<ConvoView> getConversation(String convoId);

  /// Get or create a conversation for specific members
  ///
  /// [members] List of DIDs for conversation members (caller's DID is automatically included)
  /// Returns the conversation view with MongoDB convo id
  Future<ConvoView> getConvoForMembers(List<String> members);

  /// Get messages for a conversation
  ///
  /// [convoId] The conversation ID
  /// [limit] Optional limit for number of messages to fetch
  /// [cursor] Optional cursor for pagination (message ID for older messages)
  Future<({List<MessageView> messages, String? cursor})> getMessages(
    String convoId, {
    int? limit,
    String? cursor,
  });

  /// Send a message in a conversation
  ///
  /// [convoId] The conversation ID
  /// [text] The message text
  /// [facets] Optional facets (currently ignored by server)
  /// [embed] Optional embed (at:// URI string)
  Future<MessageView> sendMessage(
    String convoId, {
    required String text,
    List<dynamic>? facets,
    String? embed,
  });

  /// Add a reaction to a message
  ///
  /// [convoId] The conversation ID
  /// [messageId] The message ID to react to
  /// [value] The reaction emoji/value
  Future<MessageView> addReaction(
    String convoId,
    String messageId,
    String value,
  );

  /// Remove a reaction from a message
  ///
  /// [convoId] The conversation ID
  /// [messageId] The message ID to remove reaction from
  /// [value] The reaction emoji/value to remove
  Future<MessageView> removeReaction(
    String convoId,
    String messageId,
    String value,
  );

  /// Update read state for a conversation
  ///
  /// [convoId] The conversation ID
  /// [messageId] The message ID to mark as read up to
  Future<ConvoView> updateRead(String convoId, String messageId);
}
