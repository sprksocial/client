import 'dart:convert';

import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/label_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/network/data/models/label_models.dart';

/// Implementation of Label-related API endpoints
class LabelRepositoryImpl implements LabelRepository {
  final SprkRepository _client;
  final _logger = GetIt.instance<LogService>().getLogger('LabelRepository');

  // Default labeler DID
  static const String _defaultLabelerDid = 'did:plc:pbgyr67hftvpoqtvaurpsctc';

  // Cache for label values and definitions
  final Map<String, List<String>> _labelValuesCache = {};
  final Map<String, List<LabelValue>> _labelValueDefinitionsCache = {};

  LabelRepositoryImpl(this._client) {
    _logger.v('LabelRepository initialized');
  }

  @override
  Future<LabelValueListResponse> getLabelValues({String? labelerDid}) async {
    final targetDid = labelerDid ?? _defaultLabelerDid;
    _logger.d('Fetching label values from labeler: $targetDid');

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      try {
        // Configure header to use the proxy for the labeler
        final Map<String, String> headers = {};
        headers['atproto-proxy'] = '$targetDid#atproto_labeler';

        final responseData = await atproto.get(
          NSID.parse('com.atproto.label.getLabelValues'),
          headers: headers,
          to: (json) => json as Map<String, dynamic>,
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
        );

        // Extract and convert the values
        final values = List<String>.from(responseData.data['values'] ?? []);

        // Update the local cache
        _labelValuesCache[targetDid] = values;

        _logger.d('Fetched ${values.length} label values successfully');

        return LabelValueListResponse(values: values);
      } catch (e) {
        // Check if this is a 501 Method Not Implemented error
        if (e.toString().contains('501 Method Not Implemented')) {
          _logger.w('Method not implemented, using default values');
          // For default labeler, return default values
          if (targetDid == _defaultLabelerDid) {
            final values = _getDefaultLabelValues();
            _labelValuesCache[targetDid] = values;
            return LabelValueListResponse(values: values);
          }
        }

        _logger.e('Error fetching label values', error: e);
        throw Exception('Error fetching label values: $e');
      }
    });
  }

  @override
  Future<LabelValueDefinitionsResponse> getLabelValueDefinitions({String? labelerDid}) async {
    final targetDid = labelerDid ?? _defaultLabelerDid;
    _logger.d('Fetching label value definitions from labeler: $targetDid');

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      try {
        // Configure header to use the proxy for the labeler
        final Map<String, String> headers = {};
        headers['atproto-proxy'] = '$targetDid#atproto_labeler';

        final responseData = await atproto.get(
          NSID.parse('com.atproto.label.getLabelValueDefinitions'),
          headers: headers,
          to: (json) => json as Map<String, dynamic>,
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
        );

        // Extract and convert the definitions
        final definitionsMaps = List<Map<String, dynamic>>.from(responseData.data['definitions'] ?? []);
        final definitions = definitionsMaps.map((map) => LabelValue.fromJson(map)).toList();

        // Update the local cache
        _labelValueDefinitionsCache[targetDid] = definitions;

        _logger.d('Fetched ${definitions.length} label definitions successfully');

        return LabelValueDefinitionsResponse(definitions: definitions);
      } catch (e) {
        // Check if this is a 501 Method Not Implemented error
        if (e.toString().contains('501 Method Not Implemented')) {
          _logger.w('Method not implemented, using default definitions');
          // For default labeler, return default definitions
          if (targetDid == _defaultLabelerDid) {
            final definitions = _getDefaultLabelValueDefinitions();
            _labelValueDefinitionsCache[targetDid] = definitions;
            return LabelValueDefinitionsResponse(definitions: definitions);
          }
        }

        _logger.e('Error fetching label definitions', error: e);
        throw Exception('Error fetching label definitions: $e');
      }
    });
  }

  @override
  Future<LabelerInfoResponse> getLabelerInfo({String? labelerDid}) async {
    final targetDid = labelerDid ?? _defaultLabelerDid;
    _logger.d('Getting info for labeler: $targetDid');

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      try {
        // Configure header to use the proxy for the labeler
        final Map<String, String> headers = {};
        headers['atproto-proxy'] = '$targetDid#atproto_labeler';

        final responseData = await atproto.get(
          NSID.parse('com.atproto.label.getLabelerInfo'),
          headers: headers,
          to: (json) => json as Map<String, dynamic>,
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
        );

        _logger.d('Labeler info retrieved successfully');

        return LabelerInfoResponse.fromJson(responseData.data);
      } catch (e) {
        // Check if this is a 501 Method Not Implemented error
        if (e.toString().contains('501 Method Not Implemented')) {
          _logger.w('Method not implemented, using default info');
          // Fallback for default labeler
          if (targetDid == _defaultLabelerDid) {
            return LabelerInfoResponse(
              did: targetDid,
              displayName: 'Default Labeler',
              description: 'System default content labeler',
            );
          } else {
            // Generic fallback for other labelers
            return LabelerInfoResponse(
              did: targetDid,
              displayName: 'Labeler ${targetDid.substring(0, 10)}...',
              description: 'Content labeler',
            );
          }
        }

        _logger.e('Error fetching labeler info', error: e);
        throw Exception('Error fetching labeler info: $e');
      }
    });
  }

  @override
  Future<QueryLabelsResponse> queryLabels({
    required List<String> uriPatterns,
    List<String>? sources,
    int limit = 50,
    String? cursor,
    String? labelerDid,
  }) async {
    final targetDid = labelerDid ?? _defaultLabelerDid;
    _logger.d('Querying labels for ${uriPatterns.length} URI patterns from labeler: $targetDid');

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      try {
        // Configure header to use the proxy for the labeler
        final Map<String, String> headers = {};
        headers['atproto-proxy'] = '$targetDid#atproto_labeler';

        // Prepare parameters
        final Map<String, dynamic> parameters = {'uriPatterns': uriPatterns};

        if (sources != null && sources.isNotEmpty) {
          parameters['sources'] = sources;
        }

        if (limit != 50) {
          parameters['limit'] = limit;
        }

        if (cursor != null) {
          parameters['cursor'] = cursor;
        }

        final responseData = await atproto.get(
          NSID.parse('com.atproto.label.queryLabels'),
          parameters: parameters,
          headers: headers,
          to: (json) => json as Map<String, dynamic>,
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
        );

        // Extract and convert the labels
        final labelsMaps = List<Map<String, dynamic>>.from(responseData.data['labels'] ?? []);
        final labels = labelsMaps.map((map) => LabelDetail.fromJson(map)).toList();

        _logger.d('Retrieved ${labels.length} labels successfully');

        return QueryLabelsResponse(labels: labels, cursor: responseData.data['cursor'] as String?);
      } catch (e) {
        _logger.e('Error querying labels', error: e);
        throw Exception('Error querying labels: $e');
      }
    });
  }

  @override
  Future<Map<String, LabelValue>> getAllLabelsWithDefinitions({String? labelerDid}) async {
    final targetDid = labelerDid ?? _defaultLabelerDid;
    _logger.d('Getting all label definitions from labeler: $targetDid');

    final Map<String, LabelValue> result = {};

    try {
      // Try to fetch the latest values and definitions
      try {
        // Load values if not already loaded for this DID
        if (!_labelValuesCache.containsKey(targetDid) || _labelValuesCache[targetDid]!.isEmpty) {
          await getLabelValues(labelerDid: targetDid);
        }

        // Load definitions if not already loaded for this DID
        if (!_labelValueDefinitionsCache.containsKey(targetDid) || _labelValueDefinitionsCache[targetDid]!.isEmpty) {
          await getLabelValueDefinitions(labelerDid: targetDid);
        }

        // Create the map of label values to their definitions
        final definitions = _labelValueDefinitionsCache[targetDid] ?? [];
        for (final definition in definitions) {
          result[definition.value] = definition;
        }

        _logger.d('Retrieved ${result.length} label definitions successfully');
      } catch (apiError) {
        _logger.w('API error, using fallback definitions', error: apiError);
        // If we can't fetch (501 or other API errors), use fallbacks for default labeler
        if (targetDid == _defaultLabelerDid) {
          // Load default fallback labels for the default labeler
          final definitions = _getDefaultLabelValueDefinitions();
          for (final definition in definitions) {
            result[definition.value] = definition;
          }
        }
      }

      return result;
    } catch (e) {
      _logger.e('Error getting all label definitions', error: e);

      // Final fallback if everything fails for the default labeler
      if (targetDid == _defaultLabelerDid) {
        final definitions = _getDefaultLabelValueDefinitions();
        for (final definition in definitions) {
          result[definition.value] = definition;
        }
      }

      return result;
    }
  }

  @override
  Future<List<FeedPost>> fetchLabelsForPosts(List<FeedPost> posts, {List<String>? sources, String? labelerDid}) async {
    // If no posts provided, return empty list
    if (posts.isEmpty) {
      return [];
    }

    _logger.d('Fetching labels for ${posts.length} posts');

    try {
      // Collect all post URIs for a single query
      final uriPatterns = posts.map((post) => post.uri).toList();

      // Get labels for all posts in a single query
      final labelResponse = await queryLabels(
        uriPatterns: uriPatterns,
        sources: sources,
        limit: 250, // Maximum limit to ensure we get all labels
        labelerDid: labelerDid,
      );

      // Group labels by URI for easier processing
      final labelsByUri = <String, List<String>>{};
      for (final label in labelResponse.labels) {
        labelsByUri.putIfAbsent(label.uri, () => []).add(label.val);
      }

      _logger.d('Found labels for ${labelsByUri.length} posts');

      // Create new FeedPost instances with updated labels
      return posts.map((post) {
        // If we have labels for this post, create a new instance with updated labels
        if (post.uri.isNotEmpty && labelsByUri.containsKey(post.uri)) {
          return post.copyWith(labels: labelsByUri[post.uri]!);
        }
        // Otherwise, return the original post
        return post;
      }).toList();
    } catch (e) {
      _logger.e('Error fetching labels for posts', error: e);
      // If there's an error, return the original posts
      return posts;
    }
  }

  /// Returns default label values for the standard labeler
  List<String> _getDefaultLabelValues() {
    return [
      '!hide',
      '!warn',
      'porn',
      'sexual',
      'nudity',
      'sexual-figurative',
      'graphic-media',
      'self-harm',
      'sensitive',
      'extremist',
      'intolerant',
      'threat',
      'rude',
      'illicit',
      'security',
      'unsafe-link',
      'impersonation',
      'misinformation',
      'scam',
      'engagement-farming',
      'spam',
      'rumor',
      'misleading',
      'inauthentic',
    ];
  }

  /// Returns default label value definitions for the standard labeler
  List<LabelValue> _getDefaultLabelValueDefinitions() {
    return [
      LabelValue(
        value: 'spam',
        identifier: 'spam',
        blurs: 'content',
        severity: 'inform',
        defaultSetting: 'hide',
        adultOnly: false,
        locales: [
          LabelLocale(lang: 'en', name: 'Spam', description: 'Unwanted, repeated, or unrelated actions that bother users.'),
        ],
      ),
      LabelValue(
        value: 'impersonation',
        identifier: 'impersonation',
        blurs: 'none',
        severity: 'inform',
        defaultSetting: 'hide',
        adultOnly: false,
        locales: [
          LabelLocale(lang: 'en', name: 'Impersonation', description: 'Pretending to be someone else without permission.'),
        ],
      ),
      LabelValue(
        value: 'scam',
        identifier: 'scam',
        blurs: 'content',
        severity: 'alert',
        defaultSetting: 'hide',
        adultOnly: false,
        locales: [LabelLocale(lang: 'en', name: 'Scam', description: 'Scams, phishing & fraud.')],
      ),
      // Add other default label values as needed
    ];
  }
}
