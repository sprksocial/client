import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/tags/feed_tag.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/tags/hashtag.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/tags/tag.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'default', type: InteractivePressable)
Widget buildInteractivePressableDefaultUseCase(BuildContext context) {
  return Center(
    child: InteractivePressable(
      pressedScale: context.knobs.double.slider(
        label: 'pressedScale',
        initialValue: 0.93,
        min: 0.8,
        max: 1.0,
        divisions: 20,
      ),
      overlayColor: context.knobs.color(
        label: 'overlayColor',
        initialValue: Colors.black26,
      ),
      duration: Duration(
        milliseconds: context.knobs.int.slider(
          label: 'duration_ms',
          initialValue: 120,
          min: 60,
          max: 400,
          divisions: 34,
        ),
      ),
      onTap: () => print('InteractivePressable tapped'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          context.knobs.string(label: 'label', initialValue: 'Press Me'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}

@UseCase(name: 'tag_basic', type: Tag)
Widget buildTagBasicUseCase(BuildContext context) {
  return Center(
    child: Tag(
      mainText: context.knobs.string(label: 'main', initialValue: 'Main'),
      secondaryText: context.knobs.string(
        label: 'secondary',
        initialValue: '42',
      ),
      onTap: () => print('Tag tapped'),
    ),
  );
}

@UseCase(name: 'glassmorphic_tag_with_delete', type: GlassmorphicTag)
Widget buildGlassmorphicTagWithDeleteUseCase(BuildContext context) {
  return Center(
    child: GlassmorphicTag(
      label: context.knobs.string(label: 'label', initialValue: 'hashtag'),
      onTap: () => print('GlassmorphicTag tapped'),
      onDeleted: context.knobs.boolean(label: 'show_delete', initialValue: true)
          ? () => print('Delete pressed')
          : null,
    ),
  );
}

@UseCase(name: 'feed_tag_selected_states', type: FeedTag)
Widget buildFeedTagSelectedStatesUseCase(BuildContext context) {
  final selected = context.knobs.boolean(label: 'selected', initialValue: true);
  return Wrap(
    spacing: 24,
    runSpacing: 16,
    children: [
      FeedTag(
        id: '1',
        text: 'Art',
        selected: selected,
        onTap: () => print('Art tapped'),
      ),
      FeedTag(
        id: '2',
        text: 'Tech',
        selected: !selected,
        onTap: () => print('Tech tapped'),
      ),
    ],
  );
}
