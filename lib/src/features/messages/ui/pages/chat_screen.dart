import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/widgets/user_avatar.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';

class ChatPage extends ConsumerStatefulWidget {
  final Conversation conversation;

  const ChatPage({super.key, required this.conversation});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  String? _currentUserDid;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _loadMessages();
    _markAsRead();
  }

  void _initializeUser() {
    _currentUserDid = ref.read(authProvider).session?.did;
  }

  String _getConversationTitle() {
    if (widget.conversation.title != null && widget.conversation.title!.isNotEmpty) {
      return widget.conversation.title!;
    }

    if (widget.conversation.type == ConversationType.direct && widget.conversation.participants.length == 2) {
      final otherParticipant = widget.conversation.participants.firstWhere(
        (p) => p.id != _currentUserDid,
        orElse: () => widget.conversation.participants.first,
      );
      return otherParticipant.displayName ?? otherParticipant.username;
    }

    if (widget.conversation.participants.length > 1) {
      final names = widget.conversation.participants
          .where((p) => p.id != _currentUserDid)
          .take(3)
          .map((p) => p.displayName ?? p.username)
          .join(', ');
      final otherParticipantsCount = widget.conversation.participants.where((p) => p.id != _currentUserDid).length;
      if (otherParticipantsCount > 3) {
        return '$names and ${otherParticipantsCount - 3} more';
      }
      return names;
    }

    return 'Conversation';
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _chatService.getMessages(widget.conversation.id);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead() async {
    await _chatService.markAsRead(widget.conversation.id);
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    await _chatService.sendMessage(widget.conversation.id, content);
    _loadMessages();
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            ConversationAvatar(conversation: widget.conversation, currentUserDid: _currentUserDid),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getConversationTitle(),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (widget.conversation.type == ConversationType.direct)
                    Text(_getOnlineStatus(), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12)),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : MessagesList(
                    messages: _messages,
                    scrollController: _scrollController,
                    currentUserDid: _currentUserDid,
                    conversation: widget.conversation,
                  ),
          ),
          MessageInput(controller: _messageController, onSend: _sendMessage),
        ],
      ),
    );
  }

  String _getOnlineStatus() {
    if (widget.conversation.type != ConversationType.direct) return '';

    final otherParticipant = widget.conversation.participants.firstWhere(
      (p) => p.id != _currentUserDid,
      orElse: () => widget.conversation.participants.first,
    );

    if (otherParticipant.isOnline) {
      return 'Online';
    } else if (otherParticipant.lastSeen != null) {
      final difference = DateTime.now().difference(otherParticipant.lastSeen!);
      if (difference.inMinutes < 60) {
        return 'Last seen ${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return 'Last seen ${difference.inHours}h ago';
      } else {
        return 'Last seen ${difference.inDays}d ago';
      }
    }

    return 'Offline';
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

class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({super.key, required this.conversation, required this.currentUserDid});

  final Conversation conversation;
  final String? currentUserDid;

  @override
  Widget build(BuildContext context) {
    if (conversation.type == ConversationType.direct) {
      final otherParticipant = conversation.participants.firstWhere(
        (p) => p.id != currentUserDid,
        orElse: () => conversation.participants.first,
      );

      return UserAvatar(
        imageUrl: otherParticipant.avatarUrl,
        username: otherParticipant.username,
        size: 36,
        backgroundColor: getAvatarColor(otherParticipant.username.hashCode),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(shape: BoxShape.circle, color: getAvatarColor(conversation.id.hashCode)),
      child: const Icon(FluentIcons.people_16_filled, color: Colors.white, size: 18),
    );
  }
}

class SenderAvatar extends StatelessWidget {
  const SenderAvatar({super.key, required this.conversation, required this.senderId});

  final Conversation conversation;
  final String senderId;

  @override
  Widget build(BuildContext context) {
    final participant = conversation.participants.firstWhere(
      (p) => p.id == senderId,
      orElse: () => conversation.participants.first,
    );

    return UserAvatar(
      imageUrl: participant.avatarUrl,
      username: participant.username,
      size: 32,
      backgroundColor: getAvatarColor(participant.username.hashCode),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.showAvatar,
    required this.conversation,
  });

  final ChatMessage message;
  final bool isCurrentUser;
  final bool showAvatar;
  final Conversation conversation;

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
            SenderAvatar(conversation: conversation, senderId: message.senderId),
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
                message.content,
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
    required this.conversation,
  });

  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final String? currentUserDid;
  final Conversation conversation;

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
        final isCurrentUser = message.senderId == currentUserDid;
        final showAvatar = !isCurrentUser && (index == messages.length - 1 || messages[index + 1].senderId != message.senderId);

        return MessageBubble(message: message, isCurrentUser: isCurrentUser, showAvatar: showAvatar, conversation: conversation);
      },
    );
  }
}

class MessageInput extends StatelessWidget {
  const MessageInput({super.key, required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

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
                onPressed: onSend,
                icon: const Icon(FluentIcons.send_24_filled, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
