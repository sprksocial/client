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

  Future<List<CompatibleModerationService>> getCompatibleModerationServices(
    Iterable<String> dids,
    ModerationServiceQuery query,
  );
}
