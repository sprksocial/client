import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/admin/defs.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart_lex/com/atproto/moderation/create_report.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';

class LabelerServiceUnavailableException implements Exception {
  const LabelerServiceUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ModerationServiceQuery {
  const ModerationServiceQuery({
    required this.fallbackDid,
    required this.subjectType,
    required this.reasonType,
    this.subjectCollection,
  });

  final String fallbackDid;
  final String subjectType;
  final String reasonType;
  final String? subjectCollection;

  factory ModerationServiceQuery.forReport({
    required String fallbackDid,
    required UModerationCreateReportSubject subject,
    required String reasonType,
  }) {
    final data = subject.data;
    return switch (data) {
      RepoStrongRef(:final uri) => ModerationServiceQuery(
        fallbackDid: fallbackDid,
        subjectType: 'record',
        subjectCollection: uri.collection.toString(),
        reasonType: reasonType,
      ),
      RepoRef() => ModerationServiceQuery(
        fallbackDid: fallbackDid,
        subjectType: 'account',
        reasonType: reasonType,
      ),
      _ => throw ArgumentError.value(
        data,
        'subject',
        'Unsupported report subject',
      ),
    };
  }
}

final class CompatibleModerationService {
  const CompatibleModerationService({
    required this.did,
    required this.displayName,
    required this.isDefault,
  });

  final String did;
  final String displayName;
  final bool isDefault;
}

/// Interface for Feed-related API endpoints
abstract class LabelerRepository {
  /// Resolves a DID or handle to the canonical service DID.
  Future<String> resolveIdentifier(String identifier);

  /// Verifies that [did] is advertised by the configured labeler appview.
  Future<void> validateService(String did);

  Future<LabelerView> getServices(List<String> dids);
  Future<LabelerViewDetailed> getServicesDetailed(List<String> dids);

  Future<({List<Label> labels, String? cursor})> queryLabels(
    List<AtUri> uris, {
    List<String>? sources,
    int? limit,
    String? cursor,
  });

  Future<List<CompatibleModerationService>> getCompatibleModerationServices(
    Iterable<String> dids,
    ModerationServiceQuery query,
  );
}
