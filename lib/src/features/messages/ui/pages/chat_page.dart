import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message_models.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/widgets/user_avatar.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/messages/providers/conversation_provider.dart';

@RoutePage()
class ChatPage extends ConsumerStatefulWidget {
  final String otherUserDid;
  final String? otherUserHandle;
  final String? otherUserDisplayName;
  final String? otherUserAvatar;

  const ChatPage({super.key, required this.otherUserDid, this.otherUserHandle, this.otherUserDisplayName, this.otherUserAvatar});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
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

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    try {
      final chatService = ref.read(conversationProvider(widget.otherUserDid).notifier);
      final response = await chatService.sendMessage(content, widget.otherUserDid);

      // Add the sent message to local list
      final sentMessage = Message(
        id: response.id,
        message: content,
        senderDid: _currentUserDid!,
        receiverDid: widget.otherUserDid,
        timestamp: response.timestamp,
      );

      setState(() {
        _messages = [..._messages, sentMessage];
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: ${e.toString()}')));
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            UserAvatar(
              imageUrl: widget.otherUserAvatar,
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
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(FluentIcons.more_vertical_24_regular, color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
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
          MessageInput(controller: _messageController, onSend: _sendMessage),
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

// -------------------------  EXTRACTED WIDGETS  -------------------------

class SenderAvatar extends StatelessWidget {
  const SenderAvatar({super.key, required this.isCurrentUser, required this.otherUserAvatar, required this.otherUserHandle});

  final bool isCurrentUser;
  final String? otherUserAvatar;
  final String? otherUserHandle;

  @override
  Widget build(BuildContext context) {
    if (isCurrentUser) {
      return UserAvatar(
        imageUrl: null, // Current user avatar - can be added later
        username: 'You',
        size: 32,
        backgroundColor: AppColors.primary,
      );
    }

    return UserAvatar(
      imageUrl: otherUserAvatar,
      username: otherUserHandle ?? 'User',
      size: 32,
      backgroundColor: getAvatarColor((otherUserHandle ?? 'User').hashCode),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.showAvatar,
    required this.otherUserAvatar,
    required this.otherUserHandle,
  });

  final Message message;
  final bool isCurrentUser;
  final bool showAvatar;
  final String? otherUserAvatar;
  final String? otherUserHandle;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser && showAvatar) ...[
            SenderAvatar(isCurrentUser: false, otherUserAvatar: otherUserAvatar, otherUserHandle: otherUserHandle),
            const SizedBox(width: 8),
          ] else if (!isCurrentUser) ...[
            const SizedBox(width: 40),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? AppColors.primary
                    : isDarkMode
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.message,
                style: TextStyle(
                  color: isCurrentUser
                      ? Colors.white
                      : isDarkMode
                      ? Colors.white
                      : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessagesList extends StatelessWidget {
  const MessagesList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.currentUserDid,
    required this.otherUserHandle,
    required this.otherUserAvatar,
  });

  final List<Message> messages;
  final ScrollController scrollController;
  final String? currentUserDid;
  final String? otherUserHandle;
  final String? otherUserAvatar;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.chat_24_regular, size: 64, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message to start the conversation',
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isCurrentUser = message.senderDid == currentUserDid;
        final showAvatar = !isCurrentUser && (index == messages.length - 1 || messages[index + 1].senderDid != message.senderDid);

        return MessageBubble(
          message: message,
          isCurrentUser: isCurrentUser,
          showAvatar: showAvatar,
          otherUserAvatar: otherUserAvatar,
          otherUserHandle: otherUserHandle,
        );
      },
    );
  }
}

class MessageInput extends StatelessWidget {
  const MessageInput({super.key, required this.controller, required this.onSend, this.isLoading = false});

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline, width: 0.5)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: IconButton(
                onPressed: isLoading ? null : onSend,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : const Icon(FluentIcons.send_24_filled, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
