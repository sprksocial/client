/// Utility functions for AT Protocol identity operations
class IdentityUtils {
  /// Checks if a string is a valid DID
  static bool isValidDid(String value) {
    return value.startsWith('did:');
  }
  
  /// Checks if a string is a valid AT Protocol handle
  static bool isValidHandle(String value) {
    // Simple regex for handle validation
    // More complex validation should be added as needed
    return RegExp(r'^[a-zA-Z0-9.-]+\.[a-zA-Z0-9]+$').hasMatch(value);
  }
  
  /// Formats a handle to ensure it doesn't have the 'at://' prefix
  static String formatHandle(String handle) {
    return handle.startsWith('at://') 
        ? handle.replaceFirst('at://', '') 
        : handle;
  }
  
  /// Formats a DID to ensure proper format
  static String formatDid(String did) {
    // Ensure the DID has the correct format
    if (!did.startsWith('did:')) {
      throw ArgumentError('Invalid DID format: $did');
    }
    return did;
  }
  
  /// Extracts the host part from a handle
  static String? extractHostFromHandle(String handle) {
    final parts = formatHandle(handle).split('.');
    if (parts.length < 2) return null;
    return parts.skip(1).join('.');
  }
  
  // Private constructor to prevent instantiation
  IdentityUtils._();
} 