/// Utilities for DID document handling
class DidUtils {
  /// Extracts the PDS domain from a DID document
  ///
  /// [doc] - The DID document as a Map
  /// Returns the PDS domain string or null if not found
  static String? extractPdsDomain(Map<String, dynamic> doc) {
    final services = doc['service'] as List<dynamic>?;
    if (services == null || services.isEmpty) {
      return null;
    }

    final pdsService = services.firstWhere(
      (s) => s['id'] == '#atproto_pds', 
      orElse: () => {}
    );

    final String? pdsUrl = pdsService['serviceEndpoint'] as String?;
    if (pdsUrl == null) {
      return null;
    }

    return pdsUrl
      .replaceFirst('http://', '')
      .replaceFirst('https://', '')
      .replaceFirst('/', '');
  }
} 