import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/messages/data/models/message_models.dart';
import 'package:spark/src/features/messages/ui/widgets/messages_list.dart';
import 'package:spark/src/features/messages/ui/widgets/sender_avatar.dart';

void main() {
  testWidgets('groups consecutive incoming messages under one sender avatar', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: MessagesList(
              messages: [
                _message(id: '1', text: 'First', senderDid: 'did:other'),
                _message(id: '2', text: 'Second', senderDid: 'did:other'),
                _message(id: '3', text: 'Reply', senderDid: 'did:me'),
              ],
              scrollController: scrollController,
              currentUserDid: 'did:me',
              otherUserHandle: 'alice.example',
              otherUserAvatar: null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    expect(find.text('Reply'), findsOneWidget);
    expect(find.byType(SenderAvatar), findsOneWidget);
  });
}

ChatMessageView _message({
  required String id,
  required String text,
  required String senderDid,
}) {
  return ChatMessageView.message(
    data: MessageView(
      id: id,
      rev: 'rev-$id',
      text: text,
      sender: SenderView(did: senderDid),
      sentAt: '2026-07-22T12:00:00.000Z',
      reactions: const [],
    ),
  );
}
