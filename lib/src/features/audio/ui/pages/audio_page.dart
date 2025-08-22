import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/features/audio/providers/audio_posts_provider.dart';
import 'package:sparksocial/src/features/search/ui/widgets/post_card.dart';

@RoutePage()
class AudioPage extends ConsumerWidget {
  const AudioPage({
    required this.audioUri,
    required this.title,
    required this.coverArtUrl,
    this.useCount,
    this.artist,
    this.trackTitle,
    super.key,
  });

  // AT-URI of the audio record (so.sprk.feed.audio)
  final String audioUri;
  final String title;
  final String coverArtUrl;
  final int? useCount;
  final String? artist;
  final String? trackTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioPostsProvider(audioUri));
    final notifier = ref.read(audioPostsProvider(audioUri).notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Audio')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: coverArtUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if ((artist?.isNotEmpty ?? false) || (trackTitle?.isNotEmpty ?? false))
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              [
                                artist,
                                trackTitle,
                              ].whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty).join(' • '),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (useCount != null)
                          Text(
                            '$useCount uses',
                            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (state.isLoading && state.posts.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          if (state.error != null && state.posts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Failed to load posts: ${state.error}'),
              ),
            ),

          if (state.posts.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.45,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= state.posts.length) {
                      notifier.loadMore();
                      return const Center(child: CircularProgressIndicator());
                    }
                    final post = state.posts[index];
                    return PostCard(post: post);
                  },
                  childCount: state.posts.length + (state.nextCursor == null ? 0 : 1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
