import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_option.freezed.dart';
part 'feed_option.g.dart';

/// Represents a selectable option in a feed selector.
@freezed
class FeedOption with _$FeedOption {
  const factory FeedOption({
    /// The displayed text for this option
    required String label,
    
    /// The value associated with this option
    required int value,
  }) = _FeedOption;

  factory FeedOption.fromJson(Map<String, dynamic> json) => _$FeedOptionFromJson(json);
} 