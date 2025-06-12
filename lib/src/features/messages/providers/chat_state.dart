import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message.dart';

part 'chat_state.freezed.dart';

/// State class for chat management
@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<Conversation> conversations,
    @Default({}) Map<String, List<ChatMessage>> messagesByConversation,
    @Default({}) Map<String, StreamSubscription<List<ChatMessage>>> messageStreams,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMessages,
    String? error,
    String? currentConversationId,
  }) = _ChatState;
}