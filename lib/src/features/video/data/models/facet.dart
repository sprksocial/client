import 'package:freezed_annotation/freezed_annotation.dart';

part 'facet.freezed.dart';
part 'facet.g.dart';

/// Represents a richtext facet for text formatting, mentions, links, etc.
@freezed
class Facet with _$Facet {
  const factory Facet({
    /// Index range for the facet in the text
    required FacetIndex index,
    
    /// Features represented by this facet (mention, link, hashtag, etc.)
    required List<FacetFeature> features,
  }) = _Facet;
  
  /// Create a Facet from JSON
  factory Facet.fromJson(Map<String, dynamic> json) => 
      _$FacetFromJson(json);
}

/// Represents the index range for a facet in the text
@freezed
class FacetIndex with _$FacetIndex {
  const factory FacetIndex({
    /// Start index (inclusive)
    required int byteStart,
    
    /// End index (exclusive)
    required int byteEnd,
  }) = _FacetIndex;
  
  /// Create a FacetIndex from JSON
  factory FacetIndex.fromJson(Map<String, dynamic> json) => 
      _$FacetIndexFromJson(json);
}

/// Represents a feature of a facet (mention, link, hashtag, etc.)
@freezed
class FacetFeature with _$FacetFeature {
  /// Mention feature for referencing a user
  const factory FacetFeature.mention({
    required String did,
  }) = MentionFeature;
  
  /// Link feature for URLs
  const factory FacetFeature.link({
    required String uri,
  }) = LinkFeature;
  
  /// Tag feature for hashtags
  const factory FacetFeature.tag({
    required String tag,
  }) = TagFeature;
  
  /// Create a FacetFeature from JSON
  factory FacetFeature.fromJson(Map<String, dynamic> json) => 
      _$FacetFeatureFromJson(json);
} 