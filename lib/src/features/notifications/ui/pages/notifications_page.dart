import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/features/notifications/providers/notification_provider.dart'
    show notificationProvider;
import 'package:spark/src/features/notifications/ui/widgets/notifications_list.dart';

@RoutePage()
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  bool _hasMarkedAsSeen = false;

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Reset the flag when refreshing so we can mark new notifications as seen
    if (notificationState.isRefreshing) {
      _hasMarkedAsSeen = false;
    }

    // Mark notifications as seen once they're loaded
    if (!_hasMarkedAsSeen &&
        !notificationState.isLoading &&
        !notificationState.isRefreshing &&
        notificationState.notifications.isNotEmpty) {
      _hasMarkedAsSeen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(notificationProvider().notifier).markAsSeen();
      });
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Notifications',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
      body: const NotificationsList(),
    );
  }
}
