import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/core/widgets/user_avatar.dart';
import 'package:sparksocial/src/features/messages/providers/conversations_provider.dart';

@RoutePage()
class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logger = GetIt.instance<LogService>().getLogger('MessagesPage');
    final chatServiceState = ref.watch(conversationsProvider);

    logger.d('Building MessagesPage');

    return chatServiceState.when(
      data: (data) => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Inbox',
            style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
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
                  Container(height: 0.5, width: double.infinity, color: theme.colorScheme.outline),
                  Expanded(
                    child: _selectedTabIndex == 0
                        ? MessagesTab(onRefresh: () => {ref.invalidate(conversationsProvider)})
                        : const ActivitiesTab(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        final theme = Theme.of(context);
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FluentIcons.error_circle_24_regular, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load conversations', style: TextStyle(color: theme.colorScheme.error)),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: () => ref.invalidate(conversationsProvider), child: const Text('Retry')),
            ],
          ),
        );
      },
    );
  }
}

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({required this.selectedTabIndex, required this.onTabChanged, super.key});
  final int selectedTabIndex;
  final Function(int) onTabChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: TabItem(isSelected: selectedTabIndex == 0, label: 'Messages', onTap: () => onTabChanged(0)),
          ),
          Expanded(
            child: TabItem(isSelected: selectedTabIndex == 1, label: 'Activities', onTap: () => onTabChanged(1)),
          ),
        ],
      ),
    );
  }
}

class TabItem extends StatelessWidget {
  const TabItem({required this.isSelected, required this.label, required this.onTap, super.key});
  final bool isSelected;
  final String label;
  final VoidCallback onTap;

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
  const MessagesTab({required this.onRefresh, super.key});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversationsProvider);

    return state.when(
      data: (data) {
        return ListView.builder(
          itemCount: data.conversations.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            // final conversation = data.conversations[index];

            return ListTile(
              leading: UserAvatar(
                imageUrl: data.conversations[index].$1.avatar.toString(),
                username: data.conversations[index].$1.handle,
                size: 36,
              ),
              title: Text(
                data.conversations[index].$1.displayName ?? data.conversations[index].$1.handle,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text('@${data.conversations[index].$1.handle}'),
              // trailing: data.conversations[index].unreadCount > 0
              //     ? Container(
              //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              //         decoration: BoxDecoration(
              //           color: Theme.of(context).colorScheme.primary,
              //           borderRadius: BorderRadius.circular(10),
              //         ),
              //         child: Text(conversation.unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
              //       )
              //     : null,
              onTap: () {
                context.router.push(
                  ChatRoute(
                    otherUserDid: data.conversations[index].$1.did,
                    otherUserHandle: data.conversations[index].$1.handle,
                    otherUserDisplayName: data.conversations[index].$1.displayName,
                    otherUserAvatar: data.conversations[index].$1.avatar.toString(),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        final theme = Theme.of(context);
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FluentIcons.error_circle_24_regular, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load conversations', style: TextStyle(color: theme.colorScheme.error)),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: onRefresh, child: const Text('Retry')),
            ],
          ),
        );
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
          Icon(FluentIcons.star_24_regular, size: 64, color: Theme.of(context).colorScheme.onSurface.withAlpha(128)),
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
            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withAlpha(128)),
          ),
        ],
      ),
    );
  }
}
