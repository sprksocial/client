
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_actions_state.freezed.dart';

/// State class for chat actions
@freezed
class ChatActionsState with _$ChatActionsState {
  const factory ChatActionsState({
    @Default(false) bool isSendingMessage,
    @Default(false) bool isMarkingAsRead,
    String? error,
  }) = _ChatActionsState;
}