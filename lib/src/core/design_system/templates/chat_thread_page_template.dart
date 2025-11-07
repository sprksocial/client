import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/glass_input.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/profile_avatar.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

class ChatThreadPageTemplate extends StatelessWidget {
  const ChatThreadPageTemplate({
    required this.displayName,
    required this.handle,
    required this.messagesWidget,
    required this.textController,
    required this.onSend,
    super.key,
    this.avatarUrl,
  });

  final String displayName;
  final String handle;
  final String? avatarUrl;
  final Widget messagesWidget;
  final TextEditingController textController;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: const AppLeadingButton(),
        title: Row(
          children: [
            ProfileAvatar(avatarUrl: avatarUrl, displayName: displayName, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: AppTypography.textMediumBold.copyWith(color: theme.colorScheme.onSurface)),
                  Text(
                    '@$handle',
                    style: AppTypography.textExtraSmallThin.copyWith(color: theme.colorScheme.onSurface.withAlpha(170)),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(height: 0.5, width: double.infinity, color: theme.colorScheme.outline),
          Expanded(child: messagesWidget),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: GlassInput.chat(
                controller: textController,
                hintText: 'Message...',
                onSendMessage: onSend,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
