import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/bluesky.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/di/service_locator.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/features/profile/ui/pages/user_list_page.dart';

part 'user_list_provider.g.dart';

class PaginatedUserList {
  final List<ProfileView> profiles;
  final String? cursor;
  final bool isFetchingMore;

  PaginatedUserList({required this.profiles, this.cursor, this.isFetchingMore = false});

  PaginatedUserList copyWith({
    List<ProfileView>? profiles,
    String? cursor,
    bool? isFetchingMore,
    bool updateCursor = false,
  }) {
    // remove profiles with unknown.invalid handle
    profiles?.removeWhere((profile) => profile.handle == 'unknown.invalid' || profile.handle.isEmpty);
    return PaginatedUserList(
      profiles: profiles ?? this.profiles,
      cursor: updateCursor ? cursor : this.cursor,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

@Riverpod(keepAlive: true)
class UserList extends _$UserList {
  final GraphRepository _graphRepository = sl<GraphRepository>();
  final AuthRepository _authRepository = sl<AuthRepository>();

  @override
  Future<PaginatedUserList> build({required String did, required UserListType type}) async {
    List<ProfileView> profiles;
    String? cursor;

    if (type == UserListType.followers) {
      final response = await _graphRepository.getFollowers(did);
      profiles = response.followers.toList();
      cursor = response.cursor;
    } else {
      final response = await _graphRepository.getFollows(did);
      profiles = response.follows.toList();
      cursor = response.cursor;
    }

    await _fetchAndMergeProfilesFromBsky(profiles);

    // remove profiles with unknown.invalid handle
    profiles.removeWhere((profile) => profile.handle == 'unknown.invalid' || profile.handle.isEmpty);

    return PaginatedUserList(profiles: profiles, cursor: cursor);
  }

  Future<void> _fetchAndMergeProfilesFromBsky(List<ProfileView> profiles) async {
    final didsToFetch = profiles.where((profile) => profile.displayName == null).map((profile) => profile.did).toList();

    if (didsToFetch.isNotEmpty) {
      final session = _authRepository.session;
      if (session != null) {
        final bsky = Bluesky.fromSession(session);
        final fetchedProfiles = <ActorProfile>[];

        for (var i = 0; i < didsToFetch.length; i += 25) {
          final batch = didsToFetch.sublist(i, i + 25 > didsToFetch.length ? didsToFetch.length : i + 25);
          final profilesResponse = await bsky.actor.getProfiles(actors: batch);
          fetchedProfiles.addAll(profilesResponse.data.profiles);
        }
        final profilesMap = {for (final p in fetchedProfiles) p.did: p};

        for (var i = 0; i < profiles.length; i++) {
          final profile = profiles[i];
          if (profilesMap.containsKey(profile.did)) {
            final fetchedProfile = profilesMap[profile.did]!;
            profiles[i] = profile.copyWith(
              displayName: fetchedProfile.displayName,
              description: fetchedProfile.description,
              handle: fetchedProfile.handle,
              avatar: fetchedProfile.avatar != null ? Uri.parse(fetchedProfile.avatar!) : null,
            );
          }
        }
      }
    }
  }

  Future<void> fetchMore() async {
    if (state.value == null || state.value!.cursor == null || state.value!.isFetchingMore) return;

    state = AsyncValue.data(state.value!.copyWith(isFetchingMore: true));

    try {
      List<ProfileView> newProfiles;
      String? newCursor;

      if (type == UserListType.followers) {
        final response = await _graphRepository.getFollowers(did, cursor: state.value!.cursor);
        newProfiles = response.followers.toList();
        newCursor = response.cursor;
      } else {
        final response = await _graphRepository.getFollows(did, cursor: state.value!.cursor);
        newProfiles = response.follows.toList();
        newCursor = response.cursor;
      }

      await _fetchAndMergeProfilesFromBsky(newProfiles);

      state = AsyncValue.data(
        state.value!.copyWith(
          profiles: [...state.value!.profiles, ...newProfiles],
          cursor: newCursor,
          isFetchingMore: false,
          updateCursor: true,
        ),
      );
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(state.value!.copyWith(isFetchingMore: false));
    }
  }

  Future<void> toggleFollow(String did) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final userIndex = currentState.profiles.indexWhere((user) => user.did == did);
    if (userIndex == -1) return;

    final user = currentState.profiles[userIndex];
    final isCurrentlyFollowing = user.viewer?.following != null;
    final currentFollowUri = user.viewer?.following;

    // Optimistic UI update
    final updatedUser = user.copyWith(
      viewer: user.viewer?.copyWith(following: isCurrentlyFollowing ? null : AtUri.parse('at://temp/uri')),
    );
    final newList = List<ProfileView>.from(currentState.profiles);
    newList[userIndex] = updatedUser;
    state = AsyncValue.data(currentState.copyWith(profiles: newList));

    try {
      final newUriString = await _graphRepository.toggleFollow(did, currentFollowUri);
      final newUri = newUriString != null ? AtUri.parse(newUriString) : null;

      // Final state update with correct URI
      final finalUser = user.copyWith(
        viewer: user.viewer?.copyWith(following: newUri),
      );
      final finalList = List<ProfileView>.from(state.value!.profiles);
      finalList[userIndex] = finalUser;
      state = AsyncValue.data(currentState.copyWith(profiles: finalList));
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(currentState);
      // Optionally, show an error message to the user
    }
  }
}
