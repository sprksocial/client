import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sparksocial/src/core/config/app_config.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart' hide Embed;
import 'package:sparksocial/src/core/network/messages/data/models/message_models.dart';
import 'package:sparksocial/src/core/network/messages/data/repository/messages_repository.dart';
import 'package:sparksocial/src/core/utils/utils.dart';
import 'package:sparksocial/src/features/auth/auth.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  MessagesRepositoryImpl(this._authRepository) {
    _logger = GetIt.I<LogService>().getLogger('MessagesRepository');
  }
  final AuthRepository _authRepository;
  late final SparkLogger _logger;

  String? get accessToken => _authRepository.dmAccessToken;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (accessToken?.isNotEmpty ?? true) 'Authorization': 'Bearer $accessToken',
  };

  Future<void> _refreshIfExpired() async {
    if (_authRepository.isAuthenticated && _authRepository.dmAccessToken == null) {
      _logger.w('DM access token is null, refreshing...');
      final refreshed = await _authRepository.refreshDMToken();
      if (!refreshed) {
        _logger.e('Failed to refresh DM token');
        await _authRepository.loginMessageService();
      }
    }
  }

  @override
  Future<({List<Message> messages, String? cursor})> getConversation(String did, {String? cursor, int? limit = 30}) async {
    try {
      final queryParameters = <String, String>{
        'with': did,
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit.toString(),
      };
      await _refreshIfExpired();

      final uri = Uri.parse('${AppConfig.messagesServiceUrl}/messages/conversation').replace(queryParameters: queryParameters);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final messagesList = (data['messages'] as List).map((json) => Message.fromJson(json as Map<String, dynamic>)).toList();

        return (messages: messagesList, cursor: data['cursor'] as String?);
      } else if (response.statusCode == 401) {
        await _refreshIfExpired();

        throw Exception('Não autorizado, vê aí se o token tá valido memo');
      } else {
        throw Exception('Erro na requisição: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('valido')) {
        await _refreshIfExpired();
        return getConversation(did, cursor: cursor, limit: limit); // FUCK IT WE BALL
      }
      rethrow;
    }
  }

  @override
  Future<({List<(ProfileViewDetailed, Message)> messages, String? cursor})> getAllConversations({
    String? cursor,
    int? limit,
  }) async {
    try {
      await _refreshIfExpired();
      final actorRepository = GetIt.I<SprkRepository>().actor;
      final queryParameters = <String, String>{
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit.toString(),
      };

      final uri = Uri.parse('${AppConfig.messagesServiceUrl}/messages/conversations').replace(queryParameters: queryParameters);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final userDid = _authRepository.session?.did;
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final messages = (data['conversations'] as List).map((json) => Message.fromJson(json as Map<String, dynamic>)).toList();
        final profileDids = (data['conversations'] as List)
            .map((json) => json['sender_did'] != userDid ? json['sender_did'] as String : json['receiver_did'] as String)
            .where((did) => did.startsWith('did:plc:'))
            .toList();
        final profiles = await actorRepository.getProfiles(profileDids);
        final conversationsList = <(ProfileViewDetailed, Message)>[];
        profiles.asMap().forEach((index, profile) {
          conversationsList.add((profile, messages[index]));
        });

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
  Future<Message> sendMessage(String did, String message, {List<Embed>? embed}) async {
    try {
      await _refreshIfExpired();
      final requestBody = <String, dynamic>{
        'receiver_did': did,
        'message': message,
        if (embed != null && embed.isNotEmpty) 'embed': embed,
      };
      _logger.d('Sending message to $did: $requestBody');

      final uri = Uri.parse('${AppConfig.messagesServiceUrl}/messages/send');

      final response = await http.post(uri, headers: _headers, body: jsonEncode(requestBody), encoding: utf8);
      _logger
        ..d('Response status code: ${response.statusCode}')
        ..d('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Message.fromJson(data['message'] as Map<String, dynamic>);
      } else if (response.statusCode == 401) {
        await _refreshIfExpired();

        throw Exception('Não autorizado, vê aí se o token tá valido memo');
      } else {
        throw Exception('Erro ao enviar mensagem: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao enviar mensagem: $e');
    }
  }
}
