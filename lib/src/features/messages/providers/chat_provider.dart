import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message.dart';
import 'package:sparksocial/src/core/network/messages/data/repositories/chat_repository.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/messages/providers/chat_state.dart';

part 'chat_provider.g.dart';

/// Provider for managing chat conversations
@riverpod
class Chat extends _$Chat {
  late final SparkLogger _logger;
  late final ChatRepository _chatRepository;
  late final AuthRepository _authRepository;

  @override
  ChatState build() {
    _logger = GetIt.instance<LogService>().getLogger('ChatProvider');
    _chatRepository = GetIt.instance<ChatRepository>();
    _authRepository = GetIt.instance<AuthRepository>();
    return const ChatState();
  }

  void dispose() {
    // Cancel all message streams when disposing
    for (final subscription in state.messageStreams.values) {
      subscription.cancel();
    }
  }

  /// Creates a new conversation or returns existing one
  Future<Conversation> createOrGetConversation(Conversation conversation) async {
    _logger.d('Creating or getting conversation: ${conversation.id}');

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check if conversation already exists
      final existingConversation = state.conversations.where((c) => c.id == conversation.id).firstOrNull;

      if (existingConversation != null) {
        _logger.d('Conversation already exists: ${conversation.id}');
        state = state.copyWith(isLoading: false);
        return existingConversation;
      }

      // Check if it's a direct message and we already have a conversation with this user
      if (conversation.type == ConversationType.direct) {
        final currentUserDid = _authRepository.session?.did;
        final otherParticipant = conversation.participants.firstWhere(
          (p) => p.id != currentUserDid,
          orElse: () => conversation.participants.first,
        );

        final existingDM = state.conversations.cast<Conversation?>().firstWhere(
          (c) => c != null && c.type == ConversationType.direct && c.participants.any((p) => p.id == otherParticipant.id),
          orElse: () => null,
        );

        if (existingDM != null) {
          _logger.d('Direct message conversation already exists: ${existingDM.id}');
          state = state.copyWith(isLoading: false);
          return existingDM;
        }
      }

      // Create the conversation via repository
      final createdConversation = await _chatRepository.createConversation(conversation);

      // Add to local state
      final updatedConversations = [createdConversation, ...state.conversations];

      state = state.copyWith(conversations: updatedConversations, isLoading: false);

      _logger.i('Conversation created successfully: ${createdConversation.id}');
      return createdConversation;
    } catch (e) {
      _logger.e('Failed to create conversation: ${conversation.id}', error: e);
      state = state.copyWith(isLoading: false, error: 'Failed to create conversation: ${e.toString()}');
      rethrow;
    }
  }

  /// Loads all conversations for the current user
  Future<void> loadConversations() async {
    _logger.d('Loading conversations');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final conversations = await _chatRepository.getConversations();

      state = state.copyWith(conversations: conversations, isLoading: false);

      _logger.i('Conversations loaded successfully: ${conversations.length}');
    } catch (e) {
      _logger.e('Failed to load conversations', error: e);
      state = state.copyWith(isLoading: false, error: 'Failed to load conversations: ${e.toString()}');
    }
  }

  /// Gets a specific conversation by ID
  Future<Conversation?> getConversation(String conversationId) async {
    _logger.d('Getting conversation: $conversationId');

    // First check local state
    final localConversation = state.conversations.where((c) => c.id == conversationId).firstOrNull;

    if (localConversation != null) {
      return localConversation;
    }

    // If not found locally, fetch from repository
    try {
      final conversation = await _chatRepository.getConversation(conversationId);

      if (conversation != null) {
        // Add to local state
        final updatedConversations = [conversation, ...state.conversations];
        state = state.copyWith(conversations: updatedConversations);
      }

      return conversation;
    } catch (e) {
      _logger.e('Failed to get conversation: $conversationId', error: e);
      return null;
    }
  }

  /// Gets messages for a conversation (from local state)
  List<ChatMessage> getMessages(String conversationId) {
    return state.messagesByConversation[conversationId] ?? [];
  }

  /// Starts streaming messages for a conversation
  Future<void> streamMessages(String conversationId) async {
    _logger.d('Starting message stream for conversation: $conversationId');

    // Cancel existing stream if any
    final existingStream = state.messageStreams[conversationId];
    if (existingStream != null) {
      await existingStream.cancel();
    }

    try {
      final messageStream = _chatRepository.streamMessages(conversationId: conversationId);

      final subscription = messageStream.listen(
        (messages) {
          _logger.d('Received ${messages.length} messages for conversation: $conversationId');

          // Update messages in state
          final updatedMessagesByConversation = Map<String, List<ChatMessage>>.from(state.messagesByConversation);
          updatedMessagesByConversation[conversationId] = messages;

          // Update last message in conversation if needed
          final updatedConversations = state.conversations.map((conv) {
            if (conv.id == conversationId && messages.isNotEmpty) {
              final lastMessage = messages.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
              return conv.copyWith(lastMessage: lastMessage, lastActivity: lastMessage.timestamp);
            }
            return conv;
          }).toList();

          state = state.copyWith(
            messagesByConversation: updatedMessagesByConversation,
            conversations: updatedConversations,
            currentConversationId: conversationId,
          );
        },
        onError: (error) {
          _logger.e('Error in message stream for conversation: $conversationId', error: error);
          state = state.copyWith(error: 'Failed to stream messages: ${error.toString()}');
        },
      );

      // Store the subscription
      final updatedStreams = Map<String, StreamSubscription<List<ChatMessage>>>.from(state.messageStreams);
      updatedStreams[conversationId] = subscription;
      state = state.copyWith(messageStreams: updatedStreams);

      _logger.i('Message stream started for conversation: $conversationId');
    } catch (e) {
      _logger.e('Failed to start message stream for conversation: $conversationId', error: e);
      state = state.copyWith(error: 'Failed to start message stream: ${e.toString()}');
    }
  }

  /// Stops streaming messages for a conversation
  Future<void> stopStreamingMessages(String conversationId) async {
    _logger.d('Stopping message stream for conversation: $conversationId');

    final subscription = state.messageStreams[conversationId];
    if (subscription != null) {
      await subscription.cancel();

      final updatedStreams = Map<String, StreamSubscription<List<ChatMessage>>>.from(state.messageStreams);
      updatedStreams.remove(conversationId);

      state = state.copyWith(messageStreams: updatedStreams);

      _logger.i('Message stream stopped for conversation: $conversationId');
    }
  }

  /// Sends a message in a conversation
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    List<String>? attachments,
  }) async {
    _logger.d('Sending message to conversation: $conversationId');

    if (!_authRepository.isAuthenticated || _authRepository.session == null) {
      throw Exception('Not authenticated. Cannot send message.');
    }

    state = state.copyWith(error: null);

    try {
      // Create optimistic message first
      final tempMessage = ChatMessage(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: _authRepository.session!.did,
        content: content,
        type: type,
        status: MessageStatus.sending,
        timestamp: DateTime.now(),
        replyToMessageId: replyToMessageId,
        attachments: attachments,
      );

      // Add optimistic message to local state
      final currentMessages = state.messagesByConversation[conversationId] ?? [];
      final updatedMessages = [...currentMessages, tempMessage];
      final updatedMessagesByConversation = Map<String, List<ChatMessage>>.from(state.messagesByConversation);
      updatedMessagesByConversation[conversationId] = updatedMessages;

      // Update conversation with new last message
      final updatedConversations = state.conversations.map((conv) {
        if (conv.id == conversationId) {
          return conv.copyWith(lastMessage: tempMessage, lastActivity: DateTime.now());
        }
        return conv;
      }).toList();

      state = state.copyWith(messagesByConversation: updatedMessagesByConversation, conversations: updatedConversations);

      // Send message via repository
      final sentMessage = await _chatRepository.sendMessage(
        conversationId: conversationId,
        content: content,
        type: type,
        replyToMessageId: replyToMessageId,
        attachments: attachments,
      );

      // Replace optimistic message with actual sent message
      final finalMessages = updatedMessages.map((msg) {
        if (msg.id == tempMessage.id) {
          return sentMessage;
        }
        return msg;
      }).toList();

      final finalMessagesByConversation = Map<String, List<ChatMessage>>.from(state.messagesByConversation);
      finalMessagesByConversation[conversationId] = finalMessages;

      // Update conversation with final message
      final finalConversations = state.conversations.map((conv) {
        if (conv.id == conversationId) {
          return conv.copyWith(lastMessage: sentMessage, lastActivity: sentMessage.timestamp);
        }
        return conv;
      }).toList();

      state = state.copyWith(messagesByConversation: finalMessagesByConversation, conversations: finalConversations);

      _logger.i('Message sent successfully: ${sentMessage.id}');
      return sentMessage;
    } catch (e) {
      _logger.e('Failed to send message to conversation: $conversationId', error: e);

      // Update optimistic message to failed status
      final currentMessages = state.messagesByConversation[conversationId] ?? [];
      final failedMessages = currentMessages.map((msg) {
        if (msg.status == MessageStatus.sending && msg.content == content) {
          return msg.copyWith(status: MessageStatus.failed);
        }
        return msg;
      }).toList();

      final updatedMessagesByConversation = Map<String, List<ChatMessage>>.from(state.messagesByConversation);
      updatedMessagesByConversation[conversationId] = failedMessages;

      state = state.copyWith(
        messagesByConversation: updatedMessagesByConversation,
        error: 'Failed to send message: ${e.toString()}',
      );

      rethrow;
    }
  }

  /// Marks a conversation as read
  Future<void> markAsRead(String conversationId) async {
    _logger.d('Marking conversation as read: $conversationId');

    try {
      await _chatRepository.markAsRead(conversationId);

      // Update local state
      final updatedConversations = state.conversations.map((conv) {
        if (conv.id == conversationId) {
          return conv.copyWith(unreadCount: 0);
        }
        return conv;
      }).toList();

      state = state.copyWith(conversations: updatedConversations);

      _logger.i('Conversation marked as read: $conversationId');
    } catch (e) {
      _logger.e('Failed to mark conversation as read: $conversationId', error: e);
      // Don't update state or throw, as this is not critical
    }
  }

  /// Removes a conversation
  Future<void> removeConversation(String conversationId) async {
    _logger.d('Removing conversation: $conversationId');

    try {
      // Stop streaming messages for this conversation
      await stopStreamingMessages(conversationId);

      // Remove from local state
      final updatedConversations = state.conversations.where((c) => c.id != conversationId).toList();

      final updatedMessagesByConversation = Map<String, List<ChatMessage>>.from(state.messagesByConversation);
      updatedMessagesByConversation.remove(conversationId);

      state = state.copyWith(conversations: updatedConversations, messagesByConversation: updatedMessagesByConversation);

      _logger.i('Conversation removed successfully: $conversationId');
    } catch (e) {
      _logger.e('Failed to remove conversation: $conversationId', error: e);
      state = state.copyWith(error: 'Failed to remove conversation: ${e.toString()}');
    }
  }

  /// Clears any existing error state
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  /// Gets the current user's DID from auth
  String? get currentUserDid => _authRepository.session?.did;

  /// Checks if user is authenticated
  bool get isAuthenticated => _authRepository.isAuthenticated;

  /// Stream of conversations (getter for compatibility)
  List<Conversation> get conversations => state.conversations;

  /// Stream of messages for current conversation (getter for compatibility)
  List<ChatMessage> get messagesForCurrentConversation {
    if (state.currentConversationId != null) {
      return getMessages(state.currentConversationId!);
    }
    return [];
  }
}
