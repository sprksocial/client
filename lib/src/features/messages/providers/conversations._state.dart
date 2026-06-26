import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spark/src/core/network/messages/data/models/message_models.dart';
import 'package:sprk_poptart/chat/sprk/actor/defs.dart';

part 'conversations._state.freezed.dart';

@freezed
abstract class ConversationsState with _$ConversationsState {
  factory ConversationsState(
    List<(ProfileViewBasic, ConvoView)> conversations,
  ) = _ConversationsState;
}
