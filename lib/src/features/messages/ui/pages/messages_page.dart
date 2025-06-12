import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/core/widgets/development_overlay.dart';

@RoutePage()
class MessagesPage extends ConsumerWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logger = GetIt.instance<LogService>().getLogger('MessagesPage');

    logger.d('Building MessagesPage');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Inbox', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        leading: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {},
          icon: Icon(FluentIcons.add_24_regular, color: theme.colorScheme.onSurface, size: 24),
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            icon: Icon(FluentIcons.search_24_regular, color: theme.colorScheme.onSurface, size: 24),
          ),
        ],
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 0.5,
                  width: double.infinity,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
            const DevelopmentOverlay(),
          ],
        ),
      ),
    );
  }
}
