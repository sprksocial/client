import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/search/data/models/search_state.dart';
import 'package:sparksocial/src/features/search/providers/search_provider.dart';
import 'package:sparksocial/src/features/search/ui/widgets/suggested_account_card.dart';

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
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users',
                    prefixIcon: Icon(FluentIcons.search_24_regular, color: theme.textTheme.bodyMedium?.color),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow.withAlpha(50),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                ),
              ),
              Theme(
                data: Theme.of(context).copyWith(tabBarTheme: const TabBarTheme(dividerColor: Colors.transparent)),
                child: TabBar(
                  tabs: const [Tab(text: 'Users')],
                  indicatorColor: colorScheme.primary,
                  labelColor: theme.textTheme.bodyLarge?.color,
                  unselectedLabelColor: theme.textTheme.bodyMedium?.color,
                ),
              ),
              Expanded(child: TabBarView(children: [UserResults(ref: ref, state: searchState)])),
            ],
          ),
        ),
      ),
    );
  }
}

class UserResults extends StatelessWidget {
  const UserResults({
    super.key,
    required this.ref,
    required this.state,
  });

  final WidgetRef ref;
  final SearchState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text(state.error!, style: const TextStyle(color: Colors.red)));
    }
    if (state.query.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return ListView.builder(
      itemCount: state.searchResults.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final actor = state.searchResults[index];
        
        // Check if the user is being followed
        final followUri = actor.viewer != null ? actor.viewer!['following'] as String? : null;
        final isFollowing = followUri != null && followUri.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SuggestedAccountCard(
            username: actor.displayName ?? actor.handle,
            handle: '@${actor.handle}',
            avatarUrl: actor.avatar ?? '',
            description: actor.description ?? '',
            onTap: () {
              if (actor.did.isNotEmpty) {
                context.router.push(ProfileRoute(did: actor.did));
              }
            },
            showFollowButton: ref.read(searchProvider.notifier).isCurrentUser(actor.did),
            isFollowing: isFollowing,
            onFollowTap: () => ref.read(searchProvider.notifier).followUser(actor.did),
            onUnfollowTap: () {
              if (followUri != null) {
                ref.read(searchProvider.notifier).unfollowUser(actor.did, followUri);
              }
            },
          ),
        );
      },
    );
  }
} 