import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/templates/info_bar_template.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/features/feed/ui/widgets/post/alt_text_dialog.dart';

/// Adapter widget to keep feature layer API stable while migrating to
/// the Design System `InfoBarTemplate`.
class InfoBar extends StatelessWidget {
  const InfoBar({
    required this.username,
    required this.displayName,
    required this.description,
    required this.hashtags,
    super.key,
    this.avatarUrl,
    this.informLabels = const [],
    this.isSprk = false,
    this.altText,
    this.onUsernameTap,
    this.onAvatarTap,
    this.onHashtagTap,
    this.onDescriptionExpandToggle,
    this.audio,
  });
  final String username;
  final String displayName;
  final String description;
  final List<String> hashtags;
  final String? avatarUrl;
  final List<String> informLabels;
  final bool isSprk;
  final String? altText;
  final VoidCallback? onUsernameTap;
  final VoidCallback? onAvatarTap;
  final Function(String)? onHashtagTap;
  final Function(bool isExpanded)? onDescriptionExpandToggle;
  final AudioView? audio;

  @override
  Widget build(BuildContext context) {
    return InfoBarTemplate(
      displayName: displayName,
      handle: username,
      description: description,
      informLabels: informLabels,
      avatarUrl: avatarUrl,
      audio: audio,
      onTitleTap: onUsernameTap,
      onHandleTap: onUsernameTap,
      onAvatarTap: onAvatarTap ?? onUsernameTap,
      onDescriptionExpandToggle: onDescriptionExpandToggle,
      altAvailable: altText != null && altText!.trim().isNotEmpty,
      onAltTap: (altText != null && altText!.trim().isNotEmpty)
          ? () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AltTextDialog(altText: altText!),
              );
            }
          : null,
    );
  }
}
