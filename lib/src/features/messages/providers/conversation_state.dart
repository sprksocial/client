import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spark/src/core/network/messages/data/models/message_models.dart';
import 'package:sprk_poptart/chat/sprk/actor/defs.dart';

part 'conversation_state.freezed.dart';

@freezed
abstract class ConversationState with _$ConversationState {
  factory ConversationState({
    required ConvoView convo,
    required ProfileViewBasic other,
    required List<ChatMessageView> messages,
    String? cursor,
  }) = _ConversationState;
}
