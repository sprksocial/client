import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/shapes.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';

class FeedCard extends StatelessWidget {
  const FeedCard({
    required this.feed,
    required this.isAdded,
    required this.onAdd,
    required this.onPin,
    required this.onUnpin,
    this.onTap,
    this.showActionButton = true,
    super.key,
  });

  final Feed feed;
  final bool isAdded;
  final VoidCallback onAdd;
  final VoidCallback onPin;
  final VoidCallback onUnpin;
  final VoidCallback? onTap;
  final bool showActionButton;

  GeneratorView? get generator => feed.view;

  bool get isPinned => feed.config.pinned;

  bool get _isTimeline => feed.type == 'timeline';

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

  String? get _description => generator?.description;

  String get _avatarUrl {
    if (generator?.avatar != null) {
      return generator!.avatar.toString();
    }
    return '';
  }

  bool get _isPrimaryAction => !isAdded || !isPinned;

  String get _actionLabel {
    if (!isAdded) return 'Add feed';
    if (isPinned) return 'Unpin feed';
    return 'Pin feed';
  }

  VoidCallback get _actionCallback {
    if (!isAdded) return onAdd;
    if (isPinned) return onUnpin;
    return onPin;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppShapes.squircleRadius);
    final borderColor = isDark ? AppColors.grey800 : AppColors.grey200;

    final Widget content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Material(
        color: isDark ? AppColors.grey700 : AppColors.grey100,
        shape: RoundedSuperellipseBorder(borderRadius: radius),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: ShapeDecoration(
            shape: RoundedSuperellipseBorder(
              side: BorderSide(color: borderColor),
              borderRadius: radius,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FeedAvatar(imageUrl: _avatarUrl),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextContent(context)),
                    ],
                  ),
                ),
                if (showActionButton) ...[
                  const SizedBox(width: 8),
                  _buildActionButton(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _title,
          style: AppTypography.textSmallBold,
          overflow: TextOverflow.ellipsis,
        ),
        if (_subtitle != null)
          Text(
            _subtitle!,
            style: AppTypography.textSmallThin,
            overflow: TextOverflow.ellipsis,
          ),
        if (_description?.isNotEmpty ?? false) ...[
          const SizedBox(height: 3),
          Text(
            _description!,
            style: AppTypography.textExtraSmallThin,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 4),
        _buildMetaRow(context),
      ],
    );
  }

  Widget _buildMetaRow(BuildContext context) {
    final likeCount = generator?.likeCount ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLiked = generator?.viewer?.like != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLiked)
          AppIcons.likeFilled(size: 14, color: AppColors.primary600)
        else
          AppIcons.like(
            size: 14,
            color: isDark ? AppColors.grey200 : AppColors.grey400,
          ),
        const SizedBox(width: 4),
        Text(_formatCount(likeCount), style: AppTypography.textExtraSmallThin),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPrimary = _isPrimaryAction;
    final backgroundColor = isPrimary
        ? AppColors.primary600
        : isDark
        ? AppColors.darkGreyButton
        : AppColors.lightGreyButton;

    final textStyle = AppTypography.textSmallMedium.copyWith(
      color: isPrimary
          ? Colors.white
          : (isDark ? AppColors.grey100 : AppColors.grey900),
    );

    return InteractivePressable(
      onTap: _actionCallback,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 110,
          minHeight: 36,
          maxHeight: 36,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: isPrimary
              ? null
              : Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : AppColors.grey200,
                  width: 1.1,
                ),
        ),
        alignment: Alignment.center,
        child: Text(
          _actionLabel,
          style: textStyle,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class _FeedAvatar extends StatelessWidget {
  const _FeedAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imageUrl.isEmpty) {
      return _FallbackAvatar(isDark: isDark);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        fadeInDuration: Duration.zero,
        imageUrl: imageUrl,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            _FallbackAvatar(isDark: isDark, showLoader: true),
        errorWidget: (context, url, error) => _FallbackAvatar(isDark: isDark),
      ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.isDark, this.showLoader = false});

  final bool isDark;
  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    const background = AppColors.primary600;
    const iconColor = AppColors.greyWhite;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: showLoader
          ? const Center(
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary500,
                  ),
                ),
              ),
            )
          : const Icon(FluentIcons.feed_24_regular, color: iconColor, size: 18),
    );
  }
}
