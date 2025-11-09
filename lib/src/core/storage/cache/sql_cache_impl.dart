import 'dart:async';
import 'dart:convert';

import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:path/path.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sqflite/sqflite.dart';

// --- Post Table ---
const String _tablePosts = 'cached_posts';
const String _columnUri = 'uri'; // TEXT PRIMARY KEY (post.uri.toString())
const String _columnString = 'cid'; // TEXT (post.cid.toString())
const String _columnAuthor = 'author'; // TEXT (JSON string of ProfileViewBasic)
const String _columnRecord = 'record'; // TEXT (JSON string of PostRecord)
const String _columnIsRepost = 'isRepost'; // INTEGER (0 or 1)
const String _columnIndexedAt = 'indexedAt'; // TEXT (ISO8601 string)
const String _columnLikeCount = 'likeCount'; // INTEGER
const String _columnReplyCount = 'replyCount'; // INTEGER
const String _columnRepostCount = 'repostCount'; // INTEGER
const String _columnQuoteCount = 'quoteCount'; // INTEGER
const String _columnLabels = 'labels'; // TEXT (JSON string of List<Label>)
const String _columnViewer = 'viewer'; // TEXT (JSON string of Viewer)
const String _columnMedia = 'media'; // TEXT (JSON string of MediaView)
const String _columnLastAccessed = 'lastAccessed'; // INTEGER (timestamp for LRU)

// --- Feed Definitions ---
const String _tableFeeds = 'feeds';
const String _columnFeedIdentifier = 'feed_identifier'; // TEXT PRIMARY KEY
const String _columnFeedName = 'feed_name'; // TEXT
const String _columnFeedType = 'feed_type'; // TEXT ('uri' or 'hardCoded')

// --- Feed-Post Associations Table ---
const String _tableFeedPostAssociations = 'feed_post_associations';
const String _columnAssociationId = 'association_id'; // INTEGER PRIMARY KEY AUTOINCREMENT
const String _columnFeedIdentifierFK = 'feed_identifier_fk'; // TEXT, Foreign Key to feeds table
const String _columnPostUriFK = 'post_uri_fk'; // TEXT, Foreign Key to cached_posts table
const String _columnAssociationOrder = 'association_order'; // INTEGER, for ordering posts within a feed

