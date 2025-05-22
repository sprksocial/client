import 'dart:typed_data';

import 'package:atproto/core.dart';
import 'package:bluesky/bluesky.dart' as bs;

import 'auth_service.dart';
import 'sprk_client.dart';

/// Service to handle user onboarding logic for Spark profiles
class OnboardingService {
  final AuthService _authService;
  final SprkClient _sprkClient;

  /// Maximum number of writes allowed in a single applyWrites request
  static const int _maxWritesPerRequest = 200;

  OnboardingService(this._authService) : _sprkClient = SprkClient(_authService);

  Future<bool> hasSparkProfile() async {
    final session = _authService.session;
    if (session == null) return false;

    final uri = AtUri.parse('at://${session.did}/so.sprk.actor.profile/self');
    try {
      final response = await _sprkClient.repo.getRecord(uri: uri);
      return response.data != null;
    } catch (e) {
      // Treat 404 and 'Could not locate record' 400 errors as no profile
      final msg = e.toString().toLowerCase();
      if (msg.contains('404') || msg.contains('could not locate record') || msg.contains('400')) {
        return false;
      }
      rethrow;
    }
  }

  /// Retrieves the Bluesky profile for import
  Future<Map<String, dynamic>?> getBskyProfile() async {
    final session = _authService.session;
    if (session == null) return null;

    try {
      final uri = AtUri.parse('at://${session.did}/app.bsky.actor.profile/self');
      final response = await _sprkClient.repo.getRecord(uri: uri);
      return response.data?.toJson();
    } catch (e) {
      // Profile might not exist
      return null;
    }
  }

  /// Creates a Spark actor profile with custom values
  Future<void> importCustomProfile({required String displayName, required String description, dynamic avatar}) async {
    final record = <String, dynamic>{
      '\$type': 'so.sprk.actor.profile',
      'displayName': displayName,
      'description': description,
      if (avatar != null) 'avatar': avatar,
    };
    final response = await _sprkClient.repo.createRecord(
      collection: NSID.parse('so.sprk.actor.profile'),
      record: record,
      rkey: 'self',
    );
    if (response.status.code != 200) {
      throw Exception('Failed to create Spark profile: ${response.status.code} ${response.data}');
    }
  }

  /// Finalizes the profile creation process including avatar upload.
  Future<void> finalizeProfileCreation({
    required String displayName,
    required String description,
    dynamic avatar, // This can be Uint8List or existing profile data
  }) async {
    dynamic avatarToSend = avatar;
    if (avatar is List<int>) {
      final resp = await _sprkClient.repo.uploadBlob(avatar as Uint8List);
      if (resp.status.code != 200) {
        throw Exception('Failed to upload avatar blob: ${resp.status.code}');
      }
      avatarToSend = resp.data.blob.toJson();
    }

    await importCustomProfile(displayName: displayName, description: description, avatar: avatarToSend);
  }

  /// Fetches the list of DIDs that the user follows on Bluesky
  Future<bs.Follows> getBskyFollows({String? cursor}) async {
    final session = _authService.session;
    final atproto = _authService.atproto;

    if (session == null || atproto == null) throw Exception('Not authenticated');

    final bsky = bs.Bluesky.fromSession(session);
    final did = session.did;
    final response = await bsky.graph.getFollows(actor: did, limit: 100, cursor: cursor);
    return response.data;
  }

