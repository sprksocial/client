import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/features/feed/data/models/image_post_state.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';

part 'image_post_provider.g.dart';

@riverpod
class ImagePost extends _$ImagePost {
  final FeedRepository _feedRepository = GetIt.instance.get<FeedRepository>();

  @override
  ImagePostState build(ImagePostState initialState) {
    return initialState;
  }
  
  void toggleLike() {
    if (state.isLiked) {
      _feedRepository.unlikePost(state.postCid);
    } else {
      _feedRepository.likePost(state.postCid, state.postUri);
    }
    state = state.copyWith(
      isLiked: !state.isLiked,
      likeCount: state.isLiked ? state.likeCount - 1 : state.likeCount + 1,
    );
  }
  
  void updateCommentCount(int count) {
    state = state.copyWith(commentCount: count);
  }
  
  void setVisible(bool isVisible) {
    state = state.copyWith(isVisible: isVisible);
  }
  
  void updateCarouselIndex(int index) {
    state = state.copyWith(currentCarouselIndex: index);
  }
  
  void toggleDescriptionExpanded(bool expanded) {
    state = state.copyWith(isDescriptionExpanded: expanded);
  }

  void toggleComments() {
    state = state.copyWith(showComments: !state.showComments);
  }
} 