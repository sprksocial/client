import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/messages/providers/conversation_provider.dart';
import 'package:spark/src/features/messages/providers/conversations_provider.dart';

class SharePanel extends ConsumerStatefulWidget {
  const SharePanel({
    required this.shareUrl,
    required this.embedCode,
    required this.atUri,
    super.key,
    this.showEmbed = true,
  });
  final String shareUrl;
  final String embedCode;
  final String atUri;
  final bool showEmbed;

  @override
  ConsumerState<SharePanel> createState() => _SharePanelState();
}

class _SharePanelState extends ConsumerState<SharePanel> {
  bool _copiedLink = false;
  bool _copiedEmbed = false;
  String? _selectedConvoId;
  bool _sending = false;

  void _copyToClipboard(String text, BuildContext context, bool isLink) {
    Clipboard.setData(ClipboardData(text: text));

    setState(() {
      if (isLink) {
        _copiedLink = true;
      } else {
        _copiedEmbed = true;
      }
    });

    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: theme.colorScheme.onPrimary),
            const SizedBox(width: 12),
            Text(isLink ? 'Video link copied!' : 'Embed code copied!'),
          ],
        ),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * 0.9,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          if (isLink) {
            _copiedLink = false;
          } else {
            _copiedEmbed = false;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final fieldBgColor = theme.colorScheme.surfaceContainerHighest;
    final dividerColor = theme.colorScheme.outline.withValues(alpha: 0.2);

    final convosAsync = ref.watch(conversationsProvider);

    final logger = GetIt.instance<LogService>().getLogger('SharePanel');

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: dividerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Share Video',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(color: dividerColor, height: 30),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    // Conversations selector
                    Text(
                      'Send to',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (_) {
                        return convosAsync.when(
                          data: (data) {
                            final items = data.conversations;
                            if (items.isEmpty) {
                              return Text(
                                'No conversations yet',
                                style: TextStyle(
                                  color: textColor.withAlpha(153),
                                ),
                              );
                            }
                            return Column(
                              children: [
                                for (final (profile, convo) in items)
                                  _ConvoListTile(
                                    displayName:
                                        profile.displayName ?? profile.handle,
                                    handle: profile.handle,
                                    avatarUrl: profile.avatar?.toString(),
                                    selected: _selectedConvoId == convo.id,
                                    onAvatarTap: () {
                                      setState(
                                        () => _selectedConvoId = convo.id,
                                      );
                                    },
                                    onTileTap: () {
                                      setState(
                                        () => _selectedConvoId = convo.id,
                                      );
                                    },
                                  ),
                              ],
                            );
                          },
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (e, st) => Text(
                            'Failed to load conversations',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Divider(color: dividerColor),
                    const SizedBox(height: 16),
                    Text(
                      'Video link',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CopyField(
                      text: widget.shareUrl,
                      context: context,
                      bgColor: fieldBgColor,
                      textColor: textColor,
                      isLink: true,
                      isCopied: _copiedLink,
                      onCopy: _copyToClipboard,
                    ),
                    if (widget.showEmbed) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Video embed',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CopyField(
                        text: widget.embedCode,
                        context: context,
                        bgColor: fieldBgColor,
                        textColor: textColor,
                        isLink: false,
                        isCopied: _copiedEmbed,
                        onCopy: _copyToClipboard,
                      ),
                    ],
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: (_selectedConvoId == null || _sending)
                          ? null
                          : () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);

                              setState(() => _sending = true);
                              try {
                                final convoId = _selectedConvoId!;
                                // Ensure conversation is loaded before sending
                                await ref.read(
                                  conversationProvider(convoId).future,
                                );
                                // Send empty message with embed set to post URI
                                await ref
                                    .read(
                                      conversationProvider(convoId).notifier,
                                    )
                                    .sendMessage(
                                      convoId,
                                      '',
                                      embed: widget.atUri,
                                    );

                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Shared to conversation'),
                                  ),
                                );
                                navigator.maybePop();
                              } catch (e) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to share: $e'),
                                  ),
                                );
                                logger.d(
                                  'Failed to share video to conversation',
                                  error: e,
                                );
                              } finally {
                                if (mounted) setState(() => _sending = false);
                              }
                            },
                      icon: _sending
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  theme.colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: const Text('Share'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CopyField extends StatelessWidget {
  const CopyField({
    required this.text,
    required this.context,
    required this.bgColor,
    required this.textColor,
    required this.isLink,
    required this.isCopied,
    required this.onCopy,
    super.key,
  });
  final String text;
  final BuildContext context;
  final Color bgColor;
  final Color textColor;
  final bool isLink;
  final bool isCopied;
  final Function(String, BuildContext, bool) onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: textColor.withAlpha(204),
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onCopy(text, context, isLink),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                  child: isCopied
                      ? const Icon(
                          Icons.check_circle,
                          key: ValueKey('copied'),
                          color: Colors.green,
                          size: 20,
                        )
                      : Icon(
                          Icons.content_copy_rounded,
                          key: const ValueKey('copy'),
                          color: accentColor,
                          size: 20,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConvoListTile extends StatelessWidget {
  const _ConvoListTile({
    required this.displayName,
    required this.handle,
    required this.avatarUrl,
    required this.selected,
    required this.onAvatarTap,
    required this.onTileTap,
  });

  final String displayName;
  final String handle;
  final String? avatarUrl;
  final bool selected;
  final VoidCallback onAvatarTap;
  final VoidCallback onTileTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTileTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: onAvatarTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipOval(
                    child: (avatarUrl != null && avatarUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: avatarUrl!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              width: 44,
                              height: 44,
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: Text(
                                  displayName.isNotEmpty
                                      ? displayName.characters.first
                                            .toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: 44,
                            height: 44,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Text(
                                displayName.isNotEmpty
                                    ? displayName.characters.first.toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),
                  if (selected)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@$handle',
                    style: TextStyle(
                      color: textColor.withAlpha(153),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
