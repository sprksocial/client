import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/features/search/providers/post_search_provider.dart';
import 'package:sparksocial/src/features/search/providers/search_provider.dart';
import 'package:sparksocial/src/features/search/ui/pages/post_results.dart';
import 'package:sparksocial/src/features/search/ui/pages/user_results.dart';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final trimmedQuery = query.trim();
    ref.read(searchProvider.notifier).updateQuery(trimmedQuery);
    ref.read(postSearchProvider.notifier).updateQuery(trimmedQuery);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 2,
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
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search users, posts...',
                    prefixIcon: Icon(FluentIcons.search_24_regular, color: theme.textTheme.bodyMedium?.color),
                    filled: true,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            iconSize: 20,
                            splashRadius: 20,
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchProvider.notifier).updateQuery('');
                              ref.read(postSearchProvider.notifier).updateQuery('');
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
              if (searchState.query.isEmpty)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // Refresh the stories timeline
                      ref.invalidate(storiesByAuthorProvider());
                    },
                    child: const CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: StoriesList()),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text('Discover new content'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                const TabBar(
                  tabs: [
                    Tab(text: 'Posts'),
                    Tab(text: 'Users'),
                  ],
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
                      PostResults(),
                      UserResults(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
