/// Repository interface for identity resolution operations
abstract class IdentityRepository {
  /// Resolves a DID to a handle
  Future<String?> resolveDidToHandle(String did);

  /// Resolves a handle to a DID
  Future<String?> resolveHandleToDid(String handle);

  /// Resolves a DID to its DID document
  Future<Map<String, dynamic>?> resolveDidToDidDoc(String did);

  /// Resolves a handle to its DID document
  Future<Map<String, dynamic>?> resolveHandleToDidDoc(String handle);

  /// Bulk resolves multiple DIDs to handles
  Future<Map<String, String?>> resolveDidsToHandles(List<String> dids);

  /// Bulk resolves multiple handles to DIDs
  Future<Map<String, String?>> resolveHandlesToDids(List<String> handles);

  /// Invalidates cache for a specific DID or handle
  void invalidateCache(String idOrHandle);

  /// Refreshes DID information by clearing cache and fetching again
  Future<bool> refreshDid(String did);

  /// Refreshes handle information by clearing cache and fetching again
  Future<bool> refreshHandle(String handle);

  /// Clears all cached identity data
  Future<void> clearCache();
}
