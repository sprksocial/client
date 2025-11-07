import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/features/messages/providers/conversation_provider.dart';

part 'polling_timer.g.dart';

@riverpod
void pollingTrigger(Ref ref, String convoId) {
  final timer = Timer.periodic(const Duration(seconds: 5), (timer) {
    ref.read(conversationProvider(convoId).notifier).checkForNewMessages();
  });

  ref.onDispose(timer.cancel);
}
