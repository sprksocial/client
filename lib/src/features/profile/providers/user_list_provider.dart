import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/bluesky.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/di/service_locator.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/features/profile/ui/pages/user_list_page.dart';

part 'user_list_provider.g.dart';

@Riverpod(keepAlive: true)
class UserList extends _$UserList {
  final GraphRepository _graphRepository = sl<GraphRepository>();
  final AuthRepository _authRepository = sl<AuthRepository>();

  @override
  Future<List<ProfileView>> build({required String did, required UserListType type}) async {
    List<ProfileView> profiles;

    if (type == UserListType.followers) {
      final response = await _graphRepository.getFollowers(did);
      profiles = response.followers.toList();
    } else {
      final response = await _graphRepository.getFollows(did);
      profiles = response.follows.toList();
    }
    // fetch profiles with missing displayname from bsky
    // may remove this if we start indexing bsky profiles
    final didsToFetch = profiles.where((profile) => profile.displayName == null).map((profile) => profile.did).toList();

    if (didsToFetch.isNotEmpty) {
      final session = _authRepository.session;
      if (session != null) {
        final bsky = Bluesky.fromSession(session);
        final profilesResponse = await bsky.actor.getProfiles(actors: didsToFetch);
        final profilesMap = {for (final p in profilesResponse.data.profiles) p.did: p};

        for (var i = 0; i < profiles.length; i++) {
          final profile = profiles[i];
          if (profilesMap.containsKey(profile.did)) {
            final fetchedProfile = profilesMap[profile.did]!;
            profiles[i] = profile.copyWith(
              displayName: fetchedProfile.displayName,
              description: fetchedProfile.description,
              handle: fetchedProfile.handle,
              avatar: fetchedProfile.avatar != null ? AtUri.parse(fetchedProfile.avatar!) : null, // TODO: will be correct uri
            );
          }
        }
      }
    }

    return profiles;
  }

  Future<void> toggleFollow(String did) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final userIndex = currentState.indexWhere((user) => user.did == did);
    if (userIndex == -1) return;

    final user = currentState[userIndex];
    final isCurrentlyFollowing = user.viewer?.following != null;
    final currentFollowUri = user.viewer?.following;

    // Optimistic UI update
    final updatedUser = user.copyWith(
      viewer: user.viewer?.copyWith(following: isCurrentlyFollowing ? null : AtUri.parse('at://temp/uri')),
    );
    final newList = List<ProfileView>.from(currentState);
    newList[userIndex] = updatedUser;
    state = AsyncValue.data(newList);

    try {
      final newUriString = await _graphRepository.toggleFollow(did, currentFollowUri);
      final newUri = newUriString != null ? AtUri.parse(newUriString) : null;

      // Final state update with correct URI
      final finalUser = user.copyWith(
        viewer: user.viewer?.copyWith(following: newUri),
      );
      final finalList = List<ProfileView>.from(state.value!);
      finalList[userIndex] = finalUser;
      state = AsyncValue.data(finalList);
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(currentState);
      // Optionally, show an error message to the user
    }
  }
}
