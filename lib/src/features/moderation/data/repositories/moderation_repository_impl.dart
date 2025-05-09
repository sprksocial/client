import 'dart:convert';

import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sparksocial/src/core/network/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/moderation/data/repositories/moderation_repository.dart';

/// Implementation of the moderation repository
class ModerationRepositoryImpl implements ModerationRepository {
  final AuthRepository _authRepository;
  final _logger = GetIt.instance<LogService>().getLogger('ModerationRepository');
  
  ModerationRepositoryImpl({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;
  
  ATProto? get _atproto => _authRepository.atproto;

  @override
  Future<bool> createReport({
    required ReportSubject subject,
    required ModerationReasonType reasonType,
    String? reason,
    ModerationService? service,
  }) async {
    _logger.i('Creating moderation report for reason: ${reasonType.value}');
    
    final authAtProto = _atproto;
    if (authAtProto == null || authAtProto.session == null) {
      _logger.e('AtProto not initialized');
      throw Exception('AtProto not initialized');
    } else if (service != null) {
      _logger.d('Using provided moderation service');
      try {
        final report = await service.createReport(
          subject: subject, 
          reasonType: reasonType, 
          reason: reason
        );
        return report.status.code == 200;
      } catch (e) {
        _logger.e('Error creating report with service', error: e);
        throw Exception('Failed to create report: $e');
      }
    } else {
      _logger.d('Using direct API call for moderation report');
      final endpoint = NSID.parse('com.atproto.moderation.createReport');
      final subjectData = subject.data;

      Map<String, dynamic> body;

      if (subjectData is StrongRef) {
        final strongRef = subjectData.toJson();
        body = {
          'subject': {
            '\$type': 'com.atproto.repo.strongRef', 
            'uri': strongRef['uri'], 
            'cid': strongRef['cid']
          },
          'reasonType': reasonType.value,
        };
      } else if (subjectData is RepoRef) {
        body = {
          'subject': {
            '\$type': 'com.atproto.admin.defs.repoRef', 
            'did': subjectData.did
          },
          'reasonType': reasonType.value,
        };
      } else {
        _logger.e('Invalid subject data type: ${subjectData.runtimeType}');
        throw Exception('Invalid subject data');
      }

      if (reason != null) {
        body['reason'] = reason;
      }

      // Send to Spark's PDS (don't use the user's PDS as it might be different)
      final uri = Uri.parse('https://pds.sprk.so/xrpc/$endpoint');
      final headers = {
        'Authorization': 'Bearer ${authAtProto.session!.accessJwt}', 
        'Content-Type': 'application/json'
      };

      _logger.d('Sending report to: $uri');
      
      try {
        final response = await http.post(
          uri, 
          headers: headers, 
          body: jsonEncode(body)
        );

        if (response.statusCode != 200) {
          _logger.e('Failed to create report: ${response.body}', 
            error: 'HTTP ${response.statusCode}');
          throw Exception('Failed to create report: ${response.body}');
        }

        _logger.i('Report created successfully');
        return true;
      } catch (e) {
        _logger.e('Error creating report', error: e);
        throw Exception('Failed to create report: $e');
      }
    }
  }
} 