import 'dart:ui' show lerpDouble;

import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/feed/providers/feed_refresh_trigger_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

class FeedsBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const FeedsBar({required this.pageController, super.key});

  final PageController pageController;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  ConsumerState<FeedsBar> createState() => _FeedsBarState();
}

class _FeedsBarState extends ConsumerState<FeedsBar> {
  late final SparkLogger _logger;
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    _logger = GetIt.I<LogService>().getLogger('FeedsBar');
  }

  double _getTabWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width + 24;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    // Calculate total width of all tabs to center them
    double totalWidth = 0;
    for (final feed in settings.feeds) {
      totalWidth += _getTabWidth(feed.name) + 8.0; // 8.0 is margin
    }
    if (settings.feeds.isNotEmpty) totalWidth -= 8.0; // remove last margin

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(221, 0, 0, 0), Colors.transparent],
          ),
        ),
      ),
      title: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          // Account for the leading widget (back button) - approximately 56px
          const leadingWidth = 56.0;
          final centeringWidth = availableWidth - leadingWidth;
          final horizontalPadding = leadingWidth + (centeringWidth - totalWidth) / 2.0;

          return SizedBox(
            height: 44,
            child: ReorderableListView.builder(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding > 0 ? horizontalPadding : 0),
              scrollDirection: Axis.horizontal,
              itemCount: settings.feeds.length,
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
                  if (newIndex > oldIndex) newIndex -= 1;
                  final activeFeedBeforeReorder = settings.activeFeed;
                  await ref.read(settingsProvider.notifier).reorderFeed(oldIndex, newIndex);
                  await Future.delayed(const Duration(milliseconds: 50));
                  final updatedSettings = ref.read(settingsProvider);
                  final newActiveFeedIndex = updatedSettings.feeds.indexOf(activeFeedBeforeReorder);
                  if (newActiveFeedIndex != -1 && widget.pageController.hasClients) {
                    if ((widget.pageController.page?.round() ?? 0) != newActiveFeedIndex) {
                      widget.pageController.jumpToPage(newActiveFeedIndex);
                    }
                  }
                } catch (e) {
                  _logger.e('Error reordering feeds: $e');
                } finally {
                  setState(() => _isReordering = false);
                }
              },
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final animValue = Curves.easeInOutCubic.transform(animation.value);
                    final elevation = lerpDouble(0, 8, animValue)!;
                    final scale = lerpDouble(1, 1.2, animValue)!;
                    return Transform.scale(
                      scale: scale,
                      child: Material(
                        elevation: elevation,
                        borderRadius: BorderRadius.circular(25),
                        shadowColor: Colors.white.withAlpha(30),
                        color: Colors.transparent,
                        child: child,
                      ),
                    );
                  },
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final feed = settings.feeds[index];
                final isSelected = settings.activeFeed == feed;
                return InkWell(
                  key: ValueKey(feed.identifier),
                  onTap: _isReordering
                      ? null
                      : () {
                          if (settings.activeFeed == feed) {
                            ref.read(feedRefreshTriggerProvider(feed).notifier).trigger();
                          } else {
                            ref.read(settingsProvider.notifier).setActiveFeed(feed);
                            final feedIndex = settings.feeds.indexOf(feed);
                            if (feedIndex != -1 && widget.pageController.hasClients) {
                              widget.pageController.jumpToPage(feedIndex);
                            }
                          }
                        },
                  borderRadius: BorderRadius.circular(25),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          feed.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white.withAlpha(140),
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          height: 2,
                          width: isSelected ? _getTabWidth(feed.name) * 0.5 : 0,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(1)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(FluentIcons.options_24_regular),
          color: Colors.white,
          iconSize: 30,
          onPressed: () => context.router.navigate(const FeedSettingsRoute()),
        ),
      ],
    );
  }
}
