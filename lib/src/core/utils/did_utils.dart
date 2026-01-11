/// Utility class for working with Decentralized Identifiers (DIDs).
///
/// Provides methods for building DID document URLs for various DID methods
/// including did:plc and did:web.
class DidUtils {
  DidUtils._();

  /// Builds the URL for fetching a DID document based on the DID method.
  ///
  /// Supported DID methods:
  /// - `did:plc` -> `https://plc.directory/<did>`
  /// - `did:web` -> `https://<domain>/.well-known/did.json` (or path-based)
  ///
  /// Throws [ArgumentError] if the DID is malformed (e.g., empty domain).
  ///
  /// Examples:
  /// ```dart
  /// // did:plc
  /// DidUtils.buildDidDocumentUrl('did:plc:abc123');
  /// // Returns: https://plc.directory/did:plc:abc123
  ///
  /// // did:web (domain only)
  /// DidUtils.buildDidDocumentUrl('did:web:example.com');
  /// // Returns: https://example.com/.well-known/did.json
  ///
  /// // did:web (with path)
  /// DidUtils.buildDidDocumentUrl('did:web:example.com:user:alice');
  /// // Returns: https://example.com/user/alice/did.json
  /// ```
  static Uri buildDidDocumentUrl(String did) {
    if (did.startsWith('did:web:')) {
      return _buildDidWebUrl(did);
    }
    // Default: did:plc or other methods use PLC directory
    return Uri.parse('https://plc.directory/$did');
  }

  /// Builds a URL for a did:web identifier.
  static Uri _buildDidWebUrl(String did) {
    // did:web:<domain> or did:web:<domain>:<path>:<segments>
    final webPart = did.substring('did:web:'.length);

    if (webPart.isEmpty) {
      throw ArgumentError('Invalid did:web identifier: missing domain');
    }

    // Split by ':' first, then decode each segment
    // This correctly handles percent-encoded colons in the domain (e.g., ports)
    final segments = webPart.split(':').map(Uri.decodeComponent).toList();

    if (segments.isEmpty || segments.first.isEmpty) {
      throw ArgumentError('Invalid did:web identifier: missing domain');
    }

    final domain = segments.first;

    if (segments.length == 1) {
      // did:web:example.com -> https://example.com/.well-known/did.json
      return Uri.parse('https://$domain/.well-known/did.json');
    } else {
      // did:web:example.com:path:to:resource ->
      // https://example.com/path/to/resource/did.json
      final path = segments.skip(1).join('/');
      return Uri.parse('https://$domain/$path/did.json');
    }
  }
}
