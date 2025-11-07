import 'dart:ui' show lerpDouble;

import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                      style: TextStyle(color: colorScheme.onSurface.withAlpha(178), fontSize: 12),
                    ),
                    value: settingsState.feedBlurEnabled,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).setFeedBlur(value);
                    },
                    secondary: Icon(FluentIcons.eye_off_24_regular, color: colorScheme.primary),
                  ),
                ),

                const SizedBox(height: 8),

                // Hide Adult Content Toggle
                Card(
                  child: SwitchListTile(
                    title: Text(
                      'Hide Adult Content',
                      style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                    ),
                    subtitle: Text(
                      'Hide content marked as adult/mature',
                      style: TextStyle(color: colorScheme.onSurface.withAlpha(178), fontSize: 12),
                    ),
                    value: settingsState.hideAdultContent,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).setHideAdultContent(value);
                    },
                    secondary: Icon(FluentIcons.shield_24_regular, color: colorScheme.primary),
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
                      style: TextStyle(color: colorScheme.onSurface.withAlpha(178), fontSize: 12),
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

          // Feeds List
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Your Feeds',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: settingsState.feeds.length,
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
                      if (_isReordering) return;

                      setState(() => _isReordering = true);

                      try {
                        // Adjust newIndex if moving down the list
                        if (newIndex > oldIndex) newIndex -= 1;

                        await ref.read(settingsProvider.notifier).reorderFeed(oldIndex, newIndex);

                        // Small delay to allow state to settle
                        await Future.delayed(const Duration(milliseconds: 50));
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to reorder feeds: $e')),
                          );
                        }
                      } finally {
                        if (context.mounted) {
                          setState(() => _isReordering = false);
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

                      return Card(
                        key: ValueKey(feed.identifier),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        elevation: _isReordering ? 0 : 1,
                        child: ListTile(
                          enabled: !_isReordering,
                          leading: Icon(_getFeedIcon(feed), color: isActive ? colorScheme.primary : colorScheme.onSurface),
                          title: Text(
                            feed.name,
                            style: TextStyle(
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                              color: isActive ? colorScheme.primary : colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            _getFeedDescription(feed),
                            style: TextStyle(color: colorScheme.onSurface.withAlpha(178), fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withAlpha(51),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Active',
                                    style: TextStyle(fontSize: 10, color: colorScheme.primary, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Icon(
                                FluentIcons.re_order_dots_vertical_24_regular,
                                color: _isReordering ? colorScheme.primary.withAlpha(128) : colorScheme.onSurface.withAlpha(178),
                              ),
                            ],
                          ),
                          onTap: _isReordering
                              ? null
                              : () {
                                  ref.read(settingsProvider.notifier).setActiveFeed(feed);
                                },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFeedIcon(Feed feed) {
    return feed.when(
      record: (name, uri) => FluentIcons.feed_24_regular,
      hardCoded: (hardCodedFeed) {
        switch (hardCodedFeed) {
          case HardCodedFeedEnum.timeline:
            return FluentIcons.people_24_regular;
          case HardCodedFeedEnum.forYou:
            return FluentIcons.star_24_regular;
          case HardCodedFeedEnum.latest:
            return FluentIcons.flash_24_regular;
        }
      },
    );
  }

  String _getFeedDescription(Feed feed) {
    return feed.when(
      record: (name, uri) => 'Custom algorithmic feed',
      hardCoded: (hardCodedFeed) {
        switch (hardCodedFeed) {
          case HardCodedFeedEnum.timeline:
            return 'Posts from accounts you follow';
          case HardCodedFeedEnum.forYou:
            return 'Personalized content recommendations';
          case HardCodedFeedEnum.latest:
            return 'Latest posts from Spark community';
        }
      },
    );
  }
}
