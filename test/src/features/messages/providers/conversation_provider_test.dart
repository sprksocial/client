import 'dart:async';
import 'dart:collection';

import 'package:sprk_poptart/chat/sprk/actor/defs.dart';

import 'package:poptart/poptart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/auth/data/models/login_result.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/messages/data/models/message_models.dart';
import 'package:spark/src/core/network/messages/data/repository/messages_repository.dart';
import 'package:spark/src/features/messages/providers/conversation_provider.dart';

void main() {
  group('Conversation provider', () {
    late _FakeMessagesRepository messagesRepository;
    late _FakeAuthRepository authRepository;

    setUp(() async {
      await GetIt.I.reset();
      messagesRepository = _FakeMessagesRepository();
      authRepository = _FakeAuthRepository();
      GetIt.I
        ..registerSingleton<MessagesRepository>(messagesRepository)
        ..registerSingleton<AuthRepository>(authRepository);
    });

    tearDown(() async {
      await GetIt.I.reset();
    });

    test('merges send and polling updates without dropping messages', () async {
      final me = ProfileViewBasic(did: 'did:me', handle: 'me.test');
      final other = ProfileViewBasic(did: 'did:other', handle: 'other.test');
      final initialMessage = _message(
        id: '1',
        text: 'initial',
        senderDid: other.did,
        sentAt: '2026-04-11T10:00:00.000Z',
      );
      final inboundMessage = _message(
        id: '2',
        text: 'incoming',
        senderDid: other.did,
        sentAt: '2026-04-11T10:00:01.000Z',
      );
      final sentMessage = _message(
        id: '3',
        text: 'outgoing',
        senderDid: me.did,
        sentAt: '2026-04-11T10:00:02.000Z',
      );

      messagesRepository.conversation = ConvoView(
        id: 'convo-1',
        rev: 'rev-1',
        members: [me, other],
        lastMessage: ChatMessageView.message(data: initialMessage),
      );
      messagesRepository.getMessagesResponses.add((
        messages: [ChatMessageView.message(data: initialMessage)],
        cursor: 'cursor-1',
      ));
      messagesRepository.getMessagesResponses.add((
        messages: [
          ChatMessageView.message(data: initialMessage),
          ChatMessageView.message(data: inboundMessage),
        ],
        cursor: 'cursor-1',
      ));

      final sendCompleter = Completer<MessageView>();
      messagesRepository.sendMessageHandler =
          ({required String convoId, required String text, String? embed}) {
            expect(convoId, 'convo-1');
            expect(text, 'hello');
            return sendCompleter.future;
          };

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(conversationProvider('convo-1').future);
      final notifier = container.read(conversationProvider('convo-1').notifier);

      final sendFuture = notifier.sendMessage('convo-1', 'hello');
      await notifier.checkForNewMessages();
      sendCompleter.complete(sentMessage);
      await sendFuture;

      final state = container.read(conversationProvider('convo-1')).value;
      expect(state, isNotNull);
      expect(state!.messages.map((message) => message.id).toList(), [
        '1',
        '2',
        '3',
      ]);
      expect(state.convo.lastMessage?.id, '3');
    });

    test('preserves deleted messages when polling updates arrive', () async {
      final me = ProfileViewBasic(did: 'did:me', handle: 'me.test');
      final other = ProfileViewBasic(did: 'did:other', handle: 'other.test');
      final initialMessage = _message(
        id: '1',
        text: 'initial',
        senderDid: other.did,
        sentAt: '2026-04-11T10:00:00.000Z',
      );
      final deletedMessage = DeletedMessageView(
        id: '2',
        rev: 'rev-2',
        sender: SenderView(did: other.did),
        sentAt: '2026-04-11T10:00:01.000Z',
      );

      messagesRepository.conversation = ConvoView(
        id: 'convo-1',
        rev: 'rev-1',
        members: [me, other],
        lastMessage: ChatMessageView.message(data: initialMessage),
      );
      messagesRepository.getMessagesResponses.add((
        messages: [ChatMessageView.message(data: initialMessage)],
        cursor: 'cursor-1',
      ));
      messagesRepository.getMessagesResponses.add((
        messages: [
          ChatMessageView.message(data: initialMessage),
          ChatMessageView.deleted(data: deletedMessage),
        ],
        cursor: 'cursor-1',
      ));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(conversationProvider('convo-1').future);
      final notifier = container.read(conversationProvider('convo-1').notifier);

      await notifier.checkForNewMessages();
      await notifier.markReadUpToLatest();

      final state = container.read(conversationProvider('convo-1')).value;
      expect(state, isNotNull);
      expect(state!.messages.map((message) => message.id).toList(), ['1', '2']);
      expect(
        state.messages.last,
        isA<ChatMessageViewDeleted>().having(
          (message) => message.id,
          'id',
          '2',
        ),
      );
      expect(messagesRepository.readUpdates, [('convo-1', '2')]);
    });

    test(
      'preserves unsupported messages when polling updates arrive',
      () async {
        final me = ProfileViewBasic(did: 'did:me', handle: 'me.test');
        final other = ProfileViewBasic(did: 'did:other', handle: 'other.test');
        final initialMessage = _message(
          id: '1',
          text: 'initial',
          senderDid: other.did,
          sentAt: '2026-04-11T10:00:00.000Z',
        );
        final unsupportedMessage = UnsupportedMessageView(
          id: '2',
          rev: 'rev-2',
          sender: SenderView(did: other.did),
          sentAt: '2026-04-11T10:00:01.000Z',
          raw: const {
            r'$type': 'chat.sprk.convo.defs#futureMessageView',
            'id': '2',
            'rev': 'rev-2',
            'sender': {'did': 'did:other'},
            'sentAt': '2026-04-11T10:00:01.000Z',
          },
        );

        messagesRepository.conversation = ConvoView(
          id: 'convo-1',
          rev: 'rev-1',
          members: [me, other],
          lastMessage: ChatMessageView.message(data: initialMessage),
        );
        messagesRepository.getMessagesResponses.add((
          messages: [ChatMessageView.message(data: initialMessage)],
          cursor: 'cursor-1',
        ));
        messagesRepository.getMessagesResponses.add((
          messages: [
            ChatMessageView.message(data: initialMessage),
            ChatMessageView.unsupported(data: unsupportedMessage),
          ],
          cursor: 'cursor-1',
        ));

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await container.read(conversationProvider('convo-1').future);
        final notifier = container.read(
          conversationProvider('convo-1').notifier,
        );

        await notifier.checkForNewMessages();
        await notifier.markReadUpToLatest();

        final state = container.read(conversationProvider('convo-1')).value;
        expect(state, isNotNull);
        expect(state!.messages.map((message) => message.id).toList(), [
          '1',
          '2',
        ]);
        expect(
          state.messages.last,
          isA<ChatMessageViewUnsupported>().having(
            (message) => message.id,
            'id',
            '2',
          ),
        );
        expect(messagesRepository.readUpdates, [('convo-1', '2')]);
      },
    );
  });
}

