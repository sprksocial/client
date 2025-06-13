import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message.dart';

part 'chat_state.freezed.dart';

@freezed
class ChatState with _$ChatState {
  const ChatState._();

  const factory ChatState({
    @Default([]) List<Conversation> conversations,
    @Default({}) Map<String, List<ChatMessage>> messagesByConversation,
    @Default(false) bool isLoading,
    @Default(false) bool isSendingMessage,
    String? error,
  }) = _ChatState;

  factory ChatState.initial() => const ChatState();

  List<Conversation> get unreadConversations =>
    conversations.where((c) => c.hasUnreadMessages).toList();

  List<Conversation> get pinnedConversations =>
    conversations.where((c) => c.isPinned).toList();

  int get totalUnreadCount =>
    conversations.fold(0, (sum, conversation) => sum + conversation.unreadCount);

  Conversation? getConversation(String conversationId) {
    try {
      return conversations.firstWhere((c) => c.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  List<ChatMessage> getMessages(String conversationId) {
    return messagesByConversation[conversationId] ?? [];
  }
}