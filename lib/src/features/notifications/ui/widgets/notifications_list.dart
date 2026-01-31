import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/features/notifications/providers/notification_provider.dart';
import 'package:spark/src/features/notifications/ui/widgets/notification_item.dart';

class NotificationsList extends ConsumerStatefulWidget {
  const NotificationsList({
    this.priority,
    this.reasons,
    super.key,
  });

  final bool? priority;
  final List<String>? reasons;

  @override
  ConsumerState<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends ConsumerState<NotificationsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
          .loadMore(
            priority: widget.priority,
            reasons: widget.reasons,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(
      notificationProvider(
        priority: widget.priority,
        reasons: widget.reasons,
      ),
    );

    final isLoading = notificationState.isLoading;
    final isEmpty = notificationState.notifications.isEmpty;
    final hasError = notificationState.hasError;

    if (isLoading && isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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
              .refresh(
                priority: widget.priority,
                reasons: widget.reasons,
              );
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
                    'Failed to load notifications',
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
                    child: const Text('Retry'),
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
              .refresh(
                priority: widget.priority,
                reasons: widget.reasons,
              );
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
                    'No notifications',
                    style: TextStyle(
                      color: colorScheme.onSurface.withAlpha(179),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You're all caught up!",
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

    return RefreshIndicator(
      onRefresh: () async {
        await ref
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
      child: ListView.builder(
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
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final groupedNotification = groupedNotifications[index];
          final notifier = ref.read(
            notificationProvider(
              priority: widget.priority,
              reasons: widget.reasons,
            ).notifier,
          );
          return NotificationItem(
            groupedNotification: groupedNotification,
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
