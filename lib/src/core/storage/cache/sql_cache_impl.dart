import 'dart:async';
import 'dart:convert';

import 'package:atproto/atproto.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import 'package:sparksocial/src/core/network/data/models/models.dart';
import 'package:atproto_core/atproto_core.dart';

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
const String _columnEmbed = 'embed'; // TEXT (JSON string of EmbedView)
const String _columnLastAccessed = 'lastAccessed'; // INTEGER (timestamp for LRU)

// --- Feed Definitions ---
const String _tableFeeds = 'feeds';
const String _columnFeedIdentifier = 'feed_identifier'; // TEXT PRIMARY KEY
const String _columnFeedName = 'feed_name'; // TEXT
const String _columnFeedType = 'feed_type'; // TEXT ('custom' or 'hardCoded')

// --- Feed-Post Associations Table ---
const String _tableFeedPostAssociations = 'feed_post_associations';
const String _columnAssociationId = 'association_id'; // INTEGER PRIMARY KEY AUTOINCREMENT
const String _columnFeedIdentifierFK = 'feed_identifier_fk'; // TEXT, Foreign Key to feeds table
const String _columnPostUriFK = 'post_uri_fk'; // TEXT, Foreign Key to cached_posts table
const String _columnAssociationOrder = 'association_order'; // INTEGER, for ordering posts within a feed

class SQLCacheImpl implements SQLCacheInterface {
  static Database? _database;
  late final SparkLogger _logger;

