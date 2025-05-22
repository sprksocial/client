import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/messages/data/models/message_data.dart';
import 'package:sparksocial/src/features/messages/ui/widgets/message_list.dart';

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key, required this.messages, required this.onMessageTap});

  final List<MessageData> messages;
  final Function(MessageData) onMessageTap;

  @override
  Widget build(BuildContext context) {
    final logger = GetIt.instance<LogService>().getLogger('MessagesTab');
    logger.d('Building MessagesTab with ${messages.length} messages');

    return MessageList(
      messages: messages,
      onMessageTap: (message) {
        logger.d('Tapped on message: ${message.id}');
        onMessageTap(message);
      },
    );
  }
}
