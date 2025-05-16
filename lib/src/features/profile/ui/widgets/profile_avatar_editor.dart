import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/profile/data/models/edit_profile_state.dart';
import 'package:sparksocial/src/features/profile/providers/edit_profile_provider.dart';

/// Widget for editing the profile avatar
class ProfileAvatarEditor extends StatelessWidget {
  /// Current state of the profile being edited
  final EditProfileState state;
  
  /// The notifier to trigger actions on the profile
  final EditProfile notifier;

  /// Creates a profile avatar editor
  const ProfileAvatarEditor({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? avatarImageProvider;
    
    if (state.localAvatar is Uint8List) {
      avatarImageProvider = MemoryImage(state.localAvatar as Uint8List);
    } else if (state.localAvatar is String) {
      avatarImageProvider = CachedNetworkImageProvider(state.localAvatar as String);
    }
    
    return Stack(
      alignment: Alignment.topRight,
      children: [
        GestureDetector(
          onTap: notifier.pickAvatar,
          child: CircleAvatar(
            radius: 50,
            backgroundImage: avatarImageProvider,
            child: avatarImageProvider == null 
                ? const Icon(Icons.person, size: 50) 
                : null,
          ),
        ),
        if (state.localAvatar is Uint8List)
          IconButton(
            icon: const Icon(Icons.undo), 
            onPressed: notifier.revertAvatar, 
            color: AppColors.pink,
          ),
      ],
    );
  }
} 