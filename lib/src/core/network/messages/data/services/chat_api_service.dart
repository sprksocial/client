import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/config/app_config.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';

/// Service responsible for REST API calls to the chat service
class ChatApiService {
  ChatApiService._();

  // Singleton instance
  static final ChatApiService _instance = ChatApiService._();
  factory ChatApiService() => _instance;

  final _sl = GetIt.instance;
  final _logger = GetIt.instance<LogService>().getLogger('ChatApiService');

  /// Create a new chat conversation
  Future<Map<String, dynamic>> createChat({
    required String type, // 'private' or 'group'
    required List<String> participantIds,
  }) async {
    final authRepository = _sl<AuthRepository>();
    if (!authRepository.isAuthenticated || authRepository.session == null) {
      throw Exception('User is not authenticated');
    }

    final jwt = authRepository.session!.accessJwt;
    final url = '${AppConfig.chatServiceUrl}/api/chats';

    _logger.i('Creating chat via REST API: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt', // ATP JWT authentication
        },
        body: jsonEncode({
          'type': type,
          'participantIds': participantIds,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        _logger.i('Chat created successfully: ${result['data']?['chatId']}');
        return result;
      } else {
        _logger.e('Failed to create chat: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create chat: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error creating chat', error: e);
      rethrow;
    }
  }

  /// Get chat conversations for the current user
  Future<Map<String, dynamic>> getChats() async {
    final authRepository = _sl<AuthRepository>();
    if (!authRepository.isAuthenticated || authRepository.session == null) {
      throw Exception('User is not authenticated');
    }

    final jwt = authRepository.session!.accessJwt;
    final url = '${AppConfig.chatServiceUrl}/api/chats';

    _logger.i('Getting chats via REST API: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt', // ATP JWT authentication
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        _logger.i('Chats retrieved successfully');
        return result;
      } else {
        _logger.e('Failed to get chats: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get chats: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error getting chats', error: e);
      rethrow;
    }
  }

  /// Get messages for a specific chat
  Future<Map<String, dynamic>> getChatMessages(String chatId) async {
    final authRepository = _sl<AuthRepository>();
    if (!authRepository.isAuthenticated || authRepository.session == null) {
      throw Exception('User is not authenticated');
    }

    final jwt = authRepository.session!.accessJwt;
    final url = '${AppConfig.chatServiceUrl}/api/chats/$chatId/messages';

    _logger.i('Getting chat messages via REST API: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt', // ATP JWT authentication
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        _logger.i('Chat messages retrieved successfully');
        return result;
      } else {
        _logger.e('Failed to get chat messages: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get chat messages: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error getting chat messages', error: e);
      rethrow;
    }
  }
}