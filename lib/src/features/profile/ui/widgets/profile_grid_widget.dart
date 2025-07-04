import 'dart:ui';

import 'package:atproto/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/utils/label_utils.dart';
import 'package:sparksocial/src/features/profile/providers/profile_feed_provider.dart';

class ProfileGridWidget extends ConsumerStatefulWidget {
  final AtUri profileUri;
  final bool videosOnly;

  const ProfileGridWidget({super.key, required this.profileUri, required this.videosOnly});

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
          padding: const EdgeInsets.all(1),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            childAspectRatio: 0.6,
          ),
          itemCount: state.loadedPosts.length + (state.isEndOfNetwork ? 0 : 1),
          itemBuilder: (context, index) {
            if (index >= state.loadedPosts.length) {
              return Container(
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
  final PostView postView;
  final String? postSource;
  final VoidCallback onTap;

  const ProfileGridTile({super.key, required this.postView, this.postSource, required this.onTap});

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

    final image = thumbnailUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox.shrink(),
            errorWidget: (context, url, error) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: Icon(FluentIcons.error_circle_24_regular, size: 20)),
            ),
          )
        : Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(child: Icon(FluentIcons.image_off_24_regular, size: 20)),
          );

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        color: AppColors.black,
        child: thumbnailUrl.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  if (_shouldBlur)
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                      child: image,
                    )
                  else
                    image,
                  if (widget.postSource != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.black.withAlpha(150), borderRadius: BorderRadius.circular(4)),
                        child: SvgPicture.asset(
                          widget.postSource == 'bsky' ? 'assets/images/bsky.svg' : 'assets/images/sprk.svg',
                          width: 12,
                          height: 12,
                        ),
                      ),
                    ),
                ],
              )
            : Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(child: Icon(FluentIcons.image_off_24_regular, size: 20)),
              ),
      ),
    );
  }
}
