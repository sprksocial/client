import 'dart:convert';

import 'package:atproto/core.dart';
import 'package:atproto/atproto.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ModService {
  final AuthService _authService;

  ModService(this._authService);

  ATProto? get _atproto => _authService.atproto;

  Future<bool> createReport({
    required ReportSubject subject,
    required ModerationReasonType reasonType,
    String? reason,
    ModerationService? service,
  }) async {
    final authAtProto = _atproto;
    if (authAtProto == null || authAtProto.session == null) {
      throw Exception('AtProto not initialized');
    } else if (service != null) {
      final report = await service.createReport(subject: subject, reasonType: reasonType, reason: reason);
      return report.status.code == 200;
    } else {
      final endpoint = NSID.parse('com.atproto.moderation.createReport');

      final subjectData = subject.data;

      Map<String, dynamic> body;

      if (subjectData is StrongRef) {
        final strongRef = subjectData.toJson();
        body = {
          'subject': {'\$type': 'com.atproto.repo.strongRef', 'uri': strongRef['uri'], 'cid': strongRef['cid']},
          'reasonType': reasonType.value,
        };
      } else if (subjectData is RepoRef) {
        body = {
          'subject': {'\$type': 'com.atproto.admin.defs.repoRef', 'did': subjectData.did},
          'reasonType': reasonType.value,
        };
      } else {
        throw Exception('Invalid subject data');
      }

      if (reason != null) {
        body['reason'] = reason;
      }

      // Make XRPC call
      // Ensure the service URL has a scheme (https://)
      String serviceUrl = authAtProto.service;
      if (!serviceUrl.startsWith('http://') && !serviceUrl.startsWith('https://')) {
        serviceUrl = 'https://$serviceUrl';
      }

      // final uri = Uri.parse('$serviceUrl/xrpc/$endpoint');
      // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ if the user account was in another PDS other than sprk.so this would send to the wrong place
      // by default, send to our PDS
      final uri = Uri.parse('https://pds.sprk.so/xrpc/$endpoint');
      final headers = {'Authorization': 'Bearer ${authAtProto.session!.accessJwt}', 'Content-Type': 'application/json'};

      debugPrint('Report endpoint URI: $uri');
      debugPrint('Report headers: $headers');
      debugPrint('Report body: $body');

      final response = await http.post(uri, headers: headers, body: jsonEncode(body));

      if (response.statusCode != 200) {
        throw Exception('Failed to create report: ${response.body}');
      }

      return true;
    }
  }
}
