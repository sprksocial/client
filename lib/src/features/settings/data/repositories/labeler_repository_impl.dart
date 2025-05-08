import 'package:sparksocial/src/core/network/atproto/data/models/label_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/storage/storage_constants.dart';
import 'package:sparksocial/src/core/storage/local/storage_manager.dart';
import 'package:sparksocial/src/features/settings/data/models/labeler.dart';
import 'package:sparksocial/src/features/settings/data/repositories/labeler_repository.dart';

/// Implementation of the LabelerRepository interface
class LabelerRepositoryImpl implements LabelerRepository {
  final SprkRepository _networkRepository;
  final StorageManager _storageManager;
  
  // Default labeler DID - used when no other labelers are configured
  static const String defaultLabelerDid = "did:plc:pbgyr67hftvpoqtvaurpsctc";

  /// Constructor
  LabelerRepositoryImpl(this._networkRepository, this._storageManager);
  
  @override
  Future<Labeler> getLabelerInfo(String labelerDid) async {
    try {
      final response = await _networkRepository.label.getLabelerInfo(labelerDid: labelerDid);
      return Labeler(
        did: response.did,
        displayName: response.displayName,
        description: response.description,
        avatar: response.avatar,
      );
    } catch (e) {
      // Fallback for labeler info if network call fails
      return Labeler(
        did: labelerDid,
        displayName: 'Labeler $labelerDid',
        description: 'Content labeler',
      );
    }
  }
  
  @override
  Future<List<String>> getLabelerLabelValues(String labelerDid) async {
    try {
      final response = await _networkRepository.label.getLabelValues(labelerDid: labelerDid);
      return response.values;
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<Map<String, LabelValue>> getLabelDefinitions(String labelerDid) async {
    try {
      final response = await _networkRepository.label.getLabelValueDefinitions(labelerDid: labelerDid);
      
      final Map<String, LabelValue> definitions = {};
      for (final def in response.definitions) {
        definitions[def.value] = def;
      }
      
      return definitions;
    } catch (e) {
      // Return empty map if we can't load definitions
      return {};
    }
  }
  
  @override
  Future<List<String>> getFollowedLabelers() async {
    final prefs = _storageManager.preferences;
    final labelers = await prefs.getStringList(StorageKeys.followedLabelers) ?? [];
    
    // If no labelers are configured, use the default labeler
    if (labelers.isEmpty) {
      return [defaultLabelerDid];
    }
    
    return labelers;
  }
  
  @override
  Future<void> addFollowedLabeler(String labelerDid) async {
    final prefs = _storageManager.preferences;
    final labelers = await prefs.getStringList(StorageKeys.followedLabelers) ?? [];
    
    if (!labelers.contains(labelerDid)) {
      labelers.add(labelerDid);
      await prefs.setStringList(StorageKeys.followedLabelers, labelers);
    }
  }
  
  @override
  Future<void> removeFollowedLabeler(String labelerDid) async {
    // Don't allow unfollowing the default labeler
    if (labelerDid == defaultLabelerDid) {
      return;
    }
    
    final prefs = _storageManager.preferences;
    final labelers = await prefs.getStringList(StorageKeys.followedLabelers) ?? [];
    
    if (labelers.contains(labelerDid)) {
      labelers.remove(labelerDid);
      await prefs.setStringList(StorageKeys.followedLabelers, labelers);
    }
  }
  
  @override
  Future<String?> getLabelPreference(String labelerDid, String labelValue) async {
    final prefs = _storageManager.preferences;
    final key = '${StorageKeys.labelPreferencePrefix}$labelerDid:$labelValue';
    return await prefs.getString(key);
  }
  
  @override
  Future<void> setLabelPreference(String labelerDid, String labelValue, String preference) async {
    final prefs = _storageManager.preferences;
    final key = '${StorageKeys.labelPreferencePrefix}$labelerDid:$labelValue';
    await prefs.setString(key, preference);
  }
} 