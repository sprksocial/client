import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/toggles/follow_button.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'follow_states', type: FollowButton)
Widget buildFollowButtonFollowStatesUseCase(BuildContext context) {
  final isFollowing = context.knobs.boolean(
    label: 'is_following',
    initialValue: false,
  );
  return Center(
    child: FollowButton(
      isFollowing: isFollowing,
      onFollow: () => print('Follow pressed'),
      onUnfollow: () => print('Unfollow pressed'),
      followText: context.knobs.string(
        label: 'follow_text',
        initialValue: 'Follow',
      ),
      unfollowText: context.knobs.string(
        label: 'unfollow_text',
        initialValue: 'Unfollow',
      ),
    ),
  );
}
