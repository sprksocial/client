import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/messages/data/models/message_models.dart';
import 'package:spark/src/core/network/messages/data/repository/messages_repository.dart';
import 'package:spark/src/features/messages/providers/conversation_state.dart';

part 'conversation_provider.g.dart';

@Riverpod(keepAlive: true)
class Conversation extends _$Conversation {
  String? _oldestCursor;

  ConversationState _mergeMessagesIntoState(
    ConversationState current,
    Iterable<MessageView> incoming, {
    String? cursor,
  }) {
    final mergedById = <String, MessageView>{
      for (final message in current.messages) message.id: message,
    };

    for (final message in incoming) {
      mergedById[message.id] = message;
    }

    final mergedMessages = mergedById.values.toList();
    final lastMessage = mergedMessages.isNotEmpty
        ? mergedMessages.last
        : current.convo.lastMessage;

    return current.copyWith(
      messages: mergedMessages,
      cursor: cursor ?? current.cursor,
      convo: current.convo.copyWith(lastMessage: lastMessage),
    );
  }

  @override
  FutureOr<ConversationState> build(String convoId) async {
    final repo = GetIt.I<MessagesRepository>();

    // Load conversation and initial messages
    final convo = await repo.getConversation(convoId);
    final meDid = GetIt.I<AuthRepository>().did;

    // Handle edge case where conversation has no members
    if (convo.members.isEmpty) {
      throw StateError('Conversation $convoId has no members');
    }

    final other = convo.members.firstWhere(
      (member) => member.did != meDid,
      orElse: () => convo.members.first,
    );

    final result = await repo.getMessages(convoId, limit: 50);
    _oldestCursor = result.cursor;

    return ConversationState(
      convo: convo,
      other: other,
      messages: result.messages,
      cursor: _oldestCursor,
    );
  }

  Future<MessageView> sendMessage(
    String convoId,
    String text, {
    String? embed,
  }) async {
    final repo = GetIt.I<MessagesRepository>();
    final current = state.value;
    if (current == null) throw StateError('Conversation not loaded');

    final sent = await repo.sendMessage(convoId, text: text, embed: embed);

    if (!ref.mounted) {
      return sent;
    }

    final latestState = state.value ?? current;
    state = AsyncValue.data(_mergeMessagesIntoState(latestState, [sent]));

    return sent;
  }

  Future<void> checkForNewMessages() async {
    final current = state.value;
    if (current == null) return;
    final repo = GetIt.I<MessagesRepository>();

    // Fetch latest batch (no cursor -> newest)
    final latest = await repo.getMessages(current.convo.id, limit: 50);

    if (!ref.mounted) {
      return;
    }

    final latestState = state.value ?? current;
    final mergedState = _mergeMessagesIntoState(
      latestState,
      latest.messages,
      cursor: latest.cursor ?? latestState.cursor,
    );

    if (mergedState != latestState) {
      state = AsyncValue.data(mergedState);
    }
  }

  /// Marks the conversation as read up to the latest message currently loaded.
  Future<void> markReadUpToLatest() async {
    final current = state.value;
    if (current == null || current.messages.isEmpty) return;
    final repo = GetIt.I<MessagesRepository>();
    final latestId = current.messages.last.id;
    try {
      await repo.updateRead(current.convo.id, latestId);
    } catch (_) {
      // Best-effort: ignore errors; backend read state will reconcile later.
    }
  }

  // TODO: load older messages using _oldestCursor if needed
}
