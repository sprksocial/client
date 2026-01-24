import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/molecules/feed_tag_list.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'interactive', type: FeedTagList)
Widget buildFeedTagListInteractiveUseCase(BuildContext context) {
  final tagCount = context.knobs.int.slider(
    label: 'tag_count',
    initialValue: 6,
    min: 2,
    max: 12,
    divisions: 10,
  );
  final selectedIndex = context.knobs.int.slider(
    label: 'selected_index',
    initialValue: 0,
    min: 0,
    max: tagCount - 1,
    divisions: tagCount - 1,
  );
  final enableReordering = context.knobs.boolean(
    label: 'enable_reordering',
    initialValue: true,
  );
  final tags = List.generate(
    tagCount,
    (i) => FeedTagData(
      id: 'tag_$i',
      text: 'Tag $i',
      isTimeline: i == 0,
      canDelete: i != 0,
    ),
  );
  return Center(
    child: Container(
      constraints: BoxConstraints(
        maxWidth: context.knobs.double.slider(
          label: 'max_width',
          initialValue: 400,
          min: 200,
          max: 800,
        ),
      ),
      child: FeedTagList(
        tags: tags,
        selectedTagId: tags[selectedIndex].id,
        enableReordering: enableReordering,
        onTagTap: (id) => debugPrint('Tag tapped: $id'),
        onReorder: (oldIndex, newIndex) =>
            debugPrint('Reorder: $oldIndex -> $newIndex'),
        onLongPress: (tag) => debugPrint('Long press: ${tag.text}'),
      ),
    ),
  );
}
