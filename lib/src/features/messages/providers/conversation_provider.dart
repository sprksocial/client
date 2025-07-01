import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart' hide Embed;
import 'package:sparksocial/src/core/network/messages/data/models/message_models.dart';
import 'package:sparksocial/src/core/network/messages/data/repository/messages_repository.dart';
import 'package:sparksocial/src/features/messages/providers/conversation_state.dart';

part 'conversation_provider.g.dart';

@Riverpod(keepAlive: true)
class Conversation extends _$Conversation {
  String? cursor;

  @override
  FutureOr<ConversationState> build(String otherDid) async {
    final other = await GetIt.I<SprkRepository>().actor.getProfile(otherDid);
    final (cursor: newCursor, messages: messages) = await GetIt.I<MessagesRepository>().getConversation(otherDid);
    cursor = newCursor;
    return ConversationState(other, messages);
  }

  Future<Message> sendMessage(String otherDid, String message, {Embed? embed}) async {
    final other = state.value?.other ?? await GetIt.I<SprkRepository>().actor.getProfile(otherDid);
    final messages = state.value?.messages ?? [];
    state = const AsyncLoading();
    state = AsyncValue.data(
      ConversationState(other, [...messages, await GetIt.I<MessagesRepository>().sendMessage(otherDid, message, embed: embed)]),
    );
    return state.value!.messages.last;
  }

  // TODO: loadmore
}
