import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/messages/data/repository/messages_repository.dart';
import 'package:sparksocial/src/features/messages/providers/conversations._state.dart';

part 'conversation_provider.g.dart';

@Riverpod(keepAlive: true)
class Conversations extends _$Conversations {
  String? cursor;

  @override
  FutureOr<ConversationsState> build() async {
    final (cursor: newCursor, messages: messages) = await GetIt.I<MessagesRepository>().getAllConversations();
    cursor = newCursor;
    return ConversationsState(messages);
  }

  // TODO: loadmore
}
