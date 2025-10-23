import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message_models.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/ui/foundation/colors.dart';
import 'package:sparksocial/src/core/ui/widgets/user_avatar.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/messages/providers/conversation_provider.dart';
import 'package:sparksocial/src/features/messages/providers/polling_timer.dart';
import 'package:sparksocial/src/features/messages/ui/widgets/message_input.dart';
import 'package:sparksocial/src/features/messages/ui/widgets/messages_list.dart';

@RoutePage()
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({required this.otherUserDid, super.key, this.otherUserHandle, this.otherUserDisplayName, this.otherUserAvatar});
  final String otherUserDid;
  final String? otherUserHandle;
  final String? otherUserDisplayName;
  final String? otherUserAvatar;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  String? _currentUserDid;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() {
    _currentUserDid = ref.read(sessionProvider)?.did;
  }

  String _getConversationTitle() {
    return widget.otherUserDisplayName ?? widget.otherUserHandle ?? 'Chat';
  }

  List<String> _extractLinks(String text) {
    final urlRegex = RegExp(
      r'https?://(?:www\.)?[a-zA-Z0-9-]+(?:\.[a-zA-Z]+)+\S*|www\.[a-zA-Z0-9-]+(?:\.[a-zA-Z]+)+\S*',
      caseSensitive: false,
    );
    return urlRegex.allMatches(text).map((match) => match.group(0)!).toList();
  }

  Future<void> _sendMessage() async {
    var content = _messageController.text.trim();
    final links = _extractLinks(content);

    // remove links from content
    for (final link in links) {
      content = content.replaceAll(link, '');
    }
    content = content.trim(); // Remove extra whitespace after link removal

    final linkEmbeds = <Embed>[];
    for (final link in links) {
      linkEmbeds.add(Embed(type: 'link', url: link, preview: link));
    }

    if (content.isEmpty && linkEmbeds.isEmpty) return;

    _messageController.clear();

    try {
      final chatService = ref.read(conversationProvider(widget.otherUserDid).notifier);
      await chatService.sendMessage(widget.otherUserDid, content, embed: linkEmbeds.isNotEmpty ? linkEmbeds : null);

      // No need to manage local state since the provider handles it
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationProvider(widget.otherUserDid));
    ref.listen(pollingTriggerProvider(widget.otherUserDid), (previous, next) {});
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => context.router.push(ProfileRoute(did: widget.otherUserDid)),
          child: Row(
            children: [
              UserAvatar(
                imageUrl: widget.otherUserAvatar ?? '',
                username: widget.otherUserHandle ?? 'User',
                size: 36,
                backgroundColor: getAvatarColor((widget.otherUserHandle ?? 'User').hashCode),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getConversationTitle(),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '@${widget.otherUserHandle ?? 'user'}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(178), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: Icon(FluentIcons.more_vertical_24_regular, color: Theme.of(context).colorScheme.onSurface),
        //   ),
        // ],
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(height: 0.5, width: double.infinity, color: Theme.of(context).colorScheme.outline),
          Expanded(
            child: state.when(
              data: (data) => MessagesList(
                messages: data.messages,
                scrollController: _scrollController,
                currentUserDid: _currentUserDid,
                otherUserHandle: widget.otherUserHandle,
                otherUserAvatar: widget.otherUserAvatar,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FluentIcons.error_circle_24_regular, size: 48, color: Theme.of(context).colorScheme.error),
                      const SizedBox(height: 16),
                      Text('Failed to load messages', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(conversationProvider(widget.otherUserDid)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
            otherDid: widget.otherUserDid,
            imagePicker: _imagePicker,
          ),
        ],
      ),
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
