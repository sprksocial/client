import 'dart:io';

/// Interface defining cache management operations
abstract class CacheManagerInterface {
  /// Get a cached file or download it if not available
  Future<File> getFile(String url);

  /// Store a file in the cache with the given key
  Future<void> putFile(String url, List<int> fileBytes);

  /// Remove a specific file from cache
  Future<void> removeFile(String url);

  /// Calculate the total size of the cache in bytes
  Future<int> getCacheSize();

  /// Clear all cached files
  Future<void> clearCache();
}
