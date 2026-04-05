import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/molecules/profile_card.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/profile/providers/user_list_provider.dart';
import 'package:spark/src/features/profile/ui/pages/user_list_page.dart';
import 'package:spark/src/features/stories/utils/story_navigation.dart';

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
    final l10n = AppLocalizations.of(context);
    if (users.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: scrollController,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.emptyNoUsers),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
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
        final hasStories = user.stories?.isNotEmpty ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ProfileCard(
            imageUrl: user.avatar?.toString() ?? '',
            userName: user.displayName ?? user.handle,
            userHandle: '@${user.handle}',
            description: user.description,
            isFollowing: user.viewer?.following != null,
            onFollow: () {
              ref
                  .read(userListProvider(did: did, type: type).notifier)
                  .followUser(user.did);
            },
            onUnfollow: () {
              ref
                  .read(userListProvider(did: did, type: type).notifier)
                  .unfollowUser(user.did);
            },
            showFollowButton: !ref
                .read(userListProvider(did: did, type: type).notifier)
                .isCurrentUser(user.did),
            hasStories: hasStories,
            onAvatarTap: hasStories
                ? () =>
                      openStoriesForProfile(context, user, source: 'user list')
                : null,
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
