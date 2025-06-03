import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sparksocial/src/core/storage/cache/cache_manager_interface.dart';

/// Manages temporary cache files for the application
class CacheManagerImpl implements CacheManagerInterface {
  /// Singleton instance
  static final CacheManagerImpl _instance = CacheManagerImpl._();

  /// Default cache manager for most files
  late final CacheManager cacheManager;

  /// Private constructor
  CacheManagerImpl._() {
    cacheManager = CacheManager(
      Config(
        'sparksocial',
        maxNrOfCacheObjects: 100,
      ),
    );
  }

  /// Get the singleton instance
  static CacheManagerImpl get instance => _instance;

  /// Get a cached file or download it if not available
  @override
  Future<File> getFile(String url) async {
    final fileInfo = await cacheManager.getFileFromCache(url);
    if (fileInfo != null) {
      return fileInfo.file;
    }

    // File not in cache, download it
    final file = await cacheManager.getSingleFile(url);
    return file;
  }

  /// Get a cached file
  /// Returns null if not found
  @override
  Future<File?> getCachedFile(String url) async {
    return (await cacheManager.getFileFromCache(url))?.file;
  }

  /// Store a file in the cache with the given key
  @override
  Future<void> putFile(String url, Uint8List fileBytes) async {
    await cacheManager.putFile(
      url,
      fileBytes,
      maxAge: const Duration(days: 7), // Cache for 7 days
    );
  }

  /// Remove a specific file from cache
  @override
  Future<void> removeFile(String url) async {
    await cacheManager.removeFile(url);
  }

  /// Calculate the total size of the cache in bytes
  @override
  Future<int> getCacheSize() async {
    final cacheDir = await getTemporaryDirectory();
    return await _calculateDirSize(cacheDir);
  }

  /// Clear all cached files
  @override
  Future<void> clearCache() async {
    await cacheManager.emptyCache();

    // Also clear the temp directory
    final tempDir = await getTemporaryDirectory();
    if (tempDir.existsSync()) {
      tempDir.listSync().forEach((entity) {
        if (entity is File) {
          try {
            entity.deleteSync();
          } catch (_) {}
        } else if (entity is Directory) {
          try {
            entity.deleteSync(recursive: true);
          } catch (_) {}
        }
      });
    }
  }

  /// Helper method to calculate directory size
  Future<int> _calculateDirSize(Directory dir) async {
    int totalSize = 0;
    try {
      if (dir.existsSync()) {
        dir.listSync(recursive: true, followLinks: false).forEach((FileSystemEntity entity) {
          if (entity is File) {
            totalSize += entity.lengthSync();
          }
        });
      }
    } catch (e) {
      // Ignore errors
    }
    return totalSize;
  }
}
