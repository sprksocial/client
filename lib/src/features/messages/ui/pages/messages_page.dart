import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/messages/providers/chat_providers_new.dart';
import 'package:sparksocial/src/core/network/chat/data/models/models.dart';

@RoutePage()
class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  int _selectedTabIndex = 0;
  List<ChatConversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    // Load chats when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChats();
    });
  }

  Future<void> _loadChats() async {
    try {
      final chatService = ref.read(chatServiceProvider.notifier);
      final response = await chatService.getChats();

      // For now, create simple conversation objects from DIDs
      // In a real implementation, you'd fetch user details for each DID
      final conversations = response.chats.map((did) => ChatConversation(
        otherUserDid: did,
        otherUserHandle: did.split(':').last, // Simple handle extraction
        lastActivity: DateTime.now(),
      )).toList();

      setState(() {
        _conversations = conversations;
      });
    } catch (e) {
      // Error will be shown in UI via provider state
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logger = GetIt.instance<LogService>().getLogger('MessagesPage');
    final chatServiceState = ref.watch(chatServiceProvider);

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
                    ? MessagesTab(
                        chatServiceState: chatServiceState,
                        conversations: _conversations,
                        onRefresh: _loadChats,
                      )
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
  final ChatServiceState chatServiceState;
  final List<ChatConversation> conversations;
  final VoidCallback onRefresh;

  const MessagesTab({
    super.key,
    required this.chatServiceState,
    required this.conversations,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (chatServiceState.isLoading && conversations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (chatServiceState.error != null && conversations.isEmpty) {
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
              onPressed: onRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (conversations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text('Start a conversation to see it here', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: conversations.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final conversation = conversations[index];

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              (conversation.otherUserDisplayName ?? conversation.otherUserHandle ?? 'U')[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            conversation.otherUserDisplayName ?? conversation.otherUserHandle ?? 'Unknown User',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text('@${conversation.otherUserHandle ?? 'unknown'}'),
          trailing: conversation.unreadCount > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    conversation.unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
              : null,
          onTap: () {
            context.router.push(ChatRoute(
              otherUserDid: conversation.otherUserDid,
              otherUserHandle: conversation.otherUserHandle,
              otherUserDisplayName: conversation.otherUserDisplayName,
              otherUserAvatar: conversation.otherUserAvatar,
            ));
          },
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
