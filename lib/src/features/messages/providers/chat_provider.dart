import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message.dart';
import 'package:sparksocial/src/core/network/messages/data/repositories/chat_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'chat_state.dart';

part 'chat_provider.g.dart';

@riverpod
class Chat extends _$Chat {
  final _sl = GetIt.instance;
  final _logger = GetIt.instance<LogService>().getLogger('ChatProvider');

  StreamSubscription<List<Conversation>>? _conversationsSubscription;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  @override
  ChatState build() {
    ref.onDispose(() {
      _conversationsSubscription?.cancel();
      _messagesSubscription?.cancel();
    });

    return ChatState.initial();
  }

  Future<void> initialize() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = _sl<ChatRepository>();
      await repository.initialize();

      // Subscribe to conversations stream
      _conversationsSubscription = repository.conversationsStream.listen(
        (conversations) {
          state = state.copyWith(
            conversations: conversations,
            isLoading: false,
            error: null,
          );
        },
        onError: (error) {
          _logger.e('Conversations stream error', error: error);
          state = state.copyWith(error: error.toString(), isLoading: false);
        },
      );

      // Subscribe to messages stream
      _messagesSubscription = repository.messagesStream.listen(
        (messages) {
          if (messages.isNotEmpty) {
            final conversationId = messages.first.conversationId;
            final updatedMessages = Map<String, List<ChatMessage>>.from(state.messagesByConversation);
            updatedMessages[conversationId] = messages;

            state = state.copyWith(messagesByConversation: updatedMessages);
          }
        },
        onError: (error) {
          _logger.e('Messages stream error', error: error);
        },
      );

      // Load initial conversations
      await loadConversations();
    } catch (e) {
      _logger.e('Failed to initialize chat provider', error: e);
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadConversations() async {
    try {
      final repository = _sl<ChatRepository>();
      final conversations = await repository.getConversations();

      state = state.copyWith(
        conversations: conversations,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      _logger.e('Failed to load conversations', error: e);
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    // Return cached messages if available
    if (state.messagesByConversation.containsKey(conversationId)) {
      return state.messagesByConversation[conversationId]!;
    }

    try {
      final repository = _sl<ChatRepository>();
      final messages = await repository.getMessages(conversationId);

      // Update state with fetched messages
      final updatedMessages = Map<String, List<ChatMessage>>.from(state.messagesByConversation);
      updatedMessages[conversationId] = messages;

      state = state.copyWith(messagesByConversation: updatedMessages);

      return messages;
    } catch (e) {
      _logger.e('Failed to get messages for conversation $conversationId', error: e);
      return [];
    }
  }

  Future<Conversation> createOrGetConversation(Conversation newConversation) async {
    try {
      final repository = _sl<ChatRepository>();
      final conversation = await repository.createOrGetConversation(newConversation);

      // Update conversations list if it's a new conversation
      final existingIndex = state.conversations.indexWhere((c) => c.id == conversation.id);
      if (existingIndex == -1) {
        final updatedConversations = [conversation, ...state.conversations];
        state = state.copyWith(conversations: updatedConversations);
      }

      return conversation;
    } catch (e) {
      _logger.e('Failed to create or get conversation', error: e);
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider for accessing individual conversation messages
@riverpod
Future<List<ChatMessage>> conversationMessages(ConversationMessagesRef ref, String conversationId) async {
  final chatNotifier = ref.read(chatProvider.notifier);
  return await chatNotifier.getMessages(conversationId);
}

// Provider for chat actions (sending messages, marking as read, etc.)
@riverpod
class ChatActions extends _$ChatActions {
  final _sl = GetIt.instance;
  final _logger = GetIt.instance<LogService>().getLogger('ChatActionsProvider');

  @override
  ChatState build() {
    return ChatState.initial();
  }

  Future<void> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    state = state.copyWith(isSendingMessage: true, error: null);

    try {
      final repository = _sl<ChatRepository>();
      await repository.sendMessage(
        conversationId: conversationId,
        content: content,
        type: type,
      );

      state = state.copyWith(isSendingMessage: false);
      _logger.i('Message sent successfully');
    } catch (e) {
      _logger.e('Failed to send message', error: e);
      state = state.copyWith(isSendingMessage: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> markConversationAsRead(String conversationId) async {
    try {
      final repository = _sl<ChatRepository>();
      await repository.markAsRead(conversationId);
      _logger.i('Marked conversation $conversationId as read');
    } catch (e) {
      _logger.e('Failed to mark conversation as read', error: e);
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}