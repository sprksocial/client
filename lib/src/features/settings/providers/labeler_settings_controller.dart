import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/labeler_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/network/atproto/data/services/appview_labeler_headers.dart';
import 'package:spark/src/core/providers/preferences_provider.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/settings/providers/labeler_policy_preferences.dart';

final labelerSettingsControllerProvider = Provider<LabelerSettingsController>(
  (ref) => LabelerSettingsController(
    ref,
    GetIt.I<SprkRepository>(),
    GetIt.I<LogService>().getLogger('LabelerSettings'),
  ),
);

final class LabelerSettingsController {
  LabelerSettingsController(this._ref, this._repository, this._logger);

  final Ref _ref;
  final SprkRepository _repository;
  final SparkLogger _logger;
  bool _defaultEnsured = false;

  String get _defaultDid => _repository.modDid.split('#').first;

  void resetSessionCache() {
    _defaultEnsured = false;
  }

  Future<Preferences> _preferences() async {
    return _ref.read(userPreferencesProvider).asData?.value ??
        _ref.read(userPreferencesProvider.future);
  }

  Future<void> _update(Preferences preferences) async {
    await _ref
        .read(userPreferencesProvider.notifier)
        .updatePreferences(preferences);
  }

  Future<List<String>> getLabelers() async {
    final preferences = await _preferences();
    var labelers =
        preferences.labelers?.map((labeler) => labeler.did).toList() ?? [];

    if (!_defaultEnsured) {
      if (!labelers.contains(_defaultDid)) {
        labelers = _normalizeLabelers(labelers);
        await _update(_withLabelers(preferences, labelers));
      }
      _defaultEnsured = true;
    }

    return _normalizeLabelers(labelers);
  }

  Future<void> addLabeler(String identifier) async {
    try {
      final did = await _repository.labeler.resolveIdentifier(identifier);
      final preferences = await _preferences();
      final current = preferences.labelers ?? [];
      if (current.any((labeler) => labeler.did == did)) return;
      if (current.length >= AppViewLabelerHeaders.maxLabelers) {
        throw StateError(
          'Cannot subscribe to more than '
          '${AppViewLabelerHeaders.maxLabelers} labelers',
        );
      }
      await _repository.labeler.validateService(did);
      await _update(
        _withLabelers(preferences, [
          ...current.map((labeler) => labeler.did),
          did,
        ]),
      );
    } catch (error, stackTrace) {
      _logger.e(
        'Could not add labeler $identifier',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> removeLabeler(String did) async {
    if (did == _defaultDid) {
      throw Exception('Cannot remove the default moderation service');
    }
    final preferences = await _preferences();
    await _update(
      _withLabelers(
        preferences,
        (preferences.labelers ?? const [])
            .map((labeler) => labeler.did)
            .where((labelerDid) => labelerDid != did),
      ),
    );
  }

  Future<void> syncLabelers() async {
    resetSessionCache();
    await _ref.read(userPreferencesProvider.notifier).refresh();
    var preferences = await _preferences();
    var labelers = _normalizeLabelers(
      (preferences.labelers ?? const []).map((labeler) => labeler.did),
    );
    if (!_sameLabelers(
      preferences.labelers?.map((labeler) => labeler.did) ?? const [],
      labelers,
    )) {
      preferences = _withLabelers(preferences, labelers);
      await _update(preferences);
    }

    final available = <String>[];
    for (final did in labelers) {
      if (did == _defaultDid) {
        available.add(did);
        continue;
      }
      try {
        await _repository.labeler.validateService(did);
        available.add(did);
      } on LabelerServiceUnavailableException catch (error, stackTrace) {
        _logger.w(
          'Removing unavailable labeler $did',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    if (!_sameLabelers(labelers, available)) {
      preferences = _withLabelers(preferences, available);
      await _update(preferences);
      labelers = available;
    }
    _defaultEnsured = true;
  }

  Future<Map<String, Setting>> getLabelSettings(String labelerDid) async {
    final preferences = await _preferences();
    return _savedSettings(preferences, labelerDid);
  }

  Future<LabelerPreferenceSnapshot> getPreferenceSnapshot(
    String labelerDid,
  ) async {
    final service = await _repository.labeler.getServicesDetailed([labelerDid]);
    final labelValues = service.policies.labelValues
        .map<String>((value) => value.toJson())
        .toList(growable: false);
    if (labelValues.isEmpty) {
      throw StateError('No label values found for labeler');
    }
    final definitions = ModerationLabelDefinitions.fromLabelers({
      labelerDid: service.policies.labelValueDefinitions ?? const [],
    });
    final definitionMap = <String, ModerationLabelDefinition>{
      for (final value in labelValues)
        value:
            ?definitions.bySource[labelerDid]?[value] ??
            definitions.global[value],
    };
    final preferences = await _preferences();
    final saved = _savedSettings(preferences, labelerDid);
    final global = _savedSettings(preferences, null);
    return LabelerPreferenceSnapshot(
      definitions: definitionMap,
      preferences: {
        for (final value in labelValues)
          value: labelPreferenceFromPolicy(
            value: value,
            savedSetting: saved[value],
            globalSetting: global[value],
            definition: definitionMap[value],
          ),
      },
    );
  }

  Future<void> setLabelPreference(
    String labelerDid,
    String value,
    Setting setting,
  ) async {
    final preferences = await _preferences();
    final updated = <Preference>[];
    var replaced = false;
    for (final preference in preferences.preferences) {
      final contentLabel = preference.contentLabelPref;
      if (contentLabel?.labelerDid == labelerDid &&
          contentLabel?.label == value) {
        updated.add(
          contentLabelPreference(
            labelerDid: labelerDid,
            label: value,
            visibility: setting.name,
          ),
        );
        replaced = true;
      } else {
        updated.add(preference);
      }
    }
    if (!replaced) {
      updated.add(
        contentLabelPreference(
          labelerDid: labelerDid,
          label: value,
          visibility: setting.name,
        ),
      );
    }
    await _update(Preferences(preferences: updated));
  }

  Map<String, Setting> _savedSettings(
    Preferences preferences,
    String? labelerDid,
  ) {
    final result = <String, Setting>{};
    for (final preference
        in preferences.contentLabelPrefs ?? const <ContentLabelPref>[]) {
      if (preference.labelerDid == labelerDid) {
        result[preference.label] = Setting.fromValue(
          preference.visibility.toJson(),
        );
      }
    }
    return result;
  }

  Preferences _withLabelers(
    Preferences preferences,
    Iterable<String> labelers,
  ) {
    final normalized = labelers.toList(growable: false);
    final subscribed = normalized.toSet();
    return Preferences(
      preferences: [
        ...preferences.preferences.where((preference) {
          if (preference.isLabelersPref) return false;
          final labelerDid = preference.contentLabelPref?.labelerDid;
          return labelerDid == null || subscribed.contains(labelerDid);
        }),
        labelersPreference([
          for (final did in normalized) LabelerPrefItem(did: did),
        ]),
      ],
    );
  }

  bool _sameLabelers(Iterable<String> left, Iterable<String> right) {
    final leftItems = left.toList(growable: false);
    final rightItems = right.toList(growable: false);
    if (leftItems.length != rightItems.length) return false;
    for (var index = 0; index < leftItems.length; index++) {
      if (leftItems[index] != rightItems[index]) return false;
    }
    return true;
  }

  List<String> _normalizeLabelers(Iterable<String> labelers) {
    return AppViewLabelerHeaders.normalize(
      defaultLabelerDid: _defaultDid,
      labelerDids: labelers,
    );
  }
}
