import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/molecules/input_field.dart';
import 'package:spark/src/core/design_system/templates/explore_page_template.dart';
import 'package:spark/src/features/search/providers/post_search_provider.dart';
import 'package:spark/src/features/search/providers/search_provider.dart';
import 'package:spark/src/features/search/providers/suggested_feeds_provider.dart';
import 'package:spark/src/features/search/ui/pages/post_results.dart';
import 'package:spark/src/features/search/ui/pages/user_results.dart';
import 'package:spark/src/features/search/ui/widgets/suggested_feeds_list.dart';
import 'package:spark/src/features/stories/providers/stories_by_author.dart';
import 'package:spark/src/features/stories/ui/widgets/stories_list.dart';

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
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final trimmedQuery = _searchController.text.trim();
    ref.read(searchProvider.notifier).updateQuery(trimmedQuery);
    ref.read(postSearchProvider.notifier).updateQuery(trimmedQuery);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return DefaultTabController(
      length: 2,
      child: ExplorePageTemplate(
        searchWidget: InputField.search(
          controller: _searchController,
          hintText: 'Search users, posts...',
          leadingWidgets: const [
            Icon(
              FluentIcons.search_24_regular,
              size: 20,
            ),
          ],
          actionWidgets: _searchController.text.isNotEmpty
              ? [
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      ref.read(searchProvider.notifier).updateQuery('');
                      ref.read(postSearchProvider.notifier).updateQuery('');
                    },
                    child: const Icon(
                      FluentIcons.dismiss_24_regular,
                      size: 20,
                    ),
                  ),
                ]
              : null,
        ),
        showTabs: searchState.query.isNotEmpty,
        tabsWidget: const TabBar(
          tabs: [
            Tab(text: 'Posts'),
            Tab(text: 'Users'),
          ],
        ),
        contentWidget: const TabBarView(
          children: [
            PostResults(),
            UserResults(),
          ],
        ),
        emptyStateWidget: RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(storiesByAuthorProvider())
              ..invalidate(suggestedFeedsProvider);
          },
          child: const CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: StoriesList()),
              SliverToBoxAdapter(child: SuggestedFeedsList()),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text('Discover new content'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
