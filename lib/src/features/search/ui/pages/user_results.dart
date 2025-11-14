import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/search/providers/search_provider.dart';
import 'package:sparksocial/src/features/search/ui/widgets/profile_card.dart';

class UserResults extends ConsumerStatefulWidget {
  const UserResults({super.key});

  @override
  ConsumerState<UserResults> createState() => _UserResultsState();
}

class _UserResultsState extends ConsumerState<UserResults> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Trigger pagination when close to the bottom
      ref.read(searchProvider.notifier).loadMoreUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(searchProvider);
    final theme = Theme.of(context);

    if (state.isLoading && state.searchResults.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (state.query.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Search for users',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a search term to find users',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.searchResults.isEmpty && !state.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_search,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No users found',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final itemCount = state.isLoadingMore ? state.searchResults.length + 1 : state.searchResults.length;

    return ListView.builder(
      controller: _scrollController,
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        if (index >= state.searchResults.length) {
          // Loading indicator at bottom
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final actor = state.searchResults[index];

        // Check if the user is being followed
        final isFollowing = actor.viewer?.following != null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ProfileCard(
            username: actor.displayName ?? actor.handle,
            handle: '@${actor.handle}',
            avatarUrl: actor.avatar?.toString() ?? '',
            description: actor.description ?? '',
            onTap: () {
              if (actor.did.isNotEmpty) {
                context.router.push(ProfileRoute(did: actor.did));
              }
            },
            showFollowButton: !ref.read(searchProvider.notifier).isCurrentUser(actor.did),
            isFollowing: isFollowing,
            onFollowTap: () => ref.read(searchProvider.notifier).followUser(actor.did),
            onUnfollowTap: () =>
                ref.read(searchProvider.notifier).unfollowUser(actor.did, actor.viewer?.following ?? AtUri.parse('')),
          ),
        );
      },
    );
  }
}