MessageView _message({
  required String id,
  required String text,
  required String senderDid,
  required String sentAt,
}) {
  return MessageView(
    id: id,
    rev: 'rev-$id',
    text: text,
    sender: SenderView(did: senderDid),
    sentAt: sentAt,
    reactions: const [],
  );
}

class _FakeMessagesRepository implements MessagesRepository {
  late ConvoView conversation;
  final Queue<({List<ChatMessageView> messages, String? cursor})>
  getMessagesResponses =
      Queue<({List<ChatMessageView> messages, String? cursor})>();
  final List<(String convoId, String messageId)> readUpdates = [];
  Future<MessageView> Function({
    required String convoId,
    required String text,
    String? embed,
  })?
  sendMessageHandler;

  @override
  Future<MessageView> addReaction(
    String convoId,
    String messageId,
    String value,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<ConvoView> getConversation(String convoId) async => conversation;

  @override
  Future<ConvoView> getConvoForMembers(List<String> members) {
    throw UnimplementedError();
  }

  @override
  Future<({List<ChatMessageView> messages, String? cursor})> getMessages(
    String convoId, {
    int? limit,
    String? cursor,
  }) async {
    expect(getMessagesResponses, isNotEmpty);
    return getMessagesResponses.removeFirst();
  }

  @override
  Future<({List<ConvoView> conversations, String? cursor})> listConversations({
    int? limit,
    String? cursor,
    String? readState,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MessageView> removeReaction(
    String convoId,
    String messageId,
    String value,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<MessageView> sendMessage(
    String convoId, {
    required String text,
    String? embed,
  }) {
    final handler = sendMessageHandler;
    if (handler == null) {
      throw StateError('sendMessageHandler not configured');
    }
    return handler(convoId: convoId, text: text, embed: embed);
  }

  @override
  Future<ConvoView> updateRead(String convoId, String messageId) async {
    readUpdates.add((convoId, messageId));
    return conversation;
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  PoptartClient? get atproto => null;

  @override
  String? get did => 'did:me';

  @override
  String? get handle => 'me.test';

  @override
  String? get lastKnownHandle => handle;

  @override
  Future<void> get initializationComplete async {}

  @override
  bool get isAuthenticated => true;

  @override
  String? get pdsEndpoint => null;

  @override
  Future<LoginResult> completeOAuth(String callbackUrl) async {
    throw UnimplementedError();
  }

  @override
  Future<String> initiateOAuth(String handle) async {
    throw UnimplementedError();
  }

  @override
  Future<String> initiateOAuthWithoutLoginHint() async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<bool> refreshToken() async => false;

  @override
  Future<bool> validateSession() async => true;
}
