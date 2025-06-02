import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../widgets/common/user_avatar.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markAsRead();
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
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: Row(
          children: [
            _buildConversationAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.displayTitle,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (widget.conversation.type == ConversationType.direct)
                    Text(
                      _getOnlineStatus(),
                      style: TextStyle(
                        color: AppTheme.getSecondaryTextColor(context),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              FluentIcons.more_vertical_24_regular,
              color: AppTheme.getTextColor(context),
            ),
          ),
        ],
        backgroundColor: isDarkMode ? Colors.black : AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            height: 0.5,
            width: double.infinity,
            color: isDarkMode ? AppColors.divider.withAlpha(51) : AppColors.divider.withAlpha(128),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMessagesList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildConversationAvatar() {
    if (widget.conversation.type == ConversationType.direct) {
      final otherParticipant = widget.conversation.participants.firstWhere(
        (p) => p.id != 'current_user_id',
        orElse: () => widget.conversation.participants.first,
      );

      return UserAvatar(
        imageUrl: otherParticipant.avatarUrl,
        username: otherParticipant.username,
        size: 36,
        backgroundColor: _getAvatarColor(otherParticipant.username.hashCode),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getAvatarColor(widget.conversation.id.hashCode),
      ),
      child: const Icon(
        FluentIcons.people_16_filled,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  String _getOnlineStatus() {
    if (widget.conversation.type != ConversationType.direct) return '';
    
    final otherParticipant = widget.conversation.participants.firstWhere(
      (p) => p.id != 'current_user_id',
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

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FluentIcons.chat_24_regular,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message to start the conversation',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isCurrentUser = message.senderId == 'current_user_id';
        final showAvatar = !isCurrentUser && (index == _messages.length - 1 || 
            _messages[index + 1].senderId != message.senderId);

        return _buildMessageBubble(message, isCurrentUser, showAvatar);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isCurrentUser, bool showAvatar) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser && showAvatar) ...[
            _buildSenderAvatar(message.senderId),
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

  Widget _buildSenderAvatar(String senderId) {
    final participant = widget.conversation.participants.firstWhere(
      (p) => p.id == senderId,
      orElse: () => widget.conversation.participants.first,
    );

    return UserAvatar(
      imageUrl: participant.avatarUrl,
      username: participant.username,
      size: 32,
      backgroundColor: _getAvatarColor(participant.username.hashCode),
    );
  }

  Widget _buildMessageInput() {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                style: TextStyle(color: AppTheme.getTextColor(context)),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(
                  FluentIcons.send_24_filled,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(int seed) {
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
} 