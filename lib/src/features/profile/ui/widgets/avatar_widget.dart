import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;

  const AvatarWidget({super.key, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null ? const Icon(Icons.person) : null,
    );
  }
}
