import 'package:flutter_test/flutter_test.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';

void main() {
  group('ModerationPreferences', () {
    final definition = _definition();

    test('source-specific preference wins for an ordinary label', () {
      final preferences = _preferences([
        const ModerationLabelPreference(
          value: 'topic',
          setting: ModerationSetting.hide,
        ),
        const ModerationLabelPreference(
          value: 'topic',
          labelerDid: 'did:plc:alpha',
          setting: ModerationSetting.warn,
        ),
      ]);

      expect(
        preferences.settingFor(_label(src: 'did:plc:alpha'), definition),
        ModerationSetting.warn,
      );
    });

    test('global adult preference overrides source-specific preference', () {
      final preferences = _preferences([
        const ModerationLabelPreference(
          value: 'porn',
          setting: ModerationSetting.hide,
        ),
        const ModerationLabelPreference(
          value: 'porn',
          labelerDid: 'did:plc:alpha',
          setting: ModerationSetting.warn,
        ),
      ]);

      expect(
        preferences.settingFor(
          _label(src: 'did:plc:alpha', val: 'porn'),
          _definition(identifier: 'porn'),
        ),
        ModerationSetting.hide,
      );
    });

    test('global preference applies to sources without an override', () {
      final preferences = _preferences([
        const ModerationLabelPreference(
          value: 'topic',
          setting: ModerationSetting.hide,
        ),
        const ModerationLabelPreference(
          value: 'topic',
          labelerDid: 'did:plc:alpha',
          setting: ModerationSetting.warn,
        ),
      ]);

      expect(
        preferences.settingFor(_label(src: 'did:plc:beta'), definition),
        ModerationSetting.hide,
      );
    });

    test('same-valued labels from different sources remain independent', () {
      final preferences = _preferences([
        const ModerationLabelPreference(
          value: 'topic',
          labelerDid: 'did:plc:alpha',
          setting: ModerationSetting.warn,
        ),
        const ModerationLabelPreference(
          value: 'topic',
          labelerDid: 'did:plc:beta',
          setting: ModerationSetting.ignore,
        ),
      ]);

      expect(
        preferences.settingFor(_label(src: 'did:plc:alpha'), definition),
        ModerationSetting.warn,
      );
      expect(
        preferences.settingFor(_label(src: 'did:plc:beta'), definition),
        ModerationSetting.ignore,
      );
    });

    test('uses definition default when no preference exists', () {
      expect(
        _preferences([]).settingFor(_label(src: 'did:plc:alpha'), definition),
        ModerationSetting.warn,
      );
    });

    test('tracks definition default changes when no preference exists', () {
      final preferences = _preferences([]);
      final label = _label(src: 'did:plc:alpha');

      expect(
        preferences.settingFor(
          label,
          _definition(defaultSetting: ModerationSetting.hide),
        ),
        ModerationSetting.hide,
      );
      expect(
        preferences.settingFor(
          label,
          _definition(defaultSetting: ModerationSetting.ignore),
        ),
        ModerationSetting.ignore,
      );
    });

    test('non-configurable labels ignore user preferences', () {
      final preferences = _preferences([
        const ModerationLabelPreference(
          value: '!hide',
          setting: ModerationSetting.ignore,
        ),
        const ModerationLabelPreference(
          value: '!hide',
          labelerDid: 'did:plc:alpha',
          setting: ModerationSetting.ignore,
        ),
      ]);
      final imperative = ModerationLabelDefinitions().global['!hide']!;

      expect(
        preferences.settingFor(
          _label(src: 'did:plc:alpha', val: '!hide'),
          imperative,
        ),
        ModerationSetting.hide,
      );
    });

    test('adult restriction forces hide before configured preferences', () {
      final adult = ModerationLabelDefinitions().global['sexual']!;
      final preference = const ModerationLabelPreference(
        value: 'sexual',
        labelerDid: 'did:plc:alpha',
        setting: ModerationSetting.ignore,
      );

      expect(
        _preferences(
          [preference],
          adultContentEnabled: false,
        ).settingFor(_label(src: 'did:plc:alpha', val: 'sexual'), adult),
        ModerationSetting.hide,
      );
      expect(
        _preferences([
          preference,
        ]).settingFor(_label(src: 'did:plc:alpha', val: 'sexual'), adult),
        ModerationSetting.ignore,
      );
    });

    test('adapts generated content-label preferences', () {
      final generated = [
        contentLabelPreference(
          labelerDid: null,
          label: 'global',
          visibility: 'hide',
        ).contentLabelPref!,
        contentLabelPreference(
          labelerDid: 'did:plc:alpha',
          label: 'specific',
          visibility: 'warn',
        ).contentLabelPref!,
        contentLabelPreference(
          labelerDid: 'did:plc:alpha',
          label: 'ignored',
          visibility: 'ignore',
        ).contentLabelPref!,
      ];

      final preferences = ModerationPreferences.fromContentLabelPrefs(
        generated,
        adultContentEnabled: true,
        authenticated: true,
      );

      expect(preferences.labels[0].setting, ModerationSetting.hide);
      expect(preferences.labels[0].labelerDid, isNull);
      expect(preferences.labels[1].setting, ModerationSetting.warn);
      expect(preferences.labels[1].labelerDid, 'did:plc:alpha');
      expect(preferences.labels[2].setting, ModerationSetting.ignore);
      expect(preferences.adultContentEnabled, isTrue);
      expect(preferences.authenticated, isTrue);
    });
  });
}

ModerationPreferences _preferences(
  List<ModerationLabelPreference> labels, {
  bool adultContentEnabled = true,
}) {
  return ModerationPreferences(
    labels: labels,
    adultContentEnabled: adultContentEnabled,
    authenticated: true,
  );
}

ModerationLabelDefinition _definition({
  String identifier = 'topic',
  ModerationSetting defaultSetting = ModerationSetting.warn,
}) {
  return ModerationLabelDefinition(
    identifier: identifier,
    definedBy: 'did:plc:alpha',
    severity: ModerationSeverity.none,
    blurs: ModerationBlur.none,
    defaultSetting: defaultSetting,
    configurable: true,
    flags: const {},
    locales: const [],
    behaviors: const {},
  );
}

Label _label({required String src, String val = 'topic'}) {
  return Label(
    src: src,
    uri: 'at://did:plc:subject/app.bsky.feed.post/1',
    val: val,
    cts: DateTime.utc(2026),
  );
}
