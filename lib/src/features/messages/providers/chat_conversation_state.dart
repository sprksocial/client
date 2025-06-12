import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message.dart';

part 'chat_conversation_state.freezed.dart';

@freezed
class ChatConversationState with _$ChatConversationState {
  const factory ChatConversationState({
    @Default([]) List<ChatMessage> messages,
    @Default(false) bool isLoading,
    String? error,
  }) = _ChatConversationState;
}
