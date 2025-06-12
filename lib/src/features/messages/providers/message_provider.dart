import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message.dart';
import 'package:sparksocial/src/core/network/messages/data/repositories/chat_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/messages/providers/chat_provider.dart';

part 'message_provider.g.dart';

/// Provider for managing messages in a specific conversation
@riverpod
class ConversationMessages extends _$ConversationMessages {
  late final SparkLogger _logger;
  late final ChatRepository _chatRepository;

  @override
  Stream<List<ChatMessage>> build(String conversationId) {
    _logger = GetIt.instance<LogService>().getLogger('ConversationMessages');
    _chatRepository = GetIt.instance<ChatRepository>();

    _logger.d('Building message stream for conversation: $conversationId');

    // Return the stream from the repository
    return _chatRepository.streamMessages(conversationId: conversationId);
  }
}

/// Family provider for getting messages synchronously from the chat provider
@riverpod
List<ChatMessage> conversationMessagesSync(Ref ref, String conversationId) {
  final chatNotifier = ref.watch(chatProvider.notifier);
  return chatNotifier.getMessages(conversationId);
}

/// Provider for sending messages
@riverpod
class MessageSender extends _$MessageSender {
  late final SparkLogger _logger;

  @override
  AsyncValue<ChatMessage?> build() {
    _logger = GetIt.instance<LogService>().getLogger('MessageSender');
    return const AsyncValue.data(null);
  }

  /// Sends a message to a conversation
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    List<String>? attachments,
  }) async {
    state = const AsyncValue.loading();

    try {
      final chatNotifier = ref.read(chatProvider.notifier);
      final sentMessage = await chatNotifier.sendMessage(
        conversationId: conversationId,
        content: content,
        type: type,
        replyToMessageId: replyToMessageId,
        attachments: attachments,
      );

      state = AsyncValue.data(sentMessage);
      return sentMessage;
    } catch (e, stackTrace) {
      _logger.e('Failed to send message', error: e, stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

/// Provider for message actions (mark as read, etc.)
@riverpod
class MessageActions extends _$MessageActions {
  late final SparkLogger _logger;

  @override
  AsyncValue<void> build() {
    _logger = GetIt.instance<LogService>().getLogger('MessageActions');
    return const AsyncValue.data(null);
  }

  /// Marks a conversation as read
  Future<void> markAsRead(String conversationId) async {
    state = const AsyncValue.loading();

    try {
      final chatNotifier = ref.read(chatProvider.notifier);
      await chatNotifier.markAsRead(conversationId);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _logger.e('Failed to mark conversation as read', error: e, stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}