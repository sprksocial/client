import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

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
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  content: SingleChildScrollView(
                    child: Text(altText!, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
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
