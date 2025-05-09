import 'package:atproto/atproto.dart';
import 'package:sparksocial/src/features/video/data/models/models.dart';

/// Interface for video-related API operations
abstract class UploadRepository {
  /// Process and upload a video file
  /// 
  /// [videoPath] The path to the video file
  /// Returns the blob reference for the video
  Future<BlobReference?> processVideo(String videoPath);

  /// Post a video to the user's feed
  /// 
  /// [videoData] The blob reference data for the video
  /// [description] The text description for the post
  /// [videoAltText] The alt text for the video
  Future<StrongRef> postVideo(
    BlobReference? videoData, {
    String description = '', 
    String videoAltText = ''
  });
  
  /// Post a video using a prepared VideoPost object
  /// 
  /// [videoPost] The prepared video post data
  Future<StrongRef> postVideoWithPost(VideoPost videoPost);
} 