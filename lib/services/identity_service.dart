import 'dart:async';
import 'dart:convert';

import 'package:atproto/atproto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CachedIdentityService extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Cache maps
  final Map<String, String> _didToHandleCache = {};
  final Map<String, String> _handleToDidCache = {};
  final Map<String, Map<String, dynamic>> _didDocCache = {};

  // Cache expiration time (24 hours)
  static const Duration _cacheExpiration = Duration(hours: 2);

  // Cache keys for persistent storage
  static const String _didToHandleCacheKey = 'did_to_handle_cache';
  static const String _handleToDidCacheKey = 'handle_to_did_cache';
  static const String _didDocCacheKey = 'did_doc_cache';
  static const String _cacheTtlKey = 'identity_cache_ttl';

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  CachedIdentityService() {
    _loadCache();
  }

  // Load cached data from SharedPreferences
  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if cache is expired
      final cacheTtl = prefs.getInt(_cacheTtlKey);
      if (cacheTtl != null && DateTime.now().millisecondsSinceEpoch > cacheTtl) {
        await _clearCache();
        return;
      }

      final didToHandleJson = prefs.getString(_didToHandleCacheKey);
      final handleToDidJson = prefs.getString(_handleToDidCacheKey);
      final didDocJson = prefs.getString(_didDocCacheKey);

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
      debugPrint('Error loading identity cache: $e');
      await _clearCache();
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

  // Save cache to SharedPreferences
  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Set expiration time (24 hours from now)
      await prefs.setInt(_cacheTtlKey, DateTime.now().add(_cacheExpiration).millisecondsSinceEpoch);

      // Save caches
      await prefs.setString(_didToHandleCacheKey, json.encode(_didToHandleCache));
      await prefs.setString(_handleToDidCacheKey, json.encode(_handleToDidCache));
      await prefs.setString(_didDocCacheKey, json.encode(_didDocCache));
    } catch (e) {
      debugPrint('Error saving identity cache: $e');
    }
  }

  // Clear all caches
  Future<void> _clearCache() async {
    _didToHandleCache.clear();
    _handleToDidCache.clear();
    _didDocCache.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_didToHandleCacheKey);
      await prefs.remove(_handleToDidCacheKey);
      await prefs.remove(_didDocCacheKey);
      await prefs.remove(_cacheTtlKey);
    } catch (e) {
      debugPrint('Error clearing identity cache: $e');
    }
  }

  /// Resolve a DID to a handle
  Future<String?> resolveDidToHandle(String did) async {
    // Check cache first
    if (_didToHandleCache.containsKey(did)) {
      return _didToHandleCache[did];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _fetchAndCacheHandle(did);
    } catch (e) {
      _error = 'Error resolving DID to handle: $e';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _fetchAndCacheHandle(String did) async {
    final didDoc = await resolveDidToDidDoc(did);
    if (didDoc == null || !didDoc.containsKey('alsoKnownAs')) {
      _error = 'Could not resolve handle for DID: $did';
      notifyListeners();
      return null;
    }

    final alsoKnownAs = didDoc['alsoKnownAs'];
    if (alsoKnownAs is! List || alsoKnownAs.isEmpty) {
      _error = 'Could not resolve handle for DID: $did';
      notifyListeners();
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

    _error = 'Could not resolve handle for DID: $did';
    notifyListeners();
    return null;
  }

  /// Resolve a DID to its DID document
  Future<Map<String, dynamic>?> resolveDidToDidDoc(String did) async {
    // Check cache first
    if (_didDocCache.containsKey(did)) {
      return _didDocCache[did];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _fetchAndCacheDidDoc(did);
    } catch (e) {
      _error = 'Error resolving DID document: $e';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> _fetchAndCacheDidDoc(String did) async {
    final url = Uri.parse('https://plc.directory/$did');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      _error = 'Failed to resolve DID document. Status: ${response.statusCode}';
      notifyListeners();
      return null;
    }

    final didDoc = json.decode(response.body);

    // Cache the result
    _didDocCache[did] = didDoc;
    await _saveCache();

    return didDoc;
  }

  /// Resolve a handle to a DID document
  Future<Map<String, dynamic>?> resolveHandleToDidDoc(String handle) async {
    // Check if we already know the DID for this handle
    String? did = _handleToDidCache[handle];

    // If not, resolve handle to DID first
    if (did == null) {
      did = await _resolveHandleToDid(handle);
      if (did == null) {
        return null;
      }
    }

    // Now that we have the DID, get the DID document
    return await resolveDidToDidDoc(did);
  }

  /// Resolve a handle to a DID (internal helper)
  Future<String?> _resolveHandleToDid(String handle) async {
    // Check cache first
    if (_handleToDidCache.containsKey(handle)) {
      return _handleToDidCache[handle];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _fetchAndCacheDid(handle);
    } catch (e) {
      _error = 'Error resolving handle to DID: $e';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _fetchAndCacheDid(String handle) async {
    final atProto = ATProto.anonymous(service: 'public.api.bsky.app');

    final resolveResult = await atProto.identity.resolveHandle(handle: handle);
    final did = resolveResult.data.did;

    // Cache the result
    _handleToDidCache[handle] = did;
    _didToHandleCache[did] = handle;
    await _saveCache();

    return did;
  }

  /// Resolve a handle to a DID (public method)
  Future<String?> resolveHandleToDid(String handle) async {
    return await _resolveHandleToDid(handle);
  }

  /// Resolve multiple DIDs to handles
  Future<Map<String, String?>> resolveDidsToHandles(List<String> dids) async {
    final results = <String, String?>{};
    final futures = <Future>[];

    for (final did in dids) {
      // Check cache first
      if (_didToHandleCache.containsKey(did)) {
        results[did] = _didToHandleCache[did];
        continue;
      }

      // Resolve asynchronously
      futures.add(
        resolveDidToHandle(did).then((handle) {
          results[did] = handle;
        }),
      );
    }

    // Wait for all remaining resolutions to complete
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    return results;
  }

  /// Resolve multiple handles to DIDs
  Future<Map<String, String?>> resolveHandlesToDids(List<String> handles) async {
    final results = <String, String?>{};
    final futures = <Future>[];

    for (final handle in handles) {
      // Check cache first
      if (_handleToDidCache.containsKey(handle)) {
        results[handle] = _handleToDidCache[handle];
        continue;
      }

      // Resolve asynchronously
      futures.add(
        _resolveHandleToDid(handle).then((did) {
          results[handle] = did;
        }),
      );
    }

    // Wait for all remaining resolutions to complete
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    return results;
  }

  /// Invalidate cache for specific DID or handle
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
    notifyListeners();
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
    notifyListeners();
  }

  /// Force refresh all cached data for a DID
  Future<bool> refreshDid(String did) async {
    invalidateCache(did);
    final handle = await resolveDidToHandle(did);
    final didDoc = await resolveDidToDidDoc(did);
    return handle != null && didDoc != null;
  }

  /// Force refresh all cached data for a handle
  Future<bool> refreshHandle(String handle) async {
    invalidateCache(handle);
    final did = await resolveHandleToDid(handle);
    if (did == null) return false;

    final didDoc = await resolveDidToDidDoc(did);
    return didDoc != null;
  }
}
