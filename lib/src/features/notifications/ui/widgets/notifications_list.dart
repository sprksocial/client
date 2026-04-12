import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/features/notifications/providers/notification_provider.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/notifications/ui/widgets/notification_item.dart';

class NotificationsList extends ConsumerStatefulWidget {
  const NotificationsList({this.priority, this.reasons, super.key});

  final bool? priority;
  final List<String>? reasons;

  @override
  ConsumerState<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends ConsumerState<NotificationsList> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _listViewportKey = GlobalKey();
  final Map<String, GlobalKey> _itemKeys = {};
  Set<String> _visibleGroupIds = const <String>{};
  bool _visibilityCheckScheduled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleVisibilityCheck();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when 80% scrolled
      ref
          .read(
            notificationProvider(
              priority: widget.priority,
              reasons: widget.reasons,
            ).notifier,
          )
          .loadMore(priority: widget.priority, reasons: widget.reasons);
    }

    _scheduleVisibilityCheck();
  }

  void _scheduleVisibilityCheck() {
    if (_visibilityCheckScheduled || !mounted) {
      return;
    }

    _visibilityCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _visibilityCheckScheduled = false;
      _updateVisibleItems();
    });
  }

  void _updateVisibleItems() {
    if (!mounted) {
      return;
    }

    final listContext = _listViewportKey.currentContext;
    if (listContext == null) {
      return;
    }

    final listRenderBox = listContext.findRenderObject() as RenderBox?;
    if (listRenderBox == null || !listRenderBox.hasSize) {
      return;
    }

    final viewportTop = listRenderBox.localToGlobal(Offset.zero).dy;
    final viewportBottom = viewportTop + listRenderBox.size.height;

    final visibleIds = <String>{};

    for (final entry in _itemKeys.entries) {
      final itemContext = entry.value.currentContext;
      if (itemContext == null) {
        continue;
      }

      final renderBox = itemContext.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) {
        continue;
      }

      final itemTop = renderBox.localToGlobal(Offset.zero).dy;
      final itemBottom = itemTop + renderBox.size.height;
      final visibleHeight =
          (itemBottom < viewportBottom ? itemBottom : viewportBottom) -
          (itemTop > viewportTop ? itemTop : viewportTop);

      if (visibleHeight <= 0) {
        continue;
      }

      final visibleFraction = visibleHeight / renderBox.size.height;
      if (visibleFraction >= 0.5) {
        visibleIds.add(entry.key);
      }
    }

    if (_setEquals(_visibleGroupIds, visibleIds)) {
      return;
    }

    setState(() {
      _visibleGroupIds = visibleIds;
    });
  }

  bool _setEquals(Set<String> a, Set<String> b) {
    if (identical(a, b)) {
      return true;
    }

    if (a.length != b.length) {
      return false;
    }

    for (final value in a) {
      if (!b.contains(value)) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notificationState = ref.watch(
      notificationProvider(priority: widget.priority, reasons: widget.reasons),
    );

    final isLoading = notificationState.isLoading;
    final isEmpty = notificationState.notifications.isEmpty;
    final hasError = notificationState.hasError;

    if (isLoading && isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError && isEmpty) {
      final errorMsg = notificationState.errorMessage;
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      return RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(
                notificationProvider(
                  priority: widget.priority,
                  reasons: widget.reasons,
                ).notifier,
              )
              .refresh(priority: widget.priority, reasons: widget.reasons);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colorScheme.onSurface.withAlpha(128),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.errorLoadingNotifications,
                    style: TextStyle(
                      color: colorScheme.onSurface.withAlpha(179),
                      fontSize: 16,
                    ),
                  ),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMsg,
                      style: TextStyle(
                        color: colorScheme.onSurface.withAlpha(102),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(
                            notificationProvider(
                              priority: widget.priority,
                              reasons: widget.reasons,
                            ).notifier,
                          )
                          .refresh(
                            priority: widget.priority,
                            reasons: widget.reasons,
                          );
                    },
                    child: Text(l10n.buttonRetry),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (notificationState.notifications.isEmpty) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      return RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(
                notificationProvider(
                  priority: widget.priority,
                  reasons: widget.reasons,
                ).notifier,
              )
              .refresh(priority: widget.priority, reasons: widget.reasons);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: colorScheme.onSurface.withAlpha(102),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.emptyNoNotifications,
                    style: TextStyle(
                      color: colorScheme.onSurface.withAlpha(179),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.messageAllCaughtUp,
                    style: TextStyle(
                      color: colorScheme.onSurface.withAlpha(102),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final groupedNotifications = notificationState.groupedNotifications;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleVisibilityCheck();
    });

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(
              notificationProvider(
                priority: widget.priority,
                reasons: widget.reasons,
              ).notifier,
            )
            .refresh(priority: widget.priority, reasons: widget.reasons);
      },
      child: ListView.builder(
        key: _listViewportKey,
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount:
            groupedNotifications.length +
            (notificationState.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= groupedNotifications.length) {
            // Loading more indicator
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final groupedNotification = groupedNotifications[index];
          final groupId = groupedNotification.primaryNotification.uri
              .toString();
          final itemKey = _itemKeys.putIfAbsent(groupId, () => GlobalKey());
          final notifier = ref.read(
            notificationProvider(
              priority: widget.priority,
              reasons: widget.reasons,
            ).notifier,
          );
          return NotificationItem(
            key: itemKey,
            groupedNotification: groupedNotification,
            isVisibleInViewport: _visibleGroupIds.contains(groupId),
            onViewed: () {
              // Mark all notifications in the group as viewed
              groupedNotification.notifications.forEach(
                notifier.markNotificationAsViewed,
              );
            },
          );
        },
      ),
    );
  }
}