  SQLCacheImpl() {
    _logger = GetIt.instance<LogService>().getLogger('SQLCacheImpl');
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'sparksocial_sql_cache.db');
    return await openDatabase(
      path,
      version: 1, // Increment this if you change the schema
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade, // Define this if you plan schema migrations
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    Batch batch = db.batch();
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
        $_columnEmbed TEXT,
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
    await batch.commit(noResult: true);
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
    for (final post in posts) {
      final map = _postViewToMap(post);
      map[_columnLastAccessed] = DateTime.now().millisecondsSinceEpoch;
      batch.insert(_tablePosts, map, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Converts a PostView to a Map suitable for SQLite storage.
  /// Complex nested objects are serialized as JSON strings.
  /// Sadly, we cannot use `toJson` directly because the nested objects don't become strings.
  Map<String, dynamic> _postViewToMap(PostView post) {
    return {
      _columnUri: post.uri.toString(),
      _columnString: post.cid,
      _columnAuthor: jsonEncode(post.author.toJson()),
      _columnRecord: jsonEncode(post.record.toJson()),
      _columnIsRepost: post.isRepost ? 1 : 0,
      _columnIndexedAt: post.indexedAt.toIso8601String(),
      _columnLikeCount: post.likeCount,
      _columnReplyCount: post.replyCount,
      _columnRepostCount: post.repostCount,
      _columnQuoteCount: post.quoteCount,
      _columnLabels: post.labels != null ? jsonEncode(post.labels!.map((e) => e.toJson()).toList()) : null,
      _columnEmbed: post.embed != null ? jsonEncode(post.embed!.toJson()) : null,
    };
  }

  /// Retrieves a PostView by its URI string.
  /// Returns null if not found.
  @override
  Future<PostView> getPost(String uriString) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tablePosts, where: '$_columnUri = ?', whereArgs: [uriString]);

    _logger.i('Post found in cache: $uriString');

    if (maps.isNotEmpty) return _mapToPostView(maps.first);

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

    return maps.map((map) => _mapToPostView(map)).toList();
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
    return maps.map((map) => _mapToPostView(map)).toList();
  }

  /// Converts a Map from SQLite back to a PostView.
  /// JSON strings are deserialized back to complex objects.
  PostView _mapToPostView(Map<String, dynamic> map) {
    return PostView(
      uri: AtUri.parse(map[_columnUri] as String),
      cid: map[_columnString] as String,
      author: ProfileViewBasic.fromJson(jsonDecode(map[_columnAuthor] as String)),
      record: PostRecord.fromJson(jsonDecode(map[_columnRecord] as String)),
      isRepost: (map[_columnIsRepost] as int) == 1,
      indexedAt: DateTime.parse(map[_columnIndexedAt] as String),
      likeCount: map[_columnLikeCount] as int?,
      replyCount: map[_columnReplyCount] as int?,
      repostCount: map[_columnRepostCount] as int?,
      quoteCount: map[_columnQuoteCount] as int?,
      labels:
          map[_columnLabels] != null
              ? (jsonDecode(map[_columnLabels] as String) as List<dynamic>)
                  .map((e) => Label.fromJson(e as Map<String, dynamic>))
                  .toList()
              : null,
      embed: map[_columnEmbed] != null ? EmbedView.fromJson(jsonDecode(map[_columnEmbed] as String)) : null,
    );
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
        FeedCustom() => 'custom',
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
      for (int i = 0; i < postUris.length; i++) {
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
    List<dynamic> arguments = [feedIdentifier];
    String limitClause = '';

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

    final String sql = '''
      SELECT p.*
      FROM $_tablePosts p
      INNER JOIN $_tableFeedPostAssociations fpa ON p.$_columnUri = fpa.$_columnPostUriFK
      WHERE fpa.$_columnFeedIdentifierFK = ?
      ORDER BY fpa.$_columnAssociationOrder DESC
      $limitClause
    ''';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, arguments);
    return maps.map((map) => _mapToPostView(map)).toList();
  }

  /// Retrieves post URIs for a specific feed, ordered by their association order
  /// (most recently added to feed first).
  ///
  /// Does NOT update the `lastAccessed` timestamp of any posts.
  ///
  /// - [feedIdentifier]: The identifier of the feed.
  /// - [limit]: The maximum number of URIs to retrieve. If null, no limit.
  /// - [offset]: The number of URIs to skip before starting to retrieve. Requires [limit] to be set.
  @override
  Future<List<String>> getUrisForFeed(Feed feed, {int? limit, int? offset}) async {
    final feedIdentifier = feed.identifier;
    final db = await database;
    List<dynamic> arguments = [feedIdentifier];
    String limitClause = '';

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

    final String sql = '''
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

      int currentMaxOrder = -1; // Start before 0 if feed is empty
      if (maxOrderResult.isNotEmpty && maxOrderResult.first['max_order'] != null) {
        currentMaxOrder = maxOrderResult.first['max_order'] as int;
      }

      // 2. Add new associations with incrementing order
      final batch = txn.batch();
      for (int i = 0; i < postUris.length; i++) {
        batch.insert(_tableFeedPostAssociations, {
          _columnFeedIdentifierFK: feedIdentifier,
          _columnPostUriFK: postUris[i],
          _columnAssociationOrder: currentMaxOrder + 1 + i,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  /// Gets the maximum association order for a feed.
  /// Returns -1 if the feed has no posts.
  @override
  Future<int> getMaxAssociationOrderForFeed(Feed feed) async {
    final feedIdentifier = feed.identifier;
    final db = await database;
    
    final List<Map<String, dynamic>> result = await db.query(
      _tableFeedPostAssociations,
      columns: ['MAX($_columnAssociationOrder) as max_order'],
      where: '$_columnFeedIdentifierFK = ?',
      whereArgs: [feedIdentifier],
    );

    if (result.isNotEmpty && result.first['max_order'] != null) {
      return result.first['max_order'] as int;
    }
    return -1;
  }

  /// Retrieves posts for a specific feed that were added after the given association order.
  /// Ordered by association order (most recently added first).
  @override
  Future<List<PostView>> getPostsForFeedAfterOrder(Feed feed, int afterOrder, {int? limit}) async {
    final feedIdentifier = feed.identifier;
    final db = await database;
    List<dynamic> arguments = [feedIdentifier, afterOrder];
    String limitClause = '';

    if (limit != null) {
      limitClause += ' LIMIT ?';
      arguments.add(limit);
    }

    final String sql = '''
      SELECT p.*
      FROM $_tablePosts p
      INNER JOIN $_tableFeedPostAssociations fpa ON p.$_columnUri = fpa.$_columnPostUriFK
      WHERE fpa.$_columnFeedIdentifierFK = ? AND fpa.$_columnAssociationOrder > ?
      ORDER BY fpa.$_columnAssociationOrder DESC
      $limitClause
    ''';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, arguments);
    return maps.map((map) => _mapToPostView(map)).toList();
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
    final cacheManager = GetIt.instance<CacheManagerInterface>();
    final countResult = await db.rawQuery('SELECT COUNT(*) FROM $_tablePosts');
    final int currentSize = Sqflite.firstIntValue(countResult) ?? 0;
    int deletedCount = 0;

    if (currentSize > postsToKeep) {
      final int numToDelete = currentSize - postsToKeep;
      // Find the URIs of the posts to delete (oldest ones)
      final List<Map<String, dynamic>> toDeleteMaps = await db.query(
        _tablePosts,
        columns: [_columnUri /*, _COLUMN_CACHED_EMBED_FILE, add other fields if needed for file deletion */],
        orderBy: '$_columnLastAccessed ASC', // Oldest first
        limit: numToDelete,
      );

      if (toDeleteMaps.isNotEmpty) {
        for (final map in toDeleteMaps) {
          final String uri = map[_columnUri] as String;
          await cacheManager.removeFile(uri);
        }

        final List<String> urisToDelete = toDeleteMaps.map((map) => map[_columnUri] as String).toList();
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

    final cacheManager = GetIt.instance<CacheManagerInterface>();
    final List<Map<String, dynamic>> toDeleteMaps = await db.query(
      _tablePosts,
      columns: [_columnUri],
      where: '$_columnLastAccessed < ?',
      whereArgs: [cutoffTimestamp],
    );
    for (final map in toDeleteMaps) {
      final String uri = map[_columnUri];
      await cacheManager.removeFile(uri);
    }

    return await db.delete(_tablePosts, where: '$_columnLastAccessed < ?', whereArgs: [cutoffTimestamp]);
  }

  /// Clears the entire PostView cache from the database.
  @override
  Future<void> clearAllData() async {
    final db = await database;
    final cacheManager = GetIt.instance<CacheManagerInterface>();
    await db.transaction((txn) async {
      await txn.delete(_tableFeedPostAssociations);
      await txn.delete(_tablePosts);
      await txn.delete(_tableFeeds);
    });
    await cacheManager.clearCache();
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
