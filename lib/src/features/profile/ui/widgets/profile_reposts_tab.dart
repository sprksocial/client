import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/profile/providers/profile_reposts_provider.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_grid_widget.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_tab_base.dart';

/// Tab widget that displays reposted posts in a grid
class ProfileRepostsTab extends ProfileTabBase {
  const ProfileRepostsTab({
    required this.profileUri,
    super.key,
  });

  final AtUri profileUri;

  @override
  List<Widget> buildSlivers(BuildContext context, WidgetRef ref) {
    // Extract actor identifier from profileUri (DID or handle)
    final actor = profileUri.hostname;

    void onPostTap(BuildContext context, WidgetRef ref, AtUri postUri) {
      final repostsState = ref.read(profileRepostsProvider(actor));
      repostsState.whenData((repostsState) {
        final filteredUris = repostsState.loadedPosts;
        final postIndex = filteredUris.indexOf(postUri);
        if (postIndex != -1) {
          context.router.push(
            StandaloneRepostsFeedRoute(
              actor: actor,
              initialPostIndex: postIndex,
            ),
          );
        } else {
          context.router.push(StandalonePostRoute(postUri: postUri.toString()));
        }
      });
    }

    return _buildRepostsGridSlivers(
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

  /// Builder function that creates slivers for the reposts grid
  List<Widget> _buildRepostsGridSlivers({
    required BuildContext context,
    required WidgetRef ref,
    required String actor,
    required Function(BuildContext, WidgetRef, AtUri) onPostTap,
  }) {
    final repostsState = ref.watch(profileRepostsProvider(actor));

    return repostsState.when(
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
                    Icon(
                      FluentIcons.arrow_repeat_all_24_regular,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No reposts yet',
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
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                const Icon(FluentIcons.error_circle_24_regular, size: 48),
                const SizedBox(height: 16),
                Text('Error loading reposts: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(profileRepostsProvider(actor).notifier).refresh(),
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
