import 'dart:typed_data';
import 'package:bluesky_poptart/app/bsky/actor/get_profile.dart'
    as bsky_actor_get_profile;
import 'package:bluesky_poptart/app/bsky/graph/get_follows.dart'
    as bsky_graph_get_follows;
import 'package:poptart_lex/com/atproto/repo/get_record.dart'
    as repo_get_record;
import 'package:poptart/poptart.dart';
import 'package:bluesky_poptart/app/bsky/actor/profile.dart';

import 'package:get_it/get_it.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/auth/data/repositories/onboarding_repository.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';
import 'package:spark/src/core/network/atproto/data/repositories/repo_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:sprk_poptart/so/sprk/graph/get_follows/output.dart'
    as sprk_get_follows;

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({
    required this._repoRepository,
    required this._authRepository,
  });
  final RepoRepository _repoRepository;
  final AuthRepository _authRepository;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'OnboardingRepository',
  );

  String? get _did => _authRepository.did;
  PoptartClient? get _atproto => _authRepository.atproto;

  @override
  Future<bool> hasSparkProfile() async {
    await _authRepository.initializationComplete;

    if (_did == null || _did!.isEmpty) {
      return false;
    }

    final uri = AtUri.parse('at://$_did/so.sprk.actor.profile/self');
    try {
      final atproto = _atproto;
      if (atproto == null) {
        _logger.w('AtProto not initialized while checking Spark profile');
        return false;
      }

      final response = await atproto.call(
        repo_get_record.comAtprotoRepoGetRecord,
        parameters: repo_get_record.RepoGetRecordInput(
          repo: uri.hostname,
          collection: uri.collection.toString(),
          rkey: uri.rkey,
        ),
      );
      _logger.i('Spark profile found: ${response.data.value}');
      return response.data.value.isNotEmpty;
    } catch (e) {
      // Treat explicit "record not found" failures as no profile.
      final msg = e.toString().toLowerCase();
      if (msg.contains('404') ||
          msg.contains('could not locate record') ||
          msg.contains('record not found')) {
        return false;
      }
      _logger.e('Error checking Spark profile', error: e);
      rethrow;
    }
  }

  @override
  Future<ActorProfileRecord?> getBskyProfile() async {
    await _authRepository.initializationComplete;

    if (_did == null || _did!.isEmpty) return null;

    try {
      final atproto = _atproto;
      if (atproto == null) {
        _logger.w('AtProto not initialized while fetching Bluesky profile');
        return null;
      }

      final uri = AtUri.parse('at://$_did/app.bsky.actor.profile/self');
      final response = await atproto.call(
        repo_get_record.comAtprotoRepoGetRecord,
        parameters: repo_get_record.RepoGetRecordInput(
          repo: uri.hostname,
          collection: uri.collection.toString(),
          rkey: uri.rkey,
        ),
      );

      return ActorProfileRecord.fromJson(response.data.value);
    } catch (e) {
      _logger.i('Bluesky profile not found', error: e);
      return null;
    }
  }

  @override
  Future<String?> getBskyAvatarUrl() async {
    await _authRepository.initializationComplete;

    if (_did == null || _did!.isEmpty) return null;

    try {
      final atproto = _atproto;
      if (atproto == null) {
        _logger.w('AtProto not initialized while fetching Bluesky avatar URL');
        return null;
      }

      final oauthSession = atproto.oAuthSession;
      if (oauthSession == null) {
        _logger.w('OAuth session missing while fetching Bluesky avatar URL');
        return null;
      }

      final bluesky = PoptartClient.fromOAuthSession(oauthSession);
      final profile = await bluesky.call(
        bsky_actor_get_profile.appBskyActorGetProfile,
        parameters: bsky_actor_get_profile.ActorGetProfileInput(actor: _did!),
      );

      return profile.data.avatar;
    } catch (e, s) {
      _logger.i(
        'Failed to resolve Bluesky avatar URL',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  @override
  Future<void> createSparkProfile({
    required String displayName,
    required String description,
    dynamic avatar,
  }) async {
    dynamic avatarField;

    // If the avatar is raw bytes, upload it as a blob first to avoid sending
    // a huge base64 payload directly in the record, which can trigger a 413
    // "request entity too large" error from the PDS.
    if (avatar != null) {
      if (avatar is Uint8List) {
        try {
          final blob = await _repoRepository.uploadBlob(avatar);
          avatarField = blob.toJson(); // include JSON representation of blob
        } catch (e, s) {
          _logger.e('Failed to upload avatar blob', error: e, stackTrace: s);
          rethrow;
        }
      } else {
        // Avatar is already a blob (e.g., imported from Bluesky).
        // Try to serialise if possible.
        try {
          // Many blob classes expose toJson(). If not, fall back to raw value.
          final toJson = (avatar as dynamic).toJson;
          avatarField = toJson is Function ? toJson() : avatar;
        } catch (_) {
          avatarField = avatar;
        }
      }
    }

    final record = <String, dynamic>{
      r'$type': 'so.sprk.actor.profile',
      'displayName': displayName,
      'description': description,
      'avatar': ?avatarField,
    };

    await _repoRepository.createRecord(
      collection: 'so.sprk.actor.profile',
      record: record,
      rkey: 'self',
    );
  }

  @override
  Future<sprk_get_follows.GraphGetFollowsOutput> getBskyFollows({
    String? cursor,
  }) async {
    if (_did == null || _atproto == null) {
      throw Exception('Not authenticated');
    }

    // Use the PoptartClient client's OAuth session if available, otherwise anonymous
    final bsky = _atproto!.oAuthSession != null
        ? PoptartClient.fromOAuthSession(_atproto!.oAuthSession!)
        : PoptartClient.anonymous();

    final response = await bsky.call(
      bsky_graph_get_follows.appBskyGraphGetFollows,
      parameters: bsky_graph_get_follows.GraphGetFollowsInput(
        actor: _did!,
        limit: 100,
        cursor: cursor,
      ),
    );

    // Convert raw data to our structured model
    final rawData = response.data.toJson();
    final rawFollows = rawData['follows'] as List<dynamic>;

    final follows = rawFollows
        .map(
          (followData) =>
              ProfileView.fromJson(followData as Map<String, dynamic>),
        )
        .toList();

    return sprk_get_follows.GraphGetFollowsOutput(
      subject: ProfileView.fromJson(rawData['subject'] as Map<String, dynamic>),
      follows: follows,
      cursor: rawData['cursor'] as String?,
    );
  }

  @override
  Future<void> createSparkFollow(String subject) async {
    final record = <String, dynamic>{
      r'$type': 'so.sprk.graph.follow',
      'subject': subject,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };

    final response = await _repoRepository.createRecord(
      collection: 'so.sprk.graph.follow',
      record: record,
    );

    if (response.uri.toString().isEmpty) {
      throw Exception('Failed to create Spark follow');
    }
  }
}
