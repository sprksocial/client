import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/network/chat/data/models/models.dart';
import 'package:sparksocial/src/core/network/chat/data/repositories/chat_repository.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'chat_service_provider.g.dart';

@riverpod
class ChatService extends _$ChatService {
  late final ChatRepository _chatRepository;
  late final AuthRepository _authRepository;
  late final SparkLogger _logger;

  @override
  ChatServiceState build() {
    _chatRepository = GetIt.instance<ChatRepository>();
    _authRepository = GetIt.instance<AuthRepository>();
    _logger = GetIt.instance<LogService>().getLogger('ChatService');

    _logger.v('ChatService provider initialized');
    _initializeAuth();

    return const ChatServiceState();
  }

  /// Initialize authentication for chat service
  void _initializeAuth() {
    if (_authRepository.isAuthenticated && _authRepository.session?.accessJwt != null) {
      _chatRepository.setAuthToken(_authRepository.session!.accessJwt);
      _logger.d('Chat service authenticated with existing session');
    }
  }

  /// Ensure the service is authenticated before making requests
  void _ensureAuthenticated() {
    if (!_authRepository.isAuthenticated) {
      throw Exception('User not authenticated. Please log in first.');
    }

    final accessJwt = _authRepository.session?.accessJwt;
    if (accessJwt == null) {
      throw Exception('No access token available. Please log in again.');
    }

    _chatRepository.setAuthToken(accessJwt);
  }

  /// Send a message to another user
  Future<SendMessageResponse> sendMessage(String message, String receiverDid) async {
    _logger.d('Sending message via ChatService to: $receiverDid');
    _ensureAuthenticated();

    state = state.copyWith(isSending: true, error: null);

    try {
      final response = await _chatRepository.sendMessage(message, receiverDid);
      state = state.copyWith(isSending: false);
      return response;
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
      rethrow;
    }
  }

  /// Get messages for a conversation with another user
  Future<GetMessagesResponse> getMessages(String otherDid, {int limit = 50}) async {
    _logger.d('Getting messages via ChatService for: $otherDid');
    _ensureAuthenticated();

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _chatRepository.getMessages(otherDid, limit: limit);
      state = state.copyWith(isLoading: false);
      return response;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Get list of all chats (conversations) for the current user
  Future<GetChatsResponse> getChats() async {
    _logger.d('Getting chats list via ChatService');
    _ensureAuthenticated();

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _chatRepository.getChats();
      state = state.copyWith(isLoading: false);
      return response;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Connect to WebSocket for real-time messaging
  WebSocketChannel connectWebSocket() {
    _logger.d('Connecting to WebSocket via ChatService');
    _ensureAuthenticated();

    try {
      state = state.copyWith(isConnecting: true, error: null);
      final channel = _chatRepository.connectWebSocket();
      state = state.copyWith(isConnecting: false, isConnected: true);
      return channel;
    } catch (e) {
      state = state.copyWith(isConnecting: false, error: e.toString());
      rethrow;
    }
  }

  /// Check the health status of the chat service
  Future<HealthCheckResponse> healthCheck() async {
    _logger.d('Performing health check via ChatService');
    // Health check doesn't require authentication
    return _chatRepository.healthCheck();
  }

  /// Close any open WebSocket connections
  void closeWebSocket() {
    _logger.d('Closing WebSocket via ChatService');
    _chatRepository.closeWebSocket();
    state = state.copyWith(isConnected: false);
  }

  /// Get the current user's DID
  String? get currentUserDid => _authRepository.session?.did;

  /// Check if the service is authenticated
  bool get isAuthenticated => _authRepository.isAuthenticated;
}

/// State class for the ChatService
class ChatServiceState {
  final bool isLoading;
  final bool isSending;
  final bool isConnecting;
  final bool isConnected;
  final String? error;

  const ChatServiceState({
    this.isLoading = false,
    this.isSending = false,
    this.isConnecting = false,
    this.isConnected = false,
    this.error,
  });

  ChatServiceState copyWith({
    bool? isLoading,
    bool? isSending,
    bool? isConnecting,
    bool? isConnected,
    String? error,
  }) {
    return ChatServiceState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
      error: error,
    );
  }
}