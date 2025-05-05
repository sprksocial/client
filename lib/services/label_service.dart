import 'dart:convert';
import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'auth_service.dart';

/// Service for handling label-related operations
class LabelService {
  final AuthService _authService;
  // labeler did
  // if null, we use the sprk pds, which calls the sprk labeler in the backend
  final String? did;
  final String serviceUrl;
  List<String> labelValues = [];
  List<Map<String, dynamic>> labelValueDefinitions = [];
  
  // Instance cache for each labeler
  static final Map<String, LabelService> _instances = {};

  /// Default constructor
  LabelService(this._authService, {this.did = 'did:plc:pbgyr67hftvpoqtvaurpsctc', this.serviceUrl = 'https://pds.sprk.so'});
  
  /// Gets or creates a LabelService instance for a specific labeler
  /// 
  /// [authService] The authentication service to be used
  /// [labelerDid] The DID of the labeler
  /// [serviceUrl] Optional service URL (PDS) that hosts the labeler
  static LabelService forLabeler(
    AuthService authService, 
    String labelerDid, 
    {String serviceUrl = 'https://pds.sprk.so'}
  ) {
    // If we already have an instance for this labeler, return it
    if (_instances.containsKey(labelerDid)) {
      return _instances[labelerDid]!;
    }
    
    // Otherwise, create a new instance
    final service = LabelService(authService, did: labelerDid, serviceUrl: serviceUrl);
    _instances[labelerDid] = service;
    return service;
  }
  
  /// Clears the instance cache
  static void clearCache() {
    _instances.clear();
  }

  ATProto? get _atproto => _authService.atproto;

