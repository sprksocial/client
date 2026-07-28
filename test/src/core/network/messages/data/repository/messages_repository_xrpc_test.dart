import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spark/src/core/network/messages/data/models/message_models.dart';
import 'package:spark/src/core/network/messages/data/repository/messages_repository_xrpc.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

void main() {
  test('listConversations sends filters and maps the response', () async {
    late http.Request captured;
    final repository = _repository(
      MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'cursor': 'next',
            'convos': [_convoJson('convo-1')],
          }),
          200,
        );
      }),
    );

    final result = await repository.listConversations(
      limit: 20,
      cursor: 'cursor',
      readState: 'unread',
    );

    expect(captured.method, 'GET');
    expect(captured.url.path, '/xrpc/chat.sprk.convo.listConvos');
    expect(captured.url.queryParameters, {
      'limit': '20',
      'cursor': 'cursor',
      'readState': 'unread',
    });
    expect(captured.headers['authorization'], 'Bearer service-token');
    expect(result.cursor, 'next');
    expect(result.conversations.single.id, 'convo-1');
  });

  test(
    'getConvoForMembers preserves repeated encoded member parameters',
    () async {
      late http.Request captured;
      final repository = _repository(
        MockClient((request) async {
          captured = request;
          return http.Response(jsonEncode({'convo': _convoJson('group')}), 200);
        }),
      );

      final result = await repository.getConvoForMembers([
        'did:plc:alice',
        'did:web:bob.test',
      ]);

      expect(captured.url.path, '/xrpc/chat.sprk.convo.getConvoForMembers');
      expect(captured.url.queryParametersAll['members'], [
        'did:plc:alice',
        'did:web:bob.test',
      ]);
      expect(result.id, 'group');
    },
  );

  test(
    'getMessages maps live, deleted, and unknown message variants',
    () async {
      final repository = _repository(
        MockClient(
          (request) async => http.Response(
            jsonEncode({
              'cursor': 'older',
              'messages': [
                _messageJson('live'),
                {
                  r'$type': 'chat.sprk.convo.defs#deletedMessageView',
                  'id': 'deleted',
                  'rev': '2',
                  'sender': {'did': 'did:plc:alice'},
                  'sentAt': '2026-07-22T12:01:00.000Z',
                },
                {
                  r'$type': 'chat.sprk.convo.defs#futureMessageView',
                  'id': 'future',
                  'rev': '3',
                  'sender': {'did': 'did:plc:alice'},
                  'sentAt': '2026-07-22T12:02:00.000Z',
                  'futureField': true,
                },
              ],
            }),
            200,
          ),
        ),
      );

      final result = await repository.getMessages('convo', limit: 3);

      expect(result.cursor, 'older');
      expect(result.messages.map((message) => message.id), [
        'live',
        'deleted',
        'future',
      ]);
      expect(result.messages[0], isA<ChatMessageViewMessage>());
      expect(result.messages[1], isA<ChatMessageViewDeleted>());
      expect(result.messages[2], isA<ChatMessageViewUnsupported>());
    },
  );

  test('sendMessage posts typed body and maps the created message', () async {
    late http.Request captured;
    final repository = _repository(
      MockClient((request) async {
        captured = request;
        return http.Response(jsonEncode(_messageJson('sent')), 201);
      }),
    );

    final result = await repository.sendMessage(
      'convo',
      text: 'hello',
      embed: 'at://did:plc:author/so.sprk.feed.post/post',
    );

    expect(captured.method, 'POST');
    expect(captured.url.path, '/xrpc/chat.sprk.convo.sendMessage');
    expect(jsonDecode(captured.body), {
      'convoId': 'convo',
      'message': {
        r'$type': 'chat.sprk.convo.defs#messageInput',
        'text': 'hello',
        'embed': 'at://did:plc:author/so.sprk.feed.post/post',
      },
    });
    expect(result.id, 'sent');
  });

  test(
    'non-success responses and token failures propagate without mapping',
    () async {
      var requests = 0;
      final transportFailure = _repository(
        MockClient((request) async {
          requests += 1;
          return http.Response('unavailable', 503);
        }),
      );

      await expectLater(
        transportFailure.getConversation('convo'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            allOf(contains('503'), contains('unavailable')),
          ),
        ),
      );

      final tokenFailure = _repository(
        MockClient((request) async {
          requests += 1;
          return http.Response('{}', 200);
        }),
        serviceToken: (_) async => throw StateError('no session'),
      );
      await expectLater(
        tokenFailure.getConversation('convo'),
        throwsA(isA<StateError>()),
      );
      expect(requests, 1);
    },
  );
}

MessagesRepositoryXrpc _repository(
  http.Client client, {
  Future<String> Function(String)? serviceToken,
}) => MessagesRepositoryXrpc.withServiceToken(
  serviceToken: serviceToken ?? (_) async => 'service-token',
  httpClient: client,
  baseUrl: 'https://chat.test',
  logger: SparkLogger(),
);

Map<String, dynamic> _convoJson(String id) => {
  r'$type': 'chat.sprk.convo.defs#convoView',
  'id': id,
  'rev': '1',
  'members': [
    {
      r'$type': 'chat.sprk.actor.defs#profileViewBasic',
      'did': 'did:plc:alice',
      'handle': 'alice.test',
    },
  ],
  'muted': false,
  'status': 'accepted',
  'unreadCount': 0,
};

Map<String, dynamic> _messageJson(String id) => {
  r'$type': 'chat.sprk.convo.defs#messageView',
  'id': id,
  'rev': '1',
  'text': 'hello',
  'sender': {'did': 'did:plc:alice'},
  'sentAt': '2026-07-22T12:00:00.000Z',
};
