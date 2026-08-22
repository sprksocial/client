import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/moderation/moderation_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/pref_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

part 'preferences_provider.g.dart';

/// Central provider for user preferences.
///
/// This provider loads preferences once at startup and holds them in memory.
/// All services that need preferences should watch this provider instead of
/// calling getPreferences() directly.
///
/// When preferences are updated (via [updatePreferences]), all watchers are
/// automatically notified of the change.
@Riverpod(keepAlive: true)
class UserPreferences extends _$UserPreferences {
  late final PrefRepository _prefRepository;
  late final SprkRepository _sprkRepository;
  late final SparkLogger _logger;

  @override
  Future<Preferences> build() async {
    _prefRepository = GetIt.instance<PrefRepository>();
    _sprkRepository = GetIt.instance<SprkRepository>();
    _logger = GetIt.instance<LogService>().getLogger('UserPreferences');

    // Wait for auth to be initialized
    await _sprkRepository.authRepository.initializationComplete;

    if (!_sprkRepository.authRepository.isAuthenticated) {
      return _configureLabelers(Preferences(preferences: []));
    }

    try {
      final preferences = await _prefRepository.getPreferences();
      return _configureLabelers(preferences);
    } catch (e) {
      _logger.e('Error loading preferences: $e');
      rethrow;
    }
  }

  /// Gets the current preferences synchronously if available.
  /// Returns null if preferences haven't been loaded yet or there was an error.
  Preferences? get currentPreferences => state.asData?.value;

  /// Refreshes preferences from the server.
  /// This should be called when logging in or when syncing from another device.
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      final preferences = await _prefRepository.getPreferences();
      state = AsyncValue.data(_configureLabelers(preferences));
    } catch (e, st) {
      _logger.e('Error refreshing preferences: $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Updates preferences on the server and in local state.
  /// This should be called whenever preferences are modified.
  Future<void> updatePreferences(Preferences preferences) async {
    try {
      await _prefRepository.putPreferences(preferences);
      state = AsyncValue.data(_configureLabelers(preferences));
    } catch (e, st) {
      _logger.e('Error updating preferences: $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Updates preferences by applying a transformation function.
  /// This is useful for making partial updates without fetching first.
  Future<void> updatePreferencesWithFn(
    Preferences Function(Preferences current) updater,
  ) async {
    final current = state.asData?.value;
    if (current == null) {
      throw Exception('Cannot update preferences: not loaded yet');
    }

    final updated = updater(current);
    await updatePreferences(updated);
  }

  Future<void> setAdultContentEnabled(bool enabled) async {
    await updatePreferencesWithFn((current) {
      final retained = current.preferences.where((preference) {
        final data = preference.unknown;
        return data?[r'$type'] != 'so.sprk.actor.defs#adultContentPref';
      });
      return Preferences(
        preferences: [
          ...retained,
          adultContentPreference(enabled: enabled),
        ],
      );
    });
  }

  Future<void> setGlobalLabelPreference(
    String label,
    ModerationSetting setting,
  ) async {
    if (!globalAdultContentLabelValues.contains(label)) {
      throw ArgumentError.value(label, 'label', 'Not a global adult label');
    }

    await updatePreferencesWithFn((current) {
      final retained = current.preferences.where((preference) {
        final contentLabelPref = preference.contentLabelPref;
        return contentLabelPref == null || contentLabelPref.label != label;
      });
      return Preferences(
        preferences: [
          ...retained,
          contentLabelPreference(
            labelerDid: null,
            label: label,
            visibility: setting.name,
          ),
        ],
      );
    });
  }

  Preferences _configureLabelers(Preferences preferences) {
    _sprkRepository.configureLabelers(
      preferences.labelers?.map((labeler) => labeler.did) ?? const [],
    );
    return preferences;
  }
}
