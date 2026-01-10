import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/design_system/components/molecules/post_tile.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/sound/providers/sound_page_provider.dart';
import 'package:spark/src/features/sound/ui/widgets/sound_header_card.dart';

@RoutePage()
class SoundPage extends ConsumerStatefulWidget {
  const SoundPage({@PathParam('audioUri') required this.audioUri, super.key});
  final String audioUri;

  @override
  ConsumerState<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends ConsumerState<SoundPage> {
  late final AtUri _audioAtUri;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _audioAtUri = AtUri.parse(widget.audioUri);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(soundPageProvider(_audioAtUri).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final soundState = ref.watch(soundPageProvider(_audioAtUri));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Sound'),
        elevation: 0,
        leading: const AppLeadingButton(),
      ),
      body: soundState.when(
        data: (state) => RefreshIndicator(
          onRefresh: () =>
              ref.read(soundPageProvider(_audioAtUri).notifier).refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header Card
              SliverToBoxAdapter(
                child: SoundHeaderCard(
                  audio: state.audio,
                  onAuthorTap: () => context.router.push(
                    ProfileRoute(
                      did: state.audio.author.did,
                      initialProfile: state.audio.author,
                    ),
                  ),
                ),
              ),

              // Posts Grid
              if (state.posts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FluentIcons.video_24_regular,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No videos using this sound yet',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(5),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          childAspectRatio: 9 / 16,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= state.posts.length) {
                          return ColoredBox(
                            color: colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }

                        final post = state.posts[index];
                        return _SoundPostTile(
                          post: post,
                          onTap: () => context.router.push(
                            StandalonePostRoute(postUri: post.uri.toString()),
                          ),
                        );
                      },
                      childCount:
                          state.posts.length + (state.isEndOfNetwork ? 0 : 1),
                    ),
                  ),
                ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FluentIcons.error_circle_24_regular, size: 48),
              const SizedBox(height: 16),
              Text('Error loading sound: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(soundPageProvider(_audioAtUri).notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoundPostTile extends StatelessWidget {
  const _SoundPostTile({
    required this.post,
    required this.onTap,
  });

  final PostView post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = post.thumbnailUrl;
    final likeCount = post.likeCount ?? 0;

    if (thumbnailUrl.isEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(
            child: Icon(FluentIcons.image_off_24_regular, size: 20),
          ),
        ),
      );
    }

    return PostTile(
      thumbnailUrl: thumbnailUrl,
      likes: likeCount,
      seen: false,
      onTap: onTap,
    );
  }
}
