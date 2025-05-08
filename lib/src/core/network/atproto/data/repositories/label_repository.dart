import 'package:sparksocial/src/core/network/atproto/data/models/label_models.dart';

/// Interface for Label-related API endpoints
abstract class LabelRepository {
  /// Fetches all available label values from the labeler
  ///
  /// This uses the getLabelValues endpoint defined by the labeler
  /// [labelerDid] The DID of the labeler to use, defaults to system labeler if not specified
  Future<LabelValueListResponse> getLabelValues({String? labelerDid});

  /// Fetches detailed definitions for all label values
  ///
  /// This uses the getLabelValueDefinitions endpoint defined by the labeler
  /// [labelerDid] The DID of the labeler to use, defaults to system labeler if not specified
  Future<LabelValueDefinitionsResponse> getLabelValueDefinitions({String? labelerDid});

  /// Gets metadata about the labeler
  ///
  /// Returns information such as name, description, avatar, and associated URLs
  /// [labelerDid] The DID of the labeler to use, defaults to system labeler if not specified
  Future<LabelerInfoResponse> getLabelerInfo({String? labelerDid});

  /// Find labels relevant to the provided AT-URI patterns
  ///
  /// [uriPatterns] List of AT URI patterns to match (boolean 'OR').
  /// Each may be a prefix (ending with '*') or a full URI.
  /// [sources] Optional list of label sources (DIDs) to filter on.
  /// [limit] Results limit (1-250, default 50).
  /// [cursor] Optional cursor for pagination.
  /// [labelerDid] The DID of the labeler to use, defaults to system labeler if not specified
  Future<QueryLabelsResponse> queryLabels({
    required List<String> uriPatterns,
    List<String>? sources,
    int limit = 50,
    String? cursor,
    String? labelerDid,
  });

  /// Get all available labels from this labeler with their definitions
  ///
  /// Returns a map of label values to their definitions
  /// [labelerDid] The DID of the labeler to use, defaults to system labeler if not specified
  Future<Map<String, LabelValue>> getAllLabelsWithDefinitions({String? labelerDid});
} 