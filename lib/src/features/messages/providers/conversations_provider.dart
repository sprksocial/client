import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/messages/data/models/message_models.dart';
import 'package:spark/src/core/network/messages/data/repository/messages_repository.dart';
import 'package:spark/src/features/messages/providers/conversations._state.dart';

part 'conversations_provider.g.dart';

@Riverpod(keepAlive: true)
class Conversations extends _$Conversations {
  String? cursor;

  @override
  FutureOr<ConversationsState> build() async {
    final repo = GetIt.I<MessagesRepository>();

    final res = await repo.listConversations(limit: 50);
    cursor = res.cursor;

    // Pick counterpart profile from hydrated conversation members
    final meDid = GetIt.I<AuthRepository>().did;
    final items = <(ProfileViewBasic, ConvoView)>[];
    for (final convo in res.conversations) {
      final profile = convo.members.firstWhere(
        (member) => member.did != meDid,
        orElse: () => convo.members.first,
      );
      items.add((profile, convo));
    }

    return ConversationsState(items);
  }
}
