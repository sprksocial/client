import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/profile/providers/user_list_provider.dart';
import 'package:sparksocial/src/features/profile/ui/pages/user_list_page.dart';
import 'package:sparksocial/src/features/search/ui/widgets/suggested_account_card.dart';

class UserListView extends ConsumerWidget {
  final List<ProfileView> users;

  const UserListView({required this.users, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (users.isEmpty) {
      return const Center(
        child: Text('No users to display.'),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SuggestedAccountCard(
            username: user.displayName ?? user.handle,
            handle: '@${user.handle}',
            avatarUrl: user.avatar.toString(),
            description: user.description,
            isFollowing: user.viewer?.following != null,
            onTap: () => context.router.push(ProfileRoute(did: user.did)),
            onFollowTap: () {
              ref.read(userListProvider(did: user.did, type: UserListType.followers).notifier).toggleFollow(user.did);
            },
            onUnfollowTap: () {
              ref.read(userListProvider(did: user.did, type: UserListType.following).notifier).toggleFollow(user.did);
            },
          ),
        );
      },
    );
  }
}
