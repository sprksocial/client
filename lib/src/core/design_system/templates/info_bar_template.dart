import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/follow_pill_button.dart';
import 'package:spark/src/core/design_system/components/molecules/profile_avatar.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';

class InfoBarTemplate extends StatefulWidget {
  const InfoBarTemplate({
    required this.displayName,
    required this.handle,
    super.key,
    this.description,
    this.descriptionMaxLines = 2,
    this.audio,
    this.informLabels = const [],
    this.showFollowButton = false,
    this.onFollow,
    this.onTitleTap,
    this.onHandleTap,
    this.onAvatarTap,
    this.onDescriptionExpandToggle,
    this.altAvailable = false,
    this.onAltTap,
    this.avatarUrl,
  });

  /// Display name
  final String displayName;

  /// Handle without leading @ (e.g. `katiemiddow.sprk.so`).
  final String handle;

  /// Optional body/description text.
  final String? description;
  final int descriptionMaxLines;

  /// Optional audio view for rich music display.
  final AudioView? audio;

  /// Informational labels (content notices, etc.).
  final List<String> informLabels;

  /// Follow button config. When false, no follow control is rendered.
  final bool showFollowButton;
  final VoidCallback? onFollow;

  /// Interactions.
  final VoidCallback? onTitleTap;
  final VoidCallback? onHandleTap;
  final VoidCallback? onAvatarTap;
  final Function(bool isExpanded)? onDescriptionExpandToggle;

  /// ALT metadata affordance.
  final bool altAvailable;
  final VoidCallback? onAltTap;

  /// Avatar shown on left of the name/handle.
  final String? avatarUrl;

  @override
  State<InfoBarTemplate> createState() => _InfoBarTemplateState();
}

class _InfoBarTemplateState extends State<InfoBarTemplate>
    with SingleTickerProviderStateMixin {
  bool _isDescriptionExpanded = false;

  void _toggleDescription() {
    setState(() => _isDescriptionExpanded = !_isDescriptionExpanded);
    widget.onDescriptionExpandToggle?.call(_isDescriptionExpanded);
  }

  @override
  Widget build(BuildContext context) {
    const textColor = AppColors.greyWhite;

    final hasDescription = widget.description?.isNotEmpty ?? false;
    final hasInform = widget.informLabels.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: widget.onTitleTap,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ProfileAvatar(
                        avatarUrl: widget.avatarUrl,
                        displayName: widget.displayName,
                        size: 32,
                        onTap: widget.onAvatarTap ?? widget.onTitleTap,
                      ),
                    ),

                    Expanded(
                      child: Text(
                        widget.handle,
                        style: AppTypography.textMediumBold.copyWith(
                          color: textColor,
                          fontSize: 17,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.altAvailable) _AltPill(onTap: widget.onAltTap),
                  ],
                ),
              ),
            ),
            if (widget.showFollowButton)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: FollowPillButton(onPressed: widget.onFollow ?? () {}),
              ),
          ],
        ),

        if (hasDescription) const SizedBox(height: 10),

        if (hasDescription)
          GestureDetector(
            onTap: _toggleDescription,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                widget.description!,
                style: AppTypography.textSmallMedium.copyWith(color: textColor),
                maxLines: _isDescriptionExpanded
                    ? null
                    : widget.descriptionMaxLines,
                overflow: _isDescriptionExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
            ),
          ),

        if (hasInform) const SizedBox(height: 8),
        if (hasInform)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final label in widget.informLabels)
                _InformChip(label: label),
            ],
          ),
      ],
    );
  }
}

class _AltPill extends StatelessWidget {
  const _AltPill({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: (isDark ? AppColors.grey600 : AppColors.lightGreyButton).withAlpha(
        180,
      ),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            'ALT',
            style: AppTypography.textExtraSmallMedium.copyWith(
              color: AppColors.greyWhite,
            ),
          ),
        ),
      ),
    );
  }
}

class _InformChip extends StatelessWidget {
  const _InformChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.blue700 : AppColors.blue50;
    final border = isDark ? AppColors.blue600 : AppColors.blue200;
    const text = AppColors.greyWhite;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border.withAlpha(160)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.textExtraSmallMedium.copyWith(color: text),
          ),
        ],
      ),
    );
  }
}
