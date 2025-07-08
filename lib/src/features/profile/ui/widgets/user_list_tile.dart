import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';

class UserListTile extends StatelessWidget {
  final ProfileView user;

  const UserListTile({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatar != null ? CachedNetworkImageProvider(user.avatar.toString()) : null,
        child: user.avatar == null ? const Icon(Icons.person) : null,
      ),
      title: Text(user.displayName ?? user.handle),
      subtitle: Text('@${user.handle}'),
      onTap: () {
        context.router.push(ProfileRoute(did: user.did));
      },
    );
  }
}
