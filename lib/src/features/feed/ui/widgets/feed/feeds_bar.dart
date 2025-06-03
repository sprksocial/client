import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'dart:ui' show lerpDouble;
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

class FeedsBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const FeedsBar({super.key, required this.pageController});

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
  
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    
    return AppBar(
      title: SizedBox(
        height: 40,
        child: ReorderableListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: settings.feeds.length,
          buildDefaultDragHandles: false, // We'll add custom drag handles
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
            // Prevent multiple simultaneous reorders
            if (_isReordering) return;
            
            setState(() {
              _isReordering = true;
            });
            
            try {
              // Adjust newIndex for Flutter's reordering behavior
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              
              // Remember which feed was active before reordering
              final activeFeedBeforeReorder = settings.activeFeed;
              
              // Perform the reorder operation
              await ref.read(settingsProvider.notifier).reorderFeed(oldIndex, newIndex);
              
              // Wait for the settings to update
              await Future.delayed(const Duration(milliseconds: 50));
              
              // Get updated settings and find new position of active feed
              final updatedSettings = ref.read(settingsProvider);
              final newActiveFeedIndex = updatedSettings.feeds.indexOf(activeFeedBeforeReorder);
              
              // Only update page controller if we found the active feed and it moved
              if (newActiveFeedIndex != -1 && widget.pageController.hasClients) {
                final currentPage = widget.pageController.page?.round() ?? 0;
                if (currentPage != newActiveFeedIndex) {
                  widget.pageController.jumpToPage(newActiveFeedIndex);
                }
              }
            } catch (e) {
              _logger.e('Error reordering feeds: $e');
            } finally {
              setState(() {
                _isReordering = false;
              });
            }
          },
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final animValue = Curves.easeInOut.transform(animation.value);
                final elevation = lerpDouble(0, 8, animValue)!;
                final scale = lerpDouble(1, 1.1, animValue)!;
                return Transform.scale(
                  scale: scale,
                  child: Material(
                    elevation: elevation,
                    borderRadius: BorderRadius.circular(25),
                    shadowColor: AppColors.pink.withAlpha(100),
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
            
            return Container(
              key: ValueKey(feed.identifier),
              margin: const EdgeInsets.only(right: 8.0),
              child: ReorderableDragStartListener(
                index: index,
                child: InkWell(
                  onTap: _isReordering ? null : () {
                    // Prevent tap during reordering
                    ref.read(settingsProvider.notifier).setActiveFeed(feed);
                    final feedIndex = settings.feeds.indexOf(feed);
                    if (feedIndex != -1 && widget.pageController.hasClients) {
                      widget.pageController.jumpToPage(feedIndex);
                    }
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.pink.withAlpha(51) : Colors.transparent,
                      border: isSelected 
                        ? Border.all(color: AppColors.pink, width: 1.5) 
                        : Border.all(color: AppColors.lightLavender.withAlpha(51), width: 1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          feed.name,
                          style: TextStyle(
                            color: AppColors.lightLavender,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(FluentIcons.options_24_regular),
          color: AppColors.lightLavender,
          iconSize: 30,
          onPressed: () => context.router.navigate(FeedSettingsRoute()),
        ),
      ],
    );
  }
}
