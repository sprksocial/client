import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';

/// Interface for Feed-related API endpoints
abstract class LabelerRepository {
  Future<LabelerView> getServices(List<String> dids);
  Future<LabelerViewDetailed> getServicesDetailed(List<String> dids);
}
