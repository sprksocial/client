import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/molecules/profile_card.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';
import 'package:spark/src/core/network/messages/data/repository/messages_repository.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/search/providers/search_provider.dart';

@RoutePage()
class NewChatSearchPage extends ConsumerStatefulWidget {
  const NewChatSearchPage({super.key});

  @override
  ConsumerState<NewChatSearchPage> createState() => _NewChatSearchPageState();
}

class _NewChatSearchPageState extends ConsumerState<NewChatSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref
        .read(searchProvider.notifier)
        .updateQuery(_searchController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 1,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users',
                    prefixIcon: Icon(
                      FluentIcons.search_24_regular,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    filled: true,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            iconSize: 20,
                            splashRadius: 20,
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchProvider.notifier).updateQuery('');
                            },
                            icon: const Icon(FluentIcons.dismiss_24_regular),
                          )
                        : null,
                    fillColor: colorScheme.surfaceContainerLow.withAlpha(50),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              // ==== Stories or Search Results ====
              if (searchState.query.isEmpty) ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FluentIcons.search_24_regular,
                          size: 48,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search for users',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the search bar above to find people',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color?.withAlpha(
                              180,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Theme(
                  data: Theme.of(context).copyWith(
                    tabBarTheme: const TabBarThemeData(
                      dividerColor: Colors.transparent,
                    ),
                  ),
                  child: TabBar(
                    tabs: const [Tab(text: 'Users')],
                    indicatorColor: colorScheme.primary,
                    labelColor: theme.textTheme.bodyLarge?.color,
                    unselectedLabelColor: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const Expanded(child: TabBarView(children: [_UserResults()])),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UserResults extends ConsumerStatefulWidget {
  const _UserResults();

  @override
  ConsumerState<_UserResults> createState() => _UserResultsState();
}

class _UserResultsState extends ConsumerState<_UserResults> {
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Trigger pagination when close to the bottom
      ref.read(searchProvider.notifier).loadMoreUsers();
    }
  }

  Future<void> _startChat(ProfileView actor) async {
    try {
      // Get or create conversation for members, then navigate with convoId
      final repo = GetIt.I<MessagesRepository>();
      final convo = await repo.getConvoForMembers([actor.did]);
      if (!mounted) return;
      context.router.push(
        ChatRoute(
          conversationId: convo.id,
          otherUserDid: actor.did,
          otherUserHandle: actor.handle,
          otherUserDisplayName: actor.displayName,
          otherUserAvatar: actor.avatar?.toString(),
        ),
      );
    } catch (_) {
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    if (state.isLoading && state.searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      return Center(
        child: Text(
          state.error!,
          style: TextStyle(color: colorScheme.error),
        ),
      );
    }
    if (state.query.isEmpty) {
      return const SizedBox.shrink();
    }

    final itemCount = state.isLoadingMore
        ? state.searchResults.length + 1
        : state.searchResults.length;

    return ListView.builder(
      controller: _scrollController,
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        if (index >= state.searchResults.length) {
          // Loading indicator at bottom
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final actor = state.searchResults[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ProfileCard(
            imageUrl: actor.avatar?.toString() ?? '',
            userName: actor.displayName ?? actor.handle,
            userHandle: '@${actor.handle}',
            description: actor.description ?? '',
            isFollowing: false,
            onFollow: () {},
            onUnfollow: () {},
            showFollowButton: false, // Not relevant when starting a chat
            onTap: () => _startChat(actor),
          ),
        );
      },
    );
  }
}
