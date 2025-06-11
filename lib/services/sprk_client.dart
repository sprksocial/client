import 'dart:convert';
import 'dart:typed_data';

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
      return await apiCall();
    } catch (e) {
      // Check if the error is a token expired error
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('400') && (errorStr.contains('expired'))) {
        // Try to refresh the token
        final refreshed = await _authService.refreshToken();
        if (!refreshed) {
          throw Exception('Failed to refresh expired token');
        }

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

  /// Repository namespace for Spark API
  RepoAPI get repo => RepoAPI(this);

  /// Chat namespace for Spark API
  ChatAPI get chat => ChatAPI(this);
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

  /// Search actors by query string.
  ///
  /// [query] The search query.
  Future<dynamic> searchActors(String query) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      return await atproto.get(
        NSID.parse('so.sprk.actor.searchActors'),
        parameters: {'q': query},
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

/// Repository-related API endpoints
class RepoAPI {
  final SprkClient _client;

  RepoAPI(this._client);

  /// Get a record from the repository
  Future<dynamic> getRecord({required AtUri uri}) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }
      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }
      return await atproto.repo.getRecord(uri: uri);
    });
  }

  /// Edit a record in the repository
  ///
  /// [uri] The URI of the record to edit
  /// [record] The record data to edit
  Future<dynamic> editRecord({required AtUri uri, required Map<String, dynamic> record}) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }
      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }
      return await atproto.repo.putRecord(uri: uri, record: record);
    });
  }

  /// Create a record in the repository
  ///
  /// [collection] The NSID of the collection to create the record in
  /// [record] The record data to create
  Future<dynamic> createRecord({required NSID collection, required Map<String, dynamic> record, String? rkey}) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      return await atproto.repo.createRecord(collection: collection, record: record, rkey: rkey);
    });
  }

  /// Delete a record from the repository
  ///
  /// [uri] The URI of the record to delete
  Future<dynamic> deleteRecord({required AtUri uri}) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      return await atproto.repo.deleteRecord(uri: uri);
    });
  }

  /// Upload a blob to the repository
  ///
  /// [data] The blob data to upload
  Future<dynamic> uploadBlob(Uint8List data) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      return await atproto.repo.uploadBlob(data);
    });
  }

  /// List records in a collection
  ///
  /// [repo] The DID of the repo to list records from
  /// [collection] The NSID of the collection to list records from
  Future<dynamic> listRecords({required String repo, required NSID collection, String? cursor, int? limit, bool? reverse}) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      return await atproto.repo.listRecords(repo: repo, collection: collection, cursor: cursor, limit: limit, reverse: reverse);
    });
  }
}

/// Chat-related API endpoints
class ChatAPI {
  final SprkClient _client;

  ChatAPI(this._client);

  /// Send a message to a conversation
  Future<dynamic> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'text',
  }) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      final messageRecord = {
        '\$type': 'so.sprk.chat.message',
        'conversationId': conversationId,
        'content': content,
        'type': messageType,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      };

      return await atproto.repo.createRecord(
        collection: NSID.parse('so.sprk.chat.message'),
        record: messageRecord,
      );
    });
  }

  /// Get messages for a conversation
  Future<dynamic> getMessages(String conversationId) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      return await atproto.get(
        NSID.parse('so.sprk.chat.getMessages'),
        parameters: {'conversationId': conversationId},
        headers: {'atproto-proxy': _client._sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
    });
  }

  /// Get conversations for the current user
  Future<dynamic> getConversations() async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      return await atproto.get(
        NSID.parse('so.sprk.chat.getConversations'),
        headers: {'atproto-proxy': _client._sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
    });
  }

  /// Mark a conversation as read
  Future<dynamic> markAsRead(String conversationId) async {
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      final readRecord = {
        '\$type': 'so.sprk.chat.read',
        'conversationId': conversationId,
        'readAt': DateTime.now().toUtc().toIso8601String(),
      };

      return await atproto.repo.createRecord(
        collection: NSID.parse('so.sprk.chat.read'),
        record: readRecord,
      );
    });
  }
}
