import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/chat/data/models/models.dart';
import 'package:sparksocial/src/features/messages/providers/chat_service_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'chat_websocket_provider.g.dart';

@riverpod
class ChatWebSocket extends _$ChatWebSocket {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  @override
  ChatWebSocketState build() {
    // Clean up when provider is disposed
    ref.onDispose(() {
      _subscription?.cancel();
      _channel?.sink.close();
    });

    return const ChatWebSocketState();
  }

  /// Connect to WebSocket for real-time messaging
  void connect() async {
    if (state.isConnected || state.isConnecting) return;

    state = state.copyWith(isConnecting: true, error: null);

    try {
      final chatService = ref.read(chatServiceProvider.notifier);
      _channel = chatService.connectWebSocket();

      // Listen to incoming messages
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnected,
      );

      state = state.copyWith(isConnecting: false, isConnected: true);
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        isConnected: false,
        error: 'Failed to connect: ${e.toString()}',
      );
    }
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _subscription?.cancel();
    _subscription = null;

    _channel?.sink.close();
    _channel = null;

    final chatService = ref.read(chatServiceProvider.notifier);
    chatService.closeWebSocket();

    state = state.copyWith(isConnected: false, isConnecting: false);
  }

  /// Handle incoming WebSocket messages
  void _onMessage(dynamic data) {
    try {
      final jsonData = jsonDecode(data) as Map<String, dynamic>;
      final wsMessage = WebSocketMessage.fromJson(jsonData);

      state = state.copyWith(lastMessage: wsMessage);

      // You can add specific message type handling here
      switch (wsMessage.type) {
        case WebSocketMessageType.newMessage:
          // Handle new message
          _handleNewMessage(wsMessage.data);
          break;
        case WebSocketMessageType.messageRead:
          // Handle message read status
          break;
        case WebSocketMessageType.typing:
          // Handle typing indicators
          break;
        case WebSocketMessageType.error:
          state = state.copyWith(error: wsMessage.error);
          break;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to parse message: ${e.toString()}');
    }
  }

  /// Handle new message from WebSocket
  void _handleNewMessage(WebSocketMessageData? messageData) {
    if (messageData == null) return;

    // Convert WebSocket message to ChatMessage
    final chatMessage = ChatMessage(
      id: messageData.id,
      message: messageData.message,
      senderDid: messageData.senderDid,
      receiverDid: messageData.receiverDid,
      timestamp: messageData.timestamp,
    );

    // Add to recent messages list
    final updatedMessages = [...state.recentMessages, chatMessage];
    // Keep only last 100 messages to avoid memory issues
    if (updatedMessages.length > 100) {
      updatedMessages.removeAt(0);
    }

    state = state.copyWith(recentMessages: updatedMessages);
  }

  /// Handle WebSocket errors
  void _onError(error) {
    state = state.copyWith(
      isConnected: false,
      error: 'WebSocket error: ${error.toString()}',
    );
  }

  /// Handle WebSocket disconnection
  void _onDisconnected() {
    state = state.copyWith(isConnected: false);
  }

  /// Send a message through WebSocket (if needed for real-time features)
  void sendWebSocketMessage(Map<String, dynamic> message) {
    if (!state.isConnected || _channel == null) {
      throw Exception('WebSocket not connected');
    }

    _channel!.sink.add(jsonEncode(message));
  }
}

/// State for WebSocket connection
class ChatWebSocketState {
  final bool isConnecting;
  final bool isConnected;
  final String? error;
  final WebSocketMessage? lastMessage;
  final List<ChatMessage> recentMessages;

  const ChatWebSocketState({
    this.isConnecting = false,
    this.isConnected = false,
    this.error,
    this.lastMessage,
    this.recentMessages = const [],
  });

  ChatWebSocketState copyWith({
    bool? isConnecting,
    bool? isConnected,
    String? error,
    WebSocketMessage? lastMessage,
    List<ChatMessage>? recentMessages,
  }) {
    return ChatWebSocketState(
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
      error: error,
      lastMessage: lastMessage ?? this.lastMessage,
      recentMessages: recentMessages ?? this.recentMessages,
    );
  }
}