import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/messages/providers/chat_provider.dart';
import 'package:sparksocial/src/features/messages/ui/widgets/conversation_list.dart';

@RoutePage()
class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize chat provider when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logger = GetIt.instance<LogService>().getLogger('MessagesPage');
    final chatState = ref.watch(chatProvider);

    logger.d('Building MessagesPage');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Inbox', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        leading: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            context.router.push(const NewChatSearchRoute());
          },
          icon: Icon(FluentIcons.add_24_regular, color: theme.colorScheme.onSurface, size: 24),
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              // TODO: Implement search functionality
            },
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
                CustomTabBar(
                  selectedTabIndex: _selectedTabIndex,
                  onTabChanged: (index) => setState(() => _selectedTabIndex = index),
                ),
                Container(
                  height: 0.5,
                  width: double.infinity,
                  color: theme.colorScheme.outline,
                ),
                Expanded(
                  child: _selectedTabIndex == 0
                    ? MessagesTab(chatState: chatState)
                    : const ActivitiesTab(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTabBar extends StatelessWidget {
  final int selectedTabIndex;
  final Function(int) onTabChanged;

  const CustomTabBar({
    super.key,
    required this.selectedTabIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: TabItem(
              isSelected: selectedTabIndex == 0,
              label: 'Messages',
              onTap: () => onTabChanged(0),
            ),
          ),
          Expanded(
            child: TabItem(
              isSelected: selectedTabIndex == 1,
              label: 'Activities',
              onTap: () => onTabChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class TabItem extends StatelessWidget {
  final bool isSelected;
  final String label;
  final VoidCallback onTap;

  const TabItem({
    super.key,
    required this.isSelected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                ? (label == 'Messages' ? theme.colorScheme.primary : theme.colorScheme.secondary)
                : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                ? (label == 'Messages' ? theme.colorScheme.primary : theme.colorScheme.secondary)
                : theme.colorScheme.onSurface.withAlpha(179),
            ),
          ),
        ),
      ),
    );
  }
}

class MessagesTab extends ConsumerWidget {
  final chatState;

  const MessagesTab({
    super.key,
    required this.chatState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (chatState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (chatState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FluentIcons.error_circle_24_regular,
              size: 48,
              color: Theme.of(context).colorScheme.error
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load conversations',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.read(chatProvider.notifier).initialize(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ConversationList(
      conversations: chatState.conversations,
      onConversationTap: (conversation) {
        context.router.push(ChatRoute(conversation: conversation));
      },
      onConversationLongPress: (conversation) {
        // TODO: Implement conversation options (delete, mute, etc.)
      },
    );
  }
}

class ActivitiesTab extends StatelessWidget {
  const ActivitiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement activities functionality when ActivityList is available
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FluentIcons.star_24_regular,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(
            'Activities',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Activity features coming soon',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
            ),
          ),
        ],
      ),
    );
  }
}
