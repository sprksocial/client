import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/avatar_widget.dart';

class UserListTile extends StatelessWidget {
  final ProfileView user;

  const UserListTile({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AvatarWidget(avatarUrl: user.avatar.toString()),
      title: Text(user.displayName ?? user.handle),
      subtitle: Text('@${user.handle}'),
      onTap: () {
        context.router.push(ProfileRoute(did: user.did));
      },
    );
  }
}
