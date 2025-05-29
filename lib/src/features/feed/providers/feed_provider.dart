import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/features/feed/providers/feed_state.dart';

part 'feed_provider.g.dart';

@Riverpod(keepAlive: true)
class FeedNotifier extends _$FeedNotifier {
  @override
  FeedState build() {
    return FeedState(active: true, pages: [], index: 0);
  }
}
