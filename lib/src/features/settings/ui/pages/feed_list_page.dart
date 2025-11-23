import 'dart:ui' show lerpDouble;

import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/settings_feed_card.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

@RoutePage()
class FeedListPage extends ConsumerStatefulWidget {
  const FeedListPage({super.key});

  @override
  ConsumerState<FeedListPage> createState() => _FeedListPageState();
}

class _FeedListPageState extends ConsumerState<FeedListPage> {
  bool _isReordering = false;
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // Settings toggles
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feed Options',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 16),

                // Feed Blur Toggle
                Card(
                  child: SwitchListTile(
                    title: Text(
                      'Blur Feed Content',
                      style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                    ),
                    subtitle: Text(
                      'Blur potentially sensitive content in feeds',
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 12),
                    ),
                    value: settingsState.feedBlurEnabled,
                    onChanged: (value) {},
                    secondary: Icon(FluentIcons.eye_off_24_regular, color: colorScheme.primary),
                  ),
                ),

                const SizedBox(height: 8),

                // Post to Bluesky Toggle
                Card(
                  child: SwitchListTile(
                    title: Text(
                      'Cross-post to Bluesky',
                      style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                    ),
                    subtitle: Text(
                      'Automatically post to Bluesky when posting to Spark',
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 12),
                    ),
                    value: settingsState.postToBskyEnabled,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).setPostToBsky(value);
                    },
                    secondary: Icon(FluentIcons.share_24_regular, color: colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),

          // Feeds List Header with Edit Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Your Feeds',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditMode = !_isEditMode;
                    });
                  },
                  icon: Icon(_isEditMode ? Icons.check : Icons.edit, size: 18),
                  label: Text(_isEditMode ? 'Done' : 'Edit', style: const TextStyle(fontSize: 14)),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Feeds List
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: settingsState.feeds.length,
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
                  await ref.read(settingsProvider.notifier).reorderFeed(oldIndex, newIndex);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to reorder feeds: $e')),
                    );
                  }
                }
              },
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final animValue = Curves.easeInOutCubic.transform(animation.value);
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
                final feed = settingsState.feeds[index];
                final isActive = settingsState.activeFeed == feed;

                return Padding(
                  key: ValueKey(feed.config.id),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SettingsFeedCard(
                    feed: feed,
                    mode: _isEditMode ? SettingsFeedCardMode.edit : SettingsFeedCardMode.display,
                    isActive: isActive,
                    index: index,
                    onTap: _isEditMode || _isReordering
                        ? null
                        : () {
                            ref.read(settingsProvider.notifier).setActiveFeed(feed);
                          },
                    onDelete: _isEditMode
                        ? () async {
                            // Handle delete action
                            try {
                              await ref.read(settingsProvider.notifier).removeFeed(feed);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Feed removed')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to remove feed: $e')),
                                );
                              }
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
                              await ref.read(settingsProvider.notifier).removeFeed(feed);
                              await ref.read(settingsProvider.notifier).addFeed(updatedFeed);
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
                              await ref.read(settingsProvider.notifier).removeFeed(feed);
                              await ref.read(settingsProvider.notifier).addFeed(updatedFeed);
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
}
