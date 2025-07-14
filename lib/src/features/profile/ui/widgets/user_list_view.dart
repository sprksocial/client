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
  final ScrollController? scrollController;
  final bool isFetchingMore;
  final String did;
  final UserListType type;

  const UserListView({
    required this.users,
    required this.did,
    required this.type,
    this.scrollController,
    this.isFetchingMore = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (users.isEmpty) {
      return const Center(
        child: Text('No users to display.'),
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: users.length + (isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (isFetchingMore && index == users.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final user = users[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SuggestedAccountCard(
            username: user.displayName ?? user.handle,
            handle: '@${user.handle}',
            avatarUrl: user.avatar.toString(),
            description: user.description,
            isFollowing: user.viewer?.following != null,
            showFollowButton: !ref.read(userListProvider(did: did, type: type).notifier).isCurrentUser(user.did),
            onTap: () => context.router.push(ProfileRoute(did: user.did)),
            onFollowTap: () {
              ref.read(userListProvider(did: did, type: type).notifier).followUser(user.did);
            },
            onUnfollowTap: () {
              ref.read(userListProvider(did: did, type: type).notifier).unfollowUser(user.did);
            },
          ),
        );
      },
    );
  }
}
