import 'dart:typed_data';

import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:bluesky/app_bsky_actor_profile.dart';
import 'package:bluesky/bluesky.dart' as bs;
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/auth/data/repositories/onboarding_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/graph_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/repo_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({required RepoRepository repoRepository, required AuthRepository authRepository})
    : _repoRepository = repoRepository,
      _authRepository = authRepository;
  final RepoRepository _repoRepository;
  final AuthRepository _authRepository;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger('OnboardingRepository');

  Session? get _session => _authRepository.session;
  ATProto? get _atproto => _authRepository.atproto;

  @override
  Future<bool> hasSparkProfile() async {
    if (_session == null) return false;

    final uri = AtUri.parse('at://${_session!.did}/so.sprk.actor.profile/self');
    try {
      final response = await _repoRepository.getRecord(uri: uri);
      _logger.i('Spark profile found: ${response.record.toJson()}');
      return response.record.toJson().isNotEmpty;
    } catch (e) {
      // Treat 404 and 'Could not locate record' 400 errors as no profile
      final msg = e.toString().toLowerCase();
      if (msg.contains('404') || msg.contains('could not locate record') || msg.contains('400')) {
        return false;
      }
      _logger.e('Error checking Spark profile', error: e);
      rethrow;
    }
  }

  @override
  Future<ActorProfileRecord?> getBskyProfile() async {
    if (_session == null) return null;

    try {
      final uri = AtUri.parse('at://${_session!.did}/app.bsky.actor.profile/self');
      final response = await _repoRepository.getRecord(uri: uri);
      return ActorProfileRecord.fromJson(response.record.toJson());
    } catch (e) {
      _logger.i('Bluesky profile not found', error: e);
      return null;
    }
  }

  @override
  Future<void> createSparkProfile({required String displayName, required String description, dynamic avatar}) async {
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
        // Avatar is already a blob (e.g., imported from Bluesky). Try to serialise if possible.
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
  Future<FollowsResponse> getBskyFollows({String? cursor}) async {
    if (_session == null || _atproto == null) {
      throw Exception('Not authenticated');
    }

    final bsky = bs.Bluesky.fromSession(_session!);
    final did = _session!.did;
    final response = await bsky.graph.getFollows(actor: did, limit: 100, cursor: cursor);

    // Convert raw data to our structured model
    final rawData = response.data.toJson();
    final rawFollows = rawData['follows'] as List<dynamic>;

    final follows = rawFollows
        .map(
          (followData) => ProfileView.fromJson(followData as Map<String, dynamic>),
        )
        .toList();

    return FollowsResponse(follows: follows, cursor: rawData['cursor'] as String?);
  }

  @override
  Future<void> createSparkFollow(String subject) async {
    final record = <String, dynamic>{
      r'$type': 'so.sprk.graph.follow',
      'subject': subject,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };

    final response = await _repoRepository.createRecord(collection: 'so.sprk.graph.follow', record: record);

    if (response.uri.toString().isEmpty) {
      throw Exception('Failed to create Spark follow');
    }
  }
}
