import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'label_service.dart';
import 'settings_service.dart';

/// Manages labelers and their preferences
class LabelerManager extends ChangeNotifier {
  final AuthService _authService;
  final SettingsService _settingsService;
  
  // Cache of labeler details: {labelerDid: {name, description, etc.}}
  final Map<String, Map<String, dynamic>> _labelerDetails = {};
  
  // Cache of labels and definitions: {labelerDid: {labelValue: definitionMap}}
  final Map<String, Map<String, Map<String, dynamic>>> _labelDefinitions = {};
  
  // Indicates if we're loading data
  bool _isLoading = false;
  
  // Default labeler DID - used when no other labelers are configured
  static const String defaultLabelerDid = "did:plc:pbgyr67hftvpoqtvaurpsctc";
  
  LabelerManager(this._authService, this._settingsService);
  
  /// Indicates if we're loading data
  bool get isLoading => _isLoading;
  
  /// Returns a list of DIDs of followed labelers
  List<String> get followedLabelers {
    final labelers = _settingsService.followedLabelers;
    // If no labelers are configured, use the default labeler
    if (labelers.isEmpty) {
      return [defaultLabelerDid];
    }
    return labelers;
  }
  
  /// Returns details of a specific labeler (null if not available)
  Map<String, dynamic>? getLabelerDetails(String labelerDid) {
    return _labelerDetails[labelerDid];
  }
  
  /// Returns the label definitions for a specific labeler (empty if not available)
  Map<String, Map<String, dynamic>> getLabelDefinitions(String labelerDid) {
    return _labelDefinitions[labelerDid] ?? {};
  }
  
  /// Gets a preference for a specific label
  LabelPreference? getLabelPreference(String labelerDid, String labelValue) {
    return _settingsService.getLabelPreference(labelerDid, labelValue);
  }
  
  /// Sets a preference for a specific label
  Future<void> setLabelPreference(
    String labelerDid, 
    String labelValue, 
    LabelPreference preference
  ) async {
    await _settingsService.setLabelPreference(labelerDid, labelValue, preference);
    notifyListeners();
  }
  
  /// Follows a new labeler
  Future<void> followLabeler(String labelerDid) async {
    await _settingsService.addFollowedLabeler(labelerDid);
    await loadLabelerData(labelerDid);
    notifyListeners();
  }
  
  /// Unfollows a labeler
  Future<void> unfollowLabeler(String labelerDid) async {
    // Don't allow unfollowing the default labeler
    if (labelerDid == defaultLabelerDid) {
      return;
    }
    
    await _settingsService.removeFollowedLabeler(labelerDid);
    // Remove from caches
    _labelerDetails.remove(labelerDid);
    _labelDefinitions.remove(labelerDid);
    notifyListeners();
  }
  
  /// Loads data for a specific labeler (details and label definitions)
  Future<void> loadLabelerData(String labelerDid) async {
    // Store current loading state
    final wasLoading = _isLoading;
    
    // If we weren't already loading, update loading state and notify
    if (!wasLoading) {
      _isLoading = true;
      // Use Future.microtask to avoid calling setState during build
      Future.microtask(() => notifyListeners());
    }
    
    try {
      // Get service for this labeler
      final labelService = LabelService.forLabeler(_authService, labelerDid);
      
      // Try to load label definitions even if labeler info fails
      try {
        // Load labeler information
        final labelerInfo = await labelService.getLabelerInfo();
        _labelerDetails[labelerDid] = labelerInfo;
      } catch (e) {
        debugPrint('Error loading labeler info: $e');
        // Fallback for labeler info
        _labelerDetails[labelerDid] = {
          'displayName': 'Labeler $labelerDid',
          'description': 'Content labeler'
        };
      }
      
      try {
        // Load label definitions
        final labelDefs = await labelService.getAllLabelsWithDefinitions();
        _labelDefinitions[labelerDid] = labelDefs;
      } catch (e) {
        debugPrint('Error loading label definitions: $e');
        // For the default labeler, use a fallback if we can't load data
        if (labelerDid == defaultLabelerDid) {
          _createDefaultLabelerFallback();
        }
      }
    } catch (e) {
      debugPrint('Error loading labeler data $labelerDid: $e');
      
      // For the default labeler, use a fallback if we can't load data
      if (labelerDid == defaultLabelerDid) {
        _createDefaultLabelerFallback();
      }
    } finally {
      _isLoading = false;
      
      // Use Future.microtask to avoid calling setState during build
      Future.microtask(() => notifyListeners());
    }
  }
  
