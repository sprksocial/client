import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/molecules/feed_card.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/features/search/providers/suggested_feeds_provider.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

class SuggestedFeedsList extends ConsumerWidget {
  const SuggestedFeedsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestedFeedsAsync = ref.watch(suggestedFeedsProvider);
    final settingsState = ref.watch(settingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Suggested Feeds',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        suggestedFeedsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Failed to load suggested feeds: $error',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          data: (generatorViews) {
            if (generatorViews.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No suggested feeds available',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: generatorViews.length,
              itemBuilder: (context, index) {
                final generatorView = generatorViews[index];

                // Create a SavedFeed config for this generator
                final savedFeed = SavedFeed(
                  type: 'feed',
                  value: generatorView.uri.toString(),
                  pinned: false,
                );

                // Check if feed is already added & get its actual pinned status
                final existingFeed = settingsState.feeds.firstWhere(
                  (f) => f.config.value == savedFeed.value,
                  orElse: () => Feed(
                    type: 'feed',
                    config: savedFeed,
                    view: generatorView,
                  ),
                );
                final isAdded = settingsState.feeds.any(
                  (f) => f.config.value == savedFeed.value,
                );

                final feed = isAdded
                    ? Feed(
                        type: existingFeed.type,
                        config: existingFeed.config,
                        view: generatorView,
                      )
                    : Feed(
                        type: 'feed',
                        config: savedFeed,
                        view: generatorView,
                      );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FeedCard(
                    feed: feed,
                    isAdded: isAdded,
                    onAdd: () async {
                      await ref.read(settingsProvider.notifier).addFeed(feed);
                    },
                    onPin: () async {
                      // Update the feed to be pinned
                      final existingFeed = settingsState.feeds.firstWhere(
                        (f) => f.config.value == savedFeed.value,
                      );
                      final updatedFeed = Feed(
                        type: existingFeed.type,
                        config: existingFeed.config.copyWith(pinned: true),
                        view: existingFeed.view,
                      );
                      await ref
                          .read(settingsProvider.notifier)
                          .setActiveFeed(updatedFeed);
                    },
                    onUnpin: () async {
                      // Remove entirely when unpinning from suggested feeds
                      final existingFeed = settingsState.feeds.firstWhere(
                        (f) => f.config.value == savedFeed.value,
                      );
                      // Find another feed to set as active if was active feed
                      if (settingsState.activeFeed.config.id ==
                          existingFeed.config.id) {
                        final otherFeed = settingsState.feeds.firstWhere(
                          (f) => f.config.id != existingFeed.config.id,
                          orElse: () => Feed(
                            type: 'timeline',
                            config: SavedFeed(
                              type: 'timeline',
                              value: 'following',
                              pinned: true,
                            ),
                          ),
                        );
                        await ref
                            .read(settingsProvider.notifier)
                            .setActiveFeed(otherFeed);
                      }
                      // Remove the feed entirely
                      await ref
                          .read(settingsProvider.notifier)
                          .removeFeed(existingFeed);
                    },
                    onTap: () async {
                      // Add feed if not already added, then set as active
                      if (!isAdded) {
                        await ref.read(settingsProvider.notifier).addFeed(feed);
                      }
                      await ref
                          .read(settingsProvider.notifier)
                          .setActiveFeed(feed);
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