  /// Creates a follow record in Spark for the given subject DID
  Future<void> createSparkFollow(String subject) async {
    final record = <String, dynamic>{
      '\$type': 'so.sprk.graph.follow',
      'subject': subject,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    final response = await _sprkClient.repo.createRecord(collection: NSID.parse('so.sprk.graph.follow'), record: record);
    if (response.status.code != 200) {
      throw Exception('Failed to create Spark follow: ${response.status.code}');
    }
  }

  /// Helper function to apply writes in chunks of 200 (max allowed per request)
  Future<void> _applyWritesInChunks(List<Map<String, dynamic>> writes, String did) async {
    final atproto = _authService.atproto;
    if (atproto == null) throw Exception('Not authenticated');

    // Split writes into chunks of max 200 items
    for (int i = 0; i < writes.length; i += _maxWritesPerRequest) {
      final end = (i + _maxWritesPerRequest < writes.length) ? i + _maxWritesPerRequest : writes.length;
      final chunk = writes.sublist(i, end);

      final response = await atproto.post(NSID.parse('com.atproto.repo.applyWrites'), body: {'repo': did, 'writes': chunk});

      if (response.status.code != 200) {
        throw Exception('Failed to apply writes: ${response.status.code}');
      }
    }
  }

  /// Creates multiple follow records in chunks using applyWrites
  /// Returns a list of DIDs that were successfully followed
  Future<List<String>> createBatchFollows(List<String> subjects) async {
    if (subjects.isEmpty) return [];

    final session = _authService.session;
    if (session == null) throw Exception('Not authenticated');

    // Create write operations for each follow
    final writes =
        subjects.map((subject) {
          return {
            '\$type': 'com.atproto.repo.applyWrites#create',
            'collection': 'so.sprk.graph.follow',
            'value': {
              '\$type': 'so.sprk.graph.follow',
              'subject': subject,
              'createdAt': DateTime.now().toUtc().toIso8601String(),
            },
          };
        }).toList();

    // Apply writes in chunks
    await _applyWritesInChunks(writes, session.did);

    return subjects;
  }

  /// Fetches the user's current Spark follows from their PDS
  /// Returns a set of DIDs that the user follows
  Future<Set<String>> getCurrentSparkFollows() async {
    final session = _authService.session;
    final atproto = _authService.atproto;

    if (session == null || atproto == null) throw Exception('Not authenticated');

    final followedDids = <String>{};
    String? cursor;

    do {
      final response = await atproto.repo.listRecords(
        repo: session.did,
        collection: NSID.parse('so.sprk.graph.follow'),
        cursor: cursor,
        limit: 100,
      );

      if (response.status.code != 200) {
        throw Exception('Failed to list Spark follows: ${response.status.code}');
      }

      for (final record in response.data.records) {
        // Convert to a Map to access the value field
        final recordMap = record.toJson();
        final value = recordMap['value'] as Map<String, dynamic>;
        final subject = value['subject'] as String;
        followedDids.add(subject);
      }

      cursor = response.data.cursor;
    } while (cursor != null);

    return followedDids;
  }

  /// Cleanup duplicate follow records to ensure unique subject values
  /// This function detects and removes duplicate follow records from the user's PDS
  Future<int> gambiarraFixDuplicates() async {
    final session = _authService.session;
    final atproto = _authService.atproto;

    if (session == null || atproto == null) throw Exception('Not authenticated');

    // Fetch all follow records
    final allFollows = <Map<String, dynamic>>[];
    String? cursor;

    do {
      final response = await atproto.repo.listRecords(
        repo: session.did,
        collection: NSID.parse('so.sprk.graph.follow'),
        cursor: cursor,
        limit: 100,
      );

      if (response.status.code != 200) {
        throw Exception('Failed to list follow records: ${response.status.code}');
      }

      for (final record in response.data.records) {
        allFollows.add(record.toJson());
      }

      cursor = response.data.cursor;
    } while (cursor != null);

    // Find duplicates: group by subject and keep track of records to delete
    final subjectToRecords = <String, List<Map<String, dynamic>>>{};

    for (final record in allFollows) {
      final subject = record['value']['subject'] as String;
      subjectToRecords[subject] ??= [];
      subjectToRecords[subject]!.add(record);
    }

    // Prepare delete operations for duplicate records
    // For each subject, keep the first record and mark the rest for deletion
    final deleteWrites = <Map<String, dynamic>>[];

    for (final entry in subjectToRecords.entries) {
      final records = entry.value;
      if (records.length > 1) {
        // Skip the first one (keep it) and mark others for deletion
        for (int i = 1; i < records.length; i++) {
          deleteWrites.add({
            '\$type': 'com.atproto.repo.applyWrites#delete',
            'collection': 'so.sprk.graph.follow',
            'rkey': records[i]['uri'].toString().split('/').last,
          });
        }
      }
    }

    // If no duplicates found, return early
    if (deleteWrites.isEmpty) return 0;

    // Apply delete operations in chunks
    await _applyWritesInChunks(deleteWrites, session.did);

    return deleteWrites.length;
  }
}
