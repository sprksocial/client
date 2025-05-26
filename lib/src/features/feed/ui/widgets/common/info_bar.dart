import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/common/alt_text_dialog.dart';

import 'hashtag_list.dart';
import 'post_source.dart';
import 'description.dart';

class InfoBar extends StatelessWidget {
  final String username;
  final String description;
  final List<String> hashtags;
  final bool isSprk;
  final String? altText;
  final VoidCallback? onUsernameTap;
  final Function(String)? onHashtagTap;
  final Function(bool isExpanded)? onDescriptionExpandToggle;

  const InfoBar({
    super.key,
    required this.username,
    required this.description,
    required this.hashtags,
    this.isSprk = false,
    this.altText,
    this.onUsernameTap,
    this.onHashtagTap,
    this.onDescriptionExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    final hasDescription = description.isNotEmpty;
    final hasHashtags = hashtags.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: GestureDetector(onTap: onUsernameTap, child: PostSource(username: username, isSprk: isSprk))),
            if (altText != null && altText!.trim().isNotEmpty) _AltButton(altText: altText!),
          ],
        ),

        if (hasDescription) const SizedBox(height: 10),

        Description(text: description, onExpandToggle: onDescriptionExpandToggle),

        if (hasDescription && hasHashtags) const SizedBox(height: 6),

        if (hasHashtags) SizedBox(height: 25, child: HashtagList(hashtags: hashtags, onHashtagTap: onHashtagTap)),

        const SizedBox(height: 25),
      ],
    );
  }
}

class _AltButton extends StatelessWidget {
  final String altText;

  const _AltButton({required this.altText});

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(FluentIcons.image_alt_text_20_regular, color: AppColors.white, size: 18),
              SizedBox(width: 6),
              Text('ALT', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
