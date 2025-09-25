import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/story_circle.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

const _demoImage = 'https://picsum.photos/200/200';

@UseCase(name: 'story', type: StoryCircle)
Widget buildStoryCircleStoryUseCase(BuildContext context) {
  return Center(
    child: StoryCircle.story(
      userName: context.knobs.string(label: 'user', initialValue: 'alice'),
      imageUrl: _demoImage,
    ),
  );
}

@UseCase(name: 'live', type: StoryCircle)
Widget buildStoryCircleLiveUseCase(BuildContext context) {
  return Center(
    child: StoryCircle.live(
      userName: context.knobs.string(label: 'user', initialValue: 'streamer'),
      imageUrl: _demoImage,
      live: context.knobs.string(label: 'badge_text', initialValue: 'LIVE'),
    ),
  );
}

@UseCase(name: 'close_friends', type: StoryCircle)
Widget buildStoryCircleCloseFriendsUseCase(BuildContext context) {
  return Center(
    child: StoryCircle.cf(
      userName: context.knobs.string(label: 'user', initialValue: 'buddy'),
      imageUrl: _demoImage,
    ),
  );
}

@UseCase(name: 'create', type: StoryCircle)
Widget buildStoryCircleCreateUseCase(BuildContext context) {
  return Center(
    child: StoryCircle.create(
      userName: context.knobs.string(label: 'user', initialValue: 'You'),
      imageUrl: _demoImage,
    ),
  );
}
