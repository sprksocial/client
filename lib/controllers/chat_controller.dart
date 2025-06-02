import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';

class ChatController extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  List<Conversation> _conversations = [];
  Map<String, List<ChatMessage>> _messagesByConversation = {};
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => List.unmodifiable(_conversations);
  bool get isLoading => _isLoading;
  String? get error => _error;

  StreamSubscription<List<Conversation>>? _conversationsSubscription;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  ChatController() {
    _initialize();
  }

  Future<void> _initialize() async {
    _setLoading(true);
    try {
      await _chatService.initialize();
      _conversations = await _chatService.getConversations();
      
      _conversationsSubscription = _chatService.conversationsStream.listen((conversations) {
        _conversations = conversations;
        notifyListeners();
      });

      _messagesSubscription = _chatService.messagesStream.listen((messages) {
        if (messages.isNotEmpty) {
          final conversationId = messages.first.conversationId;
          _messagesByConversation[conversationId] = messages;
          notifyListeners();
        }
      });

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> refreshConversations() async {
    try {
      _conversations = await _chatService.getConversations();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    if (_messagesByConversation.containsKey(conversationId)) {
      return _messagesByConversation[conversationId]!;
    }

    try {
      final messages = await _chatService.getMessages(conversationId);
      _messagesByConversation[conversationId] = messages;
      return messages;
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  Future<void> sendMessage(String conversationId, String content, {MessageType type = MessageType.text}) async {
    try {
      await _chatService.sendMessage(conversationId, content, type: type);
      final messages = await _chatService.getMessages(conversationId);
      _messagesByConversation[conversationId] = messages;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await _chatService.markAsRead(conversationId);
      final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (conversationIndex != -1) {
        _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(unreadCount: 0);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Conversation? getConversation(String conversationId) {
    try {
      return _conversations.firstWhere((c) => c.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  List<Conversation> getUnreadConversations() {
    return _conversations.where((c) => c.hasUnreadMessages).toList();
  }

  List<Conversation> getPinnedConversations() {
    return _conversations.where((c) => c.isPinned).toList();
  }

  int get totalUnreadCount {
    return _conversations.fold(0, (sum, conversation) => sum + conversation.unreadCount);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    _chatService.dispose();
    super.dispose();
  }
} 