class SQLCacheImpl implements SQLCacheInterface {
  SQLCacheImpl();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'sparksocial_sql_cache.db');
    final db = await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // Run cleanup in background to avoid blocking startup
    // Only do quick cleanup (null checks), full validation happens lazily
    unawaited(_cleanupCorruptedPostsInternal(db, quickOnly: true));

    return db;
  }

  /// Internal cleanup method that accepts a database instance
  /// [quickOnly] if true, only does fast null checks without deserialization
  Future<int> _cleanupCorruptedPostsInternal(Database db, {bool quickOnly = false}) async {
    var deletedCount = 0;

    try {
      // Find all posts with null, empty, or 'null' record field (fast check)
      final nullRecordPosts = await db.query(
        _tablePosts,
        columns: [_columnUri],
        where: '$_columnRecord IS NULL OR $_columnRecord = ? OR $_columnRecord = ? OR TRIM($_columnRecord) = ?',
        whereArgs: ['null', '', ''],
      );

      if (nullRecordPosts.isNotEmpty) {
        final urisToDelete = nullRecordPosts.map((map) => map[_columnUri] as String?).whereType<String>().toList();
        if (urisToDelete.isNotEmpty) {
          final placeholders = List.generate(urisToDelete.length, (index) => '?').join(',');
          deletedCount = await db.delete(_tablePosts, where: '$_columnUri IN ($placeholders)', whereArgs: urisToDelete);
        }
      }

      // Full validation is expensive - only do it if not in quick mode
      // and limit to a reasonable batch size to avoid blocking
      if (!quickOnly) {
        // Only check recently accessed posts (most likely to be used)
        // Limit to 1000 posts to avoid long delays
        const maxPostsToCheck = 1000;
        final postsToCheck = await db.query(
          _tablePosts,
          columns: [_columnUri, _columnRecord],
          orderBy: '$_columnLastAccessed DESC',
          limit: maxPostsToCheck,
        );

        if (postsToCheck.isEmpty) return deletedCount;

        final corruptedUris = <String>[];
        const batchSize = 50; // Process in batches to avoid memory issues

        for (var i = 0; i < postsToCheck.length; i += batchSize) {
          final batch = postsToCheck.skip(i).take(batchSize);

          for (final post in batch) {
            final uri = post[_columnUri] as String?;
            if (uri == null) continue;

            final recordJson = post[_columnRecord] as String?;
            if (recordJson == null || recordJson.isEmpty || recordJson == 'null') {
              continue; // Already handled by null check above
            }

            try {
              final decoded = jsonDecode(recordJson);
              if (decoded == null || decoded is! Map<String, dynamic>) {
                corruptedUris.add(uri);
                continue;
              }
              // Try to deserialize to catch nested null issues
              PostRecord.fromJson(decoded);
            } catch (e) {
              // Invalid JSON or deserialization failed
              corruptedUris.add(uri);
            }
          }

          // Delete corrupted posts in batches to avoid large transactions
          if (corruptedUris.length >= batchSize || i + batchSize >= postsToCheck.length) {
            if (corruptedUris.isNotEmpty) {
              final placeholders = List.generate(corruptedUris.length, (index) => '?').join(',');
              deletedCount += await db.delete(
                _tablePosts,
                where: '$_columnUri IN ($placeholders)',
                whereArgs: corruptedUris,
              );
              corruptedUris.clear();
            }
          }
        }
      }
    } catch (e) {
      // Silently handle errors during cleanup
    }

    return deletedCount;
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    // Posts Table
    batch.execute('''
      CREATE TABLE $_tablePosts (
        $_columnUri TEXT PRIMARY KEY,
        $_columnString TEXT NOT NULL,
        $_columnAuthor TEXT NOT NULL,
        $_columnRecord TEXT NOT NULL,
        $_columnIsRepost INTEGER NOT NULL,
        $_columnIndexedAt TEXT NOT NULL,
        $_columnLikeCount INTEGER,
        $_columnReplyCount INTEGER,
        $_columnRepostCount INTEGER,
        $_columnQuoteCount INTEGER,
        $_columnLabels TEXT,
        $_columnViewer TEXT,
        $_columnMedia TEXT,
        $_columnLastAccessed INTEGER NOT NULL
      )
    ''');
    // Feeds Table
    batch.execute('''
      CREATE TABLE $_tableFeeds (
        $_columnFeedIdentifier TEXT PRIMARY KEY,
        $_columnFeedName TEXT NOT NULL,
        $_columnFeedType TEXT NOT NULL
      )
    ''');
    // Feed-Post Associations Table
    batch.execute('''
      CREATE TABLE $_tableFeedPostAssociations (
        $_columnAssociationId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnFeedIdentifierFK TEXT NOT NULL,
        $_columnPostUriFK TEXT NOT NULL,
        $_columnAssociationOrder INTEGER NOT NULL,
        FOREIGN KEY ($_columnFeedIdentifierFK) REFERENCES $_tableFeeds($_columnFeedIdentifier) ON DELETE CASCADE,
        FOREIGN KEY ($_columnPostUriFK) REFERENCES $_tablePosts($_columnUri) ON DELETE CASCADE,
        UNIQUE ($_columnFeedIdentifierFK, $_columnPostUriFK),
        UNIQUE ($_columnFeedIdentifierFK, $_columnAssociationOrder)
      )
    ''');
    // Index for faster lookups of posts for a feed
    batch.execute('''
      CREATE INDEX idx_feed_posts ON $_tableFeedPostAssociations ($_columnFeedIdentifierFK, $_columnAssociationOrder)
    ''');
    // Index for faster LRU eviction and ordering queries
    batch.execute('''
      CREATE INDEX idx_last_accessed ON $_tablePosts ($_columnLastAccessed)
    ''');
    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $_tablePosts ADD COLUMN $_columnViewer TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE $_tablePosts ADD COLUMN $_columnMedia TEXT');
    }
    // Add index for performance (idempotent - will fail silently if exists)
    try {
      await db.execute('CREATE INDEX IF NOT EXISTS idx_last_accessed ON $_tablePosts ($_columnLastAccessed)');
    } catch (e) {
      // Ignore any database errors during index creation
    }
  }

  // --- CRUD Operations ---

  /// Caches a single PostView. If it already exists, it's updated.
  @override
  Future<void> cachePost(PostView post) async {
    final db = await database;
    final map = _postViewToMap(post);
    map[_columnLastAccessed] = DateTime.now().millisecondsSinceEpoch;
    await db.insert(_tablePosts, map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Caches a list of PostViews in a batch.
  @override
  Future<void> cachePosts(List<PostView> posts) async {
    if (posts.isEmpty) return;
    final db = await database;
    final batch = db.batch();
    var successCount = 0;

    for (final post in posts) {
      try {
        final map = _postViewToMap(post);
        map[_columnLastAccessed] = DateTime.now().millisecondsSinceEpoch;
        batch.insert(_tablePosts, map, conflictAlgorithm: ConflictAlgorithm.replace);
        successCount++;
      } catch (e) {
        // Skip posts that fail serialization
      }
    }

    if (successCount > 0) {
      await batch.commit(noResult: true);
    }
  }

  /// Converts a PostView to a Map suitable for SQLite storage.
  /// Complex nested objects are serialized as JSON strings.
  /// Sadly, we cannot use `toJson` directly because the nested objects don't become strings.
  Map<String, dynamic> _postViewToMap(PostView post) {
    final recordJson = jsonEncode(post.record.toJson());
    if (recordJson == 'null' || recordJson.isEmpty) {
      throw Exception('Post has null/empty record: ${post.uri}');
    }

    return {
      _columnUri: post.uri.toString(),
      _columnString: post.cid,
      _columnAuthor: jsonEncode(post.author.toJson()),
      _columnRecord: recordJson,
      _columnIsRepost: post.isRepost ? 1 : 0,
      _columnIndexedAt: post.indexedAt.toIso8601String(),
      _columnLikeCount: post.likeCount,
      _columnReplyCount: post.replyCount,
      _columnRepostCount: post.repostCount,
      _columnQuoteCount: post.quoteCount,
      _columnLabels: post.labels != null ? jsonEncode(post.labels!.map((e) => e.toJson()).toList()) : null,
      _columnViewer: post.viewer != null ? jsonEncode(post.viewer!.toJson()) : null,
      _columnMedia: post.media != null ? jsonEncode(post.media!.toJson()) : null,
    };
  }

  /// Retrieves a PostView by its URI string.
  /// Returns null if not found.
  @override
  Future<PostView> getPost(String uriString) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tablePosts, where: '$_columnUri = ?', whereArgs: [uriString]);

    if (maps.isNotEmpty) {
      try {
        return _mapToPostView(maps.first);
      } catch (e) {
        // If the post is corrupted, delete it and re-throw the original exception
        // so calling code can handle it appropriately (e.g., fall back to network)
        await db.delete(_tablePosts, where: '$_columnUri = ?', whereArgs: [uriString]);

        rethrow;
      }
    }

    throw Exception('Post not found in cache');
  }

  /// Retrieves multiple PostViews by a list of URI strings.
  @override
  Future<List<PostView>> getPostsByUris(List<AtUri> uris) async {
    if (uris.isEmpty) return [];
    final db = await database;
    final placeholders = List.generate(uris.length, (index) => '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      _tablePosts,
      where: '$_columnUri IN ($placeholders)',
      whereArgs: uris.map((uri) => uri.toString()).toList(),
    );

    final posts = <PostView>[];
    for (final map in maps) {
      try {
        posts.add(_mapToPostView(map));
      } catch (e) {
        // Skip corrupted posts
      }
    }
    return posts;
  }

  /// Given a list of AtUris, returns a sub-list containing only those URIs
  /// that are present in the `_tablePosts`. Does not update `lastAccessed`.
  @override
  Future<List<AtUri>> getExistingPostUris(List<AtUri> urisToCheck) async {
    if (urisToCheck.isEmpty) return [];
    final db = await database;
    final placeholders = List.generate(urisToCheck.length, (index) => '?').join(',');
    final uriStringsToCheck = urisToCheck.map((uri) => uri.toString()).toList();

    final List<Map<String, dynamic>> maps = await db.query(
      _tablePosts,
      columns: [_columnUri], // Only need the URI column
      where: '$_columnUri IN ($placeholders)',
      whereArgs: uriStringsToCheck,
    );

    return maps.map((map) => AtUri.parse(map[_columnUri] as String)).toList();
  }

  /// Gets posts ordered by last access time (most recently accessed first).
  @override
  Future<List<PostView>> getPostsOrderedByLastAccessed({int limit = 20, int offset = 0}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tablePosts,
      orderBy: '$_columnLastAccessed DESC',
      limit: limit,
      offset: offset,
    );
    final posts = <PostView>[];
    for (final map in maps) {
      try {
        posts.add(_mapToPostView(map));
      } catch (e) {
        // Skip corrupted posts
      }
    }
    return posts;
  }

  /// Converts a Map from SQLite back to a PostView.
  /// JSON strings are deserialized back to complex objects.
  PostView _mapToPostView(Map<String, dynamic> map) {
    final recordJson = map[_columnRecord] as String?;

    if (recordJson == null || recordJson.isEmpty || recordJson == 'null') {
      throw Exception('Post has null or invalid record in cache: ${map[_columnUri]}');
    }

    // Decode and validate record JSON
    final recordDecoded = jsonDecode(recordJson);
    if (recordDecoded == null || recordDecoded is! Map<String, dynamic>) {
      throw Exception('Post record is not a valid Map in cache: ${map[_columnUri]}');
    }

    // Decode and validate author JSON
    final authorJson = map[_columnAuthor] as String?;
    if (authorJson == null || authorJson.isEmpty || authorJson == 'null') {
      throw Exception('Post has null or invalid author in cache: ${map[_columnUri]}');
    }
    final authorDecoded = jsonDecode(authorJson);
    if (authorDecoded == null || authorDecoded is! Map<String, dynamic>) {
      throw Exception('Post author is not a valid Map in cache: ${map[_columnUri]}');
    }

    // Try to deserialize the record, catching type cast errors from nested null values
    PostRecord postRecord;
    try {
      postRecord = PostRecord.fromJson(recordDecoded);
    } catch (e) {
      throw Exception(
        'Post record has invalid nested structure in cache (likely null required fields): ${map[_columnUri]}. Error: $e',
      );
    }

    return PostView(
      uri: AtUri.parse(map[_columnUri] as String),
      cid: map[_columnString] as String,
      author: ProfileViewBasic.fromJson(authorDecoded),
      record: postRecord,
      isRepost: (map[_columnIsRepost] as int) == 1,
      indexedAt: DateTime.parse(map[_columnIndexedAt] as String),
      likeCount: map[_columnLikeCount] as int?,
      replyCount: map[_columnReplyCount] as int?,
      repostCount: map[_columnRepostCount] as int?,
      quoteCount: map[_columnQuoteCount] as int?,
      labels: map[_columnLabels] != null && map[_columnLabels] != 'null'
          ? () {
              final labelsDecoded = jsonDecode(map[_columnLabels] as String);
              if (labelsDecoded == null || labelsDecoded is! List) {
                return null;
              }
              return labelsDecoded.map((e) => e is Map<String, dynamic> ? Label.fromJson(e) : null).whereType<Label>().toList();
            }()
          : null,
      viewer: map[_columnViewer] != null && map[_columnViewer] != 'null'
          ? () {
              final viewerDecoded = jsonDecode(map[_columnViewer] as String);
              if (viewerDecoded == null || viewerDecoded is! Map<String, dynamic>) {
                return null;
              }
              return Viewer.fromJson(viewerDecoded);
            }()
          : null,
      media: map[_columnMedia] != null && map[_columnMedia] != 'null'
          ? () {
              final mediaDecoded = jsonDecode(map[_columnMedia] as String);
              if (mediaDecoded == null || mediaDecoded is! Map<String, dynamic>) {
                return null;
              }
              return MediaView.fromJson(mediaDecoded);
            }()
          : null,
    );
  }

  @override
  Future<void> updatePost(PostView post) async {
    final db = await database;
    await db.update(_tablePosts, _postViewToMap(post), where: '$_columnUri = ?', whereArgs: [post.uri.toString()]);
  }

  // --- Feed Management ---

  /// Caches a Feed object (its metadata).
  @override
  Future<void> cacheFeed(Feed feed) async {
    final db = await database;
    final identifier = feed.identifier;
    await db.insert(_tableFeeds, {
      _columnFeedIdentifier: identifier,
      _columnFeedName: feed.name,
      _columnFeedType: switch (feed) {
        FeedRecord() => 'record',
        FeedHardCoded() => 'hardCoded',
        _ => throw Exception('Unknown Feed type: ${feed.runtimeType}'),
      },
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Deletes a feed and all its associations (due to ON DELETE CASCADE).
  @override
  Future<void> deleteFeed(Feed feed) async {
    final feedIdentifier = feed.identifier;
    final db = await database;
    await db.delete(_tableFeeds, where: '$_columnFeedIdentifier = ?', whereArgs: [feedIdentifier]);
  }

  // --- Feed-Post Association Management ---

  /// Sets the posts for a given feed.
  /// This will clear any existing posts for this feed and add the new ones in the provided order.
  /// Ensures that the PostViews themselves are cached before calling this.
  @override
  Future<void> setPostsForFeed(Feed feed, List<String> postUris) async {
    final feedIdentifier = feed.identifier;
    final db = await database;
    await db.transaction((txn) async {
      // 1. Clear existing associations for this feed
      await txn.delete(_tableFeedPostAssociations, where: '$_columnFeedIdentifierFK = ?', whereArgs: [feedIdentifier]);

      // 2. Add new associations in order
      final batch = txn.batch();
      for (var i = 0; i < postUris.length; i++) {
        batch.insert(
          _tableFeedPostAssociations,
          {
            _columnFeedIdentifierFK: feedIdentifier,
            _columnPostUriFK: postUris[i],
            _columnAssociationOrder: i, // 0-indexed order
          },
          conflictAlgorithm: ConflictAlgorithm.replace, // Should not happen if we cleared first
        );
      }
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<int> getPostCountForFeed(Feed feed) async {
    final feedIdentifier = feed.identifier;
    final db = await database;
    final countResult = await db.query(
      _tableFeedPostAssociations,
      where: '$_columnFeedIdentifierFK = ?',
      whereArgs: [feedIdentifier],
      columns: ['COUNT(*) as count'],
    );
    return Sqflite.firstIntValue(countResult) ?? 0;
  }

  /// Retrieves posts for a specific feed, ordered by their association order
  /// (most recently added to feed first).
  ///
  /// Does NOT update the `lastAccessed` timestamp of the retrieved posts.
  ///
  /// - [feedIdentifier]: The identifier of the feed.
  /// - [limit]: The maximum number of posts to retrieve. If null, no limit.
  /// - [offset]: The number of posts to skip before starting to retrieve. Requires [limit] to be set.
  @override
  Future<List<PostView>> getPostsForFeed(Feed feed, {int? limit, int? offset}) async {
    final feedIdentifier = feed.identifier;
    final db = await database;
    final arguments = <dynamic>[feedIdentifier];
    var limitClause = '';

    if (limit != null) {
      limitClause += ' LIMIT ?';
      arguments.add(limit);
      if (offset != null && offset > 0) {
        // Offset only makes sense if positive
        limitClause += ' OFFSET ?';
        arguments.add(offset);
      }
    } else if (offset != null && offset > 0) {
      // If offset is provided without limit, SQLite requires a limit.
      // Use -1 for "no effective limit" when an offset is present.
      limitClause += ' LIMIT -1 OFFSET ?';
      arguments.add(offset);
    }

    final sql =
        '''
      SELECT p.*
      FROM $_tablePosts p
      INNER JOIN $_tableFeedPostAssociations fpa ON p.$_columnUri = fpa.$_columnPostUriFK
      WHERE fpa.$_columnFeedIdentifierFK = ?
      ORDER BY fpa.$_columnAssociationOrder DESC
      $limitClause
    ''';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, arguments);
    final posts = <PostView>[];
    for (final map in maps) {
      try {
        posts.add(_mapToPostView(map));
      } catch (e) {
        // Skip corrupted posts
      }
    }
    return posts;
  }

  /// Retrieves post URIs for a specific feed, ordered by their association order
  /// (most recently added to feed first).
  ///
  /// Does NOT update the `lastAccessed` timestamp of any posts.
  ///
  /// - [feed]: The identifier of the feed.
  /// - [limit]: The maximum number of URIs to retrieve. If null, no limit.
  /// - [offset]: The number of URIs to skip before starting to retrieve. Requires [limit] to be set.
  @override
  Future<List<String>> getUrisForFeed(Feed feed, {int? limit, int? offset}) async {
    final feedIdentifier = feed.identifier;
    final db = await database;
    final arguments = <dynamic>[feedIdentifier];
    var limitClause = '';

    if (limit != null) {
      limitClause += ' LIMIT ?';
      arguments.add(limit);
      if (offset != null && offset > 0) {
        limitClause += ' OFFSET ?';
        arguments.add(offset);
      }
    } else if (offset != null && offset > 0) {
      limitClause += ' LIMIT -1 OFFSET ?';
      arguments.add(offset);
    }

    final sql =
        '''
      SELECT p.$_columnUri
      FROM $_tablePosts p
      INNER JOIN $_tableFeedPostAssociations fpa ON p.$_columnUri = fpa.$_columnPostUriFK
      WHERE fpa.$_columnFeedIdentifierFK = ?
      ORDER BY fpa.$_columnAssociationOrder DESC
      $limitClause
    ''';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, arguments);
    return maps.map((map) => map[_columnUri] as String).toList();
  }

  /// Appends posts to a given feed.
  /// Assumes postUris are for new posts not already associated with this feed for this "page".
  @override
  Future<void> appendPostsToFeed(Feed feed, List<String> postUris) async {
    if (postUris.isEmpty) return;
    final feedIdentifier = feed.identifier;
    final db = await database;

    await db.transaction((txn) async {
      // 1. Find the current maximum order for this feed
      final List<Map<String, dynamic>> maxOrderResult = await txn.query(
        _tableFeedPostAssociations,
        columns: ['MAX($_columnAssociationOrder) as max_order'],
        where: '$_columnFeedIdentifierFK = ?',
        whereArgs: [feedIdentifier],
      );

      var currentMaxOrder = -1; // Start before 0 if feed is empty
      if (maxOrderResult.isNotEmpty && maxOrderResult.first['max_order'] != null) {
        currentMaxOrder = maxOrderResult.first['max_order'] as int;
      }

      // 2. Add new associations with incrementing order
      final batch = txn.batch();
      for (var i = 0; i < postUris.length; i++) {
        batch.insert(_tableFeedPostAssociations, {
          _columnFeedIdentifierFK: feedIdentifier,
          _columnPostUriFK: postUris[i],
          _columnAssociationOrder: currentMaxOrder + 1 + i,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<void> deletePost(AtUri uri) async {
    final db = await database;
    final batch = db.batch();
    batch.delete(_tablePosts, where: '$_columnUri = ?', whereArgs: [uri.toString()]);
    batch.delete(_tableFeedPostAssociations, where: '$_columnPostUriFK = ?', whereArgs: [uri.toString()]);
    await batch.commit(noResult: true);
  }

  /// Clears all posts associated with a specific feed.
  @override
  Future<void> clearPostsFromFeed(Feed feed) async {
    final feedIdentifier = feed.identifier;
    final db = await database;
    await db.delete(_tableFeedPostAssociations, where: '$_columnFeedIdentifierFK = ?', whereArgs: [feedIdentifier]);
  }

  // --- Cache Eviction ---

  /// Deletes the least recently accessed posts if the cache exceeds [maxSize].
  @override
  Future<int> evictLeastRecentlyAccessed({required int postsToKeep}) async {
    final db = await database;
    final countResult = await db.rawQuery('SELECT COUNT(*) FROM $_tablePosts');
    final currentSize = Sqflite.firstIntValue(countResult) ?? 0;
    var deletedCount = 0;

    if (currentSize > postsToKeep) {
      final numToDelete = currentSize - postsToKeep;
      // Find the URIs of the posts to delete (oldest ones)
      final List<Map<String, dynamic>> toDeleteMaps = await db.query(
        _tablePosts,
        columns: [_columnUri /*, _COLUMN_CACHED_EMBED_FILE, add other fields if needed for file deletion */],
        orderBy: '$_columnLastAccessed ASC', // Oldest first
        limit: numToDelete,
      );

      if (toDeleteMaps.isNotEmpty) {
        final urisToDelete = toDeleteMaps.map((map) => map[_columnUri] as String).toList();
        final placeholders = List.generate(urisToDelete.length, (index) => '?').join(',');
        deletedCount = await db.delete(_tablePosts, where: '$_columnUri IN ($placeholders)', whereArgs: urisToDelete);
      }
    }
    return deletedCount;
  }

  /// Deletes posts older than [maxAge]. See notes in `evictLeastRecentlyAccessed`
  /// regarding file deletion.
  @override
  Future<int> evictPostsOlderThan(Duration maxAge) async {
    final db = await database;
    final cutoffTimestamp = DateTime.now().subtract(maxAge).millisecondsSinceEpoch;

    return db.delete(_tablePosts, where: '$_columnLastAccessed < ?', whereArgs: [cutoffTimestamp]);
  }

  /// Clears the entire PostView cache from the database.
  @override
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(_tableFeedPostAssociations);
      await txn.delete(_tablePosts);
      await txn.delete(_tableFeeds);
    });
    await BetterPlayerController(const BetterPlayerConfiguration()).clearCache();
  }

  /// Removes posts with null or invalid records from the database.
  Future<int> cleanupCorruptedPosts() async {
    final db = await database;
    return _cleanupCorruptedPostsInternal(db);
  }

  /// Closes the database. Not typically needed for a singleton service
  /// that lives for the app's duration.
  @override
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
