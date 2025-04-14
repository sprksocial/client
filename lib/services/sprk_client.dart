import 'dart:convert';

import 'package:atproto/core.dart';
import 'package:sparksocial/config/app_config.dart';

import 'auth_service.dart';

/// Client for interacting with Spark API endpoints
class SprkClient {
  final AuthService _authService;
  final String _sprkDid;

  SprkClient(this._authService) : _sprkDid = _getSprkDid();

  static String _getSprkDid() {
    final sprkAppView = Uri.parse(AppConfig.appViewUrl);
    return "did:web:${sprkAppView.host}#sprk_appview";
  }

  /// Execute API request with token expiration handling
  Future<dynamic> _executeWithRetry(Future<dynamic> Function() apiCall) async {
    try {
      print("Executing call");
      return await apiCall();
    } catch (e) {
      // Check if the error is a token expired error
      final errorStr = e.toString().toLowerCase();
      print("Captured error: $errorStr");
      if (errorStr.contains('400') && (errorStr.contains('expired'))) {
        print("Refreshing token");
        // Try to refresh the token
        final refreshed = await _authService.refreshToken();
        print("Refreshed token: $refreshed");
        if (!refreshed) {
          print("Failed to refresh expired token");
          throw Exception('Failed to refresh expired token');
        }
        print("Retrying call with new token");

        // Retry the call with the new token
        return await apiCall();
      }

      // Rethrow other errors
      rethrow;
    }
  }

  /// Feed namespace for Spark API
  FeedAPI get feed => FeedAPI(this);

  /// Actor namespace for Spark API
  ActorAPI get actor => ActorAPI(this);

  /// Graph namespace for Spark API
  GraphAPI get graph => GraphAPI(this);
}

/// Feed-related API endpoints
class FeedAPI {
  final SprkClient _client;

  FeedAPI(this._client);

  /// Get a post thread by URI
  ///
  /// [postUri] The URI of the post to get the thread for
  Future<dynamic> getPostThread(String postUri) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      return await atproto.get(
        NSID.parse('so.sprk.feed.getPostThread'),
        parameters: {'uri': postUri},
        headers: {'atproto-proxy': _client._sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
    });
  }

  /// Get a feed skeleton
  ///
  /// [feed] The feed to get the skeleton for
  /// [limit] The number of items to return
  Future<dynamic> getFeedSkeleton(String feed, {int limit = 30}) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      return await atproto.get(
        NSID.parse('so.sprk.feed.getFeedSkeleton'),
        parameters: {'feed': feed, 'limit': limit},
        service: 'feeds.sprk.so',
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
    });
  }

  /// Get posts by URIs
  ///
  /// [uris] List of post URIs to fetch
  Future<dynamic> getPosts(List<String> uris) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      return await atproto.get(
        NSID.parse('so.sprk.feed.getPosts'),
        parameters: {'uris': uris},
        headers: {'atproto-proxy': _client._sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
    });
  }

  /// Get an author's feed
  ///
  /// [actor] The DID of the author
  Future<dynamic> getAuthorFeed(String actor) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      return await atproto.get(
        NSID.parse('so.sprk.feed.getAuthorFeed'),
        parameters: {'actor': actor},
        headers: {'atproto-proxy': _client._sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
    });
  }
}

/// Actor-related API endpoints
class ActorAPI {
  final SprkClient _client;

  ActorAPI(this._client);

  /// Get a profile by DID
  ///
  /// [did] The DID of the profile to get
  Future<dynamic> getProfile(String did) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      return await atproto.get(
        NSID.parse('so.sprk.actor.getProfile'),
        parameters: {'actor': did},
        headers: {'atproto-proxy': _client._sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
    });
  }
}

/// Graph-related API endpoints
class GraphAPI {
  final SprkClient _client;

  GraphAPI(this._client);

  /// Get followers for a DID
  ///
  /// [did] The DID to get followers for
  Future<dynamic> getFollowers(String did) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      return await atproto.get(
        NSID.parse('so.sprk.graph.getFollowers'),
        parameters: {'actor': did},
        headers: {'atproto-proxy': _client._sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
    });
  }

  /// Get follows for a DID
  ///
  /// [did] The DID to get follows for
  Future<dynamic> getFollows(String did) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      return await atproto.get(
        NSID.parse('so.sprk.graph.getFollows'),
        parameters: {'actor': did},
        headers: {'atproto-proxy': _client._sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
    });
  }
}
