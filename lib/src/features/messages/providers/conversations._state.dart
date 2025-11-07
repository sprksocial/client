import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message_models.dart';

part 'conversations._state.freezed.dart';

@freezed
abstract class ConversationsState with _$ConversationsState {
  factory ConversationsState(List<(ProfileViewDetailed, ConvoView)> conversations) = _ConversationsState;
}