  /// Fetches all available label values from the labeler
  /// 
  /// This uses the getLabelValues endpoint defined by the labeler
  Future<List<String>> fetchLabelValues() async {
    final client = _atproto;
    if (client == null) {
      throw Exception('ATProto client not available');
    }
    
    try {
      // Configure header to use the proxy for the labeler
      final Map<String, String> headers = {};
      if (did != null) {
        headers['atproto-proxy'] = '$did#atproto_labeler';
      }
      
      final responseData = await client.get(
        NSID.parse('com.atproto.label.getLabelValues'),
        headers: headers,
        to: (json) => json as Map<String, dynamic>,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      
      // Update the local cache - create a new list instead of clearing the existing one
      final values = List<String>.from(responseData.data['values'] ?? []);
      labelValues = values;
      
      return values;
    } catch (e) {
      // Check if this is a 501 Method Not Implemented error
      if (e.toString().contains('501 Method Not Implemented')) {
        // For default labeler, return default values
        if (did == 'did:plc:pbgyr67hftvpoqtvaurpsctc') {
          labelValues = [
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
          return labelValues;
        }
      }
      throw Exception('Error fetching label values: $e');
    }
  }

  /// Fetches detailed definitions for all label values
  /// 
  /// This uses the getLabelValueDefinitions endpoint defined by the labeler
  Future<List<Map<String, dynamic>>> fetchLabelValueDefinitions() async {
    final client = _atproto;
    if (client == null) {
      throw Exception('ATProto client not available');
    }
    
    try {
      // Configure header to use the proxy for the labeler
      final Map<String, String> headers = {};
      if (did != null) {
        headers['atproto-proxy'] = '$did#atproto_labeler';
      }
      
      final responseData = await client.get(
        NSID.parse('com.atproto.label.getLabelValueDefinitions'),
        headers: headers,
        to: (json) => json as Map<String, dynamic>,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      
      // Extract and convert the definitions
      final definitions = List<Map<String, dynamic>>.from(responseData.data['definitions'] ?? []);
      
      // Update the local cache - create a new list instead of clearing the existing one
      labelValueDefinitions = definitions;
      
      return definitions;
    } catch (e) {
      // Check if this is a 501 Method Not Implemented error
      if (e.toString().contains('501 Method Not Implemented')) {
        // For default labeler, return default definitions
        if (did == 'did:plc:pbgyr67hftvpoqtvaurpsctc') {
          final List<Map<String, dynamic>> definitions = [
            {
              'value': 'spam',
              'identifier': 'spam',
              'blurs': 'content',
              'severity': 'inform',
              'defaultSetting': 'hide',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Spam',
                  'description': 'Unwanted, repeated, or unrelated actions that bother users.',
                },
              ],
            },
            {
              'value': 'impersonation',
              'identifier': 'impersonation',
              'blurs': 'none',
              'severity': 'inform',
              'defaultSetting': 'hide',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Impersonation',
                  'description': 'Pretending to be someone else without permission.',
                },
              ],
            },
            {
              'value': 'scam',
              'identifier': 'scam',
              'blurs': 'content',
              'severity': 'alert',
              'defaultSetting': 'hide',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Scam',
                  'description': 'Scams, phishing & fraud.',
                },
              ],
            },
            {
              'value': 'intolerant',
              'identifier': 'intolerant',
              'blurs': 'content',
              'severity': 'alert',
              'defaultSetting': 'warn',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Intolerance',
                  'description': 'Discrimination against protected groups.',
                },
              ],
            },
            {
              'value': 'self-harm',
              'identifier': 'self-harm',
              'blurs': 'content',
              'severity': 'alert',
              'defaultSetting': 'warn',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Self-Harm',
                  'description': 'Promotes self-harm, including graphic images, glorifying discussions, or triggering stories.',
                },
              ],
            },
            {
              'value': 'security',
              'identifier': 'security',
              'blurs': 'content',
              'severity': 'alert',
              'defaultSetting': 'hide',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Security Concerns',
                  'description': 'May be unsafe and could harm your device, steal your info, or get your account hacked.',
                },
              ],
            },
            {
              'value': 'misleading',
              'identifier': 'misleading',
              'blurs': 'content',
              'severity': 'alert',
              'defaultSetting': 'warn',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Misleading',
                  'description': 'Altered images/videos, deceptive links, or false statements.',
                },
              ],
            },
            {
              'value': 'threat',
              'identifier': 'threat',
              'blurs': 'content',
              'severity': 'inform',
              'defaultSetting': 'hide',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Threats',
                  'description': 'Promotes violence or harm towards others, including threats, incitement, or advocacy of harm.',
                },
              ],
            },
            {
              'value': 'unsafe-link',
              'identifier': 'unsafe-link',
              'blurs': 'content',
              'severity': 'alert',
              'defaultSetting': 'hide',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Unsafe link',
                  'description': 'Links to harmful sites with malware, phishing, or violating content that risk security and privacy.',
                },
              ],
            },
            {
              'value': 'illicit',
              'identifier': 'illicit',
              'blurs': 'content',
              'severity': 'alert',
              'defaultSetting': 'hide',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Illicit',
                  'description': 'Promoting or selling potentially illicit goods, services, or activities.',
                },
              ],
            },
            {
              'value': 'misinformation',
              'identifier': 'misinformation',
              'blurs': 'content',
              'severity': 'inform',
              'defaultSetting': 'warn',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Misinformation',
                  'description': 'Spreading false or misleading info, including unverified claims and harmful conspiracy theories.',
                },
              ],
            },
            {
              'value': 'rumor',
              'identifier': 'rumor',
              'blurs': 'content',
              'severity': 'inform',
              'defaultSetting': 'warn',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Rumor',
                  'description': 'Approach with caution, as these claims lack evidence from credible sources.',
                },
              ],
            },
            {
              'value': 'rude',
              'identifier': 'rude',
              'blurs': 'content',
              'severity': 'inform',
              'defaultSetting': 'hide',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Rude',
                  'description': 'Rude or impolite, including crude language and disrespectful comments, without constructive purpose.',
                },
              ],
            },
            {
              'value': 'extremist',
              'identifier': 'extremist',
              'blurs': 'content',
              'severity': 'alert',
              'defaultSetting': 'hide',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Extremist',
                  'description': 'Radical views advocating violence, hate, or discrimination against individuals or groups.',
                },
              ],
            },
            {
              'value': 'sensitive',
              'identifier': 'sensitive',
              'blurs': 'content',
              'severity': 'alert',
              'defaultSetting': 'warn',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Sensitive',
                  'description': 'May be upsetting, covering topics like substance abuse or mental health issues, cautioning sensitive viewers.',
                },
              ],
            },
            {
              'value': 'engagement-farming',
              'identifier': 'engagement-farming',
              'blurs': 'content',
              'severity': 'alert',
              'defaultSetting': 'hide',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Engagement Farming',
                  'description': 'Insincere content or bulk actions aimed at gaining followers, including frequent follows, posts, and likes.',
                },
              ],
            },
            {
              'value': 'inauthentic',
              'identifier': 'inauthentic',
              'blurs': 'content',
              'severity': 'alert',
              'defaultSetting': 'hide',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Inauthentic Account',
                  'description': 'Bot or a person pretending to be someone else.',
                },
              ],
            },
            {
              'value': 'sexual-figurative',
              'identifier': 'sexual-figurative',
              'blurs': 'media',
              'severity': 'none',
              'defaultSetting': 'show',
              'adultOnly': true,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Sexually Suggestive (Cartoon)',
                  'description': 'Art with explicit or suggestive sexual themes, including provocative imagery or partial nudity.',
                },
              ],
            },
            {
              'value': 'porn',
              'identifier': 'porn',
              'blurs': 'content',
              'severity': 'alert',
              'defaultSetting': 'hide',
              'adultOnly': true,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Explicit Content',
                  'description': 'Pornographic or sexually explicit material',
                },
              ],
            },
            {
              'value': 'nudity',
              'identifier': 'nudity',
              'blurs': 'content',
              'severity': 'alert',
              'defaultSetting': 'warn',
              'adultOnly': true,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Nudity',
                  'description': 'Content containing nudity',
                },
              ],
            },
            {
              'value': 'sexual',
              'identifier': 'sexual',
              'blurs': 'content',
              'severity': 'alert',
              'defaultSetting': 'warn',
              'adultOnly': true,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Sexual Content',
                  'description': 'Content of a sexual nature',
                },
              ],
            },
            {
              'value': 'graphic-media',
              'identifier': 'graphic-media',
              'blurs': 'content',
              'severity': 'alert',
              'defaultSetting': 'warn',
              'adultOnly': false,
              'locales': [
                {
                  'lang': 'en',
                  'name': 'Graphic Content',
                  'description': 'Disturbing or graphic imagery',
                },
              ],
            },
          ];
          
          labelValueDefinitions = definitions;
          return definitions;
        }
      }
      throw Exception('Error fetching label definitions: $e');
    }
  }

  /// Gets metadata about the labeler
  /// 
  /// Returns information such as name, description, avatar, and associated URLs
  Future<Map<String, dynamic>> getLabelerInfo() async {
    final client = _atproto;
    if (client == null) {
      throw Exception('ATProto client not available');
    }
    
    try {
      // Configure header to use the proxy for the labeler
      final Map<String, String> headers = {};
      if (did != null) {
        headers['atproto-proxy'] = '$did#atproto_labeler';
      }
      
      try {
        final responseData = await client.get(
          NSID.parse('com.atproto.label.getLabelerInfo'),
          headers: headers,
          to: (json) => json as Map<String, dynamic>,
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
        );
        
        return responseData.data;
      } catch (apiError) {
        // Check if this is a 501 Method Not Implemented error
        if (apiError.toString().contains('501 Method Not Implemented')) {
          // Fallback for default labeler
          if (did == 'did:plc:pbgyr67hftvpoqtvaurpsctc') {
            return {
              'did': did,
              'displayName': 'Default Labeler',
              'description': 'System default content labeler'
            };
          } else {
            // Generic fallback for other labelers
            return {
              'did': did,
              'displayName': 'Labeler ${did?.substring(0, 10)}...',
              'description': 'Content labeler'
            };
          }
        }
        // For other API errors, rethrow
        rethrow;
      }
    } catch (e) {
      throw Exception('Error fetching labeler info: $e');
    }
  }

  /// Get all available labels from this labeler with their definitions
  /// 
  /// Returns a map of label values to their definitions
  Future<Map<String, Map<String, dynamic>>> getAllLabelsWithDefinitions() async {
    // Create a map of label values to their definitions
    final Map<String, Map<String, dynamic>> result = {};
    
    try {
      // Try to fetch the latest values and definitions
      try {
        await fetchLabelValues();
        await fetchLabelValueDefinitions();
        
        for (final definition in labelValueDefinitions) {
          final String value = definition['value'] as String;
          result[value] = definition;
        }
      } catch (apiError) {
        // If we can't fetch (501 or other API errors), use fallbacks for default labeler
        if (did == 'did:plc:pbgyr67hftvpoqtvaurpsctc') {
          // Default fallback labels for the default labeler
          _addDefaultLabels(result);
        }
      }
      
      return result;
    } catch (e) {
      // Final fallback if everything fails for the default labeler
      if (did == 'did:plc:pbgyr67hftvpoqtvaurpsctc') {
        _addDefaultLabels(result);
      }
      
      return result;
    }
  }
  
  /// Adds default label definitions as a fallback
  void _addDefaultLabels(Map<String, Map<String, dynamic>> result) {
    result['spam'] = {
      'value': 'spam',
      'identifier': 'spam',
      'blurs': 'content',
      'severity': 'inform',
      'defaultSetting': 'hide',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Spam',
          'description': 'Unwanted, repeated, or unrelated actions that bother users.',
        },
      ],
      'displayName': 'Spam',
      'description': 'Unwanted, repeated, or unrelated actions that bother users.'
    };
    result['impersonation'] = {
      'value': 'impersonation',
      'identifier': 'impersonation',
      'blurs': 'none',
      'severity': 'inform',
      'defaultSetting': 'hide',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Impersonation',
          'description': 'Pretending to be someone else without permission.',
        },
      ],
      'displayName': 'Impersonation',
      'description': 'Pretending to be someone else without permission.'
    };
    result['scam'] = {
      'value': 'scam',
      'identifier': 'scam',
      'blurs': 'content',
      'severity': 'alert',
      'defaultSetting': 'hide',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Scam',
          'description': 'Scams, phishing & fraud.',
        },
      ],
      'displayName': 'Scam',
      'description': 'Scams, phishing & fraud.'
    };
    result['intolerant'] = {
      'value': 'intolerant',
      'identifier': 'intolerant',
      'blurs': 'content',
      'severity': 'alert',
      'defaultSetting': 'warn',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Intolerance',
          'description': 'Discrimination against protected groups.',
        },
      ],
      'displayName': 'Intolerance',
      'description': 'Discrimination against protected groups.'
    };
    result['self-harm'] = {
      'value': 'self-harm',
      'identifier': 'self-harm',
      'blurs': 'content',
      'severity': 'alert',
      'defaultSetting': 'warn',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Self-Harm',
          'description': 'Promotes self-harm, including graphic images, glorifying discussions, or triggering stories.',
        },
      ],
      'displayName': 'Self-Harm',
      'description': 'Promotes self-harm, including graphic images, glorifying discussions, or triggering stories.'
    };
    result['security'] = {
      'value': 'security',
      'identifier': 'security',
      'blurs': 'content',
      'severity': 'alert',
      'defaultSetting': 'hide',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Security Concerns',
          'description': 'May be unsafe and could harm your device, steal your info, or get your account hacked.',
        },
      ],
      'displayName': 'Security Concerns',
      'description': 'May be unsafe and could harm your device, steal your info, or get your account hacked.'
    };
    result['misleading'] = {
      'value': 'misleading',
      'identifier': 'misleading',
      'blurs': 'content',
      'severity': 'alert',
      'defaultSetting': 'warn',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Misleading',
          'description': 'Altered images/videos, deceptive links, or false statements.',
        },
      ],
      'displayName': 'Misleading',
      'description': 'Altered images/videos, deceptive links, or false statements.'
    };
    result['threat'] = {
      'value': 'threat',
      'identifier': 'threat',
      'blurs': 'content',
      'severity': 'inform',
      'defaultSetting': 'hide',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Threats',
          'description': 'Promotes violence or harm towards others, including threats, incitement, or advocacy of harm.',
        },
      ],
      'displayName': 'Threats',
      'description': 'Promotes violence or harm towards others, including threats, incitement, or advocacy of harm.'
    };
    result['unsafe-link'] = {
      'value': 'unsafe-link',
      'identifier': 'unsafe-link',
      'blurs': 'content',
      'severity': 'alert',
      'defaultSetting': 'hide',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Unsafe link',
          'description': 'Links to harmful sites with malware, phishing, or violating content that risk security and privacy.',
        },
      ],
      'displayName': 'Unsafe link',
      'description': 'Links to harmful sites with malware, phishing, or violating content that risk security and privacy.'
    };
    result['illicit'] = {
      'value': 'illicit',
      'identifier': 'illicit',
      'blurs': 'content',
      'severity': 'alert',
      'defaultSetting': 'hide',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Illicit',
          'description': 'Promoting or selling potentially illicit goods, services, or activities.',
        },
      ],
      'displayName': 'Illicit',
      'description': 'Promoting or selling potentially illicit goods, services, or activities.'
    };
    result['misinformation'] = {
      'value': 'misinformation',
      'identifier': 'misinformation',
      'blurs': 'content',
      'severity': 'inform',
      'defaultSetting': 'warn',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Misinformation',
          'description': 'Spreading false or misleading info, including unverified claims and harmful conspiracy theories.',
        },
      ],
      'displayName': 'Misinformation',
      'description': 'Spreading false or misleading info, including unverified claims and harmful conspiracy theories.'
    };
    result['rumor'] = {
      'value': 'rumor',
      'identifier': 'rumor',
      'blurs': 'content',
      'severity': 'inform',
      'defaultSetting': 'warn',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Rumor',
          'description': 'Approach with caution, as these claims lack evidence from credible sources.',
        },
      ],
      'displayName': 'Rumor',
      'description': 'Approach with caution, as these claims lack evidence from credible sources.'
    };
    result['rude'] = {
      'value': 'rude',
      'identifier': 'rude',
      'blurs': 'content',
      'severity': 'inform',
      'defaultSetting': 'hide',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Rude',
          'description': 'Rude or impolite, including crude language and disrespectful comments, without constructive purpose.',
        },
      ],
      'displayName': 'Rude',
      'description': 'Rude or impolite, including crude language and disrespectful comments, without constructive purpose.'
    };
    result['extremist'] = {
      'value': 'extremist',
      'identifier': 'extremist',
      'blurs': 'content',
      'severity': 'alert',
      'defaultSetting': 'hide',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Extremist',
          'description': 'Radical views advocating violence, hate, or discrimination against individuals or groups.',
        },
      ],
      'displayName': 'Extremist',
      'description': 'Radical views advocating violence, hate, or discrimination against individuals or groups.'
    };
    result['sensitive'] = {
      'value': 'sensitive',
      'identifier': 'sensitive',
      'blurs': 'content',
      'severity': 'alert',
      'defaultSetting': 'warn',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Sensitive',
          'description': 'May be upsetting, covering topics like substance abuse or mental health issues, cautioning sensitive viewers.',
        },
      ],
      'displayName': 'Sensitive',
      'description': 'May be upsetting, covering topics like substance abuse or mental health issues, cautioning sensitive viewers.'
    };
    result['engagement-farming'] = {
      'value': 'engagement-farming',
      'identifier': 'engagement-farming',
      'blurs': 'content',
      'severity': 'alert',
      'defaultSetting': 'hide',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Engagement Farming',
          'description': 'Insincere content or bulk actions aimed at gaining followers, including frequent follows, posts, and likes.',
        },
      ],
      'displayName': 'Engagement Farming',
      'description': 'Insincere content or bulk actions aimed at gaining followers, including frequent follows, posts, and likes.'
    };
    result['inauthentic'] = {
      'value': 'inauthentic',
      'identifier': 'inauthentic',
      'blurs': 'content',
      'severity': 'alert',
      'defaultSetting': 'hide',
      'adultOnly': false,
      'locales': [
        {
          'lang': 'en',
          'name': 'Inauthentic Account',
          'description': 'Bot or a person pretending to be someone else.',
        },
      ],
      'displayName': 'Inauthentic Account',
      'description': 'Bot or a person pretending to be someone else.'
    };
    result['sexual-figurative'] = {
      'value': 'sexual-figurative',
      'identifier': 'sexual-figurative',
      'blurs': 'media',
      'severity': 'none',
      'defaultSetting': 'show',
      'adultOnly': true,
      'locales': [
        {
          'lang': 'en',
          'name': 'Sexually Suggestive (Cartoon)',
          'description': 'Art with explicit or suggestive sexual themes, including provocative imagery or partial nudity.',
        },
      ],
      'displayName': 'Sexually Suggestive (Cartoon)',
      'description': 'Art with explicit or suggestive sexual themes, including provocative imagery or partial nudity.'
    };
    result['porn'] = {
      'value': 'porn',
      'identifier': 'porn',
      'blurs': 'content',
      'severity': 'alert',
      'defaultSetting': 'hide',
      'adultOnly': true,
      'locales': [
        {
          'lang': 'en',
          'name': 'Explicit Content',
          'description': 'Pornographic or sexually explicit material',
        },
      ],
      'displayName': 'Explicit Content',
      'description': 'Pornographic or sexually explicit material'
    };
    result['nudity'] = {
      'value': 'nudity',
      'identifier': 'nudity',
      'blurs': 'content',
      'severity': 'alert',
      'defaultSetting': 'warn',
      'adultOnly': true,
      'locales': [
        {
          'lang': 'en',
          'name': 'Nudity',
          'description': 'Content containing nudity',
        },
      ],
      'displayName': 'Nudity',
      'description': 'Content containing nudity'
    };
    result['sexual'] = {
      'value': 'sexual',
      'identifier': 'sexual',
      'blurs': 'content',
      'severity': 'alert',
      'defaultSetting': 'warn',
      'adultOnly': true,
      'locales': [
        {
          'lang': 'en',
          'name': 'Sexual Content',
          'description': 'Content of a sexual nature',
        },
      ],
      'displayName': 'Sexual Content',
      'description': 'Content of a sexual nature'
    };
    result['graphic-media'] = {
      'value': 'graphic-media',
      'identifier': 'graphic-media',
      'blurs': 'content',
      'severity': 'alert',
      'defaultSetting': 'warn',
      'adultOnly': true,
      'locales': [
        {
          'lang': 'en',
          'name': 'Graphic Content',
          'description': 'Disturbing or graphic imagery',
        },
      ],
      'displayName': 'Graphic Content',
      'description': 'Disturbing or graphic imagery'
    };
  }

  /// Find labels relevant to the provided AT-URI patterns
  ///
  /// [uriPatterns] List of AT URI patterns to match (boolean 'OR').
  /// Each may be a prefix (ending with '*') or a full URI.
  /// [sources] Optional list of label sources (DIDs) to filter on.
  /// [limit] Results limit (1-250, default 50).
  /// [cursor] Optional cursor for pagination.
  Future<List<String>> queryLabels({
    required List<String> uriPatterns,
    List<String>? sources,
    int limit = 50,
    String? cursor,
  }) async {
    final client = _atproto;
    if (client == null) {
      throw Exception('ATProto client not available');
    }
    
    try {
      // Configure header to use the proxy for the labeler
      final Map<String, String> headers = {};
      if (did != null) {
        headers['atproto-proxy'] = '$did#atproto_labeler';
      }
      
      // Prepare parameters
      final Map<String, dynamic> parameters = {
        'uriPatterns': uriPatterns,
      };
      
      if (sources != null && sources.isNotEmpty) {
        parameters['sources'] = sources;
      }
      
      if (limit != 50) {
        parameters['limit'] = limit;
      }
      
      if (cursor != null) {
        parameters['cursor'] = cursor;
      }
      
      final responseData = await client.get(
        NSID.parse('com.atproto.label.queryLabels'),
        parameters: parameters,
        headers: headers,
        to: (json) => json as Map<String, dynamic>,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      
      // Extract only the "val" values from labels
      final labels = List<Map<String, dynamic>>.from(responseData.data['labels'] ?? []);
      return labels.map((label) => label['val'] as String).toList();
    } catch (e) {
      throw Exception('Error fetching labels: $e');
    }
  }

  /// Get full label data for the provided AT-URI patterns
  Future<Map<String, List<Map<String, dynamic>>>> getLabelsWithDetails({
    required List<String> uriPatterns,
    List<String>? sources,
    int limit = 50,
    String? cursor,
  }) async {
    final client = _atproto;
    if (client == null) {
      throw Exception('ATProto client not available');
    }
    
    try {
      // Configure header to use the proxy for the labeler
      final Map<String, String> headers = {};
      if (did != null) {
        headers['atproto-proxy'] = '$did#atproto_labeler';
      }
      
      // Prepare parameters
      final Map<String, dynamic> parameters = {
        'uriPatterns': uriPatterns,
      };
      
      if (sources != null && sources.isNotEmpty) {
        parameters['sources'] = sources;
      }
      
      if (limit != 50) {
        parameters['limit'] = limit;
      }
      
      if (cursor != null) {
        parameters['cursor'] = cursor;
      }
      
      final responseData = await client.get(
        NSID.parse('com.atproto.label.queryLabels'),
        parameters: parameters,
        headers: headers,
        to: (json) => json as Map<String, dynamic>,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      
      // Group labels by URI
      final labels = List<Map<String, dynamic>>.from(responseData.data['labels'] ?? []);
      final Map<String, List<Map<String, dynamic>>> labelsByUri = {};
      
      for (final label in labels) {
        final postUri = label['uri'] as String;
        labelsByUri[postUri] ??= [];
        labelsByUri[postUri]!.add(label);
      }
      
      return labelsByUri;
    } catch (e) {
      throw Exception('Error fetching label details: $e');
    }
  }
}
