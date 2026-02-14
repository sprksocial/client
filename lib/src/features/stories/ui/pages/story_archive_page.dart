import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/stories/providers/story_archive_provider.dart';
import 'package:spark/src/features/stories/providers/story_auto_delete_provider.dart';

@RoutePage()
class StoryArchivePage extends ConsumerWidget {
  const StoryArchivePage({super.key});

  String _resolveAtUriToHttpUrl(Uri uri, {bool isFullsize = false}) {
    final uriString = uri.toString();

    if (uriString.startsWith('http://') || uriString.startsWith('https://')) {
      return uriString;
    }

    final match = RegExp(r'^at://([^/]+)/([^/]+)/(.+)$').firstMatch(uriString);
    if (match == null) return '';

    final did = match.group(1)!;
    final collection = match.group(2)!;
    final rkey = match.group(3)!;

    if (collection != 'blob') return '';

    if (isFullsize) {
      return 'https://cdn.bsky.app/img/feed_fullsize/plain/$did/$rkey@jpeg';
    }

    return 'https://cdn.bsky.app/img/feed_thumbnail/plain/$did/$rkey@jpeg';
  }

  String _storyThumbUrl(StoryView story) {
    String pickImageThumb(ViewImage image) {
      final fullsize = image.fullsize.toString();
      if (fullsize.startsWith('http://') || fullsize.startsWith('https://')) {
        return fullsize;
      }

      final fullsizeFromAt = _resolveAtUriToHttpUrl(
        image.fullsize,
        isFullsize: true,
      );
      if (fullsizeFromAt.isNotEmpty) return fullsizeFromAt;

      final thumb = image.thumb.toString();
      if (thumb.startsWith('http://') || thumb.startsWith('https://')) {
        return thumb;
      }

      return _resolveAtUriToHttpUrl(image.thumb);
    }

    final media = story.media;

    final mediaUrl = switch (media) {
      MediaViewVideo(:final thumbnail) => _resolveAtUriToHttpUrl(thumbnail),
      MediaViewBskyVideo(:final thumbnail) => _resolveAtUriToHttpUrl(thumbnail),
      MediaViewImage(:final image) => pickImageThumb(image),
      MediaViewImages(:final images) when images.isNotEmpty => pickImageThumb(
        images.first,
      ),
      MediaViewBskyImages(:final images) when images.isNotEmpty =>
        pickImageThumb(images.first),
      MediaViewBskyRecordWithMedia(:final media) => switch (media) {
        MediaViewVideo(:final thumbnail) => _resolveAtUriToHttpUrl(thumbnail),
        MediaViewBskyVideo(:final thumbnail) => _resolveAtUriToHttpUrl(
          thumbnail,
        ),
        MediaViewImage(:final image) => pickImageThumb(image),
        MediaViewImages(:final images) when images.isNotEmpty => pickImageThumb(
          images.first,
        ),
        MediaViewBskyImages(:final images) when images.isNotEmpty =>
          pickImageThumb(images.first),
        _ => '',
      },
      _ => '',
    };

    if (mediaUrl.isNotEmpty) return mediaUrl;

    final avatarUrl = story.author.avatar?.toString();
    if (avatarUrl != null &&
        (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'))) {
      return avatarUrl;
    }

    return '';
  }

  void _openStoryViewer(BuildContext context, WidgetRef ref, int index) {
    final state = ref.read(storyArchiveProvider).value;
    if (state == null) return;
    // Build map required by AllStoriesRoute (single author -> list)
    if (state.stories.isEmpty) return;
    final author = state.stories.first.author;
    context.router.push(
      AllStoriesRoute(
        storiesByAuthor: {author: state.stories},
        initialStoryIndex: index,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(storyArchiveProvider);
    final theme = Theme.of(context);

    final autoDeletePref = ref.watch(storyAutoDeletePrefProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories Archive'),
      ),
      body: asyncState.when(
        data: (data) {
          return RefreshIndicator(
            onRefresh: () => ref.read(storyArchiveProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemCount: 1 + data.stories.length, // header + stories
              itemBuilder: (ctx, i) {
                if (i == 0) {
                  return _AutoDeleteHeader(
                    autoDeletePref: autoDeletePref,
                    ref: ref,
                  );
                }
                final storyIndex = i - 1;
                if (data.stories.isEmpty) {
                  return const SizedBox.shrink();
                }
                final story = data.stories[storyIndex];
                final age = DateTime.now().difference(story.indexedAt);
                final ageStr = age.inDays >= 1
                    ? '${age.inDays}d'
                    : age.inHours >= 1
                    ? '${age.inHours}h'
                    : age.inMinutes >= 1
                    ? '${age.inMinutes}m'
                    : 'now';
                final thumbUrl = _storyThumbUrl(story);
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _openStoryViewer(context, ref, storyIndex),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: thumbUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => Container(
                                width: 56,
                                height: 56,
                                alignment: Alignment.center,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '$ageStr ago',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(storyArchiveProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoDeleteHeader extends StatelessWidget {
  const _AutoDeleteHeader({required this.autoDeletePref, required this.ref});
  final AsyncValue<bool> autoDeletePref;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.surfaceContainerHighest;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Auto-delete stories',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              autoDeletePref.when(
                data: (enabled) => Switch(
                  value: enabled,
                  onChanged: (v) async {
                    await ref
                        .read(storyAutoDeletePrefProvider.notifier)
                        .setEnabled(v);
                    if (v) {
                      final f = ref.refresh(
                        storyAutoDeleteExecutorProvider.future,
                      );
                      await f;
                      await ref.read(storyArchiveProvider.notifier).refresh();
                    }
                  },
                ),
                loading: () => const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, _) => IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Retry',
                  onPressed: () => ref.refresh(storyAutoDeletePrefProvider),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Stories are public and stored on your PDS indefinitely. Enable '
            'this so the app auto deletes them forever after 24h. Enabling '
            'this will also execute an initial cleanup of any stories older '
            'than 24h.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
