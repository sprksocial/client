import 'dart:async';
import 'dart:convert';

import 'package:atproto/atproto.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'package:sparksocial/src/features/auth/data/repositories/identity_repository.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';

/// Implementation of [IdentityRepository] with caching capabilities
class IdentityRepositoryImpl implements IdentityRepository {
  final Map<String, String> _didToHandleCache = {};
  final Map<String, String> _handleToDidCache = {};
  final Map<String, Map<String, dynamic>> _didDocCache = {};

  static const Duration _cacheExpiration = Duration(hours: 2);
  
  final StorageManager _storageManager;
  final _logger = GetIt.instance<LogService>().getLogger('IdentityRepository');

  /// Creates a new [IdentityRepositoryImpl] instance and loads the cache
  IdentityRepositoryImpl(this._storageManager) {
    _loadCache();
  }

  Future<void> _loadCache() async {
    try {
      final cacheTtl = await _storageManager.preferences.getInt(StorageKeys.identityCacheTtl);
      if (cacheTtl != null && DateTime.now().millisecondsSinceEpoch > cacheTtl) {
        await clearCache();
        return;
      }

      final didToHandleJson = await _storageManager.preferences.getString(StorageKeys.didToHandleCache);
      final handleToDidJson = await _storageManager.preferences.getString(StorageKeys.handleToDidCache);
      final didDocJson = await _storageManager.preferences.getString(StorageKeys.didDocCache);

      if (didToHandleJson != null) {
        _loadDidToHandleCache(didToHandleJson);
      }

      if (handleToDidJson != null) {
        _loadHandleToDidCache(handleToDidJson);
      }

      if (didDocJson != null) {
        _loadDidDocCache(didDocJson);
      }
    } catch (e) {
      _logger.e('Error loading identity cache', error: e);
      await clearCache();
    }
  }

  void _loadDidToHandleCache(String jsonData) {
    final Map<String, dynamic> data = json.decode(jsonData);
    _didToHandleCache.clear();

    data.forEach((key, value) {
      if (value is String) {
        _didToHandleCache[key] = value;
      }
    });
  }

  void _loadHandleToDidCache(String jsonData) {
    final Map<String, dynamic> data = json.decode(jsonData);
    _handleToDidCache.clear();

    data.forEach((key, value) {
      if (value is String) {
        _handleToDidCache[key] = value;
      }
    });
  }

