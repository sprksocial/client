import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/ui/widgets/user_avatar.dart';

class ChatListItemData {
  const ChatListItemData({
    required this.displayName,
    required this.handle,
    required this.timestamp,
    required this.preview,
    this.avatarUrl,
    this.verified = false,
    this.unread = false,
  });

  final String? avatarUrl;
  final String displayName;
  final String handle;
  final String timestamp;
  final String preview;
  final bool verified;
  final bool unread;
}

class ChatListPageTemplate extends StatelessWidget {
  const ChatListPageTemplate({
    required this.items,
    required this.onItemTap,
    super.key,
    this.title = 'Chat',
    this.onAddTap,
    this.onSearchTap,
    this.onRefresh,
  });

  final String title;
  final List<ChatListItemData> items;
  final void Function(int index) onItemTap;
  final VoidCallback? onAddTap;
  final VoidCallback? onSearchTap;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: onAddTap,
          icon: AppIcons.addUser(color: theme.colorScheme.onSurface),
        ),
        title: Text(
          title,
          style: AppTypography.textMediumBold.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh ?? () async {},
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox.shrink(),
                itemBuilder: (context, index) => _ChatTile(
                  data: items[index],
                  onTap: () => onItemTap(index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.data, this.onTap});
  final ChatListItemData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return ListTile(
      onTap: onTap,
      horizontalTitleGap: 12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: UserAvatar(
        imageUrl: data.avatarUrl ?? '',
        username: data.handle,
        size: 50.45,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              data.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textLargeBold,
            ),
          ),
          const SizedBox(width: 6),
          if (data.unread) ...[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),

            Text(
              data.timestamp,
              style: AppTypography.textExtraSmallThin.copyWith(
                color: onSurface.withAlpha(160),
              ),
            ),
          ] else ...[
            Text(
              data.timestamp,
              style: AppTypography.textExtraSmallThin.copyWith(
                color: onSurface.withAlpha(160),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        data.preview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: data.unread
            ? AppTypography.textSmallBold.copyWith(
                color: onSurface.withAlpha(190),
              )
            : AppTypography.textSmallMedium.copyWith(
                color: onSurface.withAlpha(190),
              ),
      ),
    );
  }
}
