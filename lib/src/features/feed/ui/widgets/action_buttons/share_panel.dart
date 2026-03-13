import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/long_button.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/messages/providers/conversation_provider.dart';
import 'package:spark/src/features/messages/providers/conversations_provider.dart';

class SharePanel extends ConsumerStatefulWidget {
  const SharePanel({required this.shareUrl, required this.atUri, super.key});

  final String shareUrl;
  final String atUri;

  @override
  ConsumerState<SharePanel> createState() => _SharePanelState();
}

class _SharePanelState extends ConsumerState<SharePanel> {
  static const _actionButtonHeight = 40.0;
  static const _motionDuration = Duration(milliseconds: 300);
  static const _motionCurve = Curves.easeOutCubic;

  bool _copiedLink = false;
  String? _selectedConvoId;
  bool _sending = false;

  void _toggleSelection(String convoId) {
    setState(() {
      _selectedConvoId = _selectedConvoId == convoId ? null : convoId;
    });
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: widget.shareUrl));
    setState(() => _copiedLink = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _copiedLink = false);
    });
  }

  Future<void> _shareNatively() async {
    final logger = GetIt.instance<LogService>().getLogger('SharePanel');
    try {
      await SharePlus.instance.share(
        ShareParams(uri: Uri.parse(widget.shareUrl)),
      );
    } catch (e, st) {
      logger.e('Failed to open native share sheet', error: e, stackTrace: st);
    }
  }

  Future<void> _sendToSelectedConversation() async {
    final convoId = _selectedConvoId;
    if (convoId == null || _sending) return;

    final logger = GetIt.instance<LogService>().getLogger('SharePanel');
    final navigator = Navigator.of(context);

    setState(() => _sending = true);
    try {
      await ref.read(conversationProvider(convoId).future);
      await ref
          .read(conversationProvider(convoId).notifier)
          .sendMessage(convoId, '', embed: widget.atUri);

      navigator.maybePop();
    } catch (e, st) {
      logger.e(
        'Failed to share video to conversation',
        error: e,
        stackTrace: st,
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final dividerColor = theme.colorScheme.outline.withValues(alpha: 0.2);
    final convosAsync = ref.watch(conversationsProvider);
    final hasSelection = _selectedConvoId != null;

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
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  'Share',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(color: dividerColor, height: 30),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: convosAsync.when(
                  data: (data) {
                    final items = data.conversations;
                    if (items.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Text(
                          'No conversations yet',
                          style: TextStyle(color: textColor.withAlpha(153)),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 112,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 5),
                        itemBuilder: (_, index) {
                          final (profile, convo) = items[index];
                          return _ConvoProfileChip(
                            displayName: profile.displayName ?? profile.handle,
                            avatarUrl: profile.avatar?.toString(),
                            selected: _selectedConvoId == convo.id,
                            onTap: () => _toggleSelection(convo.id),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const _ConvoProfilesSkeleton(),
                  error: (e, st) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Text(
                      'Failed to load conversations',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  height: _actionButtonHeight,
                  child: AnimatedSwitcher(
                    duration: _motionDuration,
                    switchInCurve: _motionCurve,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final fadeAnimation = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      );
                      if (!hasSelection) {
                        return FadeTransition(
                          opacity: fadeAnimation,
                          child: child,
                        );
                      }
                      final scaleAnimation = Tween<double>(begin: 0.7, end: 1)
                          .animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            ),
                          );
                      return FadeTransition(
                        opacity: fadeAnimation,
                        child: ScaleTransition(
                          scale: scaleAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: hasSelection
                        ? SizedBox(
                            key: const ValueKey('selected-actions'),
                            width: double.infinity,
                            child: LongButton(
                              label: _sending ? 'Sending...' : 'Send',
                              onPressed: _sending
                                  ? null
                                  : _sendToSelectedConversation,
                            ),
                          )
                        : Row(
                            key: const ValueKey('default-actions'),
                            children: [
                              Expanded(
                                child: LongButton(
                                  label: _copiedLink ? 'Copied' : 'Copy link',
                                  onPressed: _copyLink,
                                  variant: LongButtonVariant.regular,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: LongButton(
                                  label: 'Share',
                                  onPressed: _shareNatively,
                                  variant: LongButtonVariant.regular,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConvoProfileChip extends StatelessWidget {
  const _ConvoProfileChip({
    required this.displayName,
    required this.avatarUrl,
    required this.selected,
    required this.onTap,
  });

  final String displayName;
  final String? avatarUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    const avatarSize = 64.0;
    const motionDuration = Duration(milliseconds: 300);
    const motionCurve = Curves.easeOutCubic;

    return SizedBox(
      width: 82,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: AnimatedScale(
            duration: motionDuration,
            curve: motionCurve,
            scale: selected ? 1 : 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      width: avatarSize,
                      height: avatarSize,
                      child: ClipOval(
                        child: (avatarUrl != null && avatarUrl!.isNotEmpty)
                            ? CachedNetworkImage(
                                fadeInDuration: Duration.zero,
                                imageUrl: avatarUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    _FallbackAvatar(
                                      displayName: displayName,
                                      theme: theme,
                                    ),
                              )
                            : _FallbackAvatar(
                                displayName: displayName,
                                theme: theme,
                              ),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: AnimatedScale(
                        duration: motionDuration,
                        curve: motionCurve,
                        scale: selected ? 1 : 0,
                        child: AnimatedOpacity(
                          duration: motionDuration,
                          curve: motionCurve,
                          opacity: selected ? 1 : 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.check,
                              size: 15,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedDefaultTextStyle(
                  duration: motionDuration,
                  curve: motionCurve,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConvoProfilesSkeleton extends StatelessWidget {
  const _ConvoProfilesSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skeletonColor = theme.colorScheme.surfaceContainerHighest;

    return SizedBox(
      height: 112,
      child: Skeletonizer(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (_, index) {
            return SizedBox(
              width: 82,
              child: Transform.scale(
                scale: 0.9,
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Skeleton.leaf(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: skeletonColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Skeleton.leaf(
                      child: Container(
                        width: 58,
                        height: 13,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: skeletonColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.displayName, required this.theme});

  final String displayName;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
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
    );
  }
}