  void _loadDidDocCache(String jsonData) {
    final Map<String, dynamic> data = json.decode(jsonData);
    _didDocCache.clear();

    data.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        _didDocCache[key] = value;
      }
    });
  }

  Future<void> _saveCache() async {
    try {
      await _storageManager.preferences.setInt(
        StorageKeys.identityCacheTtl, 
        DateTime.now().add(_cacheExpiration).millisecondsSinceEpoch
      );

      await _storageManager.preferences.setString(
        StorageKeys.didToHandleCache, 
        json.encode(_didToHandleCache)
      );
      
      await _storageManager.preferences.setString(
        StorageKeys.handleToDidCache, 
        json.encode(_handleToDidCache)
      );
      
      await _storageManager.preferences.setString(
        StorageKeys.didDocCache, 
        json.encode(_didDocCache)
      );
    } catch (e) {
      _logger.e('Error saving identity cache', error: e);
    }
  }

  @override
  Future<void> clearCache() async {
    _didToHandleCache.clear();
    _handleToDidCache.clear();
    _didDocCache.clear();

    try {
      await _storageManager.preferences.remove(StorageKeys.didToHandleCache);
      await _storageManager.preferences.remove(StorageKeys.handleToDidCache);
      await _storageManager.preferences.remove(StorageKeys.didDocCache);
      await _storageManager.preferences.remove(StorageKeys.identityCacheTtl);
    } catch (e) {
      _logger.e('Error clearing identity cache', error: e);
    }
  }

  @override
  Future<String?> resolveDidToHandle(String did) async {
    if (_didToHandleCache.containsKey(did)) {
      return _didToHandleCache[did];
    }

    try {
      return await _fetchAndCacheHandle(did);
    } catch (e) {
      _logger.e('Error resolving DID to handle', error: e);
      return null;
    }
  }

  Future<String?> _fetchAndCacheHandle(String did) async {
    final didDoc = await resolveDidToDidDoc(did);
    if (didDoc == null || !didDoc.containsKey('alsoKnownAs')) {
      _logger.w('Could not resolve handle for DID: $did');
      return null;
    }

    final alsoKnownAs = didDoc['alsoKnownAs'];
    if (alsoKnownAs is! List || alsoKnownAs.isEmpty) {
      _logger.w('Could not resolve handle for DID: $did');
      return null;
    }

    for (var aka in alsoKnownAs) {
      if (aka is String && aka.startsWith('at://')) {
        final handle = aka.replaceFirst('at://', '');

        _didToHandleCache[did] = handle;
        _handleToDidCache[handle] = did;
        await _saveCache();

        return handle;
      }
    }

    _logger.w('Could not resolve handle for DID: $did');
    return null;
  }

  @override
  Future<Map<String, dynamic>?> resolveDidToDidDoc(String did) async {
    if (_didDocCache.containsKey(did)) {
      return _didDocCache[did];
    }

    try {
      return await _fetchAndCacheDidDoc(did);
    } catch (e) {
      _logger.e('Error resolving DID document', error: e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchAndCacheDidDoc(String did) async {
    final url = Uri.parse('https://plc.directory/$did');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      _logger.w('Failed to resolve DID document. Status: ${response.statusCode}');
      return null;
    }

    final didDoc = json.decode(response.body);
    _didDocCache[did] = didDoc;
    await _saveCache();

    return didDoc;
  }

  @override
  Future<Map<String, dynamic>?> resolveHandleToDidDoc(String handle) async {
    String? did = _handleToDidCache[handle];

    if (did == null) {
      did = await resolveHandleToDid(handle);
      if (did == null) {
        return null;
      }
    }

    return await resolveDidToDidDoc(did);
  }

  @override
  Future<String?> resolveHandleToDid(String handle) async {
    if (_handleToDidCache.containsKey(handle)) {
      return _handleToDidCache[handle];
    }

    try {
      return await _fetchAndCacheDid(handle);
    } catch (e) {
      _logger.e('Error resolving handle to DID', error: e);
      return null;
    }
  }

  Future<String?> _fetchAndCacheDid(String handle) async {
    final atProto = ATProto.anonymous(service: 'public.api.bsky.app');

    final resolveResult = await atProto.identity.resolveHandle(handle: handle);
    final did = resolveResult.data.did;

    _handleToDidCache[handle] = did;
    _didToHandleCache[did] = handle;
    await _saveCache();

    return did;
  }

  @override
  Future<Map<String, String?>> resolveDidsToHandles(List<String> dids) async {
    final results = <String, String?>{};
    final futures = <Future>[];

    for (final did in dids) {
      if (_didToHandleCache.containsKey(did)) {
        results[did] = _didToHandleCache[did];
        continue;
      }

      futures.add(
        resolveDidToHandle(did).then((handle) {
          results[did] = handle;
        }),
      );
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    return results;
  }

  @override
  Future<Map<String, String?>> resolveHandlesToDids(List<String> handles) async {
    final results = <String, String?>{};
    final futures = <Future>[];

    for (final handle in handles) {
      if (_handleToDidCache.containsKey(handle)) {
        results[handle] = _handleToDidCache[handle];
        continue;
      }

      futures.add(
        resolveHandleToDid(handle).then((did) {
          results[handle] = did;
        }),
      );
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    return results;
  }

  @override
  void invalidateCache(String idOrHandle) {
    if (idOrHandle.startsWith('did:')) {
      _invalidateDid(idOrHandle);
      return;
    }

    _invalidateHandle(idOrHandle);
  }

  void _invalidateDid(String did) {
    if (!_didToHandleCache.containsKey(did)) {
      return;
    }

    final handle = _didToHandleCache[did];
    _didToHandleCache.remove(did);

    if (handle != null) {
      _handleToDidCache.remove(handle);
    }

    _didDocCache.remove(did);
    _saveCache();
  }

  void _invalidateHandle(String handle) {
    if (!_handleToDidCache.containsKey(handle)) {
      return;
    }

    final did = _handleToDidCache[handle];
    _handleToDidCache.remove(handle);

    if (did != null) {
      _didToHandleCache.remove(did);
      _didDocCache.remove(did);
    }

    _saveCache();
  }

  @override
  Future<bool> refreshDid(String did) async {
    invalidateCache(did);
    final handle = await resolveDidToHandle(did);
    final didDoc = await resolveDidToDidDoc(did);
    return handle != null && didDoc != null;
  }

  @override
  Future<bool> refreshHandle(String handle) async {
    invalidateCache(handle);
    final did = await resolveHandleToDid(handle);
    if (did == null) return false;

    final didDoc = await resolveDidToDidDoc(did);
    return didDoc != null;
  }
} 