import 'dart:convert';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sparksocial/src/core/network/chat/data/models/models.dart';
import 'package:sparksocial/src/core/network/chat/data/repositories/chat_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Implementation of Spark Chat API endpoints
class ChatRepositoryImpl implements ChatRepository {
  static const String _baseUrl = 'https://chat.sprk.so';
  static const String _wsUrl = 'wss://chat.sprk.so/ws';

  final _logger = GetIt.instance<LogService>().getLogger('ChatRepository');
  final http.Client _httpClient;

  String? _jwtToken;
  WebSocketChannel? _webSocketChannel;

  ChatRepositoryImpl([http.Client? httpClient]) : _httpClient = httpClient ?? http.Client() {
    _logger.v('ChatRepository initialized');
  }

  @override
  void setAuthToken(String token) {
    _jwtToken = token;
    _logger.d('JWT token set for chat authentication');
  }

  Map<String, String> get _authHeaders {
    if (_jwtToken == null) {
      throw Exception('JWT token not set. Call setAuthToken() first.');
    }
    return {
      'Authorization': 'Bearer $_jwtToken',
      'Content-Type': 'application/json',
    };
  }

  @override
  Future<SendMessageResponse> sendMessage(String message, String receiverDid) async {
    _logger.d('Sending message to DID: $receiverDid');

    try {
      final request = SendMessageRequest(
        message: message,
        receiverDid: receiverDid,
      );

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/xrpc/so.sprk.chat.sendMessage'),
        headers: _authHeaders,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        _logger.d('Message sent successfully');
        return SendMessageResponse.fromJson(responseData);
      } else {
        _logger.e('Failed to send message: ${response.statusCode} ${response.body}');
        throw Exception('Failed to send message: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _logger.e('Error sending message', error: e);
      rethrow;
    }
  }

  @override
  Future<GetMessagesResponse> getMessages(String otherDid, {int limit = 50}) async {
    _logger.d('Getting messages for conversation with DID: $otherDid, limit: $limit');

    try {
      final uri = Uri.parse('$_baseUrl/xrpc/so.sprk.chat.getMessages').replace(
        queryParameters: {
          'otherDid': otherDid,
          'limit': limit.toString(),
        },
      );

      final response = await _httpClient.get(
        uri,
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        _logger.d('Messages retrieved successfully');
        return GetMessagesResponse.fromJson(responseData);
      } else {
        _logger.e('Failed to get messages: ${response.statusCode} ${response.body}');
        throw Exception('Failed to get messages: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _logger.e('Error getting messages', error: e);
      rethrow;
    }
  }

  @override
  Future<GetChatsResponse> getChats() async {
    _logger.d('Getting chats list');

    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/xrpc/so.sprk.chat.getChats'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        _logger.d('Chats list retrieved successfully');
        return GetChatsResponse.fromJson(responseData);
      } else {
        _logger.e('Failed to get chats: ${response.statusCode} ${response.body}');
        throw Exception('Failed to get chats: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _logger.e('Error getting chats', error: e);
      rethrow;
    }
  }

  @override
  WebSocketChannel connectWebSocket() {
    _logger.d('Connecting to WebSocket');

    try {
      if (_jwtToken == null) {
        throw Exception('JWT token not set. Call setAuthToken() first.');
      }

      // Close existing connection if any
      closeWebSocket();

      _webSocketChannel = WebSocketChannel.connect(
        Uri.parse(_wsUrl),
        protocols: ['Bearer $_jwtToken'], // Some WebSocket implementations expect protocols
      );

      _logger.d('WebSocket connected successfully');
      return _webSocketChannel!;
    } catch (e) {
      _logger.e('Error connecting to WebSocket', error: e);
      rethrow;
    }
  }

  @override
  void closeWebSocket() {
    _logger.d('Closing WebSocket connection');

    try {
      _webSocketChannel?.sink.close();
      _webSocketChannel = null;
      _logger.d('WebSocket connection closed');
    } catch (e) {
      _logger.w('Error closing WebSocket', error: e);
    }
  }

  @override
  Future<HealthCheckResponse> healthCheck() async {
    _logger.d('Performing health check');

    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/health'),
        // Health check doesn't require authentication
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        _logger.d('Health check successful');
        return HealthCheckResponse.fromJson(responseData);
      } else {
        _logger.e('Health check failed: ${response.statusCode} ${response.body}');
        throw Exception('Health check failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _logger.e('Error during health check', error: e);
      rethrow;
    }
  }

  /// Dispose of resources
  void dispose() {
    _logger.d('Disposing ChatRepository');
    closeWebSocket();
    _httpClient.close();
  }
}