  /// Creates fallback data for the default labeler if we can't load the real data
  void _createDefaultLabelerFallback() {
    _labelerDetails[defaultLabelerDid] = {
      'displayName': 'Default Labeler',
      'description': 'System default content labeler'
    };
    
    _labelDefinitions[defaultLabelerDid] = {
      'spam': {
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
      },
      'impersonation': {
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
      },
      'scam': {
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
      },
      'intolerant': {
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
      },
      'self-harm': {
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
      },
      'security': {
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
      },
      'misleading': {
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
      },
      'threat': {
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
      },
      'unsafe-link': {
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
      },
      'illicit': {
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
      },
      'misinformation': {
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
      },
      'rumor': {
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
      },
      'rude': {
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
      },
      'extremist': {
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
      },
      'sensitive': {
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
      },
      'engagement-farming': {
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
      },
      'inauthentic': {
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
      },
      'sexual-figurative': {
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
      },
      'porn': {
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
      },
      'nudity': {
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
      },
      'sexual': {
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
      },
      'graphic-media': {
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
        'displayName': 'Graphic Content',
        'description': 'Disturbing or graphic imagery'
      },
    };
  }
  
  /// Loads data for all followed labelers
  Future<void> loadAllFollowedLabelers() async {
    _isLoading = true;
    // Use Future.microtask to avoid calling setState during build
    Future.microtask(() => notifyListeners());
    
    try {
      final labelers = List<String>.from(followedLabelers);
      
      for (final labelerDid in labelers) {
        await loadLabelerData(labelerDid);
      }
    } finally {
      _isLoading = false;
      // Use Future.microtask to avoid calling setState during build
      Future.microtask(() => notifyListeners());
    }
  }
  
  /// Checks if content should be hidden based on its labels
  bool shouldHideContent(List<String> contentLabels) {
    if (contentLabels.isEmpty) return false;
    
    // First check for special '!hide' label which always hides content
    if (contentLabels.contains('!hide')) {
      return true;
    }
    
    final settingsService = _settingsService;
    
    // For each label in the content
    for (final labelValue in contentLabels) {
      // Check in each followed labeler
      for (final labelerDid in followedLabelers) {
        // Get the label definition to check defaultSetting
        final labelDefinition = getLabelDefinitions(labelerDid)[labelValue];
        
        // Get preference with defaultSetting consideration
        final preference = settingsService.getLabelPreferenceOrDefault(
          labelerDid, 
          labelValue,
          labelDefinition
        );
        
        // If any labeler says to hide, hide
        if (preference == LabelPreference.hide) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// Checks if content should display a warning based on its labels
  bool shouldWarnContent(List<String> contentLabels) {
    if (contentLabels.isEmpty) return false;
    
    // First check for special '!warn' label which always warns for content
    if (contentLabels.contains('!warn')) {
      return true;
    }
    
    final settingsService = _settingsService;
    
    // For each label in the content
    for (final labelValue in contentLabels) {
      // Check in each followed labeler
      for (final labelerDid in followedLabelers) {
        // Get the label definition to check defaultSetting
        final labelDefinition = getLabelDefinitions(labelerDid)[labelValue];
        
        // Get preference with defaultSetting consideration
        final preference = settingsService.getLabelPreferenceOrDefault(
          labelerDid, 
          labelValue,
          labelDefinition
        );
        
        // If any labeler says to warn (and none say to hide), warn
        if (preference == LabelPreference.warn) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// Gets warning messages for content based on its labels
  List<String> getWarningMessages(List<String> contentLabels) {
    final Set<String> warnings = {};
    
    // Check for special '!warn' label which has a dedicated warning message
    if (contentLabels.contains('!warn')) {
      warnings.add("This content has been flagged by the publisher as requiring a warning");
    }
    
    final settingsService = _settingsService;
    
    // For each label in the content
    for (final labelValue in contentLabels) {
      // Skip processing the special labels
      if (labelValue == '!warn' || labelValue == '!hide') continue;
      
      // Check in each followed labeler
      for (final labelerDid in followedLabelers) {
        // Get the label definition to check defaultSetting
        final labelDefinition = getLabelDefinitions(labelerDid)[labelValue];
        
        // Get preference with defaultSetting consideration
        final preference = settingsService.getLabelPreferenceOrDefault(
          labelerDid, 
          labelValue,
          labelDefinition
        );
        
        // If the labeler says to warn about this label
        if (preference == LabelPreference.warn) {
          // Get the definition of this label
          final labelDef = _labelDefinitions[labelerDid]?[labelValue];
          if (labelDef != null) {
            // Add the warning message (or the label value if no message)
            String? displayName;
            
            // Try to get display name from locales first
            if (labelDef['locales'] != null) {
              final locales = labelDef['locales'] as List;
              if (locales.isNotEmpty) {
                final enLocale = locales.first;
                displayName = enLocale['name'] as String?;
              }
            }
            
            // Fallback to legacy displayName
            displayName ??= labelDef['displayName'] as String?;
            
            // Fallback to label value
            displayName ??= labelValue;
            
            warnings.add(displayName);
          } else {
            // If we don't have the definition, use the raw value
            warnings.add("This post contains content that was labeled as $labelValue");
          }
        }
      }
    }
    
    return warnings.toList();
  }
} 