import 'package:bluesky_poptart/app/bsky/actor/get_profile.dart'
    as bsky_actor_get_profile;
import 'package:bluesky_poptart/app/bsky/actor/get_profiles.dart'
    as bsky_actor_get_profiles;
import 'package:poptart/poptart.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

/// Adapter for Bluesky actor models <-> Spark actor models
///
/// Handles bidirectional conversion between Bluesky actor/profile data structures
/// and Spark actor/profile data structures.
class BskyActorAdapter {
  const BskyActorAdapter();

  // ===========================================================================
  // Bluesky -> Spark Conversions
  // ===========================================================================

  /// Get a single profile from Bluesky and convert to Spark format
  Future<ProfileViewDetailed> getProfileFromBluesky(
    PoptartClient bluesky,
    String did,
  ) async {
    final profile = await bluesky.call(
      bsky_actor_get_profile.appBskyActorGetProfile,
      parameters: bsky_actor_get_profile.ActorGetProfileInput(actor: did),
    );
    return convertBskyProfileToSpark(profile.data.toJson());
  }

  /// Get multiple profiles from Bluesky and convert to Spark format
  Future<List<ProfileViewDetailed>> getProfilesFromBluesky(
    PoptartClient bluesky,
    List<String> dids,
  ) async {
    final profiles = await bluesky.call(
      bsky_actor_get_profiles.appBskyActorGetProfiles,
      parameters: bsky_actor_get_profiles.ActorGetProfilesInput(actors: dids),
    );
    return profiles.data.profiles
        .map((p) => convertBskyProfileToSpark(p.toJson()))
        .toList();
  }

  /// Convert a Bluesky profile JSON to Spark ProfileViewDetailed
  ProfileViewDetailed convertBskyProfileToSpark(
    Map<String, dynamic> bskyProfileJson,
  ) {
    // Bluesky and Spark profile structures are compatible, just parse directly
    return ProfileViewDetailed.fromJson(bskyProfileJson);
  }

  /// Convert a Bluesky ProfileView JSON to Spark ProfileView
  ProfileView convertBskyProfileViewToSpark(
    Map<String, dynamic> bskyProfileJson,
  ) {
    return ProfileView.fromJson(bskyProfileJson);
  }

  /// Convert a Bluesky ProfileViewBasic JSON to Spark ProfileViewBasic
  ProfileViewBasic convertBskyProfileViewBasicToSpark(
    Map<String, dynamic> bskyProfileJson,
  ) {
    return ProfileViewBasic.fromJson(bskyProfileJson);
  }
}

/// Singleton instance of the Bluesky actor adapter
///
/// Use this instance for all actor/profile model conversions:
/// ```dart
/// final bluesky = PoptartClient.fromOAuthSession(session);
/// final profile = await bskyActorAdapter.getProfileFromBluesky(bluesky, did);
/// ```
const bskyActorAdapter = BskyActorAdapter();
