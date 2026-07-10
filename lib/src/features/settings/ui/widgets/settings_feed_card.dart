import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/shapes.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

enum SettingsFeedCardMode { display, edit }

class SettingsFeedCard extends ConsumerWidget {
  const SettingsFeedCard({
    required this.feed,
    required this.mode,
    required this.index,
    this.interactionEnabled = true,
    super.key,
  });

  final Feed feed;
  final SettingsFeedCardMode mode;
  final int index;
  final bool interactionEnabled;

  GeneratorView? get _generator => feed.view;

  bool get _isTimeline => feed.type == 'timeline';

  bool get _isLiked => _generator?.viewer?.like != null;

  bool get _canDelete =>
      !(feed.type == 'timeline' && feed.config.value == 'following');

  String _getTitle(AppLocalizations l10n) {
    return _generator?.displayName ??
        (_isTimeline ? l10n.labelFollowing : feed.config.value);
  }

  String? _getSubtitle(AppLocalizations l10n) {
    if (_generator != null) {
      return l10n.labelFeedByCreator(_generator!.creator.handle);
    }
    return _isTimeline ? l10n.messagePostsFromFollowing : null;
  }

  Future<void> _selectFeed(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(settingsProvider.notifier).setActiveFeed(feed);
    } catch (_) {
      if (!context.mounted) return;
      _showFeedUpdateError(context);
    }
  }

  Future<void> _deleteFeed(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(settingsProvider.notifier).removeFeed(feed);
    } catch (_) {
      if (!context.mounted) return;
      _showFeedUpdateError(context);
    }
  }

  Future<void> _setLiked(
    BuildContext context,
    WidgetRef ref, {
    required bool liked,
  }) async {
    try {
      await ref
          .read(settingsProvider.notifier)
          .setFeedLiked(feed, liked: liked);
    } catch (_) {
      if (!context.mounted) return;
      _showFeedUpdateError(context);
    }
  }

  void _showFeedUpdateError(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.errorUpdatingFeeds)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return _SettingsFeedCardView(
      title: _getTitle(l10n),
      subtitle: _getSubtitle(l10n),
      avatarUrl: _generator?.avatar?.toString() ?? '',
      mode: mode,
      index: index,
      isTimeline: _isTimeline,
      isLiked: _isLiked,
      onTap:
          mode == SettingsFeedCardMode.display &&
              interactionEnabled &&
              feed.config.pinned
          ? () => _selectFeed(context, ref)
          : null,
      onDelete: mode == SettingsFeedCardMode.edit && _canDelete
          ? () => _deleteFeed(context, ref)
          : null,
      onLikedChanged: _generator != null
          ? (liked) => _setLiked(context, ref, liked: liked)
          : null,
    );
  }
}

class _SettingsFeedCardView extends StatelessWidget {
  const _SettingsFeedCardView({
    required this.title,
    required this.subtitle,
    required this.avatarUrl,
    required this.mode,
    required this.index,
    required this.isTimeline,
    required this.isLiked,
    required this.onTap,
    required this.onDelete,
    required this.onLikedChanged,
  });

  final String title;
  final String? subtitle;
  final String avatarUrl;
  final SettingsFeedCardMode mode;
  final int index;
  final bool isTimeline;
  final bool isLiked;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onLikedChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppShapes.squircleRadius);
    final borderColor = isDark ? AppColors.grey800 : AppColors.grey200;

    if (mode == SettingsFeedCardMode.edit) {
      return _buildEditMode(context, radius, borderColor);
    }

    return _buildDisplayMode(context, radius, borderColor);
  }

  Widget _buildDisplayMode(
    BuildContext context,
    BorderRadius radius,
    Color borderColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.grey700 : AppColors.grey100;

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: borderColor),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(child: _buildTextContent()),
                const SizedBox(width: 8),
                _buildLikeButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditMode(
    BuildContext context,
    BorderRadius radius,
    Color borderColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.grey700 : AppColors.grey100;

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(child: _buildTextContent()),
              const SizedBox(width: 8),
              _buildDeleteButton(),
              const SizedBox(width: 8),
              _buildDragHandle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 40,
        height: 40,
        child: avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackAvatar(),
              )
            : _buildFallbackAvatar(),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return ColoredBox(
      color: AppColors.primary600,
      child: Icon(
        isTimeline
            ? FluentIcons.people_24_regular
            : FluentIcons.feed_24_regular,
        size: 20,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTypography.textSmallBold,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: AppTypography.textExtraSmallThin,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ],
    );
  }

  Widget _buildDragHandle() {
    return ReorderableDragStartListener(
      index: index,
      child: Icon(
        Icons.drag_indicator,
        size: 20,
        color: Colors.grey.withAlpha(178),
      ),
    );
  }

  Widget _buildLikeButton() {
    if (isTimeline) return const SizedBox.shrink();

    return InteractivePressable(
      onTap: onLikedChanged == null ? null : () => onLikedChanged!(!isLiked),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLiked ? AppColors.primary600 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isLiked ? AppColors.primary600 : Colors.grey.withAlpha(100),
          ),
        ),
        child: isLiked
            ? AppIcons.likeFilled(size: 16, color: Colors.white)
            : AppIcons.like(size: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildDeleteButton() {
    if (onDelete == null) return const SizedBox.shrink();

    return InteractivePressable(
      onTap: onDelete,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade500,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.delete, size: 16, color: Colors.white),
      ),
    );
  }
}
