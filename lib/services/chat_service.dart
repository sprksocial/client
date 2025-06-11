import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import 'auth_service.dart';
import 'sprk_client.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final StreamController<List<Conversation>> _conversationsController = StreamController<List<Conversation>>.broadcast();
  final StreamController<List<ChatMessage>> _messagesController = StreamController<List<ChatMessage>>.broadcast();
  
  List<Conversation> _conversations = [];
  final Map<String, List<ChatMessage>> _messagesByConversation = {};
  
  AuthService? _authService;
  SprkClient? _client;

  Stream<List<Conversation>> get conversationsStream => _conversationsController.stream;
  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;

  List<Conversation> get conversations => List.unmodifiable(_conversations);

  void setAuthService(AuthService authService) {
    _authService = authService;
    _client = SprkClient(authService);
  }

  Future<void> initialize() async {
    _conversationsController.add(_conversations);
  }

  Future<List<Conversation>> getConversations() async {
    if (_client == null) {
      return _conversations;
    }

    try {
      final response = await _client!.chat.getConversations();
      return _conversations;
    } catch (e) {
      debugPrint('Failed to fetch conversations from API: $e');
      return _conversations;
    }
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    if (_client == null) {
      return _messagesByConversation[conversationId] ?? [];
    }

    try {
      final response = await _client!.chat.getMessages(conversationId);
      return _messagesByConversation[conversationId] ?? [];
    } catch (e) {
      debugPrint('Failed to fetch messages from API: $e');
      return _messagesByConversation[conversationId] ?? [];
    }
  }

  Future<Conversation?> getConversation(String conversationId) async {
    try {
      return _conversations.firstWhere((c) => c.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  Future<void> sendMessage(String conversationId, String content, {MessageType type = MessageType.text}) async {
    if (_authService == null || !_authService!.isAuthenticated) {
      throw Exception('Not authenticated. Cannot send message.');
    }

    if (_client == null) {
      throw Exception('Chat client not initialized');
    }

    final userDid = _authService!.session?.did ?? 'current_user_id';
    
    final message = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: userDid,
      content: content,
      type: type,
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
    );

    _messagesByConversation[conversationId] ??= [];
    _messagesByConversation[conversationId]!.add(message);

    final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (conversationIndex != -1) {
      _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
        lastMessage: message,
        lastActivity: DateTime.now(),
      );
    }

    _conversationsController.add(_conversations);
    _messagesController.add(_messagesByConversation[conversationId]!);

    try {
      final response = await _client!.chat.sendMessage(
        conversationId: conversationId,
        content: content,
        messageType: type.name,
      );

      if (response.status.code == 200) {
        final sentMessage = message.copyWith(
          id: response.data.uri.toString(),
          status: MessageStatus.sent,
        );
        
        final messageIndex = _messagesByConversation[conversationId]!.length - 1;
        _messagesByConversation[conversationId]![messageIndex] = sentMessage;
        
        _messagesController.add(_messagesByConversation[conversationId]!);
      } else {
        throw Exception('Failed to send message: ${response.status.code}');
      }
    } catch (e) {
      final failedMessage = message.copyWith(status: MessageStatus.failed);
      final messageIndex = _messagesByConversation[conversationId]!.length - 1;
      _messagesByConversation[conversationId]![messageIndex] = failedMessage;
      
      _messagesController.add(_messagesByConversation[conversationId]!);
      
      debugPrint('Failed to send message: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String conversationId) async {
    if (_client != null) {
      try {
        await _client!.chat.markAsRead(conversationId);
      } catch (e) {
        debugPrint('Failed to mark as read via API: $e');
      }
    }

    final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (conversationIndex != -1) {
      _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(unreadCount: 0);
      _conversationsController.add(_conversations);
    }
  }

  Future<Conversation> createOrGetConversation(Conversation newConversation) async {
    final currentUserDid = _authService?.session?.did ?? 'current_user_id';
    final otherParticipant = newConversation.participants.firstWhere(
      (p) => p.id != currentUserDid,
      orElse: () => newConversation.participants.first,
    );

    final existingConversation = _conversations.cast<Conversation?>().firstWhere(
      (c) => c != null && 
             c.type == ConversationType.direct && 
             c.participants.any((p) => p.id == otherParticipant.id),
      orElse: () => null,
    );

    if (existingConversation != null) {
      return existingConversation;
    }

    final dmConversation = newConversation.copyWith(
      lastActivity: DateTime.now(),
      unreadCount: 0,
    );

    _conversations.insert(0, dmConversation);
    _messagesByConversation[dmConversation.id] = [];
    
    _conversationsController.add(_conversations);
    
    debugPrint('Created new DM conversation with ${otherParticipant.displayName ?? otherParticipant.username}');
    
    return dmConversation;
  }





  void dispose() {
    _conversationsController.close();
    _messagesController.close();
  }
} 