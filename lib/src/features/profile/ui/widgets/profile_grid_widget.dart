import 'package:atproto/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/post_tile.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/utils/label_utils.dart';
import 'package:sparksocial/src/features/profile/providers/profile_feed_provider.dart';

class ProfileGridWidget extends ConsumerStatefulWidget {
  const ProfileGridWidget({required this.profileUri, required this.videosOnly, super.key});
  final AtUri profileUri;
  final bool videosOnly;

  @override
  ConsumerState<ProfileGridWidget> createState() => _ProfileGridWidgetState();
}

class _ProfileGridWidgetState extends ConsumerState<ProfileGridWidget> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      ref.read(profileFeedProvider(widget.profileUri, widget.videosOnly).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(profileFeedProvider(widget.profileUri, widget.videosOnly));

    return feedState.when(
      data: (state) {
        if (state.loadedPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.videosOnly ? FluentIcons.video_24_regular : FluentIcons.image_24_regular,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.videosOnly ? 'No videos yet' : 'No images yet',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(5),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 9 / 16,
          ),
          itemCount: state.loadedPosts.length + (state.isEndOfNetwork ? 0 : 1),
          itemBuilder: (context, index) {
            if (index >= state.loadedPosts.length) {
              return ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              );
            }

            final postUri = state.loadedPosts[index];
            final postView = state.postViews[postUri];
            final postSource = state.postSources[postUri];

            if (postView == null) {
              return const SizedBox.shrink();
            }

            return ProfileGridTile(
              postView: postView,
              postSource: postSource,
              onTap: () => _onPostTap(postUri),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FluentIcons.error_circle_24_regular, size: 48),
            const SizedBox(height: 16),
            Text('Error loading posts: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(profileFeedProvider(widget.profileUri, widget.videosOnly).notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _onPostTap(AtUri postUri) {
    final feedState = ref.read(profileFeedProvider(widget.profileUri, widget.videosOnly));
    feedState.whenData((state) {
      final postIndex = state.loadedPosts.indexOf(postUri);
      if (postIndex != -1) {
        context.router.push(
          StandaloneProfileFeedRoute(
            profileUri: widget.profileUri.toString(),
            videosOnly: widget.videosOnly,
            initialPostIndex: postIndex,
          ),
        );
      } else {
        context.router.push(StandalonePostRoute(postUri: postUri.toString()));
      }
    });
  }
}

class ProfileGridTile extends StatefulWidget {
  const ProfileGridTile({required this.postView, required this.onTap, super.key, this.postSource});
  final PostView postView;
  final String? postSource;
  final VoidCallback onTap;

  @override
  State<ProfileGridTile> createState() => _ProfileGridTileState();
}

class _ProfileGridTileState extends State<ProfileGridTile> {
  bool _shouldBlur = false;

  @override
  void initState() {
    super.initState();
    _checkContentWarning();
  }

  @override
  void didUpdateWidget(covariant ProfileGridTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.postView.uri != oldWidget.postView.uri) {
      _checkContentWarning();
    }
  }

  Future<void> _checkContentWarning() async {
    final labels = widget.postView.labels ?? [];
    final shouldBlur = labels.isNotEmpty ? await LabelUtils.shouldBlurContent(labels) : false;
    if (mounted) {
      setState(() => _shouldBlur = shouldBlur);
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = widget.postView.thumbnailUrl;

    // Use like count as a proxy for views, or 0 if not available
    final viewCount = widget.postView.likeCount ?? 0;

    if (thumbnailUrl.isEmpty) {
      return GestureDetector(
        onTap: widget.onTap,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(child: Icon(FluentIcons.image_off_24_regular, size: 20)),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PostTile(
          thumbnailUrl: thumbnailUrl,
          views: viewCount,
          seen: false,
          nsfwBlur: _shouldBlur,
          onTap: widget.onTap,
        ),
        // if (widget.postSource != null)
        //   Positioned(
        //     top: 8,
        //     right: 8,
        //     child: Container(
        //       padding: const EdgeInsets.all(4),
        //       decoration: BoxDecoration(
        //         color: Colors.black.withAlpha(150),
        //         borderRadius: BorderRadius.circular(4),
        //       ),
        //       child: SvgPicture.asset(
        //         widget.postSource == 'bsky' ? 'assets/images/bsky.svg' : 'assets/images/sprk.svg',
        //         width: 12,
        //         height: 12,
        //       ),
        //     ),
        //   ),
      ],
    );
  }
}
