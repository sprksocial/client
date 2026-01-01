import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/design_system/templates/chat_list_page_template.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
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
    final logger = GetIt.instance<LogService>().getLogger('MessagesPage');
    final chatServiceState = ref.watch(conversationsProvider);

    logger.d('Building MessagesPage');

    return chatServiceState.when(
      data: (data) {
        final items = data.conversations.map((tuple) {
          final profile = tuple.$1;
          final convo = tuple.$2;
          final last = convo.lastMessage;
          final ts = _formatTime(last?.sentAt);
          final preview = (last?.text ?? '').trim();
          return ChatListItemData(
            avatarUrl: profile.avatar?.toString(),
            displayName: profile.displayName ?? profile.handle,
            handle: profile.handle,
            timestamp: ts,
            preview: preview.isNotEmpty ? preview : '',
            unread: (convo.unreadCount) > 0,
          );
        }).toList();

        Future<void> refreshAndInvalidate() async {
          final refreshed = await ref.refresh(conversationsProvider.future);
          logger.d('Refreshed conversations: ${refreshed.conversations.length}');
        }

        return ChatListPageTemplate(
          items: items,
          selectedTabIndex: _selectedTabIndex,
          onTabChanged: (i) => setState(() => _selectedTabIndex = i),
          onItemTap: (index) async {
            final profile = data.conversations[index].$1;
            final convo = data.conversations[index].$2;
            context.router.push(
              ChatRoute(
                conversationId: convo.id,
                otherUserDid: profile.did,
                otherUserHandle: profile.handle,
                otherUserDisplayName: profile.displayName,
                otherUserAvatar: profile.avatar.toString(),
              ),
            );
          },
          onAddTap: () => context.router.push(const NewChatSearchRoute()),
          onSearchTap: () {},
          onRefresh: refreshAndInvalidate,
          activityWidget: const ActivitiesTab(),
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
              ElevatedButton(onPressed: () => ref.invalidate(conversationsProvider), child: const Text('Retry')),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(String? sentAtIso) {
    if (sentAtIso == null || sentAtIso.isEmpty) return '';
    try {
      final dt = DateTime.tryParse(sentAtIso)?.toLocal();
      if (dt == null) return '';
      String two(int v) => v.toString().padLeft(2, '0');
      return '${two(dt.hour)}:${two(dt.minute)}';
    } catch (_) {
      return '';
    }
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
