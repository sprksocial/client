import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/config/app_config.dart';
import 'package:spark/src/core/network/messages/data/models/message_models.dart';
import 'package:spark/src/core/network/messages/data/repository/messages_repository.dart';
import 'package:spark/src/core/network/xrpc/service_auth_helper.dart';
import 'package:spark/src/core/utils/utils.dart';
import 'package:sprk_poptart/chat/sprk/convo/add_reaction/output.dart'
    as add_reaction;
import 'package:sprk_poptart/chat/sprk/convo/defs.dart' as chat_defs;
import 'package:sprk_poptart/chat/sprk/convo/get_convo/output.dart'
    as get_convo;
import 'package:sprk_poptart/chat/sprk/convo/get_convo_for_members/output.dart'
    as get_convo_for_members;
import 'package:sprk_poptart/chat/sprk/convo/get_messages/output.dart'
    as get_messages;
import 'package:sprk_poptart/chat/sprk/convo/get_messages/union_main_messages.dart'
    as get_messages_union;
import 'package:sprk_poptart/chat/sprk/convo/list_convos/output.dart'
    as list_convos;
import 'package:sprk_poptart/chat/sprk/convo/remove_reaction/output.dart'
    as remove_reaction;
import 'package:sprk_poptart/chat/sprk/convo/send_message/input.dart'
    as send_message;
import 'package:sprk_poptart/chat/sprk/convo/update_read/output.dart'
    as update_read;

/// XRPC-based implementation of MessagesRepository using service auth
class MessagesRepositoryXrpc implements MessagesRepository {
  MessagesRepositoryXrpc(this._serviceAuthHelper) {
    _logger = GetIt.I<LogService>().getLogger('MessagesRepositoryXrpc');
  }

  final ServiceAuthHelper _serviceAuthHelper;
  late final SparkLogger _logger;

  /// Base URL for the chat service XRPC endpoints
  String get _baseUrl => AppConfig.messagesServiceUrl;

  static const _listConvosNsid = 'chat.sprk.convo.listConvos';
  static const _getConvoNsid = 'chat.sprk.convo.getConvo';
  static const _getConvoForMembersNsid = 'chat.sprk.convo.getConvoForMembers';
  static const _getMessagesNsid = 'chat.sprk.convo.getMessages';
  static const _sendMessageNsid = 'chat.sprk.convo.sendMessage';
  static const _addReactionNsid = 'chat.sprk.convo.addReaction';
  static const _removeReactionNsid = 'chat.sprk.convo.removeReaction';
  static const _updateReadNsid = 'chat.sprk.convo.updateRead';

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

    final data = await _callQuery(_listConvosNsid, params);

    final output = list_convos.ConvoListConvosOutput.fromJson(data);
    final convos = output.convos
        .map(ConvoView.fromChat)
        .toList(growable: false);

    return (conversations: convos, cursor: output.cursor);
  }

  @override
  Future<ConvoView> getConversation(String convoId) async {
    final data = await _callQuery(_getConvoNsid, {'convoId': convoId});

    return ConvoView.fromChat(
      get_convo.ConvoGetConvoOutput.fromJson(data).convo,
    );
  }

  @override
  Future<ConvoView> getConvoForMembers(List<String> members) async {
    // Build URL with repeated members parameters
    // Need to manually construct query string for repeated params
    final baseUri = Uri.parse('$_baseUrl/xrpc/$_getConvoForMembersNsid');
    final queryParts = members
        .map((m) => 'members=${Uri.encodeComponent(m)}')
        .join('&');
    final url = Uri.parse('$baseUri?$queryParts');

    final token = await _serviceAuthHelper.getServiceToken(
      _getConvoForMembersNsid,
    );

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ConvoView.fromChat(
        get_convo_for_members.ConvoGetConvoForMembersOutput.fromJson(
          data,
        ).convo,
      );
    } else {
      throw Exception(
        'XRPC query failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  @override
  Future<({List<ChatMessageView> messages, String? cursor})> getMessages(
    String convoId, {
    int? limit,
    String? cursor,
  }) async {
    final params = <String, String>{
      'convoId': convoId,
      if (limit != null) 'limit': limit.toString(),
      'cursor': ?cursor,
    };

    final data = await _callQuery(_getMessagesNsid, params);

    final output = get_messages.ConvoGetMessagesOutput.fromJson(data);
    final messages = output.messages
        .map(_chatMessageFromChat)
        .toList(growable: false);

    return (messages: messages, cursor: output.cursor);
  }

  @override
  Future<MessageView> sendMessage(
    String convoId, {
    required String text,
    String? embed,
  }) async {
    // NOTE: We intentionally do NOT retry sendMessage because it's not
    // idempotent. Retrying could create duplicate user-visible messages
    // if the first request succeeded but the connection dropped before
    // the client received the response.
    // See: https://docs.aws.amazon.com/general/latest/gr/api-retries.html
    final body = send_message.ConvoSendMessageInput(
      convoId: convoId,
      message: chat_defs.MessageInput(
        text: text,
        embed: embed == null ? null : AtUri.parse(embed),
      ),
    ).toJson();

    final data = await _callProcedure(_sendMessageNsid, body);

    return MessageView.fromChat(chat_defs.MessageView.fromJson(data));
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

    final data = await _callProcedure(_addReactionNsid, body);

    return MessageView.fromChat(
      add_reaction.ConvoAddReactionOutput.fromJson(data).message,
    );
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

    final data = await _callProcedure(_removeReactionNsid, body);

    return MessageView.fromChat(
      remove_reaction.ConvoRemoveReactionOutput.fromJson(data).message,
    );
  }

  @override
  Future<ConvoView> updateRead(String convoId, String messageId) async {
    final body = <String, dynamic>{'convoId': convoId, 'messageId': messageId};

    final data = await _callProcedure(_updateReadNsid, body);

    return ConvoView.fromChat(
      update_read.ConvoUpdateReadOutput.fromJson(data).convo,
    );
  }
}

ChatMessageView _chatMessageFromChat(
  get_messages_union.UConvoGetMessagesMessages message,
) {
  return switch (message) {
    get_messages_union.UConvoGetMessagesMessagesMessageView(:final data) =>
      ChatMessageView.message(data: MessageView.fromChat(data)),
    get_messages_union.UConvoGetMessagesMessagesDeletedMessageView(
      :final data,
    ) =>
      ChatMessageView.deleted(data: DeletedMessageView.fromChat(data)),
    get_messages_union.UConvoGetMessagesMessagesUnknown(:final data) =>
      ChatMessageView.unsupportedFromRaw(data),
  };
}
