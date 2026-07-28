import 'dart:async';
import 'dart:convert';

import 'package:poptart_lex/com/atproto/identity/resolve_handle.dart'
    as identity_resolve_handle;
import 'package:poptart/poptart.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'package:spark/src/core/auth/data/repositories/identity_repository.dart';
import 'package:spark/src/core/storage/storage.dart';
import 'package:spark/src/core/utils/did_utils.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

/// Implementation of [IdentityRepository] with caching capabilities
class IdentityRepositoryImpl implements IdentityRepository {
  IdentityRepositoryImpl._(
    StorageManager storageManager, {
    LocalStorageInterface? preferences,
    SparkLogger? logger,
    DateTime Function()? now,
    http.Client? httpClient,
    Future<String> Function(String handle)? handleResolver,
  }) : _preferences = preferences ?? storageManager.preferences,
       _logger =
           logger ??
           GetIt.instance<LogService>().getLogger('IdentityRepository'),
       _now = now ?? DateTime.now,
       _didHttpClient = httpClient,
       _resolveHandleOverride = handleResolver;

  /// Creates a fully initialized repository after restoring persisted caches.
  static Future<IdentityRepositoryImpl> create(
    StorageManager storageManager, {
    LocalStorageInterface? preferences,
    SparkLogger? logger,
    DateTime Function()? now,
    http.Client? httpClient,
    Future<String> Function(String handle)? handleResolver,
  }) async {
    final repository = IdentityRepositoryImpl._(
      storageManager,
      preferences: preferences,
      logger: logger,
      now: now,
      httpClient: httpClient,
      handleResolver: handleResolver,
    );
    await repository._loadCache();
    return repository;
  }

  final Map<String, String> _didToHandleCache = {};
  final Map<String, String> _handleToDidCache = {};
  final Map<String, Map<String, dynamic>> _didDocCache = {};

  static const Duration _cacheExpiration = Duration(hours: 2);

  final LocalStorageInterface _preferences;
  final SparkLogger _logger;
  final DateTime Function() _now;
  final http.Client? _didHttpClient;
  final Future<String> Function(String handle)? _resolveHandleOverride;

  Future<void> _loadCache() async {
    try {
      final cacheTtl = await _preferences.getInt(StorageKeys.identityCacheTtl);
      if (cacheTtl != null && _now().millisecondsSinceEpoch > cacheTtl) {
        await clearCache();
        return;
      }

      final didToHandleJson = await _preferences.getString(
        StorageKeys.didToHandleCache,
      );
      final handleToDidJson = await _preferences.getString(
        StorageKeys.handleToDidCache,
      );
      final didDocJson = await _preferences.getString(StorageKeys.didDocCache);

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
    final data = json.decode(jsonData) as Map<String, dynamic>;
    _didToHandleCache.clear();

    data.forEach((key, value) {
      if (value is String) {
        _didToHandleCache[key] = value;
      }
    });
  }

  void _loadHandleToDidCache(String jsonData) {
    final data = json.decode(jsonData) as Map<String, dynamic>;
    _handleToDidCache.clear();

    data.forEach((key, value) {
      if (value is String) {
        _handleToDidCache[key] = value;
      }
    });
  }

  void _loadDidDocCache(String jsonData) {
    final data = json.decode(jsonData) as Map<String, dynamic>;
    _didDocCache.clear();

    data.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        _didDocCache[key] = value;
      }
    });
  }

  Future<void> _saveCache() async {
    try {
      await _preferences.setInt(
        StorageKeys.identityCacheTtl,
        _now().add(_cacheExpiration).millisecondsSinceEpoch,
      );

      await _preferences.setString(
        StorageKeys.didToHandleCache,
        json.encode(_didToHandleCache),
      );

      await _preferences.setString(
        StorageKeys.handleToDidCache,
        json.encode(_handleToDidCache),
      );

      await _preferences.setString(
        StorageKeys.didDocCache,
        json.encode(_didDocCache),
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
      await _preferences.remove(StorageKeys.didToHandleCache);
      await _preferences.remove(StorageKeys.handleToDidCache);
      await _preferences.remove(StorageKeys.didDocCache);
      await _preferences.remove(StorageKeys.identityCacheTtl);
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

    for (final aka in alsoKnownAs) {
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
    final url = DidUtils.buildDidDocumentUrl(did);
    final response = await (_didHttpClient?.get(url) ?? http.get(url));

    if (response.statusCode != 200) {
      _logger.e('Failed to fetch DID document: ${response.statusCode}');
      throw Exception('Failed to fetch DID document: ${response.statusCode}');
    }

    final didDoc = json.decode(response.body);
    _didDocCache[did] = didDoc as Map<String, dynamic>;
    await _saveCache();

    return didDoc;
  }

  @override
  Future<Map<String, dynamic>?> resolveHandleToDidDoc(String handle) async {
    var did = _handleToDidCache[handle];

    if (did == null) {
      did = await resolveHandleToDid(handle);
      if (did == null) {
        return null;
      }
    }

    return resolveDidToDidDoc(did);
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
    final override = _resolveHandleOverride;
    final String did;
    if (override != null) {
      did = await override(handle);
    } else {
      final atProto = PoptartClient.anonymous(service: 'public.api.bsky.app');
      final resolveResult = await atProto.call(
        identity_resolve_handle.comAtprotoIdentityResolveHandle,
        parameters: identity_resolve_handle.IdentityResolveHandleInput(
          handle: handle,
        ),
      );
      did = resolveResult.data.did;
    }

    _handleToDidCache[handle] = did;
    _didToHandleCache[did] = handle;
    await _saveCache();

    return did;
  }

  @override
  Future<Map<String, String?>> resolveDidsToHandles(List<String> dids) async {
    final results = <String, String?>{};
    final futures = <Future<String?>>[];

    for (final did in dids) {
      if (_didToHandleCache.containsKey(did)) {
        results[did] = _didToHandleCache[did];
        continue;
      }

      futures.add(
        resolveDidToHandle(did).then((handle) {
          results[did] = handle;
          return null;
        }),
      );
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    return results;
  }

  @override
  Future<Map<String, String?>> resolveHandlesToDids(
    List<String> handles,
  ) async {
    final results = <String, String?>{};
    final futures = <Future<String?>>[];

    for (final handle in handles) {
      if (_handleToDidCache.containsKey(handle)) {
        results[handle] = _handleToDidCache[handle];
        continue;
      }

      futures.add(
        resolveHandleToDid(handle).then((did) {
          results[handle] = did;
          return null;
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
