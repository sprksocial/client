import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/molecules/profile_card.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/profile/providers/blocks_provider.dart';

class BlocksListView extends ConsumerWidget {
  final List<ProfileView> users;
  final ScrollController? scrollController;
  final bool isFetchingMore;
  final String did;

  const BlocksListView({
    required this.users,
    required this.did,
    this.scrollController,
    this.isFetchingMore = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (users.isEmpty) {
      return const Center(
        child: Text('No blocked users.'),
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
          child: ProfileCard(
            imageUrl: user.avatar?.toString() ?? '',
            userName: user.displayName ?? user.handle,
            userHandle: '@${user.handle}',
            description: user.description,
            isFollowing: false,
            isBlocking: true,
            onFollow: () {},
            onUnfollow: () {},
            onUnblock: () {
              ref.read(blocksProvider(did: did).notifier).unblockUser(user.did);
            },
            onTap: () => context.router.push(
              ProfileRoute(
                did: user.did,
                initialProfile: ProfileViewBasic(
                  did: user.did,
                  handle: user.handle,
                  displayName: user.displayName,
                  avatar: user.avatar,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
