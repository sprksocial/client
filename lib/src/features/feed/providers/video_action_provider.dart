import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/network/data/repositories/repo_repository.dart';
import 'package:sparksocial/src/features/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/features/feed/data/models/video_action_state.dart';

part 'video_action_provider.g.dart';

/// Provider for the feed repository
@riverpod
FeedRepository feedRepository(Ref ref) {
  return GetIt.instance<FeedRepository>();
}

/// Provider for the auth repository
@riverpod
AuthRepository authRepository(Ref ref) {
  return GetIt.instance<AuthRepository>();
}

/// Provider for repo repository
@riverpod
RepoRepository repoRepository(Ref ref) {
  return GetIt.instance<RepoRepository>();
}

/// Provider for managing post interactions
@riverpod
class VideoActionNotifier extends _$VideoActionNotifier {
  @override
  VideoActionState build() {
    return const VideoActionState();
  }

  /// Like a post
  Future<LikePostResponse?> likePost(String postCid, String postUri) async {
    if (state.isLoading) return null;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await ref.read(feedRepositoryProvider).likePost(postCid, postUri);
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
      await ref.read(feedRepositoryProvider).unlikePost(likeUri);
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
      final success = await ref.read(feedRepositoryProvider).deletePost(postUri);
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
} 