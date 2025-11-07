import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message_models.dart';
import 'package:sparksocial/src/core/network/messages/data/repository/messages_repository.dart';
import 'package:sparksocial/src/features/messages/providers/conversation_state.dart';

part 'conversation_provider.g.dart';

@Riverpod(keepAlive: true)
class Conversation extends _$Conversation {
  String? _oldestCursor;

  @override
  FutureOr<ConversationState> build(String convoId) async {
    final repo = GetIt.I<MessagesRepository>();
    final sprk = GetIt.I<SprkRepository>();

    // Load conversation and initial messages
    final convo = await repo.getConversation(convoId);
    final meDid = GetIt.I<AuthRepository>().session?.did;
    final otherDid = convo.members.firstWhere((d) => d != meDid, orElse: () => convo.members.first);
    final other = await sprk.actor.getProfile(otherDid);

    final result = await repo.getMessages(convoId, limit: 50);
    _oldestCursor = result.cursor;

    return ConversationState(convo: convo, other: other, messages: result.messages, cursor: _oldestCursor);
  }

  Future<MessageView> sendMessage(String convoId, String text, {String? embed}) async {
    final repo = GetIt.I<MessagesRepository>();
    final current = state.value;
    if (current == null) throw StateError('Conversation not loaded');

    final sent = await repo.sendMessage(convoId, text: text, embed: embed);
    state = AsyncValue.data(
      current.copyWith(messages: [...current.messages, sent]),
    );
    return sent;
  }

  Future<void> checkForNewMessages() async {
    final current = state.value;
    if (current == null) return;
    final repo = GetIt.I<MessagesRepository>();

    // Fetch latest batch (no cursor -> newest)
    final latest = await repo.getMessages(current.convo.id, limit: 50);
    // Merge by id
    final existingIds = {for (final m in current.messages) m.id};
    final newOnes = latest.messages.where((m) => !existingIds.contains(m.id)).toList();
    if (newOnes.isNotEmpty) {
      state = AsyncValue.data(current.copyWith(messages: [...current.messages, ...newOnes]));
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
