import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:atproto/core.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/features/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/storage/cache/cache_manager_interface.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/profile/data/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final AuthRepository _authRepository;
  final SprkRepository _sprkRepository;
  final CacheManagerInterface _cacheManager;
  final _logger = GetIt.instance<LogService>().getLogger('ProfileRepository');


  ProfileRepositoryImpl({
    required AuthRepository authRepository,
    required SprkRepository sprkRepository,
    required CacheManagerInterface cacheManager,
  })  : _authRepository = authRepository,
        _sprkRepository = sprkRepository,
        _cacheManager = cacheManager;


  @override
  Future<Profile?> getProfile(String did, {bool forceRefresh = false}) async {
    if (!_authRepository.isAuthenticated) return null;

    String? existingFollowUri = await _getExistingFollowUri(did);

    // Try Spark profile first
    try {
      final sprkProfile = await _getProfileFullSprk(did, forceRefresh: forceRefresh);
      if (sprkProfile != null) {
        // Convert to ProfileResponse and use that to create a Profile
        final profileResponse = ProfileResponse(
          did: sprkProfile['did'] as String,
          handle: sprkProfile['handle'] as String,
          displayName: sprkProfile['displayName'] as String?,
          description: sprkProfile['description'] as String?,
          avatar: sprkProfile['avatar'] as String?,
          banner: sprkProfile['banner'] as String?,
          followsYou: (sprkProfile['viewer'] as Map<String, dynamic>?)?.containsKey('followedBy') ?? false,
          youFollow: existingFollowUri != null,
          viewer: {
            'following': existingFollowUri
          },
        );
        
        return Profile(
          did: profileResponse.did,
          handle: profileResponse.handle,
          displayName: profileResponse.displayName,
          description: profileResponse.description,
          avatar: profileResponse.avatar,
          banner: profileResponse.banner,
          followersCount: sprkProfile['followersCount'] as int? ?? 0,
          followingCount: sprkProfile['followingCount'] as int? ?? 0,
          postsCount: sprkProfile['postsCount'] as int? ?? 0,
          isSprk: true,
          isFollowing: profileResponse.youFollow,
          followUri: existingFollowUri,
        );
      }
    } catch (e) {
      _logger.w('Error fetching Spark profile: $e');
      // Only continue to Bluesky if it's a 404-like error
      final errorMsg = e.toString().toLowerCase();
      if (!errorMsg.contains('404')) {
        throw Exception('Failed to fetch Spark profile: $e');
      }
    }

    // Try Bluesky profile if Spark fails with 404
    try {
      final bskyProfile = await _getProfileFullBsky(did, forceRefresh: forceRefresh);
      if (bskyProfile != null) {
        // Create a Profile directly from the ActorProfile
        final profile = Profile(
          did: bskyProfile.did,
          handle: bskyProfile.handle,
          displayName: bskyProfile.displayName,
          description: bskyProfile.description,
          avatar: bskyProfile.avatar,
          banner: null,
          followersCount: bskyProfile.followersCount,
          followingCount: bskyProfile.followsCount,
          postsCount: bskyProfile.postsCount,
          isSprk: false,
          isFollowing: existingFollowUri != null,
          followUri: existingFollowUri,
        );

        // Try to enhance with Spark data, but don't fail if these calls fail
        try {
          final sparkFollowers = await _sprkRepository.graph.getFollowers(did);
          final followersCount = profile.followersCount + sparkFollowers.followers.length;
          
          final sparkFollows = await _sprkRepository.graph.getFollows(did);
          final followingCount = profile.followingCount + sparkFollows.follows.length;
          
          return profile.copyWith(
            followersCount: followersCount,
            followingCount: followingCount,
          );
        } catch (e) {
          _logger.w('Error fetching Spark graph data: $e');
          return profile;
        }
      }
    } catch (e) {
      _logger.e('Error fetching Bluesky profile: $e');
      return null;
    }

    return null;
  }

  // Helper method to get existing follow URI
  Future<String?> _getExistingFollowUri(String did) async {
    try {
      final existingFollows = await _authRepository.atproto!.repo.listRecords(
        repo: _authRepository.session!.did,
        collection: NSID.parse('so.sprk.graph.follow'),
      );

      // Find the follow record for this DID if it exists
      for (final record in existingFollows.data.records) {
        if (record.value['subject'] == did) {
          return record.uri.toString();
        }
      }
    } catch (e) {
      _logger.w('Error checking existing follows: $e');
    }
    return null;
  }

  Future<bsky.ActorProfile?> _getProfileFullBsky(String did, {bool forceRefresh = false}) async {
    if (!_authRepository.isAuthenticated) return null;


    // First check cache if not forcing refresh
    if (!forceRefresh) {
      try {
        final cacheFile = await _cacheManager.getFile(did);
        if (await cacheFile.exists()) {
          final jsonString = await cacheFile.readAsString();
          final profileData = json.decode(jsonString);
          return bsky.ActorProfile.fromJson(profileData);
        }
      } catch (e) {
        _logger.w('Error reading from cache: $e');
        // Continue to fetch from network
      }
    }

    // Fetch from network
    try {
      final blueskyClient = bsky.Bluesky.fromSession(_authRepository.session!);
      final response = await blueskyClient.actor.getProfile(actor: did);

      // Cache the response
      final profileJson = response.data.toJson();
      final jsonString = json.encode(profileJson);
      await _cacheManager.putFile(did, Uint8List.fromList(utf8.encode(jsonString)));

      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<Map<String, dynamic>?> _getProfileFullSprk(String did, {bool forceRefresh = false}) async {
    if (!_authRepository.isAuthenticated) return null;


    // First check cache if not forcing refresh
    if (!forceRefresh) {
      try {
        final cacheFile = await _cacheManager.getFile(did);
        if (await cacheFile.exists()) {
          final jsonString = await cacheFile.readAsString();
          return json.decode(jsonString);
        }
      } catch (e) {
        _logger.w('Error reading from cache: $e');
        // Continue to fetch from network
      }
    }

    // Fetch from network
    try {
      final profileRes = await _sprkRepository.actor.getProfile(did);
      final profile = profileRes.toJson();

      // Ensure we have the viewer information
      if (!profile.containsKey('viewer')) {
        profile['viewer'] = {};
      }

      // Cache the response
      final jsonString = json.encode(profile);
      await _cacheManager.putFile(did, Uint8List.fromList(utf8.encode(jsonString)));

      return profile;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  @override
  Future<void> clearProfileCache(String did) async {
    await _cacheManager.removeFile(did);
  }

  @override
  Future<AuthorFeedResponse> getProfileVideosSprk(String did, {int limit = 50, String? cursor}) async {
    if (!_authRepository.isAuthenticated) {
      throw Exception('Not authenticated');
    }

    try {
      // Check for existing follow first
      String? existingFollowUri = await _getExistingFollowUri(did);

      // Get author feed with pagination support
      final response = await _sprkRepository.feed.getAuthorFeed(
        did,
        limit: limit,
        cursor: cursor,
      );
      
      // Add follow status to the response posts
      final feedWithFollowInfo = response.feed.map((post) {
        // Create a new post with updated viewer field
        return post.copyWith(
          viewer: {...post.viewer, 'following': existingFollowUri},
        );
      }).toList();
      
      return AuthorFeedResponse(
        feed: feedWithFollowInfo,
        cursor: response.cursor,
      );
    } catch (e) {
      throw Exception('Failed to fetch profile videos: $e');
    }
  }

  @override
  Future<AuthorFeedResponse> getProfileVideosBsky(String did, {int limit = 50, String? cursor}) async {
    if (!_authRepository.isAuthenticated) {
      throw Exception('Not authenticated');
    }

    try {
      // Check for existing follow first
      String? existingFollowUri = await _getExistingFollowUri(did);

      final blueskyClient = bsky.Bluesky.fromSession(_authRepository.session!);
      final response = await blueskyClient.feed.getAuthorFeed(
        actor: did, 
        filter: bsky.FeedFilter.postsWithVideo,
        limit: limit,
        cursor: cursor,
      );
      
      // Convert to our AuthorFeedResponse model
      final feed = response.data.feed.map((feedViewPost) {
        final bskyAuthor = feedViewPost.post.author;
        
        // Create our PostAuthor model from Bluesky author
        final postAuthor = PostAuthor(
          did: bskyAuthor.did,
          handle: bskyAuthor.handle,
          displayName: bskyAuthor.displayName,
          avatar: bskyAuthor.avatar,
          isFollowing: existingFollowUri != null,
        );
        
        // Create embedMap from Bluesky embed if it exists
        Map<String, dynamic>? embedMap;
        if (feedViewPost.post.embed != null) {
          embedMap = <String, dynamic>{
            'type': feedViewPost.post.embed.runtimeType.toString(),
            // Add basic embed info
            'data': {'uri': feedViewPost.post.uri}
          };
        }
        
        // Convert record to Map
        final recordMap = feedViewPost.post.record.toJson();
        
        // Create our Post model
        return Post(
          uri: feedViewPost.post.uri.toString(),
          cid: feedViewPost.post.cid,
          author: postAuthor,
          record: recordMap,
          indexedAt: feedViewPost.post.indexedAt,
          embed: embedMap,
          viewer: {'following': existingFollowUri},
        );
      }).toList();
      
      return AuthorFeedResponse(
        feed: feed,
        cursor: response.data.cursor,
      );
    } catch (e) {
      throw Exception('Failed to fetch profile videos: $e');
    }
  }

  @override
  Future<void> updateProfile({required String displayName, required String description, dynamic avatar}) async {
    if (!_authRepository.isAuthenticated) {
      throw Exception('Not authenticated');
    }
    
    final record = <String, dynamic>{
      '\$type': 'so.sprk.actor.profile',
      'displayName': displayName,
      'description': description,
      if (avatar != null) 'avatar': avatar,
    };
    
    final response = await _sprkRepository.repo.editRecord(
      uri: AtUri.parse('at://${_authRepository.session!.did}/so.sprk.actor.profile/self'),
      record: record,
    );
    
    if (response.value.isEmpty) {
      throw Exception('Failed to update Spark profile');
    }

    // Clear cache for the updated profile
    final String? currentUserDid = _authRepository.session?.did;
    if (currentUserDid != null) {
      await clearProfileCache(currentUserDid);
    }
  }

  @override
  Future<bool> isEarlySupporter(String did) async {
    _logger.d('Checking early supporter status for DID: $did');
    try {
      final response = await http.get(Uri.parse('https://spark-match.sparksplatforms.workers.dev/?did=$did'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool isSupporter = data['found'] == true;
        _logger.d('Early supporter status for $did: $isSupporter');
        return isSupporter;
      }
      _logger.w('Failed to check early supporter status for $did, status code: ${response.statusCode}');
      return false;
    } catch (e, s) {
      _logger.e('Error checking early supporter status for $did', error: e, stackTrace: s);
      return false;
    }
  }
} 