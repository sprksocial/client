import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/profile/providers/profile_likes_provider.dart';
import 'package:spark/src/features/profile/ui/widgets/profile_grid_widget.dart';
import 'package:spark/src/features/profile/ui/widgets/profile_tab_base.dart';

/// Tab widget that displays liked posts in a grid
class ProfileLikesTab extends ProfileTabBase {
  const ProfileLikesTab({
    required this.profileUri,
    this.bsky = false,
    super.key,
  });

  final AtUri profileUri;

  /// Whether to use Bluesky API instead of Spark API.
  final bool bsky;

  @override
  List<Widget> buildSlivers(BuildContext context, WidgetRef ref) {
    // Extract actor identifier from profileUri (DID or handle)
    final actor = profileUri.hostname;

    void onPostTap(BuildContext context, WidgetRef ref, AtUri postUri) {
      ref.read(profileLikesProvider(actor, bsky)).whenData((likesState) {
        final filteredUris = likesState.loadedPosts;
        final postIndex = filteredUris.indexOf(postUri);
        if (postIndex != -1) {
          context.router.push(
            StandaloneLikesFeedRoute(
              did: actor,
              initialPostIndex: postIndex,
              bsky: bsky,
            ),
          );
        } else {
          context.router.push(
            StandalonePostRoute(postUri: postUri.toString()),
          );
        }
      });
    }

    return _buildLikesGridSlivers(
      context: context,
      ref: ref,
      actor: actor,
      onPostTap: onPostTap,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This widget is used by route pages to build slivers
    // The actual rendering happens in ProfilePageTemplate via buildSlivers()
    return const SizedBox.shrink();
  }

  /// Builder function that creates slivers for the likes grid
  List<Widget> _buildLikesGridSlivers({
    required BuildContext context,
    required WidgetRef ref,
    required String actor,
    required Function(BuildContext, WidgetRef, AtUri) onPostTap,
  }) {
    final likesState = ref.watch(profileLikesProvider(actor, bsky));

    return likesState.when(
      data: (state) {
        // Display all posts returned by server - no client-side filtering
        final filteredUris = state.loadedPosts;

        if (filteredUris.isEmpty) {
          return [
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcons.likeFilled(
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No likes yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        }

        // Add bottom padding to account for tab bar when on main navigation
        final bottomPadding =
            MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;

        return [
          SliverPadding(
            padding: const EdgeInsets.all(5),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 9 / 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final postUri = filteredUris[index];
                  final postView = state.postViews[postUri];
                  final postSource = state.postSources[postUri];

                  if (postView == null) {
                    return const SizedBox.shrink();
                  }

                  return ProfileGridTile(
                    postView: postView,
                    postSource: postSource,
                    onTap: () => onPostTap(context, ref, postUri),
                  );
                },
                childCount: filteredUris.length,
              ),
            ),
          ),
          // Bottom padding for tab bar
          SliverPadding(padding: EdgeInsets.only(bottom: bottomPadding)),
        ];
      },
      loading: () => [
        SliverPadding(
          padding: const EdgeInsets.all(5),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 9 / 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => Skeletonizer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              childCount: 12,
            ),
          ),
        ),
      ],
      error: (error, stack) => [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text('Error loading likes: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(profileLikesProvider(actor, bsky).notifier)
                      .refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
