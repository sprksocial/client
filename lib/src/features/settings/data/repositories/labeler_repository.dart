import 'package:sparksocial/src/core/network/data/models/label_models.dart';
import 'package:sparksocial/src/features/settings/data/models/labeler.dart';

/// Repository interface for handling labeler-related operations in the app local storage
abstract class LabelerRepository {
  /// Get information about a labeler
  Future<Labeler> getLabelerInfo(String labelerDid);
  
  /// Get all label values from a labeler
  Future<List<String>> getLabelerLabelValues(String labelerDid);
  
  /// Get label definitions from a labeler
  Future<Map<String, LabelValue>> getLabelDefinitions(String labelerDid);
  
  /// Get followed labelers from storage
  Future<List<String>> getFollowedLabelers();
  
  /// Add a labeler to the followed list
  Future<void> addFollowedLabeler(String labelerDid);
  
  /// Remove a labeler from the followed list
  Future<void> removeFollowedLabeler(String labelerDid);
  
  /// Get label preference
  Future<String?> getLabelPreference(String labelerDid, String labelValue);
  
  /// Set label preference
  Future<void> setLabelPreference(String labelerDid, String labelValue, String preference);
} 