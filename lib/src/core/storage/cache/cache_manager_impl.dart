import 'dart:io';
import 'dart:typed_data';
import 'package:atproto/core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sparksocial/src/core/storage/cache/cache_manager_interface.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:atproto/atproto.dart' as atproto;

/// Manages temporary cache files for the application
class CacheManagerImpl implements CacheManagerInterface {
  /// Singleton instance
  static final CacheManagerImpl _instance = CacheManagerImpl._();

  /// Default cache manager for most files
  late final CacheManager cacheManager;

  /// Logger for debugging
  late final SparkLogger _logger;

  /// Private constructor
  CacheManagerImpl._() {
    cacheManager = CacheManager(
      Config(
        'sparksocial',
        maxNrOfCacheObjects: 100,
      ),
    );
    _logger = GetIt.instance<LogService>().getLogger('CacheManager');
  }

  /// Get the singleton instance
  static CacheManagerImpl get instance => _instance;

  /// Check if a URL is an AT Protocol blob URL
  bool _isAtProtocolBlobUrl(String url) {
    return url.startsWith('at://') && url.contains('/blob/');
  }

  /// Extract DID and CID from AT Protocol blob URL
  ({String did, String cid})? _parseAtProtocolBlobUrl(String url) {
    // Format: at://did:plc:xxx/blob/xxx
    final match = RegExp(r'^at://([^/]+)/blob/(.+)$').firstMatch(url);
    if (match != null) {
      return (did: match.group(1)!, cid: match.group(2)!);
    }
    return null;
  }

    /// Download blob from AT Protocol API
  Future<Uint8List> _downloadAtProtocolBlob(String did, String cid) async {
    try {
      final sprkRepository = GetIt.instance<SprkRepository>();
      final authRepository = sprkRepository.authRepository;

      if (authRepository.atproto == null) {
        throw Exception('AT Protocol client not initialized');
      }

      _logger.d('Downloading AT Protocol blob: did=$did, cid=$cid');

      final response = await authRepository.atproto!.get(
        NSID.parse('com.atproto.sync.getBlob'),
        parameters: {'did': did, 'cid': cid},
        headers: {'Accept': '*/*'},
      );

      if (response.status != HttpStatus.ok) {
        throw Exception('Failed to download blob: ${response.status}');
      }

      final bytes = response.data as Uint8List;
      _logger.d('Successfully downloaded AT Protocol blob: ${bytes.length} bytes');
      return bytes;
    } catch (e) {
      _logger.e('Error downloading AT Protocol blob: $e');
      rethrow;
    }
  }

  /// Get a cached file or download it if not available
  @override
  Future<File> getFile(String url) async {
    if (_isAtProtocolBlobUrl(url)) {
      return _getAtProtocolBlobFile(url);
    }

    final fileInfo = await cacheManager.getFileFromCache(url);
    if (fileInfo != null) {
      return fileInfo.file;
    }

    // File not in cache, download it
    final file = await cacheManager.getSingleFile(url);
    return file;
  }

  /// Get AT Protocol blob file from cache or download
  Future<File> _getAtProtocolBlobFile(String url) async {
    final fileInfo = await cacheManager.getFileFromCache(url);
    if (fileInfo != null) {
      return fileInfo.file;
    }

    // Parse the AT Protocol URL
    final parsed = _parseAtProtocolBlobUrl(url);
    if (parsed == null) {
      throw Exception('Invalid AT Protocol blob URL: $url');
    }

    // Download the blob
    final bytes = await _downloadAtProtocolBlob(parsed.did, parsed.cid);

    // Store in cache
    await cacheManager.putFile(url, bytes, maxAge: const Duration(days: 7));

    // Return the cached file
    final cachedFileInfo = await cacheManager.getFileFromCache(url);
    if (cachedFileInfo == null) {
      throw Exception('Failed to cache AT Protocol blob');
    }

    return cachedFileInfo.file;
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
