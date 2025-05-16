import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/messages/providers/messages_provider.dart';
import 'package:sparksocial/src/features/messages/ui/widgets/tab_item.dart';
import 'package:get_it/get_it.dart';

class CustomTabBar extends ConsumerWidget {
  const CustomTabBar({
    super.key,
    required this.selectedTabIndex,
  });

  final int selectedTabIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final logger = GetIt.instance<LogService>().getLogger('MessagesPage');
    
    logger.d('Building CustomTabBar with selectedTabIndex: $selectedTabIndex');

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: TabItem(
              isSelected: selectedTabIndex == 0,
              label: 'Messages',
              onTap: () {
                logger.d('Switching to Messages tab');
                ref.read(messagesPageProvider.notifier).setSelectedTab(0);
              },
              isDarkMode: isDarkMode,
            ),
          ),
          Expanded(
            child: TabItem(
              isSelected: selectedTabIndex == 1,
              label: 'Activities',
              onTap: () {
                logger.d('Switching to Activities tab');
                ref.read(messagesPageProvider.notifier).setSelectedTab(1);
              },
              isDarkMode: isDarkMode,
            ),
          ),
        ],
      ),
    );
  }
} 