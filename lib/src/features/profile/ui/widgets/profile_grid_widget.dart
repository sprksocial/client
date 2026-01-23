import 'package:atproto/core.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spark/src/core/design_system/components/molecules/post_tile.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/features/profile/providers/profile_feed_provider.dart';

/// Builder function that creates slivers for the profile grid
List<Widget> buildProfileGridSlivers({
  required BuildContext context,
  required WidgetRef ref,
  required AtUri profileUri,
  required bool videosOnly,
  required Function(BuildContext, WidgetRef, AtUri) onPostTap,
  bool both = false,
  bool bsky = false,
}) {
  final feedState = ref.watch(
    profileFeedProvider(profileUri, videosOnly, bsky),
  );

  return feedState.when(
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
                    both
                        ? FluentIcons.grid_24_regular
                        : (videosOnly
                              ? FluentIcons.video_24_regular
                              : FluentIcons.image_24_regular),
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    both
                        ? 'No posts yet'
                        : (videosOnly ? 'No videos yet' : 'No images yet'),
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
              Text('Error loading posts: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(
                      profileFeedProvider(
                        profileUri,
                        videosOnly,
                        bsky,
                      ).notifier,
                    )
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

class ProfileGridTile extends StatelessWidget {
  const ProfileGridTile({
    required this.postView,
    required this.onTap,
    super.key,
    this.postSource,
  });
  final PostView postView;
  final String? postSource;
  final VoidCallback onTap;

  /// Check for adult content labels synchronously without network calls
  bool _hasAdultLabel() {
    final labels = postView.labels;
    if (labels == null || labels.isEmpty) return false;

    // Check for common adult content labels synchronously
    const adultLabels = {'porn', 'sexual', 'nudity', 'nsfw', 'adult'};
    return labels.any((label) => adultLabels.contains(label.val.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = postView.thumbnailUrl;
    final shouldBlur = _hasAdultLabel();

    // Use like count as a proxy for views, or 0 if not available
    final likeCount = postView.likeCount ?? 0;

    if (thumbnailUrl.isEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(
            child: Icon(FluentIcons.image_off_24_regular, size: 20),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PostTile(
          thumbnailUrl: thumbnailUrl,
          likes: likeCount,
          seen: false,
          nsfwBlur: shouldBlur,
          onTap: onTap,
        ),
        if (postSource != null)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              height: 20,
              width: 20,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(150),
                borderRadius: BorderRadius.circular(15),
              ),
              child: SvgPicture.asset(
                postSource == 'bsky' ? 'images/bsky.svg' : 'images/sprk.svg',
                width: 12,
                height: 12,
                package: 'assets',
              ),
            ),
          ),
      ],
    );
  }
}
