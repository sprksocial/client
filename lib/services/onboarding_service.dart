import 'package:atproto/core.dart';
import 'package:bluesky/bluesky.dart' as bs;

import 'auth_service.dart';
import 'sprk_client.dart';

/// Service to handle user onboarding logic for Spark profiles
class OnboardingService {
  final AuthService _authService;
  final SprkClient _sprkClient;

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
  Future<bs.ActorProfile?> getBskyProfile() async {
    final session = _authService.session;
    if (session == null) return null;
    final bsky = bs.Bluesky.fromSession(session);
    final profile = await bsky.actor.getProfile(actor: session.did);
    return profile.data;
  }

  /// Imports data from Bluesky profile into a Spark actor profile
  Future<void> importBskyProfile() async {
    final bskyProfile = await getBskyProfile();
    if (bskyProfile == null) return;
    final record = <String, dynamic>{
      '\$type': 'so.sprk.actor.profile',
      'displayName': bskyProfile.displayName ?? '',
      'description': bskyProfile.description ?? '',
      if (bskyProfile.avatar != null) 'avatar': bskyProfile.avatar,
    };
    final response = await _sprkClient.repo.createRecord(
      collection: NSID.parse('so.sprk.actor.profile'),
      record: record,
      rkey: 'self',
    );
    if (response.status.code != 200) {
      throw Exception('Failed to import Spark profile: ${response.status.code} ${response.data}');
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

  /// Creates an empty Spark actor profile if the user skips import
  Future<void> createEmptySparkProfile() async {
    final record = <String, dynamic>{'\$type': 'so.sprk.actor.profile', 'displayName': '', 'description': ''};
    final response = await _sprkClient.repo.createRecord(
      collection: NSID.parse('so.sprk.actor.profile'),
      record: record,
      rkey: 'self',
    );
    if (response.status.code != 200) {
      throw Exception('Failed to create empty Spark profile: ${response.status.code} ${response.data}');
    }
  }

  /// Fetches the list of DIDs that the user follows on Bluesky
  Future<bs.Follows> getBskyFollows() async {
    final session = _authService.session;
    final atproto = _authService.atproto;

    if (session == null || atproto == null) throw Exception('Not authenticated');

    final bsky = bs.Bluesky.fromSession(session);
    final did = session.did;
    // TODO: Paginate with cursor
    final response = await bsky.graph.getFollows(actor: did, limit: 100);
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
}
