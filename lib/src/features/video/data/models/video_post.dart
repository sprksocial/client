import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/label_models.dart';
import 'package:sparksocial/src/features/video/data/models/facet.dart';
import 'package:sparksocial/src/features/video/data/models/video_embed.dart';

part 'video_post.freezed.dart';
part 'video_post.g.dart';

/// Represents a post containing a video
@freezed
class VideoPost with _$VideoPost {
  const factory VideoPost({
    /// The type of post, typically 'so.sprk.feed.post'
    @JsonKey(name: r'$type') required String type,
    
    /// Post text/description
    @Default('') String text,
    
    /// Video embed containing the actual video data
    required VideoEmbed embed,
    
    /// When the post was created (ISO 8601 format)
    required String createdAt,
    
    /// Optional language tags
    List<String>? langs,
    
    /// Optional content warning labels
    @JsonKey(name: 'labels') List<LabelDetail>? labels,
    
    /// Optional tags for discovery
    List<String>? tags,
    
    /// Optional facets for rich text formatting
    List<Facet>? facets,
  }) = _VideoPost;
  
  /// Create a VideoPost from JSON
  factory VideoPost.fromJson(Map<String, dynamic> json) => 
      _$VideoPostFromJson(json);
  
  /// Create a new empty VideoPost
  factory VideoPost.create({
    required String text,
    required Map<String, dynamic> videoData,
    String? videoAltText,
    List<String>? tags,
    List<LabelDetail>? labels,
    List<Facet>? facets,
  }) {
    final videoEmbed = {
      r'$type': 'so.sprk.embed.video',
      'video': videoData,
    };
    
    // Add alt text if provided
    if (videoAltText != null && videoAltText.isNotEmpty) {
      videoEmbed['alt'] = videoAltText;
    }
    
    return VideoPost(
      type: 'so.sprk.feed.post',
      text: text,
      embed: VideoEmbed.fromJson(videoEmbed),
      createdAt: DateTime.now().toUtc().toIso8601String(),
      tags: tags,
      labels: labels,
      facets: facets,
    );
  }
} 