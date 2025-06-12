import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message.dart';
import 'package:sparksocial/src/core/network/messages/data/repositories/chat_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/messages/providers/chat_actions_state.dart';
import 'package:sparksocial/src/features/messages/providers/chat_conversation_state.dart';

part 'chat_providers.g.dart';

/// Provider for ChatRepository instance
@riverpod
ChatRepository chatRepository(Ref ref) {
  return GetIt.instance<ChatRepository>();
}

/// Provider that streams messages for a specific conversation
@riverpod
Stream<List<ChatMessage>> conversationMessages(
  Ref ref,
  String conversationId, {
  int? limit,
  String? cursor,
}) {
  final repository = ref.watch(chatRepositoryProvider);
  final logger = GetIt.instance<LogService>().getLogger('ConversationMessagesProvider');

  logger.d('Creating message stream for conversation: $conversationId');

  return repository.streamMessages(
    conversationId: conversationId,
    limit: limit,
    cursor: cursor,
  );
}


/// Provider for chat actions (send message, mark as read, etc.)
@riverpod
class ChatActions extends _$ChatActions {
  late final SparkLogger _logger;

  @override
  ChatActionsState build() {
    _logger = GetIt.instance<LogService>().getLogger('ChatActions');
    return const ChatActionsState();
  }

  /// Sends a message to the specified conversation
  Future<void> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    List<String>? attachments,
  }) async {
    if (content.trim().isEmpty) {
      _logger.w('Attempted to send empty message');
      return;
    }

    state = state.copyWith(isSendingMessage: true, error: null);

    try {
      _logger.d('Sending message to conversation: $conversationId');

      // TODO: Implement actual message sending via AT Protocol
      // For now, this is a placeholder that simulates the action
      await Future.delayed(const Duration(milliseconds: 500));

      _logger.i('Message sent successfully to conversation: $conversationId');
      state = state.copyWith(isSendingMessage: false);
    } catch (e) {
      _logger.e('Failed to send message to conversation: $conversationId', error: e);
      state = state.copyWith(
        isSendingMessage: false,
        error: 'Failed to send message: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Marks all messages in a conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    state = state.copyWith(isMarkingAsRead: true, error: null);

    try {
      _logger.d('Marking conversation as read: $conversationId');

      // TODO: Implement actual mark as read via AT Protocol
      // For now, this is a placeholder that simulates the action
      await Future.delayed(const Duration(milliseconds: 200));

      _logger.i('Conversation marked as read: $conversationId');
      state = state.copyWith(isMarkingAsRead: false);
    } catch (e) {
      _logger.e('Failed to mark conversation as read: $conversationId', error: e);
      state = state.copyWith(
        isMarkingAsRead: false,
        error: 'Failed to mark as read: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Clears any existing error state
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

/// Provider for managing chat conversation state
@riverpod
class ChatConversation extends _$ChatConversation {
  late final SparkLogger _logger;

  @override
  ChatConversationState build(String conversationId) {
    _logger = GetIt.instance<LogService>().getLogger('ChatConversation');

    // Watch the messages stream and update state accordingly
    final messagesAsync = ref.watch(conversationMessagesProvider(conversationId));

    return messagesAsync.when(
      data: (messages) {
        _logger.d('Received ${messages.length} messages for conversation: $conversationId');
        return ChatConversationState(
          messages: messages,
          isLoading: false,
          error: null,
        );
      },
      error: (error, stackTrace) {
        _logger.e('Error loading messages for conversation: $conversationId', error: error);
        return ChatConversationState(
          isLoading: false,
          error: error.toString(),
        );
      },
      loading: () => const ChatConversationState(isLoading: true),
    );
  }

    /// Loads more messages (for pagination)
  Future<void> loadMoreMessages(String conversationId) async {
    // TODO: Implement pagination logic for loading more messages
    _logger.d('Loading more messages for conversation: $conversationId');

    // For now, this will be implemented when pagination is needed
    // The current stream provider will handle real-time updates
  }

  /// Refreshes the conversation messages
  void refresh(String conversationId) {
    _logger.d('Refreshing conversation: $conversationId');
    ref.invalidate(conversationMessagesProvider(conversationId));
  }
}