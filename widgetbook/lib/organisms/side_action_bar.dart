import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/organisms/side_action_bar.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'default', type: SparkSideActionBar)
Widget buildSparkSideActionBarUseCase(BuildContext context) {
  final likeCount = context.knobs.string(
    label: 'likeCount',
    initialValue: '456k',
  );
  final commentCount = context.knobs.string(
    label: 'commentCount',
    initialValue: '2.4k',
  );
  final curateCount = context.knobs.string(
    label: 'curateCount',
    initialValue: '129',
  );
  final shareCount = context.knobs.string(
    label: 'shareCount',
    initialValue: '98',
  );
  final isLiked = context.knobs.boolean(label: 'isLiked', initialValue: true);
  final isCurated = context.knobs.boolean(
    label: 'isCurated',
    initialValue: false,
  );

  return _ScaffoldedBackground(
    child: SparkSideActionBar(
      likeCount: likeCount,
      commentCount: commentCount,
      curateCount: curateCount,
      shareCount: shareCount,
      isLiked: isLiked,
      isCurated: isCurated,
      onLike: () => print('Like tapped (current: $isLiked)'),
      onComment: () => print('Comment tapped'),
      onCurate: () => print('Curate tapped (current: $isCurated)'),
      onShare: () => print('Share tapped'),
    ),
  );
}

@UseCase(name: 'empty_counts', type: SparkSideActionBar)
Widget buildSparkSideActionBarEmptyCountsUseCase(BuildContext context) {
  final isLiked = context.knobs.boolean(label: 'isLiked', initialValue: false);
  final isCurated = context.knobs.boolean(
    label: 'isCurated',
    initialValue: false,
  );

  return _ScaffoldedBackground(
    child: SparkSideActionBar(
      likeCount: '',
      commentCount: '',
      curateCount: '',
      shareCount: '',
      isLiked: isLiked,
      isCurated: isCurated,
      onLike: () => print('Like tapped'),
      onComment: () => print('Comment tapped'),
      onCurate: () => print('Curate tapped'),
      onShare: () => print('Share tapped'),
    ),
  );
}

@UseCase(name: 'interactive_stateful', type: SparkSideActionBar)
Widget buildSparkSideActionBarInteractiveStatefulUseCase(BuildContext context) {
  final startLiked = context.knobs.boolean(
    label: 'startLiked',
    initialValue: false,
  );
  final startCurated = context.knobs.boolean(
    label: 'startCurated',
    initialValue: false,
  );
  final likeCountStart = context.knobs.int.slider(
    label: 'likeStart',
    initialValue: 120,
    min: 0,
    max: 5000,
    divisions: 50,
  );
  final commentCountStart = context.knobs.int.slider(
    label: 'commentStart',
    initialValue: 30,
    min: 0,
    max: 5000,
    divisions: 50,
  );
  final curateCountStart = context.knobs.int.slider(
    label: 'curateStart',
    initialValue: 12,
    min: 0,
    max: 5000,
    divisions: 50,
  );
  final shareCountStart = context.knobs.int.slider(
    label: 'shareStart',
    initialValue: 8,
    min: 0,
    max: 5000,
    divisions: 50,
  );

  return StatefulBuilder(
    builder: (ctx, setState) {
      var liked = startLiked;
      var curated = startCurated;
      var likeCount = likeCountStart;
      var curateCount = curateCountStart;

      return _ScaffoldedBackground(
        child: SparkSideActionBar(
          likeCount: likeCount.toString(),
          commentCount: commentCountStart.toString(),
          curateCount: curateCount.toString(),
          shareCount: shareCountStart.toString(),
          isLiked: liked,
          isCurated: curated,
          onLike: () {
            setState(() {
              liked = !liked;
              likeCount += liked ? 1 : -1;
            });
            print('Like toggled -> $liked (count: $likeCount)');
          },
          onCurate: () {
            setState(() {
              curated = !curated;
              curateCount += curated ? 1 : -1;
            });
            print('Curate toggled -> $curated (count: $curateCount)');
          },
          onComment: () => print('Comment tapped'),
          onShare: () => print('Share tapped'),
        ),
      );
    },
  );
}

