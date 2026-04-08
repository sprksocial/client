import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/molecules/input_field.dart';
import 'package:spark/src/core/design_system/templates/explore_page_template.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/utils/image_url_resolver.dart';
import 'package:spark/src/features/search/providers/actor_typeahead_provider.dart';
import 'package:spark/src/features/search/providers/actor_typeahead_state.dart';
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
  bool _showSubmittedResults = false;

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

    if (_showSubmittedResults) {
      setState(() {
        _showSubmittedResults = false;
      });
    }

    if (trimmedQuery.isEmpty) {
      ref.read(actorTypeaheadProvider.notifier).clear();
      ref.read(searchProvider.notifier).updateQuery('');
      ref.read(postSearchProvider.notifier).updateQuery('');
      return;
    }

    ref.read(actorTypeaheadProvider.notifier).updateQuery(trimmedQuery);
  }

  Future<void> _submitFullSearch([String? query]) async {
    final trimmedQuery = (query ?? _searchController.text).trim();

    if (trimmedQuery.isEmpty) {
      setState(() {
        _showSubmittedResults = false;
      });
      ref.read(actorTypeaheadProvider.notifier).clear();
      ref.read(searchProvider.notifier).updateQuery('');
      ref.read(postSearchProvider.notifier).updateQuery('');
      return;
    }

    ref.read(actorTypeaheadProvider.notifier).clear();
    setState(() {
      _showSubmittedResults = true;
    });

    await Future.wait([
      ref.read(searchProvider.notifier).submitQuery(trimmedQuery),
      ref.read(postSearchProvider.notifier).submitQuery(trimmedQuery),
    ]);
  }

  void _onSuggestionSelected(ProfileViewBasic actor) {
    context.router.push(ProfileRoute(did: actor.did, initialProfile: actor));
  }

  void _onSubmitted(String _) {
    unawaited(_submitFullSearch());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userSearchState = ref.watch(searchProvider);
    final postSearchState = ref.watch(postSearchProvider);
    final typeaheadState = ref.watch(actorTypeaheadProvider);
    final hasQuery = _searchController.text.trim().isNotEmpty;
    final hasSubmittedQuery =
        userSearchState.query.isNotEmpty || postSearchState.query.isNotEmpty;
    final showSubmittedResults =
        _showSubmittedResults && hasQuery && hasSubmittedQuery;

    return DefaultTabController(
      length: 2,
      child: ExplorePageTemplate(
        searchWidget: InputField.search(
          controller: _searchController,
          hintText: l10n.hintSearchUsersPosts,
          onSubmitted: _onSubmitted,
          textInputAction: TextInputAction.search,
          leadingWidgets: const [Icon(FluentIcons.search_24_regular, size: 20)],
          actionWidgets: _searchController.text.isNotEmpty
              ? [
                  GestureDetector(
                    onTap: _searchController.clear,
                    child: const Icon(FluentIcons.dismiss_24_regular, size: 20),
                  ),
                ]
              : null,
        ),
        showTabs: showSubmittedResults,
        tabsWidget: TabBar(
          tabs: [
            Tab(text: l10n.tabPosts),
            Tab(text: l10n.tabUsers),
          ],
        ),
        contentWidget: const TabBarView(
          children: [PostResults(), UserResults()],
        ),
        emptyStateWidget: hasQuery
            ? _ActorTypeaheadSuggestions(
                state: typeaheadState,
                onSuggestionSelected: _onSuggestionSelected,
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref
                    ..invalidate(storiesByAuthorProvider())
                    ..invalidate(suggestedFeedsProvider);
                },
                child: CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(child: StoriesList()),
                    const SliverToBoxAdapter(child: SuggestedFeedsList()),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text(l10n.emptyDiscoverContent)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ActorTypeaheadSuggestions extends StatelessWidget {
  const _ActorTypeaheadSuggestions({
    required this.state,
    required this.onSuggestionSelected,
  });

  final ActorTypeaheadState state;
  final ValueChanged<ProfileViewBasic> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.isLoading && state.results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.error != null && state.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No user suggestions',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final actor = state.results[index];
        final avatarUrl = resolveImageUrlObject(actor.avatar);

        return ListTile(
          onTap: () => onSuggestionSelected(actor),
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: CircleAvatar(
            radius: 18,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null ? const Icon(Icons.person) : null,
          ),
          title: Text(actor.displayName ?? actor.handle),
          subtitle: Text('@${actor.handle}'),
        );
      },
    );
  }
}
