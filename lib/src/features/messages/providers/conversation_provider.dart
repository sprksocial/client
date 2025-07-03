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

  Future<Message> sendMessage(String otherDid, String message, {List<Embed>? embed}) async {
    final other = state.value?.other ?? await GetIt.I<SprkRepository>().actor.getProfile(otherDid);
    final messages = state.value?.messages ?? [];
    state = const AsyncLoading();
    state = AsyncValue.data(
      ConversationState(other, [...messages, await GetIt.I<MessagesRepository>().sendMessage(otherDid, message, embed: embed)]),
    );
    return state.value!.messages.last;
  }

  Future<void> checkForNewMessages() async {
    if (state.value == null) return;
    final otherDid = state.value!.other.did;
    final (cursor: _, messages: newBatch) = await GetIt.I<MessagesRepository>().getConversation(otherDid, cursor: cursor);
    final newestMessage = newBatch.isNotEmpty ? newBatch.last : null;
    if (newestMessage != null && (state.value!.messages.isEmpty || newestMessage.timestamp.compareTo(state.value!.messages.last.timestamp) > 0)) {
      // only new messages from the new batch
      final newMessages = newBatch.where((msg) => !state.value!.messages.any((m) => m.id == msg.id)).toList();
      final updatedMessages = [...state.value!.messages, ...newMessages];
      state = AsyncValue.data(ConversationState(state.value!.other, updatedMessages));
    } 
  }

  // TODO: loadmore
}
