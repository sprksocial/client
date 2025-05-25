import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/features/feed/data/models/video_action_state.dart';

part 'video_action_provider.g.dart';

/// Provider for managing post interactions
@riverpod
class VideoActionNotifier extends _$VideoActionNotifier {
  late final FeedRepository _feedRepository;

  @override
  VideoActionState build() {
    _feedRepository = GetIt.instance<FeedRepository>();
    return const VideoActionState();
  }

  /// Like a post
  Future<LikePostResponse?> likePost(String postCid, String postUri) async {
    if (state.isLoading) return null;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _feedRepository.likePost(postCid, postUri);
      state = state.copyWith(isLoading: false);
      return response;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Unlike a post
  Future<bool> unlikePost(String likeUri) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _feedRepository.unlikePost(likeUri);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Delete a post
  Future<bool> deletePost(String postUri) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _feedRepository.deletePost(postUri);
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
