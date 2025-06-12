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
}
