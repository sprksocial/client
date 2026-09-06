import 'package:poptart/poptart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/components/molecules/post_tile.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderated_content.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/features/profile/providers/profile_feed_provider.dart';

/// Builder function that creates slivers for the profile grid
List<Widget> buildProfileGridSlivers({
  required BuildContext context,
  required WidgetRef ref,
  required AtUri profileUri,
  required bool videosOnly,
  required void Function(BuildContext, WidgetRef, AtUri) onPostTap,
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
                  AppIcon(
                    both
                        ? AppIconData.grid
                        : (videosOnly
                              ? AppIconData.video
                              : AppIconData.gallery),
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
            delegate: SliverChildBuilderDelegate((context, index) {
              final postUri = filteredUris[index];
              final postView = state.postViews[postUri];

              if (postView == null) {
                return const SizedBox.shrink();
              }

              return ProfileGridTile(
                postView: postView,
                onTap: () => onPostTap(context, ref, postUri),
              );
            }, childCount: filteredUris.length),
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
              const AppIcon(AppIconData.warning, size: 48),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).errorWithDetail(error.toString()),
              ),
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
                child: Text(AppLocalizations.of(context).buttonRetry),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class ProfileGridTile extends ConsumerWidget {
  const ProfileGridTile({
    required this.postView,
    required this.onTap,
    super.key,
  });
  final PostView postView;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnailUrl = postView.thumbnailUrl;

    // Use like count as a proxy for views, or 0 if not available
    final likeCount = postView.likeCount ?? 0;

    if (thumbnailUrl.isEmpty) {
      return ModeratedContent(
        subject: ModerationSubject.content(
          labels: postView.labels ?? const [],
          authorLabels: postView.author.labels ?? const [],
          subjectDid: postView.author.did,
        ),
        context: ModerationContext.contentList,
        presentation: const ModerationPresentation.compact(),
        child: GestureDetector(
          onTap: onTap,
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(
              child: AppIcon(AppIconData.mediaUnavailable, size: 20),
            ),
          ),
        ),
      );
    }

    return ModeratedContent(
      subject: ModerationSubject.content(
        labels: postView.labels ?? const [],
        authorLabels: postView.author.labels ?? const [],
        subjectDid: postView.author.did,
      ),
      context: ModerationContext.contentList,
      presentation: ModerationPresentation.compact(
        onConcealedTap: onTap,
        blurredChild: PostTile(
          thumbnailUrl: thumbnailUrl,
          likes: likeCount,
          seen: false,
          nsfwBlur: true,
          onTap: onTap,
        ),
      ),
      child: PostTile(
        thumbnailUrl: thumbnailUrl,
        likes: likeCount,
        seen: false,
        nsfwBlur: false,
        onTap: onTap,
      ),
    );
  }
}
