import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/post_tile.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

const _demoThumbnail = 'https://picsum.photos/400/600';

@UseCase(name: 'default', type: PostTile)
Widget buildPostTileUseCase(BuildContext context) {
  return Center(
    child: SizedBox(
      width: context.knobs.double.slider(
        label: 'width',
        initialValue: 150,
        min: 100,
        max: 300,
      ),
      height: context.knobs.double.slider(
        label: 'height',
        initialValue: 200,
        min: 150,
        max: 400,
      ),
      child: PostTile(
        thumbnailUrl: context.knobs.string(
          label: 'thumbnailUrl',
          initialValue: _demoThumbnail,
        ),
        likes: context.knobs.int.slider(
          label: 'likes',
          initialValue: 1239,
          min: 0,
          max: 100000,
        ),
        seen: context.knobs.boolean(label: 'seen', initialValue: false),
        nsfwBlur: context.knobs.boolean(label: 'nsfwBlur', initialValue: false),
        onTap: () => print('PostTile tapped'),
      ),
    ),
  );
}

@UseCase(name: 'seen', type: PostTile)
Widget buildPostTileSeenUseCase(BuildContext context) {
  return Center(
    child: SizedBox(
      width: 150,
      height: 200,
      child: PostTile(
        thumbnailUrl: _demoThumbnail,
        likes: context.knobs.int.slider(
          label: 'likes',
          initialValue: 5420,
          min: 0,
          max: 100000,
        ),
        seen: true,
        nsfwBlur: false,
        onTap: () => print('Seen PostTile tapped'),
      ),
    ),
  );
}

@UseCase(name: 'high_views', type: PostTile)
Widget buildPostTileHighViewsUseCase(BuildContext context) {
  return Center(
    child: SizedBox(
      width: 150,
      height: 200,
      child: PostTile(
        thumbnailUrl: _demoThumbnail,
        likes: context.knobs.int.input(label: 'likes', initialValue: 1234567),
        seen: context.knobs.boolean(label: 'seen', initialValue: false),
        nsfwBlur: context.knobs.boolean(label: 'nsfwBlur', initialValue: false),
        onTap: () => print('High views PostTile tapped'),
      ),
    ),
  );
}

@UseCase(name: 'grid', type: PostTile)
Widget buildPostTileGridUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return PostTile(
          thumbnailUrl: 'https://picsum.photos/400/600?random=$index',
          likes: (index + 1) * 1000,
          seen: index % 3 == 0,
          nsfwBlur: index % 5 == 0,
          onTap: () => print('Grid PostTile $index tapped'),
        );
      },
    ),
  );
}
