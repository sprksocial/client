import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/features/profile/providers/user_list_provider.dart';
import 'package:spark/src/features/profile/ui/widgets/user_list_view.dart';

enum UserListType { followers, following }

@RoutePage()
class UserListPage extends ConsumerStatefulWidget {
  final String did;
  final UserListType type;

  const UserListPage({required this.did, required this.type, super.key});

  @override
  ConsumerState<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends ConsumerState<UserListPage> {
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
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref
          .read(userListProvider(did: widget.did, type: widget.type).notifier)
          .fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userListAsync = ref.watch(
      userListProvider(did: widget.did, type: widget.type),
    );
    final title = widget.type == UserListType.followers
        ? 'Followers'
        : 'Following';

    return Scaffold(
      appBar: AppBar(
        leading: const AppLeadingButton(tooltip: 'Back'),
        title: Text(title),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userListProvider(did: widget.did, type: widget.type));
          await ref.read(
            userListProvider(did: widget.did, type: widget.type).future,
          );
        },
        child: userListAsync.when(
          data: (userList) => UserListView(
            users: userList.profiles,
            did: widget.did,
            type: widget.type,
            scrollController: _scrollController,
            isFetchingMore: userList.isFetchingMore,
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
