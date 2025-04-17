import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/widgets/dialogs/alt_text_dialog.dart';

import 'hashtag_list.dart';
import 'username_label.dart';
import 'video_description.dart';

class VideoInfoBar extends StatelessWidget {
  final String username;
  final String description;
  final List<String> hashtags;
  final bool isSprk;
  final String? altText;
  final VoidCallback? onUsernameTap;
  final Function(String)? onHashtagTap;
  final Function(bool isExpanded)? onDescriptionExpandToggle;

  const VideoInfoBar({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: GestureDetector(onTap: onUsernameTap, child: UsernameLabel(username: username, isSprk: isSprk))),
            if (altText != null && altText!.trim().isNotEmpty) _buildAltButton(context),
          ],
        ),

        const SizedBox(height: 10),

        VideoDescription(text: description, onExpandToggle: onDescriptionExpandToggle),

        const SizedBox(height: 6),

        SizedBox(height: 30, child: HashtagList(hashtags: hashtags, onHashtagTap: onHashtagTap)),
      ],
    );
  }

  Widget _buildAltButton(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha(100),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AltTextDialog(altText: altText!),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(FluentIcons.image_alt_text_20_regular, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text('ALT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
