import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:sparksocial/src/core/network/auth/models/identity_info.dart';
import 'package:sparksocial/src/core/network/auth/repositories/identity_repository.dart';
import 'package:sparksocial/src/core/di/service_locator.dart';

part 'identity_providers.g.dart';

/// Provider for the identity repository
@riverpod
IdentityRepository identityRepository(Ref ref) {
  return sl<IdentityRepository>();
}

/// Provider for resolving a DID to a handle
@riverpod
Future<String?> didToHandle(Ref ref, String did) async {
  final repository = ref.watch(identityRepositoryProvider);
  return repository.resolveDidToHandle(did);
}

/// Provider for resolving a handle to a DID
@riverpod
Future<String?> handleToDid(Ref ref, String handle) async {
  final repository = ref.watch(identityRepositoryProvider);
  return repository.resolveHandleToDid(handle);
}

/// Provider for resolving a DID to its DID document
@riverpod
Future<Map<String, dynamic>?> didToDoc(Ref ref, String did) async {
  final repository = ref.watch(identityRepositoryProvider);
  return repository.resolveDidToDidDoc(did);
}

/// Provider for resolving a handle to its DID document
@riverpod
Future<Map<String, dynamic>?> handleToDoc(Ref ref, String handle) async {
  final repository = ref.watch(identityRepositoryProvider);
  return repository.resolveHandleToDidDoc(handle);
}

/// Provider to get a complete IdentityInfo object from a DID
@riverpod
Future<IdentityState> identityInfoFromDid(Ref ref, String did) async {
  final repository = ref.watch(identityRepositoryProvider);
  
  try {
    final handle = await repository.resolveDidToHandle(did);
    if (handle == null) {
      return const IdentityState.error('Failed to resolve handle for DID');
    }
    
    final didDoc = await repository.resolveDidToDidDoc(did);
    
    return IdentityState.success(
      IdentityInfo(
        did: did,
        handle: handle,
        didDocument: didDoc,
      ),
    );
  } catch (e) {
    return IdentityState.error(e.toString());
  }
}

/// Provider to get a complete IdentityInfo object from a handle
@riverpod
Future<IdentityState> identityInfoFromHandle(Ref ref, String handle) async {
  final repository = ref.watch(identityRepositoryProvider);
  
  try {
    final did = await repository.resolveHandleToDid(handle);
    if (did == null) {
      return const IdentityState.error('Failed to resolve DID for handle');
    }
    
    final didDoc = await repository.resolveDidToDidDoc(did);
    
    return IdentityState.success(
      IdentityInfo(
        did: did,
        handle: handle,
        didDocument: didDoc,
      ),
    );
  } catch (e) {
    return IdentityState.error(e.toString());
  }
} 