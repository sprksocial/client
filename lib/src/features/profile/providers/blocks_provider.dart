import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/di/service_locator.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/features/profile/providers/user_list_provider.dart';

part 'blocks_provider.g.dart';

@Riverpod(keepAlive: true)
class Blocks extends _$Blocks {
  final GraphRepository _graphRepository = sl<GraphRepository>();
  final ActorRepository _actorRepository = sl<ActorRepository>();

  @override
  Future<PaginatedUserList> build({required String did}) async {
    final response = await _graphRepository.getBlocks(did);
    final profiles = response.blocks.toList();
    final cursor = response.cursor;

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
