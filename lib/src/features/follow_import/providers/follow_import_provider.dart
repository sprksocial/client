import 'package:bluesky_poptart/app/bsky/actor/profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/data/repositories/bluesky_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/graph_repository.dart';
import 'package:spark/src/features/feed/providers/feed_provider.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

part 'follow_import_provider.freezed.dart';
part 'follow_import_provider.g.dart';

@freezed
abstract class FollowImportSessionState with _$FollowImportSessionState {
  const FollowImportSessionState._();

  const factory FollowImportSessionState({
    @Default(false) bool selectionInitialized,
    @Default(<String>{}) Set<String> selectedDids,
    @Default(<String>{}) Set<String> importedDids,
    @Default(false) bool isSubmitting,
    @Default(false) bool isComplete,
    @Default(false) bool hasPartialFailure,
  }) = _FollowImportSessionState;

  Set<String> get remainingSelectedDids =>
      selectedDids.difference(importedDids);
}

@riverpod
BlueskyRepository followImportBlueskyRepository(Ref ref) {
  return GetIt.instance<BlueskyRepository>();
}

/// The current user's Bluesky profile, when one exists in their repository.
@riverpod
Future<ActorProfileRecord?> followImportBskyProfile(Ref ref) {
  return ref.watch(followImportBlueskyRepositoryProvider).getProfileRecord();
}

@riverpod
ActorRepository followImportActorRepository(Ref ref) {
  return GetIt.instance<ActorRepository>();
}

@riverpod
GraphRepository followImportGraphRepository(Ref ref) {
  return GetIt.instance<GraphRepository>();
}

/// Finds Bluesky follows that have Spark profiles and are not followed yet.
@riverpod
Future<List<ProfileViewDetailed>> followImportMatches(Ref ref) async {
  final blueskyRepository = ref.watch(followImportBlueskyRepositoryProvider);
  final actorRepository = ref.watch(followImportActorRepositoryProvider);
  final followedDids = <String>[];
  final seenDids = <String>{};
  final seenCursors = <String>{};
  String? cursor;

  do {
    final page = await blueskyRepository.getFollows(cursor: cursor);
    for (final follow in page.follows) {
      if (seenDids.add(follow.did)) followedDids.add(follow.did);
    }

    cursor = page.cursor;
    if (cursor != null && !seenCursors.add(cursor)) {
      throw StateError('Bluesky follows pagination returned a repeated cursor');
    }
  } while (cursor != null);

  final profilesByDid = <String, ProfileViewDetailed>{};
  for (var start = 0; start < followedDids.length; start += 25) {
    final end = (start + 25).clamp(0, followedDids.length);
    final profiles = await actorRepository.getProfiles(
      followedDids.sublist(start, end),
    );
    for (final profile in profiles) {
      // AppView can return actor shells without a Spark profile record;
      // indexedAt is only populated from so.sprk.actor.profile/self.
      if (profile.indexedAt != null && profile.viewer?.following == null) {
        profilesByDid[profile.did] = profile;
      }
    }
  }

  return [for (final did in followedDids) ?profilesByDid[did]];
}

/// Owns follow selection and partial-import progress for either import flow.
@riverpod
class FollowImportController extends _$FollowImportController {
  @override
  FollowImportSessionState build() => const FollowImportSessionState();

  void initializeSelection(Iterable<String> dids) {
    if (state.selectionInitialized) return;
    state = state.copyWith(
      selectionInitialized: true,
      selectedDids: {...state.importedDids, ...dids},
    );
  }

  void replaceSelection(Iterable<String> dids) {
    state = state.copyWith(selectedDids: {...state.importedDids, ...dids});
  }

  void resetSelection() {
    state = state.copyWith(
      selectionInitialized: false,
      selectedDids: state.importedDids,
      isComplete: false,
      hasPartialFailure: false,
    );
  }

  Future<bool> importSelected() async {
    if (state.isSubmitting) return false;
    final requestedDids = state.remainingSelectedDids;
    if (requestedDids.isEmpty) return false;

    final keepAliveLink = ref.keepAlive();
    state = state.copyWith(isSubmitting: true, hasPartialFailure: false);

    try {
      final repository = ref.read(followImportGraphRepositoryProvider);
      await repository.ensureFollowingBatch(requestedDids);
      if (!ref.mounted) return true;
      state = state.copyWith(
        importedDids: {...state.importedDids, ...requestedDids},
        isSubmitting: false,
        isComplete: true,
      );
      return true;
    } on EnsureFollowingBatchException catch (error) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        importedDids: {...state.importedDids, ...error.ensuredDids},
        isSubmitting: false,
        hasPartialFailure: true,
      );
      return false;
    } catch (_) {
      if (!ref.mounted) return false;
      state = state.copyWith(isSubmitting: false, hasPartialFailure: true);
      return false;
    } finally {
      keepAliveLink.close();
    }
  }

  /// Reloads the canonical Following feed after standalone imports complete.
  Future<void> refreshFollowingFeed() async {
    final feeds = ref.read(settingsProvider).feeds;
    for (final feed in feeds) {
      if (feed.type == 'timeline' && feed.config.value == 'following') {
        await ref.read(feedProvider(feed).notifier).loadAndUpdateFirstLoad();
        return;
      }
    }
  }
}
