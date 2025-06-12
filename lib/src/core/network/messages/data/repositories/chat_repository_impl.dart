import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message.dart';
import 'package:sparksocial/src/core/network/messages/data/repositories/chat_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/network/messages/data/services/chat_socket_service.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';

/// Implementation of the chat repository for AT Protocol
class ChatRepositoryImpl implements ChatRepository {
  final _logger = GetIt.instance<LogService>().getLogger('ChatRepository');

  ChatRepositoryImpl() {
    _logger.i('Initializing ChatRepository');
  }

  @override
  Stream<List<ChatMessage>> streamMessages({
    required String conversationId,
    int? limit,
    String? cursor,
  }) {
    _logger.d('Opening stream for conversation: $conversationId');

    final controller = StreamController<List<ChatMessage>>();

    // We wrap everything in a separate async callback to avoid blocking
    () async {
      try {
        final socket = await ChatSocketService().socket;

        final auth = GetIt.instance<AuthRepository>();
        final userId = auth.session?.did;

        // Join the conversation room so that the backend starts sending events.
        socket.emit('join-chat', {
          'chatId': conversationId,
          if (userId != null) 'userId': userId,
        });

        // Helper to parse incoming data and push to controller.
        void handleEvent(dynamic data) {
          try {
            if (data == null) return;

            // The server may send a single message or a list of messages.
            if (data is List) {
              final messages = data
                  .whereType<Map<String, dynamic>>()
                  .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
                  .toList();
              if (messages.isNotEmpty) controller.add(messages);
            } else if (data is Map<String, dynamic>) {
              final message = ChatMessage.fromJson(Map<String, dynamic>.from(data));
              controller.add([message]);
            }
          } catch (e) {
            _logger.e('Failed to parse message for conversation $conversationId', error: e);
          }
        }

        // Listen for both historical and real-time messages.
        socket.on('initial-messages', handleEvent);
        socket.on('new-message', handleEvent);

        // Clean up when the stream is canceled.
        controller.onCancel = () {
          _logger.d('Closing stream for conversation: $conversationId');
          socket.emit('leave-chat', {'chatId': conversationId});
          socket.off('initial-messages', handleEvent);
          socket.off('new-message', handleEvent);
        };
      } catch (e) {
        _logger.e('Error setting up chat stream for conversation $conversationId', error: e);
        controller.addError(e);
        await controller.close();
      }
    }();

    return controller.stream;
  }
}