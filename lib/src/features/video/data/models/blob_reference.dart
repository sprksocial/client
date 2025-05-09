import 'package:freezed_annotation/freezed_annotation.dart';

part 'blob_reference.freezed.dart';
part 'blob_reference.g.dart';

/// Represents a blob reference in the AT Protocol
@freezed
class BlobReference with _$BlobReference {
  const factory BlobReference({
    /// The type of the blob, usually 'blob'
    @JsonKey(name: '\$type') required String type,
    
    /// The MIME type of the blob
    required String mimeType,
    
    /// Size of the blob in bytes
    required int size,
    
    /// Content reference (CID)
    required String ref,
    
    /// Creation time in ISO 8601 format
    String? createdAt,
  }) = _BlobReference;
  
  /// Create a BlobReference from JSON
  factory BlobReference.fromJson(Map<String, dynamic> json) => 
      _$BlobReferenceFromJson(json);
      
  /// Create an empty BlobReference
  factory BlobReference.empty() => const BlobReference(
    type: 'blob',
    mimeType: 'video/mp4',
    size: 0,
    ref: '',
  );
} 