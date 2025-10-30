import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message_models.dart';
import 'package:sparksocial/src/core/network/messages/data/repository/messages_repository.dart';
import 'package:sparksocial/src/features/messages/providers/conversations._state.dart';

part 'conversations_provider.g.dart';

@Riverpod(keepAlive: true)
class Conversations extends _$Conversations {
  String? cursor;

  @override
  FutureOr<ConversationsState> build() async {
    final repo = GetIt.I<MessagesRepository>();
    final sprk = GetIt.I<SprkRepository>();

    final res = await repo.listConversations(limit: 50);
    cursor = res.cursor;

    // Resolve profiles for the counterpart in each convo
    final meDid = GetIt.I<AuthRepository>().session?.did;
    final items = <(ProfileViewDetailed, ConvoView)>[];
    for (final convo in res.conversations) {
      final otherDid = convo.members.firstWhere((d) => d != meDid, orElse: () => convo.members.first);
      final profile = await sprk.actor.getProfile(otherDid);
      items.add((profile, convo));
    }

    return ConversationsState(items);
  }
}
