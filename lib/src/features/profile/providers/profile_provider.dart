import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart' as actor_models;
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/features/profile/data/repositories/profile_repository.dart';
import 'package:get_it/get_it.dart';

part 'profile_provider.g.dart';

/// Profile provider for getting and managing profiles
/// 
/// Usage:
/// ```dart
/// final profileAsync = ref.watch(profileProvider('did:plc:1234'));
/// ```
@riverpod
class Profile extends _$Profile {
  late final ProfileRepository _profileRepository;
  late final String _did;

  @override
  FutureOr<actor_models.Profile?> build(String did) {
    _profileRepository = GetIt.instance<ProfileRepository>();
    _did = did;
    return _fetchProfile(did);
  }

  /// Fetch a profile for the given DID
  Future<actor_models.Profile?> _fetchProfile(String did, {bool forceRefresh = false}) async {
    try {
      return await _profileRepository.getProfile(did, forceRefresh: forceRefresh);
    } catch (e, stackTrace) {
      debugPrint('Error fetching profile: $e\n$stackTrace');
      return null;
    }
  }

  /// Refresh the profile
  Future<void> refreshProfile() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchProfile(_did, forceRefresh: true));
  }

  /// Get profile videos from Spark
  /// 
  /// [limit] Maximum number of items to return (default: 50)
  /// [cursor] Pagination cursor for the next page
  Future<AuthorFeedResponse?> getProfileVideosSprk({int limit = 50, String? cursor}) async {
    try {
      return await _profileRepository.getProfileVideosSprk(
        _did,
        limit: limit,
        cursor: cursor,
      );
    } catch (e) {
      debugPrint('Error fetching Spark videos: $e');
      return null;
    }
  }

  /// Get profile videos from Bluesky
  /// 
  /// [limit] Maximum number of items to return (default: 50)
  /// [cursor] Pagination cursor for the next page
  Future<AuthorFeedResponse?> getProfileVideosBsky({int limit = 50, String? cursor}) async {
    try {
      return await _profileRepository.getProfileVideosBsky(
        _did,
        limit: limit,
        cursor: cursor,
      );
    } catch (e) {
      debugPrint('Error fetching Bluesky videos: $e');
      return null;
    }
  }

  /// Update the profile
  Future<void> updateProfile({
    required String displayName, 
    required String description, 
    dynamic avatar,
  }) async {
    try {
      await _profileRepository.updateProfile(
        displayName: displayName, 
        description: description, 
        avatar: avatar,
      );
      refreshProfile();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Clear the profile cache
  Future<void> clearCache() async {
    await _profileRepository.clearProfileCache(_did);
    refreshProfile();
  }
} 