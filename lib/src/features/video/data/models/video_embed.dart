import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/features/video/data/models/blob_reference.dart';

part 'video_embed.freezed.dart';
part 'video_embed.g.dart';

/// Represents a video embed in a post
@freezed
class VideoEmbed with _$VideoEmbed {
  const factory VideoEmbed({
    /// The type of embed, typically 'so.sprk.embed.video'
    @JsonKey(name: '\$type') required String type,
    
    /// The video blob reference
    required BlobReference video,
    
    /// Optional alt text for accessibility
    String? alt,
  }) = _VideoEmbed;
  
  /// Create a VideoEmbed from JSON
  factory VideoEmbed.fromJson(Map<String, dynamic> json) => 
      _$VideoEmbedFromJson(json);
      
  /// Create an empty VideoEmbed
  factory VideoEmbed.empty() => VideoEmbed(
    type: 'so.sprk.embed.video',
    video: BlobReference.empty(),
  );
} 