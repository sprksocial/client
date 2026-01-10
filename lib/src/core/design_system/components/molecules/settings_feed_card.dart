import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/shapes.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';

enum SettingsFeedCardMode {
  display,
  edit,
}

class SettingsFeedCard extends StatelessWidget {
  const SettingsFeedCard({
    required this.feed,
    required this.mode,
    required this.isActive,
    required this.index,
    this.onTap,
    this.onDelete,
    this.onPin,
    this.onUnpin,
    this.onLike,
    this.onUnlike,
    super.key,
  });

  final Feed feed;
  final SettingsFeedCardMode mode;
  final bool isActive;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;
  final VoidCallback? onUnpin;
  final VoidCallback? onLike;
  final VoidCallback? onUnlike;

  GeneratorView? get generator => feed.view;

  bool get _isTimeline => feed.type == 'timeline';

  bool get _isLiked => feed.view?.viewer?.like != null;

  String get _title {
    if (generator != null) {
      return generator!.displayName;
    }
    return _isTimeline ? 'Following' : feed.config.value;
  }

  String? get _subtitle {
    if (generator != null) {
      return 'by @${generator!.creator.handle}';
    }
    if (_isTimeline) {
      return 'Posts from people you follow';
    }
    return null;
  }

  String get _avatarUrl {
    if (generator?.avatar != null) {
      return generator!.avatar.toString();
    }
    return '';
  }

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
              _buildLikeButton(),
            ],
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
              _buildEditActions(),
              const SizedBox(width: 8),
              _buildDragHandle(index),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: _avatarUrl.isNotEmpty
            ? Image.network(
                _avatarUrl,
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
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary600,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _isTimeline
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
          _title,
          style: AppTypography.textSmallBold,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        if (_subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            _subtitle!,
            style: AppTypography.textExtraSmallThin,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ],
    );
  }

  Widget _buildDragHandle(int index) {
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
    // Don't show like button for timeline
    if (_isTimeline) return const SizedBox.shrink();

    return InteractivePressable(
      onTap: _isLiked ? onUnlike : onLike,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isLiked ? AppColors.primary600 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _isLiked
                ? AppColors.primary600
                : (Colors.grey.withAlpha(100)),
          ),
        ),
        child: _isLiked
            ? AppIcons.likeFilled(
                size: 16,
                color: Colors.white,
              )
            : AppIcons.like(
                size: 16,
                color: Colors.grey,
              ),
      ),
    );
  }

  Widget _buildEditActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onDelete != null) ...[
          const SizedBox(width: 8),
          InteractivePressable(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade500,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.delete,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
