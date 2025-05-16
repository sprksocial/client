import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/features/messages/data/models/activity_data.dart';
import 'package:sparksocial/src/features/messages/data/models/message_data.dart';

part 'messages_page_state.freezed.dart';

@freezed
class MessagesPageState with _$MessagesPageState {
  const factory MessagesPageState({
    required int selectedTabIndex,
    required List<MessageData> messages,
    required List<ActivityData> activities,
  }) = _MessagesPageState;
} 