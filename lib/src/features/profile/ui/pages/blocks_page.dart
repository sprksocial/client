import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/profile/providers/blocks_provider.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/blocks_list_view.dart';

@RoutePage()
class BlocksPage extends ConsumerStatefulWidget {
  const BlocksPage({super.key});

  @override
  ConsumerState<BlocksPage> createState() => _BlocksPageState();
}

class _BlocksPageState extends ConsumerState<BlocksPage> {
  final _scrollController = ScrollController();

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
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final session = ref.read(sessionProvider);
      if (session != null) {
        ref.read(blocksProvider(did: session.did).notifier).fetchMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppLeadingButton(tooltip: 'Back'),
          title: const Text('Blocked Users'),
        ),
        body: const Center(
          child: Text('Please log in to view blocked users'),
        ),
      );
    }

    final blocksAsync = ref.watch(blocksProvider(did: session.did));

    return Scaffold(
      appBar: AppBar(
        leading: const AppLeadingButton(tooltip: 'Back'),
        title: const Text('Blocked Users'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(blocksProvider(did: session.did));
          await ref.read(blocksProvider(did: session.did).future);
        },
        child: blocksAsync.when(
          data: (blocksList) => BlocksListView(
            users: blocksList.profiles,
            did: session.did,
            scrollController: _scrollController,
            isFetchingMore: blocksList.isFetchingMore,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('An error occurred: $error'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
