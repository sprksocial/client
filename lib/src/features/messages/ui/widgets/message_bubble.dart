import 'package:flutter/material.dart';
import 'package:spark/src/core/network/messages/data/models/message_models.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/features/messages/ui/widgets/sender_avatar.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    required this.isCurrentUser,
    required this.showAvatar,
    required this.otherUserAvatar,
    required this.otherUserHandle,
    this.embeds,
    super.key,
  });

  final MessageView message;
  final bool isCurrentUser;
  final bool showAvatar;
  final String? otherUserAvatar;
  final String? otherUserHandle;
  final List<Widget>? embeds;
  String _removeLinksFromText(String text) {
    // Regex pattern to match URLs
    final urlPattern = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false,
    );

    var cleanedText = text.replaceAll(urlPattern, '').trim();

    // Clean up spaces and newlines that might be left after URL removal
    return cleanedText = cleanedText.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    final cleanedMessage = _removeLinksFromText(message.text);
    final hasEmbeds = embeds != null && embeds!.isNotEmpty;
    final hasText = cleanedMessage.isNotEmpty;

    if (!hasText && !hasEmbeds) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser && showAvatar) ...[
            SenderAvatar(
              isCurrentUser: false,
              otherUserAvatar: otherUserAvatar,
              otherUserHandle: otherUserHandle,
            ),
            const SizedBox(width: 8),
          ] else if (!isCurrentUser) ...[
            const SizedBox(width: 40),
          ],
          if (!hasText && hasEmbeds)
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: embeds!,
              ),
            )
          else
            Flexible(
              child: Container(
                padding: hasEmbeds
                    ? const EdgeInsets.symmetric(horizontal: 2, vertical: 2)
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? AppColors.primary
                      : isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasEmbeds) ...embeds!,
                    if (hasEmbeds && hasText) const SizedBox(height: 2),
                    if (hasText) Text(cleanedMessage),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
