import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:spark/src/core/config/app_config.dart';
import 'package:spark/src/core/network/messages/data/models/message_models.dart';
import 'package:spark/src/core/network/messages/data/repository/messages_repository.dart';
import 'package:spark/src/core/network/xrpc/service_auth_helper.dart';
import 'package:spark/src/core/utils/utils.dart';

/// XRPC-based implementation of MessagesRepository using service auth
class MessagesRepositoryXrpc implements MessagesRepository {
  MessagesRepositoryXrpc(this._serviceAuthHelper) {
    _logger = GetIt.I<LogService>().getLogger('MessagesRepositoryXrpc');
  }

  final ServiceAuthHelper _serviceAuthHelper;
  late final SparkLogger _logger;

  /// Base URL for the chat service XRPC endpoints
  String get _baseUrl => AppConfig.messagesServiceUrl;

  /// Makes an XRPC query (GET) request
  Future<Map<String, dynamic>> _callQuery(
    String nsid,
    Map<String, String> params,
  ) async {
    try {
      final token = await _serviceAuthHelper.getServiceToken(nsid);
      final url = Uri.parse(
        '$_baseUrl/xrpc/$nsid',
      ).replace(queryParameters: params.isEmpty ? null : params);

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'XRPC query failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      _logger.e('Error calling XRPC query $nsid', error: e);
      rethrow;
    }
  }

  /// Makes an XRPC procedure (POST) request
  Future<Map<String, dynamic>> _callProcedure(
    String nsid,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await _serviceAuthHelper.getServiceToken(nsid);
      final url = Uri.parse('$_baseUrl/xrpc/$nsid');

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 204) {
        // No content, but considered success
        return <String, dynamic>{};
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return <String, dynamic>{};
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'XRPC procedure failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      _logger.e('Error calling XRPC procedure $nsid', error: e);
      rethrow;
    }
  }

  @override
  Future<({List<ConvoView> conversations, String? cursor})> listConversations({
    int? limit,
    String? cursor,
    String? readState,
  }) async {
    final params = <String, String>{
      if (limit != null) 'limit': limit.toString(),
      'cursor': ?cursor,
      'readState': ?readState,
    };

    final data = await _callQuery('so.sprk.chat.listConvos', params);

    final convos =
        (data['convos'] as List<dynamic>?)
            ?.map((json) => ConvoView.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];

    return (conversations: convos, cursor: data['cursor'] as String?);
  }

  @override
  Future<ConvoView> getConversation(String convoId) async {
    final data = await _callQuery('so.sprk.chat.getConvo', {
      'convoId': convoId,
    });

    return ConvoView.fromJson(data['convo'] as Map<String, dynamic>);
  }

  @override
  Future<ConvoView> getConvoForMembers(List<String> members) async {
    // Build URL with repeated members parameters
    // Need to manually construct query string for repeated params
    final baseUri = Uri.parse('$_baseUrl/xrpc/so.sprk.chat.getConvoForMembers');
    final queryParts = members
        .map((m) => 'members=${Uri.encodeComponent(m)}')
        .join('&');
    final url = Uri.parse('$baseUri?$queryParts');

    final token = await _serviceAuthHelper.getServiceToken(
      'so.sprk.chat.getConvoForMembers',
    );

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ConvoView.fromJson(data['convo'] as Map<String, dynamic>);
    } else {
      throw Exception(
        'XRPC query failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  @override
  Future<({List<MessageView> messages, String? cursor})> getMessages(
    String convoId, {
    int? limit,
    String? cursor,
  }) async {
    final params = <String, String>{
      'convoId': convoId,
      if (limit != null) 'limit': limit.toString(),
      'cursor': ?cursor,
    };

    final data = await _callQuery('so.sprk.chat.getMessages', params);

    final messages =
        (data['messages'] as List<dynamic>?)
            ?.map((json) => MessageView.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];

    return (messages: messages, cursor: data['cursor'] as String?);
  }

  @override
  Future<MessageView> sendMessage(
    String convoId, {
    required String text,
    List<dynamic>? facets,
    String? embed,
  }) async {
    // NOTE: We intentionally do NOT retry sendMessage because it's not
    // idempotent. Retrying could create duplicate user-visible messages
    // if the first request succeeded but the connection dropped before
    // the client received the response.
    // See: https://docs.aws.amazon.com/general/latest/gr/api-retries.html
    final body = <String, dynamic>{
      'convoId': convoId,
      'message': <String, dynamic>{
        'text': text,
        'facets': ?facets,
        'embed': ?embed,
      },
    };

    final data = await _callProcedure('so.sprk.chat.sendMessage', body);

    return MessageView.fromJson(data);
  }

  @override
  Future<MessageView> addReaction(
    String convoId,
    String messageId,
    String value,
  ) async {
    final body = <String, dynamic>{
      'convoId': convoId,
      'messageId': messageId,
      'value': value,
    };

    final data = await _callProcedure('so.sprk.chat.addReaction', body);

    return MessageView.fromJson(data);
  }

  @override
  Future<MessageView> removeReaction(
    String convoId,
    String messageId,
    String value,
  ) async {
    final body = <String, dynamic>{
      'convoId': convoId,
      'messageId': messageId,
      'value': value,
    };

    final data = await _callProcedure('so.sprk.chat.removeReaction', body);

    return MessageView.fromJson(data);
  }

  @override
  Future<ConvoView> updateRead(String convoId, String messageId) async {
    final body = <String, dynamic>{'convoId': convoId, 'messageId': messageId};

    final data = await _callProcedure('so.sprk.chat.updateRead', body);

    return ConvoView.fromJson(data['convo'] as Map<String, dynamic>);
  }
}
