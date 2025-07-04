import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message_models.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/messages/ui/widgets/sender_avatar.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.showAvatar,
    required this.otherUserAvatar,
    required this.otherUserHandle,
  });

  final Message message;
  final bool isCurrentUser;
  final bool showAvatar;
  final String? otherUserAvatar;
  final String? otherUserHandle;
  String _removeLinksFromText(String text) {
    // Regex pattern to match URLs
    final urlPattern = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false,
    );
    
    String cleanedText = text.replaceAll(urlPattern, '').trim();
    
    // Clean up multiple spaces and newlines that might be left after URL removal
    cleanedText = cleanedText.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleanedText;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser && showAvatar) ...[
            SenderAvatar(isCurrentUser: false, otherUserAvatar: otherUserAvatar, otherUserHandle: otherUserHandle),
            const SizedBox(width: 8),
          ] else if (!isCurrentUser) ...[
            const SizedBox(width: 40),
          ],
          Flexible(
            child: () {
              final cleanedMessage = _removeLinksFromText(message.message);
              // Only show the bubble if there's text content after removing links
              if (cleanedMessage.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? AppColors.primary
                      : isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cleanedMessage,
                  style: TextStyle(
                    color: isCurrentUser
                        ? Colors.white
                        : isDarkMode
                        ? Colors.white
                        : Colors.black,
                    fontSize: 16,
                  ),
                ),
              );
            }(),
          ),
        ],
      ),
    );
  }
}
