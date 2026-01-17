import 'package:atproto_core/atproto_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/di/service_locator.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/features/profile/ui/pages/user_list_page.dart';

part 'user_list_provider.g.dart';

class PaginatedUserList {
  final List<ProfileView> profiles;
  final String? cursor;
  final bool isFetchingMore;

  PaginatedUserList({
    required this.profiles,
    this.cursor,
    this.isFetchingMore = false,
  });

  PaginatedUserList copyWith({
    List<ProfileView>? profiles,
    String? cursor,
    bool? isFetchingMore,
    bool updateCursor = false,
  }) {
    // remove profiles with unknown.invalid handle
    profiles?.removeWhere(
      (profile) =>
          profile.handle == 'unknown.invalid' || profile.handle.isEmpty,
    );
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
  final ActorRepository _actorRepository = sl<ActorRepository>();
  final AuthRepository _authRepository = sl<AuthRepository>();

  bool isCurrentUser(String did) {
    final currentDid = _authRepository.did;
    if (currentDid == null) return false;
    return currentDid == did;
  }

  @override
  Future<PaginatedUserList> build({
    required String did,
    required UserListType type,
  }) async {
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

    await _fetchAndMergeProfiles(profiles);

    // remove profiles with unknown.invalid handle
    profiles.removeWhere(
      (profile) =>
          profile.handle == 'unknown.invalid' || profile.handle.isEmpty,
    );

    return PaginatedUserList(profiles: profiles, cursor: cursor);
  }

  /// Fetch missing profile data using ActorRepository (Spark-first with
  /// Bluesky fallback)
  /// Only fetches profiles that are actually incomplete (missing key fields)
  Future<void> _fetchAndMergeProfiles(
    List<ProfileView> profiles,
  ) async {
    // Check if profile is incomplete - need to check multiple fields
    // A profile is incomplete if it's missing displayName, description, or avatar
    // AND has a valid handle (if handle is missing, it's likely a deleted account)
    final didsToFetch = profiles
        .where((profile) {
          // Profile is incomplete if it has a valid handle but is missing key fields
          final hasValidHandle = profile.handle.isNotEmpty &&
              profile.handle != 'unknown.invalid';
          final isIncomplete = hasValidHandle &&
              (profile.displayName == null ||
                  profile.description == null ||
                  profile.avatar == null);
          return isIncomplete;
        })
        .map((profile) => profile.did)
        .toList();

    if (didsToFetch.isEmpty) return;

    // Use ActorRepository which has proper Spark-first, Bluesky-fallback logic
    final fetchedProfiles = <ProfileViewDetailed>[];

    for (var i = 0; i < didsToFetch.length; i += 25) {
      final batch = didsToFetch.sublist(
        i,
        i + 25 > didsToFetch.length ? didsToFetch.length : i + 25,
      );
      try {
        final batchProfiles = await _actorRepository.getProfiles(batch);
        fetchedProfiles.addAll(batchProfiles);
      } catch (e) {
        // If batch fails, continue with other batches
        continue;
      }
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
          avatar: fetchedProfile.avatar,
        );
      }
    }
  }

  Future<void> followUser(String userDid) async {
    try {
      final response = await _graphRepository.followUser(userDid);
      final updatedProfiles = state.value!.profiles.map((p) {
        if (p.did == userDid) {
          return p.copyWith(
            viewer:
                p.viewer?.copyWith(following: AtUri.parse(response.uri)) ??
                ActorViewer(following: AtUri.parse(response.uri)),
          );
        }
        return p;
      }).toList();
      state = AsyncValue.data(state.value!.copyWith(profiles: updatedProfiles));
    } catch (e) {
      // handle error, maybe revert state
    }
  }

  Future<void> unfollowUser(String userDid) async {
    final profile = state.value!.profiles.firstWhere((p) => p.did == userDid);
    final followUri = profile.viewer?.following;
    if (followUri == null) return;

    try {
      await _graphRepository.unfollowUser(followUri);
      final updatedProfiles = state.value!.profiles.map((p) {
        if (p.did == userDid) {
          return p.copyWith(viewer: p.viewer?.copyWith(following: null));
        }
        return p;
      }).toList();
      state = AsyncValue.data(state.value!.copyWith(profiles: updatedProfiles));
    } catch (e) {
      // handle error, maybe revert state
    }
  }

  Future<void> fetchMore() async {
    if (state.value == null ||
        state.value!.cursor == null ||
        state.value!.isFetchingMore) {
      return;
    }

    state = AsyncValue.data(state.value!.copyWith(isFetchingMore: true));

    try {
      List<ProfileView> newProfiles;
      String? newCursor;

      if (type == UserListType.followers) {
        final response = await _graphRepository.getFollowers(
          did,
          cursor: state.value!.cursor,
        );
        newProfiles = response.followers.toList();
        newCursor = response.cursor;
      } else {
        final response = await _graphRepository.getFollows(
          did,
          cursor: state.value!.cursor,
        );
        newProfiles = response.follows.toList();
        newCursor = response.cursor;
      }

      await _fetchAndMergeProfiles(newProfiles);

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
}
