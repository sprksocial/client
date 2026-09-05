import 'dart:typed_data';

import 'package:poptart_lex/com/atproto/repo/get_record.dart'
    as repo_get_record;
import 'package:poptart/poptart.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/auth/data/repositories/onboarding_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/repo_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({
    required this._repoRepository,
    required this._authRepository,
    SparkLogger? logger,
  }) : _logger =
           logger ??
           GetIt.instance<LogService>().getLogger('OnboardingRepository');
  final RepoRepository _repoRepository;
  final AuthRepository _authRepository;
  final SparkLogger _logger;

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
}
