import 'package:bluesky/bluesky.dart' as bsky;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/di/service_locator.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/features/profile/providers/user_list_provider.dart';

part 'blocks_provider.g.dart';

@Riverpod(keepAlive: true)
class Blocks extends _$Blocks {
  final GraphRepository _graphRepository = sl<GraphRepository>();
  final AuthRepository _authRepository = sl<AuthRepository>();

  @override
  Future<PaginatedUserList> build({required String did}) async {
    final response = await _graphRepository.getBlocks(did);
    final profiles = response.blocks.toList();
    final cursor = response.cursor;

    await _fetchAndMergeProfilesFromBsky(profiles);

    // remove profiles with unknown.invalid handle
    profiles.removeWhere(
      (profile) =>
          profile.handle == 'unknown.invalid' || profile.handle.isEmpty,
    );

    return PaginatedUserList(profiles: profiles, cursor: cursor);
  }

  Future<void> _fetchAndMergeProfilesFromBsky(
    List<ProfileView> profiles,
  ) async {
    final didsToFetch = profiles
        .where((profile) => profile.displayName == null)
        .map((profile) => profile.did)
        .toList();

    if (didsToFetch.isNotEmpty) {
      final session = _authRepository.session;
      if (session != null) {
        final bskyClient = bsky.Bluesky.fromSession(session);
        final fetchedProfiles = <dynamic>[];

        for (var i = 0; i < didsToFetch.length; i += 25) {
          final batch = didsToFetch.sublist(
            i,
            i + 25 > didsToFetch.length ? didsToFetch.length : i + 25,
          );
          final profilesResponse = await bskyClient.actor.getProfiles(
            actors: batch,
          );
          fetchedProfiles.addAll(profilesResponse.data.profiles);
        }
        final profilesMap = {for (final p in fetchedProfiles) p.did: p};

        for (var i = 0; i < profiles.length; i++) {
          final profile = profiles[i];
          if (profilesMap.containsKey(profile.did)) {
            final fetchedProfile = profilesMap[profile.did]!;
            profiles[i] = profile.copyWith(
              displayName: fetchedProfile.displayName as String?,
              description: fetchedProfile.description as String?,
              handle: fetchedProfile.handle as String,
              avatar: fetchedProfile.avatar != null
                  ? Uri.parse(fetchedProfile.avatar as String)
                  : null,
            );
          }
        }
      }
    }
  }

  Future<void> unblockUser(String userDid) async {
    final profile = state.value!.profiles.firstWhere((p) => p.did == userDid);
    final blockUri = profile.viewer?.blocking;
    if (blockUri == null) return;

    await _graphRepository.unblockUser(blockUri);
    final updatedProfiles = state.value!.profiles
        .where((p) => p.did != userDid)
        .toList();
    state = AsyncValue.data(state.value!.copyWith(profiles: updatedProfiles));
  }

  Future<void> fetchMore() async {
    if (state.value == null ||
        state.value!.cursor == null ||
        state.value!.isFetchingMore) {
      return;
    }

    state = AsyncValue.data(state.value!.copyWith(isFetchingMore: true));

    try {
      final response = await _graphRepository.getBlocks(
        did,
        cursor: state.value!.cursor,
      );
      final newProfiles = response.blocks.toList();
      final newCursor = response.cursor;

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
}
