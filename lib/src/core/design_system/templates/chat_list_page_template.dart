import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/components/atoms/tab_item.dart';
import 'package:spark/src/core/design_system/components/molecules/app_tab_bar.dart';
import 'package:spark/src/core/design_system/components/molecules/glass_avatar.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

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
    required this.selectedTabIndex,
    required this.onTabChanged,
    super.key,
    this.title = 'Chat',
    this.onAddTap,
    this.onSearchTap,
    this.activityWidget,
    this.onRefresh,
  });

  final String title;
  final List<ChatListItemData> items;
  final void Function(int index) onItemTap;
  final int selectedTabIndex;
  final void Function(int index) onTabChanged;
  final VoidCallback? onAddTap;
  final VoidCallback? onSearchTap;
  final Widget? activityWidget;
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
          _Tabs(selectedIndex: selectedTabIndex, onChanged: onTabChanged),
          Expanded(
            child: selectedTabIndex == 0
                ? RefreshIndicator(
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
                  )
                : (activityWidget ?? const SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.selectedIndex, required this.onChanged});
  final int selectedIndex;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactive = theme.colorScheme.onSurface.withAlpha(179);

    return AppTabBar(
      tabs: [
        AppTabItem(
          activeChild: const Text(
            'Messages',
            style: AppTypography.textMediumBold,
          ),
          inactiveChild: Text(
            'Messages',
            style: AppTypography.textMediumBold.copyWith(color: inactive),
          ),
          isSelected: selectedIndex == 0,
          onTap: () => onChanged(0),
          indicatorColor: theme.colorScheme.onSurface,
        ),
        // AppTabItem(
        //   activeChild: Text(
        //     'Activity',
        //     style: AppTypography.textMediumBold.copyWith(
        //       color: theme.colorScheme.onSurface,
        //     ),
        //   ),
        //   inactiveChild: Text(
        //     'Activity',
        //     style: AppTypography.textMediumBold.copyWith(color: inactive),
        //   ),
        //   isSelected: selectedIndex == 1,
        //   onTap: () => onChanged(1),
        //   indicatorColor: theme.colorScheme.onSurface,
        // ),
      ],
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
      leading: GlassAvatar(
        imageUrl: data.avatarUrl ?? '',
        username: data.handle,
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
