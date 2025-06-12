import 'dart:async';
import 'dart:convert';

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

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    List<String>? attachments,
  }) async {
    _logger.d('Sending message to conversation: $conversationId');

    final auth = GetIt.instance<AuthRepository>();
    if (!auth.isAuthenticated || auth.session == null) {
      _logger.e('Not authenticated. Cannot send message.');
      throw Exception('Not authenticated. Cannot send message.');
    }

    final userId = auth.session!.did;

    // Create the message with sending status
    final message = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: userId,
      content: content,
      type: type,
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
      replyToMessageId: replyToMessageId,
      attachments: attachments,
    );

    try {
      final socket = await ChatSocketService().socket;

      // Send message via socket
      final completer = Completer<ChatMessage>();

      // Listen for the response
      socket.once('message-sent', (data) {
        try {
          if (data is Map<String, dynamic>) {
            final sentMessage = ChatMessage.fromJson(Map<String, dynamic>.from(data));
            completer.complete(sentMessage);
          } else {
            completer.completeError('Invalid response format');
          }
        } catch (e) {
          completer.completeError(e);
        }
      });

      // Listen for errors
      socket.once('message-error', (data) {
        final errorMessage = data is Map<String, dynamic> ? data['error'] : 'Failed to send message';
        completer.completeError(Exception(errorMessage));
      });

      // Emit the message
      socket.emit('send-message', {
        'chatId': conversationId,
        'content': content,
        'type': type.name,
        'messageId': message.id,
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
        if (attachments != null) 'attachments': attachments,
      });

      // Wait for response or timeout
      final sentMessage = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.e('Message send timeout for conversation: $conversationId');
          throw Exception('Message send timeout');
        },
      );

      _logger.i('Message sent successfully: ${sentMessage.id}');
      return sentMessage;
    } catch (e) {
      _logger.e('Failed to send message to conversation: $conversationId', error: e);

      // Return the message with failed status
      final failedMessage = message.copyWith(status: MessageStatus.failed);
      return failedMessage;
    }
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    _logger.d('Marking conversation as read: $conversationId');

    final auth = GetIt.instance<AuthRepository>();
    if (!auth.isAuthenticated || auth.session == null) {
      _logger.w('Not authenticated. Cannot mark as read.');
      return;
    }

    try {
      final socket = await ChatSocketService().socket;

      socket.emit('mark-as-read', {
        'chatId': conversationId,
      });

      _logger.i('Conversation marked as read: $conversationId');
    } catch (e) {
      _logger.e('Failed to mark conversation as read: $conversationId', error: e);
      // Don't throw here, as marking as read is not critical
    }
  }

  @override
  Future<List<Conversation>> getConversations({
    int? limit,
    String? cursor,
  }) async {
    _logger.d('Fetching conversations');

    final auth = GetIt.instance<AuthRepository>();
    if (!auth.isAuthenticated || auth.session == null) {
      _logger.w('Not authenticated. Cannot fetch conversations.');
      return [];
    }

    try {
      final socket = await ChatSocketService().socket;
      final completer = Completer<List<Conversation>>();

      // Listen for the response
      socket.once('conversations-list', (data) {
        try {
          if (data is List) {
            final conversations = data
                .whereType<Map<String, dynamic>>()
                .map((e) => Conversation.fromJson(Map<String, dynamic>.from(e)))
                .toList();
            completer.complete(conversations);
          } else {
            completer.complete([]);
          }
        } catch (e) {
          _logger.e('Failed to parse conversations', error: e);
          completer.complete([]);
        }
      });

      // Listen for errors
      socket.once('conversations-error', (data) {
        final errorMessage = data is Map<String, dynamic> ? data['error'] : 'Failed to fetch conversations';
        completer.completeError(Exception(errorMessage));
      });

      // Request conversations
      socket.emit('get-conversations', {
        if (limit != null) 'limit': limit,
        if (cursor != null) 'cursor': cursor,
      });

      // Wait for response or timeout
      final conversations = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.e('Get conversations timeout');
          return <Conversation>[];
        },
      );

      _logger.i('Fetched ${conversations.length} conversations');
      return conversations;
    } catch (e) {
      _logger.e('Failed to fetch conversations', error: e);
      return [];
    }
  }

  @override
  Future<Conversation?> getConversation(String conversationId) async {
    _logger.d('Fetching conversation: $conversationId');

    final auth = GetIt.instance<AuthRepository>();
    if (!auth.isAuthenticated || auth.session == null) {
      _logger.w('Not authenticated. Cannot fetch conversation.');
      return null;
    }

    try {
      final socket = await ChatSocketService().socket;
      final completer = Completer<Conversation?>();

      // Listen for the response
      socket.once('conversation-details', (data) {
        try {
          if (data is Map<String, dynamic>) {
            final conversation = Conversation.fromJson(Map<String, dynamic>.from(data));
            completer.complete(conversation);
          } else {
            completer.complete(null);
          }
        } catch (e) {
          _logger.e('Failed to parse conversation', error: e);
          completer.complete(null);
        }
      });

      // Listen for errors
      socket.once('conversation-error', (data) {
        final errorMessage = data is Map<String, dynamic> ? data['error'] : 'Failed to fetch conversation';
        completer.completeError(Exception(errorMessage));
      });

      // Request conversation
      socket.emit('get-conversation', {
        'chatId': conversationId,
      });

      // Wait for response or timeout
      final conversation = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.e('Get conversation timeout: $conversationId');
          return null;
        },
      );

      if (conversation != null) {
        _logger.i('Fetched conversation: ${conversation.id}');
      } else {
        _logger.w('Conversation not found: $conversationId');
      }

      return conversation;
    } catch (e) {
      _logger.e('Failed to fetch conversation: $conversationId', error: e);
      return null;
    }
  }

  @override
  Future<Conversation> createConversation(Conversation conversation) async {
    _logger.d('Creating conversation: ${conversation.id}');

    final auth = GetIt.instance<AuthRepository>();
    if (!auth.isAuthenticated || auth.session == null) {
      _logger.e('Not authenticated. Cannot create conversation.');
      throw Exception('Not authenticated. Cannot create conversation.');
    }

    try {
      final socket = await ChatSocketService().socket;
      final completer = Completer<Conversation>();

      // Listen for the response
      socket.once('conversation-created', (data) {
        try {
          if (data is Map<String, dynamic>) {
            final createdConversation = Conversation.fromJson(Map<String, dynamic>.from(data));
            completer.complete(createdConversation);
          } else {
            completer.completeError('Invalid response format');
          }
        } catch (e) {
          completer.completeError(e);
        }
      });

      // Listen for errors
      socket.once('conversation-creation-error', (data) {
        final errorMessage = data is Map<String, dynamic> ? data['error'] : 'Failed to create conversation';
        completer.completeError(Exception(errorMessage));
      });

      // Emit the conversation creation request
      socket.emit('create-conversation', conversation.toJson());

      // Wait for response or timeout
      final createdConversation = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.e('Create conversation timeout: ${conversation.id}');
          throw Exception('Create conversation timeout');
        },
      );

      _logger.i('Conversation created successfully: ${createdConversation.id}');
      return createdConversation;
    } catch (e) {
      _logger.e('Failed to create conversation: ${conversation.id}', error: e);
      rethrow;
    }
  }
}