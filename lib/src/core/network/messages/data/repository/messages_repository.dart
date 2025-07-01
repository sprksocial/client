import 'package:sparksocial/src/core/network/atproto/data/models/models.dart' hide Embed;
import 'package:sparksocial/src/core/network/messages/data/models/message_models.dart';

/// Interface for Messages-related API endpoints
abstract class MessagesRepository {
  /// Get messages for a conversation
  ///
  /// [did] The DID of the other user in the conversation
  /// [cursor] Optional cursor for pagination (eventually)
  /// [limit] Optional limit for number of messages to fetch (eventually)
  Future<({List<Message> messages, String? cursor})> getConversation(String did, {String? cursor, int? limit});

  /// Get messages for all conversations
  ///
  /// [cursor] Optional cursor for pagination (eventually)
  /// [limit] Optional limit for number of messages to fetch (eventually)
  Future<({List<(ProfileViewDetailed, Message)> messages, String? cursor})> getAllConversations({String? cursor, int? limit});

  /// Send a message to a user
  /// [did] The DID of the user to send the message to
  /// [message] The message content
  /// [embed] Optional embed data to include with the message
  ///
  Future<void> sendMessage(String did, String message, {Embed? embed});
  // tem que retornar um future message
}
