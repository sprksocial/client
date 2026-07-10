import 'package:poptart/poptart.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

part 'post_likes_provider.g.dart';

final class PostLikesState {
  const PostLikesState({
    required this.likes,
    this.cursor,
    this.isFetchingMore = false,
  });

  final List<PostLike> likes;
  final String? cursor;
  final bool isFetchingMore;

  PostLikesState copyWith({
    List<PostLike>? likes,
    String? cursor,
    bool? isFetchingMore,
    bool updateCursor = false,
  }) {
    return PostLikesState(
      likes: likes ?? this.likes,
      cursor: updateCursor ? cursor : this.cursor,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

@riverpod
class PostLikes extends _$PostLikes {
  final FeedRepository _feedRepository = GetIt.instance<SprkRepository>().feed;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'PostLikes',
  );

  @override
  Future<PostLikesState> build({required String uri, String? cid}) async {
    try {
      final result = await _feedRepository.getLikes(AtUri.parse(uri), cid: cid);
      return PostLikesState(likes: result.likes, cursor: result.cursor);
    } catch (error, stackTrace) {
      _logger.e(
        'Failed to load likes for $uri',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> fetchMore() async {
    final current = state.value;
    if (current == null || current.cursor == null || current.isFetchingMore) {
      return;
    }

    state = AsyncValue.data(current.copyWith(isFetchingMore: true));

    try {
      final result = await _feedRepository.getLikes(
        AtUri.parse(uri),
        cid: cid,
        cursor: current.cursor,
      );
      if (!ref.mounted) return;

      final existingDids = current.likes.map((like) => like.actor.did).toSet();
      final newLikes = result.likes
          .where((like) => existingDids.add(like.actor.did))
          .toList();
      state = AsyncValue.data(
        current.copyWith(
          likes: [...current.likes, ...newLikes],
          cursor: result.cursor,
          isFetchingMore: false,
          updateCursor: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.e(
        'Failed to load more likes for $uri',
        error: error,
        stackTrace: stackTrace,
      );
      if (!ref.mounted) return;
      state = AsyncValue.data(current.copyWith(isFetchingMore: false));
    }
  }
}
