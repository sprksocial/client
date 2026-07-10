import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/molecules/profile_card.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/feed/providers/post_likes_provider.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

Future<void> showPostLikesSheet({
  required BuildContext context,
  required String uri,
  String? cid,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.7,
    ),
    builder: (context) => _PostLikesSheet(uri: uri, cid: cid),
  );
}

class _PostLikesSheet extends ConsumerStatefulWidget {
  const _PostLikesSheet({required this.uri, this.cid});

  final String uri;
  final String? cid;

  @override
  ConsumerState<_PostLikesSheet> createState() => _PostLikesSheetState();
}

class _PostLikesSheetState extends ConsumerState<_PostLikesSheet> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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
    if (_scrollController.hasClients &&
        _scrollController.position.extentAfter < 200) {
      ref
          .read(postLikesProvider(uri: widget.uri, cid: widget.cid).notifier)
          .fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final likes = ref.watch(
      postLikesProvider(uri: widget.uri, cid: widget.cid),
    );
    final scrollController = _scrollController;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final listPadding = EdgeInsets.only(top: 8, bottom: bottomInset);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            l10n.pageTitlePostLikes,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Divider(
          height: 0.2,
          thickness: 0.2,
          color: Theme.of(context).colorScheme.outline,
        ),
        Expanded(
          child: likes.when(
            data: (state) {
              if (state.likes.isEmpty) {
                return ListView(
                  controller: scrollController,
                  padding: listPadding,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(child: Text(l10n.emptyNoPostLikes)),
                    ),
                  ],
                );
              }

              return ListView.builder(
                controller: scrollController,
                padding: listPadding,
                itemCount: state.likes.length + (state.isFetchingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.likes.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final actor = state.likes[index].actor;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ProfileCard(
                      imageUrl: actor.avatar?.toString() ?? '',
                      userName: actor.displayName ?? actor.handle,
                      userHandle: '@${actor.handle}',
                      description: actor.description,
                      isFollowing: actor.viewer?.following != null,
                      showFollowButton: false,
                      onTap: () {
                        final router = context.router;
                        Navigator.of(context).pop();
                        router.push(
                          ProfileRoute(
                            did: actor.did,
                            initialProfile: ProfileViewBasic(
                              did: actor.did,
                              handle: actor.handle,
                              displayName: actor.displayName,
                              avatar: actor.avatar,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => ListView(
              controller: scrollController,
              padding: listPadding,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(l10n.errorLoadingLikes)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
