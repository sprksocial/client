import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/search/providers/search_provider.dart';
import 'package:sparksocial/src/features/search/ui/widgets/suggested_account_card.dart';
import 'package:sparksocial/src/features/stories/providers/stories_by_author.dart';
import 'package:sparksocial/src/features/stories/ui/widgets/stories_list.dart';

/// Search page to find users
@RoutePage()
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchProvider.notifier).updateQuery(_searchController.text.trim());
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
                    prefixIcon: Icon(FluentIcons.search_24_regular, color: theme.textTheme.bodyMedium?.color),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              // ==== Stories or Search Results ====
              if (searchState.query.isEmpty) ...[
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // Refresh the stories timeline
                      ref.invalidate(storiesByAuthorProvider());
                    },
                    child: CustomScrollView(
                      slivers: [
                        const SliverToBoxAdapter(child: StoriesList()),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FluentIcons.search_24_regular, size: 48, color: theme.textTheme.bodyMedium?.color),
                                const SizedBox(height: 16),
                                Text(
                                  'Search for users',
                                  style: TextStyle(fontSize: 16, color: theme.textTheme.bodyMedium?.color),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the search bar above to find people',
                                  style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color?.withAlpha(180)),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Theme(
                  data: Theme.of(context).copyWith(tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent)),
                  child: TabBar(
                    tabs: const [Tab(text: 'Users')],
                    indicatorColor: colorScheme.primary,
                    labelColor: theme.textTheme.bodyLarge?.color,
                    unselectedLabelColor: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const Expanded(child: TabBarView(children: [UserResults()])),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class UserResults extends ConsumerStatefulWidget {
  const UserResults({super.key});

  @override
  ConsumerState<UserResults> createState() => _UserResultsState();
}

class _UserResultsState extends ConsumerState<UserResults> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Trigger pagination when close to the bottom
      ref.read(searchProvider.notifier).loadMoreUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    if (state.isLoading && state.searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(
        child: Text(state.error!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (state.query.isEmpty) {
      return const SizedBox.shrink();
    }

    final itemCount = state.isLoadingMore ? state.searchResults.length + 1 : state.searchResults.length;

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

        // Check if the user is being followed
        final isFollowing = actor.viewer?.following != null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SuggestedAccountCard(
            username: actor.displayName ?? actor.handle,
            handle: '@${actor.handle}',
            avatarUrl: actor.avatar?.toString() ?? '',
            description: actor.description ?? '',
            onTap: () {
              if (actor.did.isNotEmpty) {
                context.router.push(ProfileRoute(did: actor.did));
              }
            },
            showFollowButton: !ref.read(searchProvider.notifier).isCurrentUser(actor.did),
            isFollowing: isFollowing,
            onFollowTap: () => ref.read(searchProvider.notifier).followUser(actor.did),
            onUnfollowTap: () =>
                ref.read(searchProvider.notifier).unfollowUser(actor.did, actor.viewer?.following ?? AtUri.parse('')),
          ),
        );
      },
    );
  }
}
