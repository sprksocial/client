import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/profile/providers/edit_profile_provider.dart';
import 'package:sparksocial/src/features/profile/providers/edit_profile_state.dart';

/// Widget for editing the profile avatar
class ProfileAvatarEditor extends StatefulWidget {
  /// Creates a profile avatar editor
  const ProfileAvatarEditor({required this.state, required this.notifier, super.key});

  /// Current state of the profile being edited
  final EditProfileState state;

  /// The notifier to trigger actions on the profile
  final EditProfile notifier;

  @override
  State<ProfileAvatarEditor> createState() => _ProfileAvatarEditorState();
}

class _ProfileAvatarEditorState extends State<ProfileAvatarEditor> {
  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? avatarImageProvider;

    if (widget.state.localAvatar is Uint8List) {
      avatarImageProvider = MemoryImage(widget.state.localAvatar as Uint8List);
    } else if (widget.state.localAvatar is String) {
      avatarImageProvider = CachedNetworkImageProvider(widget.state.localAvatar as String);
    }

    return Stack(
      alignment: Alignment.topRight,
      children: [
        GestureDetector(
          onTap: () {
            widget.notifier.pickAvatar();
          },
          child: CircleAvatar(
            radius: 50,
            backgroundImage: avatarImageProvider,
            child: avatarImageProvider == null ? const Icon(Icons.person, size: 50) : null,
          ),
        ),
        if (widget.state.localAvatar is Uint8List)
          IconButton(icon: const Icon(Icons.undo), onPressed: widget.notifier.revertAvatar, color: AppColors.pink),
      ],
    );
  }
}
