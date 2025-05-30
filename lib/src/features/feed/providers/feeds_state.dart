import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

part 'feeds_state.freezed.dart';

@freezed
abstract class FeedsState with _$FeedsState {
  factory FeedsState({
    required List<Feed> feeds,
    required Feed activeFeed,
  }) = _FeedsState;
}
