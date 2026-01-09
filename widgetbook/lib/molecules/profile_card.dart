import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/molecules/profile_card.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

const _demoImage = 'https://picsum.photos/200/200';

@UseCase(name: 'follow_card', type: ProfileCard)
Widget buildProfileCardFollowCardUseCase(BuildContext context) {
  final isFollowing = context.knobs.boolean(
    label: 'is_following',
    initialValue: false,
  );
  return Center(
    child: ProfileCard(
      imageUrl: _demoImage,
      userName: context.knobs.string(
        label: 'user_name',
        initialValue: 'Jane Doe',
      ),
      userHandle: context.knobs.string(
        label: 'user_handle',
        initialValue: '@janedoe',
      ),
      isFollowing: isFollowing,
      onFollow: () => print('Follow'),
      onUnfollow: () => print('Unfollow'),
    ),
  );
}
