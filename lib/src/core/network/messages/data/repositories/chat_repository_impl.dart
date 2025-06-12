import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message.dart';
import 'package:sparksocial/src/core/network/messages/data/services/chat_socket_service.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final _sl = GetIt.instance;
  final _logger = GetIt.instance<LogService>().getLogger('ChatRepositoryImpl');

  final StreamController<List<Conversation>> _conversationsController =
    StreamController<List<Conversation>>.broadcast();
  final StreamController<List<ChatMessage>> _messagesController =
    StreamController<List<ChatMessage>>.broadcast();

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

      // Load initial conversations
      await _loadInitialConversations();

      _conversationsController.add(_conversations);
      _logger.i('Chat repository initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize chat repository', error: e);
      rethrow;
    }
  }

  void _setupSocketListeners(socket) {
    // Listen for new conversations
    socket.on('conversation_update', (data) {
      _logger.d('Received conversation update: $data');
      _handleConversationUpdate(data);
    });

    // Listen for new messages
    socket.on('new_message', (data) {
      _logger.d('Received new message: $data');
      _handleNewMessage(data);
    });

    // Listen for message status updates
    socket.on('message_status_update', (data) {
      _logger.d('Received message status update: $data');
      _handleMessageStatusUpdate(data);
    });

    // Listen for read receipts
    socket.on('message_read', (data) {
      _logger.d('Received message read event: $data');
      _handleMessageRead(data);
    });
  }

  Future<void> _loadInitialConversations() async {
    // For now, we'll start with empty conversations
    // In a real implementation, you would load from local storage or API
    _conversations = [];
  }

  void _handleConversationUpdate(Map<String, dynamic> data) {
    try {
      final conversation = Conversation.fromJson(data);
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
      final message = ChatMessage.fromJson(data);
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
          unreadCount: isFromCurrentUser ?
            _conversations[conversationIndex].unreadCount :
            _conversations[conversationIndex].unreadCount + 1,
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
      final status = MessageStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => MessageStatus.sent,
      );
      final conversationId = data['conversationId'] as String;

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
      final conversationId = data['conversationId'] as String;

      // Update conversation unread count
      final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (conversationIndex != -1) {
        _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
          unreadCount: 0,
        );
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
      // Request messages from socket
      final socketService = ChatSocketService();
      final socket = await socketService.socket;

      // Emit request for messages
      socket.emit('get_messages', {'conversationId': conversationId});

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
  Future<void> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
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
      // Send via socket
      final socketService = ChatSocketService();
      final socket = await socketService.socket;

      socket.emit('send_message', {
        'conversationId': conversationId,
        'content': content,
        'type': type.name,
        'tempId': message.id,
      });

      _logger.i('Message sent successfully');
    } catch (e) {
      // Update message status to failed
      final messageIndex = _messagesByConversation[conversationId]!.length - 1;
      _messagesByConversation[conversationId]![messageIndex] =
        message.copyWith(status: MessageStatus.failed);

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

      socket.emit('mark_as_read', {'conversationId': conversationId});

      // Update local state immediately
      final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (conversationIndex != -1) {
        _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
          unreadCount: 0,
        );
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
      (c) => c != null &&
             c.type == ConversationType.direct &&
             c.participants.any((p) => p.id == otherParticipant.id),
      orElse: () => null,
    );

    if (existingConversation != null) {
      return existingConversation;
    }

    // Create new conversation
    final dmConversation = newConversation.copyWith(
      lastActivity: DateTime.now(),
      unreadCount: 0,
    );

    try {
      // Create via socket
      final socketService = ChatSocketService();
      final socket = await socketService.socket;

      socket.emit('create_conversation', {
        'type': dmConversation.type.name,
        'participants': dmConversation.participants.map((p) => p.toJson()).toList(),
        'tempId': dmConversation.id,
      });

      // Add to local state immediately
      _conversations.insert(0, dmConversation);
      _messagesByConversation[dmConversation.id] = [];

      _conversationsController.add(_conversations);

      _logger.i('Created new DM conversation with ${otherParticipant.displayName ?? otherParticipant.username}');

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
  }
}