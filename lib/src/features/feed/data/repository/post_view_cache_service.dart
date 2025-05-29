import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sqflite/sqflite.dart';

import 'package:sparksocial/src/core/network/data/models/models.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:atproto/atproto.dart';

// --- Table and Column Definitions ---
const String _tablePosts = 'cached_posts';
const String _columnUri = 'uri'; // TEXT PRIMARY KEY (post.uri.toString())
const String _columnCID = 'cid'; // TEXT (post.cid.toString())
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
const String _columnCachedEmbedFile = 'cachedEmbedFile'; // TEXT (just for video files)
const String _columnLastAccessed = 'lastAccessed'; // INTEGER (timestamp for LRU)

class PostViewCacheService {
  static final PostViewCacheService _instance = PostViewCacheService._internal();
  factory PostViewCacheService() => _instance;
  PostViewCacheService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'sparksocial_post_cache.db');
    return await openDatabase(
      path,
      version: 1, // Increment this if you change the schema
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade, // Define this if you plan schema migrations
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tablePosts (
        $_columnUri TEXT PRIMARY KEY,
        $_columnCID TEXT NOT NULL,
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
        $_columnCachedEmbedFile TEXT,
        $_columnLastAccessed INTEGER NOT NULL
      )
    ''');
  }

  // --- Conversion Helpers ---
  Map<String, dynamic> _postViewToDbMap(PostView post) {
    return {
      _columnUri: post.uri.toString(),
      _columnCID: post.cid.toString(),
      _columnAuthor: jsonEncode(post.author.toJson()),
      _columnRecord: jsonEncode(post.record.toJson()),
      _columnIsRepost: post.isRepost ? 1 : 0,
      _columnIndexedAt: post.indexedAt.toIso8601String(),
      _columnLikeCount: post.likeCount,
      _columnReplyCount: post.replyCount,
      _columnRepostCount: post.repostCount,
      _columnQuoteCount: post.quoteCount,
      _columnLabels: post.labels != null ? jsonEncode(post.labels!.map((l) => l.toJson()).toList()) : null,
      _columnEmbed: post.embed != null ? jsonEncode(post.embed!.toJson()) : null,
      _columnCachedEmbedFile: post.cachedEmbedFile,
      // lastAccessed is updated on insert/update or retrieval
      _columnLastAccessed: DateTime.now().millisecondsSinceEpoch,
    };
  }

  PostView _postViewFromDbMap(Map<String, dynamic> map) {
    return PostView(
      uri: AtUri.parse(map[_columnUri] as String),
      // The CID class from atproto package likely handles parsing in its constructor
      cid: CID.parse(map[_columnCID] as String),
      author: ProfileViewBasic.fromJson(jsonDecode(map[_columnAuthor] as String) as Map<String, dynamic>),
      record: PostRecord.fromJson(jsonDecode(map[_columnRecord] as String) as Map<String, dynamic>),
      isRepost: (map[_columnIsRepost] as int) == 1,
      indexedAt: DateTime.parse(map[_columnIndexedAt] as String),
      likeCount: map[_columnLikeCount] as int?,
      replyCount: map[_columnReplyCount] as int?,
      repostCount: map[_columnRepostCount] as int?,
      quoteCount: map[_columnQuoteCount] as int?,
      labels: map[_columnLabels] != null
          ? (jsonDecode(map[_columnLabels] as String) as List<dynamic>)
                .map((l) => Label.fromJson(l as Map<String, dynamic>))
                .toList()
          : null,
      embed: map[_columnEmbed] != null
          ? EmbedView.fromJson(jsonDecode(map[_columnEmbed] as String) as Map<String, dynamic>)
          : null,
      cachedEmbedFile: map[_columnCachedEmbedFile] as String?,
    );
  }

  // --- CRUD Operations ---

  /// Caches a single PostView. If it already exists, it's updated.
  Future<void> cachePost(PostView post) async {
    final db = await database;
    final map = _postViewToDbMap(post); // lastAccessed is set here
    await db.insert(_tablePosts, map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Caches a list of PostViews in a batch.
  Future<void> cachePosts(List<PostView> posts) async {
    if (posts.isEmpty) return;
    final db = await database;
    final batch = db.batch();
    for (final post in posts) {
      final map = _postViewToDbMap(post); // lastAccessed is set here
      batch.insert(_tablePosts, map, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Retrieves a PostView by its URI string. Updates its lastAccessed time.
  /// Returns null if not found.
  Future<PostView?> getPost(String uriString) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tablePosts, where: '$_columnUri = ?', whereArgs: [uriString]);

    if (maps.isNotEmpty) {
      // Update last_accessed time
      await db.update(
        _tablePosts,
        {_columnLastAccessed: DateTime.now().millisecondsSinceEpoch},
        where: '$_columnUri = ?',
        whereArgs: [uriString],
      );

      PostView post = _postViewFromDbMap(maps.first);
      if (post.cachedEmbedFile != null && !await File(post.cachedEmbedFile!).exists()) {
        await updateCachedEmbedFile(post.uri.toString(), null);
        return post.copyWith(cachedEmbedFile: null); // Assumes PostView has copyWith
      }
      return post;
    }
    return null;
  }

  /// Retrieves multiple PostViews by a list of URI strings. Updates their lastAccessed time.
  Future<List<PostView>> getPostsByUris(List<String> uriStrings) async {
    if (uriStrings.isEmpty) return [];
    final db = await database;
    final placeholders = List.generate(uriStrings.length, (index) => '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      _tablePosts,
      where: '$_columnUri IN ($placeholders)',
      whereArgs: uriStrings,
    );

    final posts = <PostView>[];
    if (maps.isNotEmpty) {
      final batch = db.batch();
      final List<String> foundUris = [];

      for (final map in maps) {
        posts.add(_postViewFromDbMap(map));
        foundUris.add(map[_columnUri] as String);
      }

      // Update last_accessed time only for posts that were actually found
      for (final uriString in foundUris) {
        batch.update(
          _tablePosts,
          {_columnLastAccessed: DateTime.now().millisecondsSinceEpoch},
          where: '$_columnUri = ?',
          whereArgs: [uriString],
        );
      }
      await batch.commit(noResult: true);
    }
    return posts;
  }

  /// Gets posts ordered by last access time (most recently accessed first).
  Future<List<PostView>> getPostsOrderedByLastAccessed({int limit = 20, int offset = 0}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tablePosts,
      orderBy: '$_columnLastAccessed DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => _postViewFromDbMap(map)).toList();
  }

  /// Updates the cachedEmbedFile path for a specific post.
  /// Can be used to set the path after a download or clear it (by passing null).
  Future<void> updateCachedEmbedFile(String uriString, String? filePath) async {
    final db = await database;
    await db.update(
      _tablePosts,
      {
        _columnCachedEmbedFile: filePath,
        _columnLastAccessed: DateTime.now().millisecondsSinceEpoch, // Also update access time
      },
      where: '$_columnUri = ?',
      whereArgs: [uriString],
    );
  }

  // --- Cache Eviction ---

  /// Deletes the least recently accessed posts if the cache exceeds [maxSize].
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
          final String? filePath = map[_columnCachedEmbedFile] as String?;
          final post = await getPost(uri); // Or reconstruct enough to get videoUrl
          if (post != null && post.cachedEmbedFile != null) {
            await cacheManager.removeFile(post.cachedEmbedFile!);
          }
          if (filePath != null) {
            await File(filePath).delete();
          }
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
  Future<int> evictPostsOlderThan(Duration maxAge) async {
    final db = await database;
    final cutoffTimestamp = DateTime.now().subtract(maxAge).millisecondsSinceEpoch;

    final cacheManager = GetIt.instance<CacheManagerInterface>();
    final List<Map<String, dynamic>> toDeleteMaps = await db.query(
      _tablePosts,
      columns: [_columnUri, _columnCachedEmbedFile],
      where: '$_columnLastAccessed < ?',
      whereArgs: [cutoffTimestamp],
    );
    for (final map in toDeleteMaps) {
      final String? filePath = map[_columnCachedEmbedFile] as String?;
      if (filePath != null) {
        await cacheManager.removeFile(filePath);
      }
    }

    return await db.delete(_tablePosts, where: '$_columnLastAccessed < ?', whereArgs: [cutoffTimestamp]);
  }

  /// Clears the entire PostView cache from the database.
  /// See notes in `evictLeastRecentlyAccessed` regarding file deletion.
  Future<void> clearAllCachedPosts() async {
    final db = await database;
    final cacheManager = GetIt.instance<CacheManagerInterface>();
    await db.delete(_tablePosts);
    await cacheManager.clearCache();
  }

  /// Closes the database. Not typically needed for a singleton service
  /// that lives for the app's duration.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
