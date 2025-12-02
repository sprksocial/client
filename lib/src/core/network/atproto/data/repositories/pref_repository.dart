import 'package:sparksocial/src/core/network/atproto/data/models/pref_models.dart';

/// Interface for Preference-related API endpoints
abstract class PrefRepository {
  /// Get user preferences from the backend
  Future<Preferences> getPreferences();

  /// Update user preferences on the backend
  ///
  /// [preferences] The preferences to update
  Future<void> putPreferences(Preferences preferences);
}
