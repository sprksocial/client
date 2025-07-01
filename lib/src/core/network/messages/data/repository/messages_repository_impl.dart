import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sparksocial/src/core/config/app_config.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart' hide Embed;
import 'package:sparksocial/src/features/auth/auth.dart';
import 'messages_repository.dart';
import '../models/message_models.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  final AuthRepository _authRepository;

  MessagesRepositoryImpl(this._authRepository);

  String? get accessToken => _authRepository.dmAccessToken;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (accessToken?.isNotEmpty == true) 'Authorization': 'Bearer $accessToken',
  };

  @override
  Future<({List<Message> messages, String? cursor})> getConversation(String did, {String? cursor, int? limit = 30}) async {
    try {
      final queryParameters = <String, String>{
        'with': did,
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit.toString(),
      };

      final uri = Uri.parse('${AppConfig.messagesServiceUrl}/conversation').replace(queryParameters: queryParameters);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final messagesList = (data['messages'] as List).map((json) => Message.fromJson(json)).toList();

        return (messages: messagesList, cursor: data['cursor'] as String?);
      } else if (response.statusCode == 401) {
        throw Exception('Não autorizado, vê aí se o token tá valido memo');
      } else {
        throw Exception('Erro na requisição: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar conversa: $e');
    }
  }

  @override
  Future<({List<(ProfileViewDetailed, Message)> messages, String? cursor})> getAllConversations({
    String? cursor,
    int? limit,
  }) async {
    try {
      final queryParameters = <String, String>{
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit.toString(),
      };

      final uri = Uri.parse('${AppConfig.messagesServiceUrl}/conversations').replace(queryParameters: queryParameters);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final conversationsList = (data['conversations'] as List)
            .map((json) => (ProfileViewDetailed.fromJson(json['profile']), Message.fromJson(json['lastMessage'])))
            .toList();

        return (messages: conversationsList, cursor: data['cursor'] as String?);
      } else if (response.statusCode == 401) {
        throw Exception('Não autorizado, vê aí se o token tá valido memo');
      } else {
        throw Exception('Erro ao buscar conversas: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar conversas: $e');
    }
  }

  @override
  Future<Message> sendMessage(String did, String message, {Embed? embed}) async {
    try {
      final requestBody = <String, dynamic>{
        'receiver_did': did,
        'message': message,
        if (embed != null && embed.isNotEmpty) 'embed': [embed.toJson()],
      };

      final uri = Uri.parse('${AppConfig.messagesServiceUrl}/send');

      final response = await http.post(uri, headers: _headers, body: jsonEncode(requestBody));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Message.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Não autorizado, vê aí se o token tá valido memo');
      } else {
        throw Exception('Erro ao enviar mensagem: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao enviar mensagem: $e');
    }
  }
}
