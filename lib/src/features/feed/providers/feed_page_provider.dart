import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/feed/data/models/feed_page_state.dart';
import 'package:sparksocial/src/features/feed/data/repositories/preload_repository.dart';
import 'package:sparksocial/src/features/feed/providers/preload_provider.dart';
import 'package:sparksocial/src/features/feed/providers/video_action_provider.dart';

part 'feed_page_provider.g.dart';

/// Provider for the feed page state
@riverpod
class FeedPageStateNotifier extends _$FeedPageStateNotifier {
  final _logger = GetIt.instance<LogService>().getLogger('FeedPage');
  late final FeedRepository _feedRepository;
  late final PreloadRepository _preloadRepository;
  
  @override
  FeedPageState build(int feedType, {List<FeedPost>? initialPosts, int? initialIndex}) {
    _feedRepository = ref.read(feedRepositoryProvider);
    _preloadRepository = ref.read(preloadRepositoryProvider);
    
    // If we have initial posts, use them and skip loading
    if (initialPosts != null) {
      final initIndex = initialIndex ?? 0;
      // Schedule preloading after the build completes
      Future.microtask(() => _preloadInitialMedia(initialPosts, initIndex));
      
      return FeedPageState(
        isLoading: false, // Not loading because we have initial posts
        posts: initialPosts,
        currentIndex: initIndex,
      );
    }
    
    // Schedule fetching the feed after the build completes
    Future.microtask(() => _fetchFeed(feedType));
    return FeedPageState.initial(); // Return an initial loading state
  }
  
  /// Fetch the feed based on feed type
  Future<void> _fetchFeed(int feedType) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentIndex: 0,
    );
    
    try {
      final posts = await _feedRepository.fetchFeed(feedType);
      final uniquePosts = _removeDuplicatePosts(posts);
      
      state = state.copyWith(
        isLoading: false,
        posts: uniquePosts,
        currentIndex: 0,
      );
      
      _preloadInitialMedia(uniquePosts, 0);
    } catch (e) {
      _logger.e('Error fetching feed', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// Remove duplicate posts from the feed
  List<FeedPost> _removeDuplicatePosts(List<FeedPost> posts) {
    if (posts.isEmpty) return [];

    final uniquePosts = <FeedPost>[];

    for (final post in posts) {
      final isDuplicate = uniquePosts.any((uniquePost) => 
        uniquePost.uri == post.uri && uniquePost.cid == post.cid);
      
      if (!isDuplicate) {
        uniquePosts.add(post);
      }
    }

    return uniquePosts;
  }
  
  /// Preload media for the initial posts
  Future<void> _preloadInitialMedia(List<FeedPost> posts, int startIndex) async {
    if (posts.isEmpty) return;
    
    // Preload the current post first
    if (startIndex >= 0 && startIndex < posts.length) {
      final post = posts[startIndex];
      await _preloadMedia(startIndex, post);
    }
    
    // Then preload the next few posts
    for (int i = 1; i <= 3 && startIndex + i < posts.length; i++) {
      final post = posts[startIndex + i];
      _preloadMedia(startIndex + i, post);
    }
  }
  
  /// Preload media for a specific post
  Future<void> _preloadMedia(int index, FeedPost post) async {
    if (index < 0 || index >= (state.posts.length)) return;
    
    ref.read(preloadMediaProvider(
      index: index,
      videoUrl: post.videoUrl,
      imageUrls: post.imageUrls,
    ).future);
  }
  
  /// Update the current index when page changes
  void updateIndex(int newIndex) {
    if (state.currentIndex != newIndex) {
      // Pause current video
      _preloadRepository.pauseVideo(state.currentIndex);
      
      // Update state
      state = state.copyWith(currentIndex: newIndex);
      
      // Update which media is loaded
      _preloadRepository.updateLoadedMedia(
        newIndex, 
        state.currentIndex, 
        state.posts.length
      );
      
      // Unload videos that are more than 6 positions away
      for (int i = 0; i < state.posts.length; i++) {
        if (i < newIndex - 6 || i > newIndex + 6) {
          _preloadRepository.unloadVideo(i);
        }
      }
      
      // Preload videos within 3 positions
      for (int i = newIndex - 3; i <= newIndex + 3; i++) {
        if (i >= 0 && i < state.posts.length) {
          final post = state.posts[i];
          _preloadMedia(i, post);
        }
      }
    }
  }
  
  /// Refresh the feed
  Future<void> refreshFeed(int feedType) async {
    _preloadRepository.pauseVideo(state.currentIndex);
    await _fetchFeed(feedType);
  }
  
  /// Handle parent visibility changes
  void handleParentVisibilityChange(bool isVisible) {
    if (!isVisible) {
      // Save current playing state before pausing
      final preloadedVideo = _preloadRepository.getPreloadedVideo(state.currentIndex);
      final wasPlaying = preloadedVideo?.controller.value.isPlaying ?? false;
      
      state = state.copyWith(wasPlayingBeforePause: wasPlaying);
      _preloadRepository.pauseVideo(state.currentIndex);
    } else {
      // Restore playing state
      if (state.wasPlayingBeforePause) {
        _preloadRepository.resumeVideo(state.currentIndex);
      }
      state = state.copyWith(wasPlayingBeforePause: false);
    }
  }
  
  /// Handle like press for a post
  Future<void> handleLikePress(FeedPost post) async {
    final videoActionNotifier = ref.read(videoActionNotifierProvider.notifier);
    
    try {
      LikePostResponse? response;
      
      if (post.likeUri != null) {
        // Unlike the post
        await _feedRepository.unlikePost(post.likeUri!);
        response = null;
      } else {
        // Like the post
        response = await videoActionNotifier.likePost(post.cid, post.uri);
      }
      
      // Update the post in the state
      final index = state.posts.indexWhere((p) => p.uri == post.uri);
      if (index >= 0) {
        final updatedPosts = [...state.posts];
        updatedPosts[index] = post.copyWith(
          likeCount: post.likeCount + (response != null ? 1 : -1),
          likeUri: response?.uri,
        );
        
        state = state.copyWith(posts: updatedPosts);
      }
    } catch (e) {
      _logger.e('Error liking post', error: e);
    }
  }
  
  /// Check if content should show a warning
  bool shouldWarnContent(FeedPost post) {
    return post.labels.isNotEmpty;
  }
  
  /// Get warning messages for content
  List<String> getWarningMessages(FeedPost post) {
    final warningMessages = <String>[];
    
    for (final label in post.labels) {
      // In a complete implementation we would get the label definition
      // from the label repository
      warningMessages.add(label);
    }
    
    return warningMessages;
  }
} 