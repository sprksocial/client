import 'package:flutter_test/flutter_test.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/moderation/moderation.dart';

void main() {
  group('ModerationLabelDefinitions', () {
    test('resolves definitions by label source and value', () {
      final definitions = ModerationLabelDefinitions.fromLabelers({
        'did:plc:alpha': [_lexDefinition('topic', severity: 'alert')],
        'did:plc:beta': [_lexDefinition('topic', severity: 'inform')],
      });

      expect(
        definitions
            .lookup(_label(src: 'did:plc:alpha', val: 'topic'))
            ?.severity,
        ModerationSeverity.alert,
      );
      expect(
        definitions.lookup(_label(src: 'did:plc:beta', val: 'topic'))?.severity,
        ModerationSeverity.inform,
      );
      expect(
        definitions.lookup(_label(src: 'did:plc:other', val: 'topic')),
        isNull,
      );
    });

    test('falls back to global definitions', () {
      final definitions = ModerationLabelDefinitions();

      expect(
        definitions
            .lookup(_label(src: 'did:plc:any', val: 'sexual'))
            ?.definedBy,
        isNull,
      );
    });

    test('imperative definitions cannot be replaced by a labeler', () {
      final definitions = ModerationLabelDefinitions.fromLabelers({
        'did:plc:labeler': [
          _lexDefinition('!hide', severity: 'none', blurs: 'none'),
        ],
      });

      final result = definitions.lookup(
        _label(src: 'did:plc:labeler', val: '!hide'),
      )!;
      expect(result.definedBy, isNull);
      expect(result.configurable, isFalse);
      expect(result.noOverride, isTrue);
    });

    test(
      'imperative definitions cannot be replaced by a global definition',
      () {
        final replacement = ModerationLabelDefinition(
          identifier: '!hide',
          severity: ModerationSeverity.none,
          blurs: ModerationBlur.none,
          defaultSetting: ModerationSetting.ignore,
          configurable: true,
          flags: const {},
          locales: const [],
          behaviors: const {},
        );
        final definitions = ModerationLabelDefinitions(
          definitions: [replacement],
        );

        expect(definitions.global['!hide'], isNot(same(replacement)));
        expect(definitions.global['!hide']?.configurable, isFalse);
      },
    );

    test('includes current, legacy, and imperative global fallbacks', () {
      final values = ModerationLabelDefinitions().global.keys;

      expect(
        values,
        containsAll([
          '!hide',
          '!takedown',
          '!warn',
          '!no-promote',
          '!no-unauthenticated',
          'porn',
          'sexual',
          'nudity',
          'graphic-media',
          'gore',
          'nsfl',
          'dmca-violation',
          'doxxing',
        ]),
      );
    });

    test('uses a labeler definition before a same-valued global default', () {
      final definitions = ModerationLabelDefinitions.fromLabelers({
        'did:plc:labeler': [
          _lexDefinition('sexual', severity: 'inform', blurs: 'none'),
        ],
      });

      final result = definitions.lookup(
        _label(src: 'did:plc:labeler', val: 'sexual'),
      )!;
      expect(result.definedBy, 'did:plc:labeler');
      expect(result.severity, ModerationSeverity.inform);
      expect(result.blurs, ModerationBlur.none);
    });
  });

  group('interpretLabelValueDefinition', () {
    test('preserves metadata and derives protocol flags', () {
      final result = interpretLabelValueDefinition(
        _lexDefinition(
          'custom-adult',
          severity: 'inform',
          blurs: 'none',
          defaultSetting: 'hide',
          adultOnly: true,
          locales: const [
            LabelValueDefinitionStrings(
              lang: 'fr',
              name: 'Nom',
              description: 'Description',
            ),
          ],
        ),
        definedBy: 'did:plc:labeler',
      );

      expect(result.identifier, 'custom-adult');
      expect(result.definedBy, 'did:plc:labeler');
      expect(result.severity, ModerationSeverity.inform);
      expect(result.blurs, ModerationBlur.none);
      expect(result.defaultSetting, ModerationSetting.hide);
      expect(result.configurable, isTrue);
      expect(
        result.flags,
        containsAll([ModerationLabelFlag.adult, ModerationLabelFlag.noSelf]),
      );
      expect(result.locales.single.name, 'Nom');
    });

    test('defaults an absent or unknown setting to warn', () {
      expect(
        interpretLabelValueDefinition(
          _lexDefinition('absent'),
          definedBy: 'did:plc:labeler',
        ).defaultSetting,
        ModerationSetting.warn,
      );
      expect(
        interpretLabelValueDefinition(
          _lexDefinition('unknown', defaultSetting: 'surprise'),
          definedBy: 'did:plc:labeler',
        ).defaultSetting,
        ModerationSetting.warn,
      );
    });

    test('maps content blur behavior for each target', () {
      final result = interpretLabelValueDefinition(
        _lexDefinition('topic', severity: 'alert', blurs: 'content'),
        definedBy: 'did:plc:labeler',
      );

      expect(
        result.behaviorFor(
          ModerationTarget.account,
        )[ModerationContext.contentList],
        ModerationAction.blur,
      );
      expect(
        result.behaviorFor(
          ModerationTarget.account,
        )[ModerationContext.contentView],
        ModerationAction.alert,
      );
      expect(
        result.behaviorFor(
          ModerationTarget.profile,
        )[ModerationContext.profileView],
        ModerationAction.alert,
      );
      expect(
        result.behaviorFor(
          ModerationTarget.content,
        )[ModerationContext.contentList],
        ModerationAction.blur,
      );
    });

    test('adult content blur also blurs direct content views', () {
      final result = interpretLabelValueDefinition(
        _lexDefinition(
          'adult',
          severity: 'alert',
          blurs: 'content',
          adultOnly: true,
        ),
        definedBy: 'did:plc:labeler',
      );

      expect(
        result.behaviorFor(
          ModerationTarget.content,
        )[ModerationContext.contentView],
        ModerationAction.blur,
      );
      expect(
        result.behaviorFor(
          ModerationTarget.account,
        )[ModerationContext.contentView],
        ModerationAction.blur,
      );
    });

    test('maps media blur behavior to media, avatars, and banners', () {
      final result = interpretLabelValueDefinition(
        _lexDefinition('topic', severity: 'inform', blurs: 'media'),
        definedBy: 'did:plc:labeler',
      );

      expect(
        result.behaviorFor(
          ModerationTarget.content,
        )[ModerationContext.contentMedia],
        ModerationAction.blur,
      );
      expect(
        result.behaviorFor(
          ModerationTarget.content,
        )[ModerationContext.contentView],
        ModerationAction.blur,
      );
      expect(
        result.behaviorFor(
          ModerationTarget.account,
        )[ModerationContext.contentView],
        ModerationAction.blur,
      );
      expect(
        result.behaviorFor(ModerationTarget.profile)[ModerationContext.avatar],
        ModerationAction.blur,
      );
      expect(
        result.behaviorFor(ModerationTarget.account)[ModerationContext.banner],
        ModerationAction.blur,
      );
      expect(
        result.behaviorFor(
          ModerationTarget.profile,
        )[ModerationContext.profileList],
        ModerationAction.inform,
      );
    });

    test('maps no-blur severity to alerts or information', () {
      final alert = interpretLabelValueDefinition(
        _lexDefinition('alert', severity: 'alert', blurs: 'none'),
        definedBy: 'did:plc:labeler',
      );
      final inform = interpretLabelValueDefinition(
        _lexDefinition('inform', severity: 'inform', blurs: 'none'),
        definedBy: 'did:plc:labeler',
      );

      expect(
        alert.behaviorFor(
          ModerationTarget.content,
        )[ModerationContext.contentView],
        ModerationAction.alert,
      );
      expect(
        inform.behaviorFor(
          ModerationTarget.account,
        )[ModerationContext.profileList],
        ModerationAction.inform,
      );
    });
  });

  group('labeler-authored locale selection', () {
    final definition = ModerationLabelDefinition(
      identifier: 'topic',
      definedBy: 'did:plc:labeler',
      severity: ModerationSeverity.inform,
      blurs: ModerationBlur.none,
      defaultSetting: ModerationSetting.warn,
      configurable: true,
      flags: const {},
      locales: const [
        ModerationLabelStrings(
          lang: 'en-US',
          name: 'English',
          description: 'English description',
        ),
        ModerationLabelStrings(
          lang: 'fr',
          name: 'Français',
          description: 'Description française',
        ),
        ModerationLabelStrings(
          lang: 'pt-BR',
          name: 'Português',
          description: 'Descrição',
        ),
      ],
      behaviors: const {},
    );

    test('matches exact tags case-insensitively and accepts underscores', () {
      expect(definition.stringsFor(['EN_us'])?.name, 'English');
    });

    test('truncates regional tags using lookup fallback', () {
      expect(definition.stringsFor(['fr-CA'])?.name, 'Français');
    });

    test('matches a labeler regional variant by primary language', () {
      expect(definition.stringsFor(['pt'])?.name, 'Português');
    });

    test('honors preferred locale order', () {
      expect(definition.stringsFor(['de', 'fr'])?.name, 'Français');
    });

    test('falls back to labeler English then its first locale', () {
      expect(definition.stringsFor(['de'])?.name, 'English');

      final withoutEnglish = ModerationLabelDefinition(
        identifier: 'topic',
        severity: ModerationSeverity.none,
        blurs: ModerationBlur.none,
        defaultSetting: ModerationSetting.warn,
        configurable: true,
        flags: const {},
        locales: const [
          ModerationLabelStrings(lang: 'ja', name: '日本語', description: '説明'),
        ],
        behaviors: const {},
      );
      expect(withoutEnglish.stringsFor(['de'])?.name, '日本語');
    });

    test('returns null instead of inventing app-owned label strings', () {
      final system = ModerationLabelDefinitions().global['!hide']!;
      expect(system.stringsFor(['en']), isNull);
    });
  });
}

LabelValueDefinition _lexDefinition(
  String identifier, {
  String severity = 'none',
  String blurs = 'none',
  String? defaultSetting,
  bool? adultOnly,
  List<LabelValueDefinitionStrings> locales = const [],
}) {
  return LabelValueDefinition(
    identifier: identifier,
    severity: LabelValueDefinitionSeverity.valueOf(severity)!,
    blurs: LabelValueDefinitionBlurs.valueOf(blurs)!,
    defaultSetting: LabelValueDefinitionDefaultSetting.valueOf(defaultSetting),
    adultOnly: adultOnly,
    locales: locales,
  );
}

Label _label({required String src, required String val}) {
  return Label(
    src: src,
    uri: 'at://did:plc:subject/app.bsky.feed.post/1',
    val: val,
    cts: DateTime.utc(2026),
  );
}
