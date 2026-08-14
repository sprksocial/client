import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';

class LabelerServiceUnavailableException implements Exception {
  const LabelerServiceUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Interface for Feed-related API endpoints
abstract class LabelerRepository {
  /// Resolves a DID or handle to the canonical service DID.
  Future<String> resolveIdentifier(String identifier);

  /// Verifies that [did] is advertised by the configured labeler appview.
  Future<void> validateService(String did);

  Future<LabelerView> getServices(List<String> dids);
  Future<LabelerViewDetailed> getServicesDetailed(List<String> dids);
}
