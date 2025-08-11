import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/ui/foundation/colors.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/post/alt_text_dialog.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/post/description.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/post/hashtag_list.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/post/post_source.dart';

class InfoBar extends StatelessWidget {
  const InfoBar({
    required this.username,
    required this.description,
    required this.hashtags,
    super.key,
    this.informLabels = const [],
    this.isSprk = false,
    this.altText,
    this.onUsernameTap,
    this.onHashtagTap,
    this.onDescriptionExpandToggle,
  });
  final String username;
  final String description;
  final List<String> hashtags;
  final List<String> informLabels;
  final bool isSprk;
  final String? altText;
  final VoidCallback? onUsernameTap;
  final Function(String)? onHashtagTap;
  final Function(bool isExpanded)? onDescriptionExpandToggle;

  @override
  Widget build(BuildContext context) {
    final hasDescription = description.isNotEmpty;
    final hasHashtags = hashtags.isNotEmpty;
    final hasInformLabels = informLabels.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onUsernameTap,
                child: PostSource(username: username, isSprk: isSprk),
              ),
            ),
            if (altText != null && altText!.trim().isNotEmpty) _AltButton(altText: altText!),
          ],
        ),

        if (hasDescription) const SizedBox(height: 10),

        Description(text: description, onExpandToggle: onDescriptionExpandToggle),

        if (hasDescription && hasHashtags) const SizedBox(height: 6),

        if (hasHashtags)
          SizedBox(
            height: 25,
            child: HashtagList(hashtags: hashtags, onHashtagTap: onHashtagTap),
          ),

        if (hasInformLabels && (hasHashtags || hasDescription)) const SizedBox(height: 6),

        if (hasInformLabels) _InformLabels(labels: informLabels),
      ],
    );
  }
}

class _AltButton extends StatelessWidget {
  const _AltButton({required this.altText});
  final String altText;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.black.withAlpha(100),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AltTextDialog(altText: altText),
          );
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.image_alt_text_20_regular, color: AppColors.white, size: 18),
              SizedBox(width: 6),
              Text(
                'ALT',
                style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InformLabels extends StatelessWidget {
  const _InformLabels({required this.labels});
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: labels.map((label) => _InformLabelChip(label: label)).toList(),
    );
  }
}

class _InformLabelChip extends StatelessWidget {
  const _InformLabelChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.blue.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            FluentIcons.info_16_regular,
            color: AppColors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
