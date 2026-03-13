import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/stories/providers/story_auto_delete_provider.dart';
import 'package:spark/src/features/stories/providers/story_manager_provider.dart';

@RoutePage()
class StoryManagerPage extends ConsumerWidget {
  const StoryManagerPage({super.key});

  void _openStoryViewer(BuildContext context, WidgetRef ref, int index) {
    final state = ref.read(storyManagerProvider).value;
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

  Future<void> _deleteStory(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) async {
    final notifier = ref.read(storyManagerProvider.notifier);
    final stories = ref.read(storyManagerProvider).value?.stories ?? [];
    if (index >= stories.length) return;
    final story = stories[index];
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Story'),
            content: const Text('Are you sure you want to delete this story?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).maybePop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).maybePop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!shouldDelete) return;
    await notifier.deleteStory(story);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(storyManagerProvider);
    final theme = Theme.of(context);

    final autoDeletePref = ref.watch(storyAutoDeletePrefProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Story Manager')),
      body: asyncState.when(
        data: (data) {
          return RefreshIndicator(
            onRefresh: () => ref.read(storyManagerProvider.notifier).refresh(),
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
                final thumbUrl = switch (story.media) {
                  MediaViewVideo(:final thumbnail) => thumbnail.toString(),
                  MediaViewImage(:final image) => image.thumb.toString(),
                  _ => story.author.avatar.toString(),
                };
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _openStoryViewer(context, ref, storyIndex),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Story ${data.stories.length - storyIndex}',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Posted $ageStr ago',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            tooltip: 'Delete',
                            onPressed: () =>
                                _deleteStory(context, ref, storyIndex),
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
                    ref.read(storyManagerProvider.notifier).refresh(),
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
                      await ref.read(storyManagerProvider.notifier).refresh();
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
