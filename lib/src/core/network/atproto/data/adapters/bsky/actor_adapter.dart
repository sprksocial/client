import 'package:bluesky/bluesky.dart' as bsky;
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';

/// Adapter for Bluesky actor models <-> Spark actor models
///
/// Handles bidirectional conversion between Bluesky actor/profile data structures
/// and Spark actor/profile data structures.
class BskyActorAdapter {
  const BskyActorAdapter();

  // ============================================================================
  // Bluesky -> Spark Conversions
  // ============================================================================

  /// Get a single profile from Bluesky and convert to Spark format
  Future<ProfileViewDetailed> getProfileFromBluesky(bsky.Bluesky bluesky, String did) async {
    final profile = await bluesky.actor.getProfile(actor: did);
    return convertBskyProfileToSpark(profile.data.toJson());
  }

  /// Get multiple profiles from Bluesky and convert to Spark format
  Future<List<ProfileViewDetailed>> getProfilesFromBluesky(bsky.Bluesky bluesky, List<String> dids) async {
    final profiles = await bluesky.actor.getProfiles(actors: dids);
    return profiles.data.profiles.map((p) => convertBskyProfileToSpark(p.toJson())).toList();
  }

  /// Convert a Bluesky profile JSON to Spark ProfileViewDetailed
  ProfileViewDetailed convertBskyProfileToSpark(Map<String, dynamic> bskyProfileJson) {
    // Bluesky and Spark profile structures are compatible, just parse directly
    return ProfileViewDetailed.fromJson(bskyProfileJson);
  }

  /// Convert a Bluesky ProfileView JSON to Spark ProfileView
  ProfileView convertBskyProfileViewToSpark(Map<String, dynamic> bskyProfileJson) {
    return ProfileView.fromJson(bskyProfileJson);
  }

  /// Convert a Bluesky ProfileViewBasic JSON to Spark ProfileViewBasic
  ProfileViewBasic convertBskyProfileViewBasicToSpark(Map<String, dynamic> bskyProfileJson) {
    return ProfileViewBasic.fromJson(bskyProfileJson);
  }
}

/// Singleton instance of the Bluesky actor adapter
///
/// Use this instance for all actor/profile model conversions:
/// ```dart
/// final bluesky = Bluesky.fromSession(session);
/// final profile = await bskyActorAdapter.getProfileFromBluesky(bluesky, did);
/// ```
const bskyActorAdapter = BskyActorAdapter();
