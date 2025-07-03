import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message_models.dart';
import 'package:sparksocial/src/core/widgets/image_content.dart';
import 'package:sparksocial/src/core/widgets/video_content.dart';
import 'package:sparksocial/src/features/messages/ui/pages/chat_page.dart';
import 'package:sparksocial/src/features/messages/ui/widgets/message_bubble.dart';

class MessagesList extends StatelessWidget {
  const MessagesList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.currentUserDid,
    required this.otherUserHandle,
    required this.otherUserAvatar,
  });

  final List<Message> messages;
  final ScrollController scrollController;
  final String? currentUserDid;
  final String? otherUserHandle;
  final String? otherUserAvatar;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.chat_24_regular, size: 64, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message to start the conversation',
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isCurrentUser = message.senderDid == currentUserDid;
        final showAvatar = !isCurrentUser && (index == messages.length - 1 || messages[index + 1].senderDid != message.senderDid);

        List<Widget>? embeds;

        if (message.embed?.isNotEmpty ?? false) {
          List<String> images = [];
          List<String> videos = [];
          for (final embed in message.embed!) {
            if (embed.type == 'image') {
              if (embed.url?.isNotEmpty ?? false) {
                images.add(embed.url!);
              }
            } else if (embed.type == 'video') {
              if (embed.url?.isNotEmpty ?? false) {
                videos.add(embed.url!);
              }
            } else if (embed.type == 'link') {
            } // eventually audios perhaps..
          }
          if (images.isNotEmpty) {
            embeds ??= [];
            embeds.add(ImageContent(imageUrls: images, borderRadius: BorderRadius.circular(12), thumbnailSize: 120));
          }
          if (videos.isNotEmpty) {
            embeds ??= [];
            for (var videoUrl in videos) {
              embeds.add(VideoContent(borderRadius: BorderRadius.circular(12), videoUrl: videoUrl));
            }
          }
        }

        return Column(
          children: [
            MessageBubble(
              message: message,
              isCurrentUser: isCurrentUser,
              showAvatar: showAvatar,
              otherUserAvatar: otherUserAvatar,
              otherUserHandle: otherUserHandle,
            ),
            if (embeds != null) ...embeds.map(
              (embed) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: embed,
              ),
            ),
          ],
        );
      },
    );
  }
}
