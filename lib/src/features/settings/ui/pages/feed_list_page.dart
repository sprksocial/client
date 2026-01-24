import 'dart:ui' show lerpDouble;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/design_system/components/molecules/settings_feed_card.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';
import 'package:spark/src/features/settings/providers/settings_state.dart';

@RoutePage()
class FeedListPage extends ConsumerStatefulWidget {
  const FeedListPage({super.key});

  @override
  ConsumerState<FeedListPage> createState() => _FeedListPageState();
}

class _FeedListPageState extends ConsumerState<FeedListPage>
    with AutomaticKeepAliveClientMixin {
  bool _isReordering = false;
  bool _isEditMode = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final settingsState = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const AppLeadingButton(),
        title: const Text('Your Feeds'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
            icon: Icon(_isEditMode ? Icons.check : Icons.edit, size: 18),
            label: Text(
              _isEditMode ? 'Done' : 'Edit',
              style: const TextStyle(fontSize: 14),
            ),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Feeds List
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _getFilteredFeeds(settingsState).length,
              buildDefaultDragHandles: false,
              onReorderStart: (index) {
                setState(() {
                  _isReordering = true;
                });
              },
              onReorderEnd: (index) {
                setState(() {
                  _isReordering = false;
                });
              },
              onReorder: (oldIndex, newIndex) async {
                // Adjust newIndex if moving down the list
                if (newIndex > oldIndex) newIndex -= 1;

                try {
                  // Get the actual indices in the full feeds list
                  final filteredFeeds = _getFilteredFeeds(settingsState);
                  final actualOldIndex = settingsState.feeds.indexOf(
                    filteredFeeds[oldIndex],
                  );
                  final actualNewIndex = newIndex < filteredFeeds.length
                      ? settingsState.feeds.indexOf(filteredFeeds[newIndex])
                      : settingsState.feeds.length - 1;

                  await ref
                      .read(settingsProvider.notifier)
                      .reorderFeed(actualOldIndex, actualNewIndex);
                } catch (e) {
                  // Error handling - snackbar removed
                }
              },
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final animValue = Curves.easeInOutCubic.transform(
                      animation.value,
                    );
                    final elevation = lerpDouble(2, 8, animValue)!;
                    final scale = lerpDouble(1, 1.05, animValue)!;

                    return Transform.scale(
                      scale: scale,
                      child: Material(
                        elevation: elevation,
                        borderRadius: BorderRadius.circular(12),
                        shadowColor: colorScheme.shadow.withAlpha(100),
                        surfaceTintColor: Colors.transparent,
                        color: Colors.transparent,
                        child: child,
                      ),
                    );
                  },
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final filteredFeeds = _getFilteredFeeds(settingsState);
                final feed = filteredFeeds[index];
                final isActive = settingsState.activeFeed == feed;

                // Determine if feed can be deleted (Following can't be deleted)
                final canDelete =
                    !(feed.type == 'timeline' &&
                        feed.config.value == 'following');

                return Padding(
                  key: ValueKey(feed.config.id),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SettingsFeedCard(
                    feed: feed,
                    mode: _isEditMode
                        ? SettingsFeedCardMode.edit
                        : SettingsFeedCardMode.display,
                    isActive: isActive,
                    index: index,
                    onTap: _isEditMode || _isReordering
                        ? null
                        : () {
                            ref
                                .read(settingsProvider.notifier)
                                .setActiveFeed(feed);
                          },
                    onDelete: _isEditMode && canDelete
                        ? () async {
                            // Handle delete action
                            try {
                              await ref
                                  .read(settingsProvider.notifier)
                                  .removeFeed(feed);
                            } catch (e) {
                              // Error handling - snackbar removed
                            }
                          }
                        : null,
                    onPin: _isEditMode
                        ? () async {
                            // Handle pin action
                            if (!feed.config.pinned) {
                              final updatedFeed = Feed(
                                type: feed.type,
                                config: feed.config.copyWith(pinned: true),
                                view: feed.view,
                              );
                              await ref
                                  .read(settingsProvider.notifier)
                                  .removeFeed(feed);
                              await ref
                                  .read(settingsProvider.notifier)
                                  .addFeed(updatedFeed);
                            }
                          }
                        : null,
                    onUnpin: _isEditMode
                        ? () async {
                            // Handle unpin action
                            if (feed.config.pinned) {
                              final updatedFeed = Feed(
                                type: feed.type,
                                config: feed.config.copyWith(pinned: false),
                                view: feed.view,
                              );
                              await ref
                                  .read(settingsProvider.notifier)
                                  .removeFeed(feed);
                              await ref
                                  .read(settingsProvider.notifier)
                                  .addFeed(updatedFeed);
                            }
                          }
                        : null,
                    onLike: feed.view != null
                        ? () async {
                            try {
                              await ref
                                  .read(settingsProvider.notifier)
                                  .likeFeed(feed);
                            } catch (e) {
                              // Error handling - snackbar removed
                            }
                          }
                        : null,
                    onUnlike: feed.view?.viewer?.like != null
                        ? () async {
                            try {
                              await ref
                                  .read(settingsProvider.notifier)
                                  .unlikeFeed(feed);
                            } catch (e) {
                              // Error handling - snackbar removed
                            }
                          }
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Feed> _getFilteredFeeds(SettingsState settingsState) {
    return settingsState.feeds;
  }
}
