import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/features/profile/providers/user_list_provider.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/user_list_view.dart';

enum UserListType { followers, following }

@RoutePage()
class UserListPage extends ConsumerWidget {
  final String did;
  final UserListType type;

  const UserListPage({required this.did, required this.type, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userListAsync = ref.watch(userListProvider(did: did, type: type));
    final title = type == UserListType.followers ? 'Followers' : 'Following';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userListProvider(did: did, type: type));
          await ref.read(userListProvider(did: did, type: type).future);
        },
        child: userListAsync.when(
          data: (users) => UserListView(users: users),
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
