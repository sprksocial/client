import 'dart:ui' show lerpDouble;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';
import 'package:spark/src/features/settings/providers/settings_state.dart';
import 'package:spark/src/features/settings/ui/widgets/settings_feed_card.dart';

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

  void _showFeedReorderError() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.errorUpdatingFeeds)));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final settingsState = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const AppLeadingButton(),
        title: Text(l10n.pageTitleYourFeeds),
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
              _isEditMode ? l10n.buttonDone : l10n.buttonEdit,
              style: const TextStyle(fontSize: 14),
            ),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              onReorderItem: (oldIndex, newIndex) async {
                // Adjust newIndex if moving down the list
                final adjustedNewIndex = newIndex > oldIndex
                    ? newIndex - 1
                    : newIndex;

                try {
                  final filteredFeeds = _getFilteredFeeds(settingsState);
                  final reorderedFeeds = [...filteredFeeds];
                  final movedFeed = reorderedFeeds.removeAt(oldIndex);
                  final beforeFeedId = adjustedNewIndex < reorderedFeeds.length
                      ? reorderedFeeds[adjustedNewIndex].config.id
                      : null;

                  await ref
                      .read(settingsProvider.notifier)
                      .reorderFeed(
                        movedFeedId: movedFeed.config.id,
                        beforeFeedId: beforeFeedId,
                      );
                } catch (_) {
                  _showFeedReorderError();
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

                return Padding(
                  key: ValueKey(feed.config.id),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SettingsFeedCard(
                    feed: feed,
                    mode: _isEditMode
                        ? SettingsFeedCardMode.edit
                        : SettingsFeedCardMode.display,
                    index: index,
                    interactionEnabled: !_isReordering,
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
