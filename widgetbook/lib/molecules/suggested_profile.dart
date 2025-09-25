import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/suggested_profile.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

const _demoImage = 'https://picsum.photos/200/200';

@UseCase(name: 'follow_card', type: SuggestedProfile)
Widget buildSuggestedProfileFollowCardUseCase(BuildContext context) {
  final isFollowing = context.knobs.boolean(
    label: 'is_following',
    initialValue: false,
  );
  return Center(
    child: SuggestedProfile(
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
