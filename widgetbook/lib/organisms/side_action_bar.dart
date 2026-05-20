import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/organisms/side_action_bar.dart';
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
  final repostCount = context.knobs.string(
    label: 'repostCount',
    initialValue: '1.2k',
  );
  final shareCount = context.knobs.string(
    label: 'shareCount',
    initialValue: '98',
  );
  final isLiked = context.knobs.boolean(label: 'isLiked', initialValue: true);
  final isReposted = context.knobs.boolean(
    label: 'isReposted',
    initialValue: false,
  );

  return _ScaffoldedBackground(
    child: SparkSideActionBar(
      likeCount: likeCount,
      commentCount: commentCount,
      repostCount: repostCount,
      shareCount: shareCount,
      isLiked: isLiked,
      isReposted: isReposted,
      onLike: () => print('Like tapped (current: $isLiked)'),
      onComment: () => print('Comment tapped'),
      onRepost: () => print('Repost tapped (current: $isReposted)'),
      onShare: () => print('Share tapped'),
    ),
  );
}

@UseCase(name: 'empty_counts', type: SparkSideActionBar)
Widget buildSparkSideActionBarEmptyCountsUseCase(BuildContext context) {
  final isLiked = context.knobs.boolean(label: 'isLiked', initialValue: false);
  final isReposted = context.knobs.boolean(
    label: 'isReposted',
    initialValue: false,
  );

  return _ScaffoldedBackground(
    child: SparkSideActionBar(
      likeCount: '',
      commentCount: '',
      repostCount: '',
      shareCount: '',
      isLiked: isLiked,
      isReposted: isReposted,
      onLike: () => print('Like tapped'),
      onComment: () => print('Comment tapped'),
      onRepost: () => print('Repost tapped'),
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
  final startReposted = context.knobs.boolean(
    label: 'startReposted',
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
  final repostCountStart = context.knobs.int.slider(
    label: 'repostStart',
    initialValue: 45,
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
      var reposted = startReposted;
      var likeCount = likeCountStart;
      var repostCount = repostCountStart;

      return _ScaffoldedBackground(
        child: SparkSideActionBar(
          likeCount: likeCount.toString(),
          commentCount: commentCountStart.toString(),
          repostCount: repostCount.toString(),
          shareCount: shareCountStart.toString(),
          isLiked: liked,
          isReposted: reposted,
          onLike: () {
            setState(() {
              liked = !liked;
              likeCount += liked ? 1 : -1;
            });
            print('Like toggled -> $liked (count: $likeCount)');
          },
          onRepost: () {
            setState(() {
              reposted = !reposted;
              repostCount += reposted ? 1 : -1;
            });
            print('Repost toggled -> $reposted (count: $repostCount)');
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
        repostCount: '5',
        shareCount: '1',
        isLiked: true,
        isReposted: false,
      ),
    ),
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
  final repostCount = context.knobs.string(
    label: 'repostCount',
    initialValue: '89',
  );
  final shareCount = context.knobs.string(
    label: 'shareCount',
    initialValue: '89',
  );
  final isLiked = context.knobs.boolean(label: 'isLiked', initialValue: true);
  final isReposted = context.knobs.boolean(
    label: 'isReposted',
    initialValue: false,
  );

  return StatefulBuilder(
    builder: (ctx, setState) {
      var liked = isLiked;
      var reposted = isReposted;

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
              ),
            ),
            Positioned(
              right: 16,
              bottom: 100,
              child: SparkSideActionBar(
                likeCount: likeCount,
                commentCount: commentCount,
                repostCount: repostCount,
                shareCount: shareCount,
                isLiked: liked,
                isReposted: reposted,
                onLike: () {
                  setState(() => liked = !liked);
                  print('Like toggled: $liked');
                },
                onComment: () => print('Comment tapped'),
                onRepost: () {
                  setState(() => reposted = !reposted);
                  print('Repost toggled: $reposted');
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
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFF050506)),
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