@UseCase(name: 'dense_spacing', type: SparkSideActionBar)
Widget buildSparkSideActionBarDenseSpacingUseCase(BuildContext context) {
  // This variant demonstrates how the bar might look when placed tighter to edges.
  final scale = context.knobs.double.slider(
    label: 'scale',
    initialValue: 0.85,
    min: 0.5,
    max: 1.2,
    divisions: 14,
  );
  return Transform.scale(
    scale: scale,
    child: _ScaffoldedBackground(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: const SparkSideActionBar(
        likeCount: '12',
        commentCount: '3',
        curateCount: '4',
        shareCount: '1',
        isLiked: true,
        isCurated: true,
      ),
    ),
  );
}

@UseCase(name: 'curate_popover', type: SparkSideActionBar)
Widget buildSparkSideActionBarCuratePopoverUseCase(BuildContext context) {
  final likeCount = context.knobs.int.slider(
    label: 'likes',
    initialValue: 25,
    min: 0,
    max: 999,
    divisions: 50,
  );
  final commentCount = context.knobs.int.slider(
    label: 'comments',
    initialValue: 8,
    min: 0,
    max: 500,
    divisions: 50,
  );
  final shareCount = context.knobs.int.slider(
    label: 'shares',
    initialValue: 2,
    min: 0,
    max: 500,
    divisions: 50,
  );

  return StatefulBuilder(
    builder: (ctx, setState) {
      var curated = false;
      var curateCount = 5;
      return _ScaffoldedBackground(
        child: SparkSideActionBar(
          likeCount: likeCount.toString(),
          commentCount: commentCount.toString(),
          curateCount: curateCount.toString(),
          shareCount: shareCount.toString(),
          isLiked: false,
          isCurated: curated,
          curateDestinations: [
            CurateDestination(
              'Feed 1',
              onSelected: () => print('Feed 1 selected'),
            ),
            CurateDestination(
              'Feed 2',
              onSelected: () => print('Feed 2 selected'),
            ),
            CurateDestination(
              'Ideas',
              onSelected: () => print('Ideas selected'),
            ),
          ],
          onCurate: () {
            setState(() {
              curated = true;
              curateCount += 1;
            });
            print('Curated! Total: $curateCount');
          },
          onComment: () => print('Comment tapped'),
          onLike: () => print('Like tapped'),
          onShare: () => print('Share tapped'),
        ),
      );
    },
  );
}

@UseCase(name: 'with_image_background', type: SparkSideActionBar)
Widget buildSparkSideActionBarWithImageBackgroundUseCase(BuildContext context) {
  final imageUrl = context.knobs.string(
    label: 'imageUrl',
    initialValue:
        'https://picsum.photos/600/1200?random=${DateTime.now().millisecond % 20}',
  );

  final likeCount = context.knobs.string(
    label: 'likeCount',
    initialValue: '2.4k',
  );

  final commentCount = context.knobs.string(
    label: 'commentCount',
    initialValue: '156',
  );

  final curateCount = context.knobs.string(
    label: 'curateCount',
    initialValue: '42',
  );

  final shareCount = context.knobs.string(
    label: 'shareCount',
    initialValue: '89',
  );

  final isLiked = context.knobs.boolean(label: 'isLiked', initialValue: true);

  final isCurated = context.knobs.boolean(
    label: 'isCurated',
    initialValue: false,
  );

  return StatefulBuilder(
    builder: (ctx, setState) {
      var liked = isLiked;
      var curated = isCurated;

      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 64,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade900,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: 16,
              bottom: 100,
              child: SparkSideActionBar(
                likeCount: likeCount,
                commentCount: commentCount,
                curateCount: curateCount,
                shareCount: shareCount,
                isLiked: liked,
                isCurated: curated,
                curateDestinations: [
                  CurateDestination(
                    'Feed 1',
                    onSelected: () => print('Feed 1 selected'),
                  ),
                  CurateDestination(
                    'Feed 2',
                    onSelected: () => print('Feed 2 selected'),
                  ),
                  CurateDestination(
                    'Feed 3',
                    onSelected: () => print('Feed 3 selected'),
                  ),
                ],
                onLike: () {
                  setState(() => liked = !liked);
                  print('Like toggled: $liked');
                },
                onComment: () => print('Comment tapped'),
                onCurate: () {
                  setState(() => curated = true);
                  print('Curated!');
                },
                onShare: () => print('Share tapped'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _ScaffoldedBackground extends StatelessWidget {
  const _ScaffoldedBackground({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0E0F11), Color(0xFF050506)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: padding.bottom,
              right: padding.right,
              top: padding.top,
              child: Align(alignment: Alignment.centerRight, child: child),
            ),
          ],
        ),
      ),
    );
  }
}
