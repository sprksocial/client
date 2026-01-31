import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/templates/chat_thread_page_template.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/messages/providers/conversation_provider.dart';
import 'package:spark/src/features/messages/providers/polling_timer.dart';
import 'package:spark/src/features/messages/ui/widgets/messages_list.dart';

@RoutePage()
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({
    @PathParam('conversationId') required this.conversationId,
    this.otherUserDid,
    super.key,
    this.otherUserHandle,
    this.otherUserDisplayName,
    this.otherUserAvatar,
  });
  final String conversationId;
  final String? otherUserDid;
  final String? otherUserHandle;
  final String? otherUserDisplayName;
  final String? otherUserAvatar;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentUserDid;
  bool _markedReadOnce = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() {
    _currentUserDid = ref.read(currentDidProvider);
  }

  String _getConversationTitle() {
    return widget.otherUserDisplayName ?? widget.otherUserHandle ?? 'Chat';
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    try {
      final chatService = ref.read(
        conversationProvider(widget.conversationId).notifier,
      );
      await chatService.sendMessage(widget.conversationId, content);
    } catch (e) {
      // Error handling - snackbar removed
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationProvider(widget.conversationId));
    ref
      ..listen(
        pollingTriggerProvider(widget.conversationId),
        (previous, next) {},
      )
      // When the conversation loads for the first time, notify backend as read
      ..listen(conversationProvider(widget.conversationId), (prev, next) {
        final data = next.asData?.value;
        if (!_markedReadOnce && data != null && data.messages.isNotEmpty) {
          _markedReadOnce = true;
          ref
              .read(conversationProvider(widget.conversationId).notifier)
              .markReadUpToLatest();
        }
      });
    final messagesWidget = state.when(
      data: (data) => MessagesList(
        messages: data.messages,
        scrollController: _scrollController,
        currentUserDid: _currentUserDid,
        otherUserHandle: widget.otherUserHandle,
        otherUserAvatar: widget.otherUserAvatar,
      ),
      loading: () {
        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: const Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FluentIcons.error_circle_24_regular,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load messages',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  ref.invalidate(conversationProvider(widget.conversationId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );

    return ChatThreadPageTemplate(
      displayName: _getConversationTitle(),
      handle: widget.otherUserHandle ?? 'user',
      avatarUrl: widget.otherUserAvatar,
      messagesWidget: messagesWidget,
      textController: _messageController,
      onSend: _sendMessage,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

Color getAvatarColor(int seed) {
  final colors = [
    AppColors.primary,
    AppColors.pink,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
  ];
  return colors[seed.abs() % colors.length];
}
