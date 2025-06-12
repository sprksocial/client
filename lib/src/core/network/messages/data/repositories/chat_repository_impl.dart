import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message.dart';
import 'package:sparksocial/src/core/network/messages/data/services/chat_socket_service.dart';
import 'package:sparksocial/src/core/network/messages/data/services/chat_api_service.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final _sl = GetIt.instance;
  final _logger = GetIt.instance<LogService>().getLogger('ChatRepositoryImpl');

  final StreamController<List<Conversation>> _conversationsController = StreamController<List<Conversation>>.broadcast();
  final StreamController<List<ChatMessage>> _messagesController = StreamController<List<ChatMessage>>.broadcast();

  List<Conversation> _conversations = [];
  final Map<String, List<ChatMessage>> _messagesByConversation = {};

  @override
  Stream<List<Conversation>> get conversationsStream => _conversationsController.stream;

  @override
  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;

  @override
  Future<void> initialize() async {
    _logger.i('Initializing chat repository');

    try {
      // Initialize socket connection
      final socketService = ChatSocketService();
      final socket = await socketService.socket;

      // Set up socket event listeners
      _setupSocketListeners(socket);

      // Load initial conversations via REST API
      await _loadInitialConversations();

      _conversationsController.add(_conversations);
      _logger.i('Chat repository initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize chat repository', error: e);
      rethrow;
    }
  }

  void _setupSocketListeners(socket) {
    // Listen for new messages (matching the example's event name)
    socket.on('new-message', (data) {
      _logger.d('Received new message: $data');
      _handleNewMessage(data);
    });

    // Listen for message status updates
    socket.on('message-status-update', (data) {
      _logger.d('Received message status update: $data');
      _handleMessageStatusUpdate(data);
    });

    // Listen for read receipts
    socket.on('message-read', (data) {
      _logger.d('Received message read event: $data');
      _handleMessageRead(data);
    });

    // Listen for chat updates
    socket.on('chat-updated', (data) {
      _logger.d('Received chat update: $data');
      _handleConversationUpdate(data);
    });

    // Listen for connection events
    socket.on('connect', (_) {
      _logger.i('Socket connected successfully');
    });

    socket.on('connect_error', (error) {
      _logger.e('Socket connection error', error: error);
    });
  }

  Future<void> _loadInitialConversations() async {
    try {
      final apiService = ChatApiService();
      final result = await apiService.getChats();

      if (result['data'] != null && result['data']['chats'] != null) {
        final chatsData = result['data']['chats'] as List;
        _conversations = chatsData.map((chatData) => _mapApiChatToConversation(chatData)).toList();
      } else {
        _conversations = [];
      }
    } catch (e) {
      _logger.e('Failed to load initial conversations', error: e);
      _conversations = [];
    }
  }

  Conversation _mapApiChatToConversation(Map<String, dynamic> chatData) {
    // Map the API response to our Conversation model
    // This will need to match the actual API response structure
    return Conversation(
      id: chatData['chatId'] ?? chatData['id'] ?? 'unknown',
      type: chatData['type'] == 'private' ? ConversationType.direct : ConversationType.group,
      participants: (chatData['participants'] as List? ?? [])
          .map(
            (p) => ChatParticipant(
              id: p['id'] ?? p['userId'] ?? 'unknown',
              username: p['username'] ?? p['handle'] ?? 'unknown',
              displayName: p['displayName'] ?? p['name'],
              avatarUrl: p['avatarUrl'] ?? p['avatar'],
              isOnline: p['isOnline'] ?? false,
            ),
          )
          .toList(),
      title: chatData['title'],
      lastActivity: chatData['lastActivity'] != null
          ? DateTime.tryParse(chatData['lastActivity']) ?? DateTime.now()
          : DateTime.now(),
      unreadCount: chatData['unreadCount'] ?? 0,
    );
  }

  void _handleConversationUpdate(Map<String, dynamic> data) {
    try {
      final conversation = _mapApiChatToConversation(data);
      final index = _conversations.indexWhere((c) => c.id == conversation.id);

      if (index != -1) {
        _conversations[index] = conversation;
      } else {
        _conversations.insert(0, conversation);
      }

      _conversationsController.add(_conversations);
    } catch (e) {
      _logger.e('Failed to handle conversation update', error: e);
    }
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      // Map the socket message data to our ChatMessage model
      final message = ChatMessage(
        id: data['messageId'] ?? data['id'] ?? 'unknown',
        conversationId: data['chatId'] ?? data['conversationId'] ?? 'unknown',
        senderId: data['senderId'] ?? data['userId'] ?? 'unknown',
        content: data['text'] ?? data['content'] ?? '',
        type: MessageType.text, // Default to text for now
        status: MessageStatus.delivered,
        timestamp: data['timestamp'] != null ? DateTime.tryParse(data['timestamp']) ?? DateTime.now() : DateTime.now(),
      );

      final conversationId = message.conversationId;

      _messagesByConversation[conversationId] ??= [];
      _messagesByConversation[conversationId]!.add(message);

      // Update conversation with latest message
      final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (conversationIndex != -1) {
        final currentUserDid = _sl<AuthRepository>().session?.did;
        final isFromCurrentUser = message.senderId == currentUserDid;

        _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
          lastMessage: message,
          lastActivity: message.timestamp,
          unreadCount: isFromCurrentUser
              ? _conversations[conversationIndex].unreadCount
              : _conversations[conversationIndex].unreadCount + 1,
        );

        _conversationsController.add(_conversations);
      }

      _messagesController.add(_messagesByConversation[conversationId]!);
    } catch (e) {
      _logger.e('Failed to handle new message', error: e);
    }
  }

  void _handleMessageStatusUpdate(Map<String, dynamic> data) {
    try {
      final messageId = data['messageId'] as String;
      final status = MessageStatus.values.firstWhere((s) => s.name == data['status'], orElse: () => MessageStatus.sent);
      final conversationId = data['chatId'] ?? data['conversationId'] as String;

      final messages = _messagesByConversation[conversationId];
      if (messages != null) {
        final messageIndex = messages.indexWhere((m) => m.id == messageId);
        if (messageIndex != -1) {
          messages[messageIndex] = messages[messageIndex].copyWith(status: status);
          _messagesController.add(messages);
        }
      }
    } catch (e) {
      _logger.e('Failed to handle message status update', error: e);
    }
  }

  void _handleMessageRead(Map<String, dynamic> data) {
    try {
      final conversationId = data['chatId'] ?? data['conversationId'] as String;

      // Update conversation unread count
      final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (conversationIndex != -1) {
        _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(unreadCount: 0);
        _conversationsController.add(_conversations);
      }
    } catch (e) {
      _logger.e('Failed to handle message read event', error: e);
    }
  }

  @override
  Future<List<Conversation>> getConversations() async {
    return List.unmodifiable(_conversations);
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    if (_messagesByConversation.containsKey(conversationId)) {
      return _messagesByConversation[conversationId]!;
    }

    try {
      // Try to get messages via REST API first
      final apiService = ChatApiService();
      final result = await apiService.getChatMessages(conversationId);

      if (result['data'] != null && result['data']['messages'] != null) {
        final messagesData = result['data']['messages'] as List;
        final messages = messagesData
            .map(
              (msgData) => ChatMessage(
                id: msgData['messageId'] ?? msgData['id'] ?? 'unknown',
                conversationId: conversationId,
                senderId: msgData['senderId'] ?? msgData['userId'] ?? 'unknown',
                content: msgData['text'] ?? msgData['content'] ?? '',
                type: MessageType.text,
                status: MessageStatus.delivered,
                timestamp: msgData['timestamp'] != null
                    ? DateTime.tryParse(msgData['timestamp']) ?? DateTime.now()
                    : DateTime.now(),
              ),
            )
            .toList();

        _messagesByConversation[conversationId] = messages;
        return messages;
      }

      // Fallback to socket request
      final socketService = ChatSocketService();
      final socket = await socketService.socket;

      socket.emit('join-chat', {'chatId': conversationId, 'userId': socket.id});

      // For now, return empty list and wait for socket response
      _messagesByConversation[conversationId] = [];
      return [];
    } catch (e) {
      _logger.e('Failed to get messages for conversation $conversationId', error: e);
      return [];
    }
  }

  @override
  Future<Conversation?> getConversation(String conversationId) async {
    try {
      return _conversations.firstWhere((c) => c.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> sendMessage({required String conversationId, required String content, MessageType type = MessageType.text}) async {
    final authRepository = _sl<AuthRepository>();
    if (!authRepository.isAuthenticated || authRepository.session == null) {
      throw Exception('Not authenticated. Cannot send message.');
    }

    final userDid = authRepository.session!.did;

    // Create optimistic message
    final message = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: userDid,
      content: content,
      type: type,
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
    );

    // Add to local messages immediately
    _messagesByConversation[conversationId] ??= [];
    _messagesByConversation[conversationId]!.add(message);

    // Update conversation
    final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (conversationIndex != -1) {
      _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
        lastMessage: message,
        lastActivity: DateTime.now(),
      );
      _conversationsController.add(_conversations);
    }

    _messagesController.add(_messagesByConversation[conversationId]!);

    try {
      // Send via socket using the event name from the example
      final socketService = ChatSocketService();
      final socket = await socketService.socket;

      socket.emit('send-message', {'chatId': conversationId, 'senderId': userDid, 'text': content, 'tempId': message.id});

      _logger.i('Message sent successfully');
    } catch (e) {
      // Update message status to failed
      final messageIndex = _messagesByConversation[conversationId]!.length - 1;
      _messagesByConversation[conversationId]![messageIndex] = message.copyWith(status: MessageStatus.failed);

      _messagesController.add(_messagesByConversation[conversationId]!);

      _logger.e('Failed to send message', error: e);
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    try {
      // Send via socket
      final socketService = ChatSocketService();
      final socket = await socketService.socket;

      socket.emit('mark-as-read', {'chatId': conversationId});

      // Update local state immediately
      final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (conversationIndex != -1) {
        _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(unreadCount: 0);
        _conversationsController.add(_conversations);
      }

      _logger.i('Marked conversation $conversationId as read');
    } catch (e) {
      _logger.e('Failed to mark conversation as read', error: e);
      rethrow;
    }
  }

  @override
  Future<Conversation> createOrGetConversation(Conversation newConversation) async {
    final currentUserDid = _sl<AuthRepository>().session?.did ?? 'current_user_id';
    final otherParticipant = newConversation.participants.firstWhere(
      (p) => p.id != currentUserDid,
      orElse: () => newConversation.participants.first,
    );

    // Check for existing conversation
    final existingConversation = _conversations.cast<Conversation?>().firstWhere(
      (c) => c != null && c.type == ConversationType.direct && c.participants.any((p) => p.id == otherParticipant.id),
      orElse: () => null,
    );

    if (existingConversation != null) {
      return existingConversation;
    }

    try {
      // Create via REST API first
      final apiService = ChatApiService();
      final participantIds = newConversation.participants.map((p) => p.id).toList();

      final result = await apiService.createChat(
        type: newConversation.type == ConversationType.direct ? 'private' : 'group',
        participantIds: participantIds,
      );

      // Extract the chat ID from the API response
      final chatId = result['data']?['chatId'] ?? result['data']?['id'];
      if (chatId == null) {
        throw Exception('No chat ID returned from API');
      }

      // Create the conversation with the server-provided ID
      final dmConversation = newConversation.copyWith(id: chatId, lastActivity: DateTime.now(), unreadCount: 0);

      // Add to local state
      _conversations.insert(0, dmConversation);
      _messagesByConversation[dmConversation.id] = [];

      _conversationsController.add(_conversations);

      // Join the chat via socket
      final socketService = ChatSocketService();
      final socket = await socketService.socket;

      socket.emit('join-chat', {'chatId': chatId, 'userId': currentUserDid});

      _logger.i('Created new conversation with ${otherParticipant.displayName ?? otherParticipant.username}');

      return dmConversation;
    } catch (e) {
      _logger.e('Failed to create conversation', error: e);
      rethrow;
    }
  }

  @override
  void dispose() {
    _logger.i('Disposing chat repository');
    _conversationsController.close();
    _messagesController.close();

    // Dispose socket service
    final socketService = ChatSocketService();
    socketService.dispose();
  }
}
