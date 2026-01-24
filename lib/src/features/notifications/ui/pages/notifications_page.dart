import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/features/notifications/providers/notification_provider.dart'
    show notificationProvider;
import 'package:spark/src/features/notifications/providers/unread_count_provider.dart'
    show unreadCountProvider;
import 'package:spark/src/features/notifications/ui/widgets/notifications_list.dart';

@RoutePage()
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Mark notifications as seen when page is viewed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(
            notificationProvider().notifier,
          )
          .markAsSeen();
      // Refresh unread count after marking as seen
      ref.read(unreadCountProvider().notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: const NotificationsList(),
    );
  }
}
