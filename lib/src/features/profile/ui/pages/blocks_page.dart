import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/profile/providers/blocks_provider.dart';
import 'package:spark/src/features/profile/ui/widgets/blocks_list_view.dart';

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
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final currentDid = ref.read(currentDidProvider);
      if (currentDid != null) {
        ref.read(blocksProvider(did: currentDid).notifier).fetchMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDid = ref.watch(currentDidProvider);

    if (currentDid == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppLeadingButton(tooltip: 'Back'),
          title: const Text('Blocked Users'),
        ),
        body: const Center(child: Text('Please log in to view blocked users')),
      );
    }

    final blocksAsync = ref.watch(blocksProvider(did: currentDid));

    return Scaffold(
      appBar: AppBar(
        leading: const AppLeadingButton(tooltip: 'Back'),
        title: const Text('Blocked Users'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(blocksProvider(did: currentDid));
          await ref.read(blocksProvider(did: currentDid).future);
        },
        child: blocksAsync.when(
          data: (blocksList) => BlocksListView(
            users: blocksList.profiles,
            did: currentDid,
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
