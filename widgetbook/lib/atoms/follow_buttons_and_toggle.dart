import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/toggles/follow_button.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/toggles/glass_follow_button.dart';

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

@UseCase(name: 'glass_follow_states', type: GlassFollowButton)
Widget buildGlassFollowButtonGlassFollowStatesUseCase(BuildContext context) {
  final isFollowing = context.knobs.boolean(
    label: 'is_following',
    initialValue: false,
  );
  return Center(
    child: GlassFollowButton(
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
