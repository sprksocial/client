import 'package:flutter_test/flutter_test.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/moderation/moderation.dart';

void main() {
  final now = DateTime.utc(2026, 8, 8, 12);

  group('ModerationEngine lifecycle', () {
    test('ignores negated labels', () {
      final decision = _engine().evaluate(
        [_label(val: 'sexual', neg: true)],
        target: ModerationTarget.content,
        now: now,
      );

      expect(decision.causes, isEmpty);
    });

    test('ignores expired labels including the exact expiry instant', () {
      final decision = _engine().evaluate(
        [
          _label(val: 'sexual', exp: now.subtract(const Duration(seconds: 1))),
          _label(val: 'sexual', exp: now),
          _label(val: 'sexual', exp: now.add(const Duration(seconds: 1))),
        ],
        target: ModerationTarget.content,
        now: now,
      );

      expect(decision.causes, hasLength(1));
      expect(
        decision.causes.single.label.exp,
        now.add(const Duration(seconds: 1)),
      );
    });

    test('ignores unknown label values', () {
      final decision = _engine().evaluate(
        [_label(val: 'not-defined')],
        target: ModerationTarget.content,
        now: now,
      );

      expect(decision.causes, isEmpty);
    });

    test('ignores unsupported custom self-labels', () {
      final engine = _engine(
        definitions: {
          'did:plc:author': [_definition('custom')],
        },
      );

      final decision = engine.evaluate(
        [_label(src: 'did:plc:author', val: 'custom')],
        target: ModerationTarget.content,
        subjectDid: 'did:plc:author',
        now: now,
      );

      expect(decision.causes, isEmpty);
    });

    test('allows supported built-in self-labels', () {
      final decision = _engine().evaluate(
        [_label(src: 'did:plc:author', val: 'sexual')],
        target: ModerationTarget.content,
        subjectDid: 'did:plc:author',
        now: now,
      );

      expect(decision.causes.single.definition.identifier, 'sexual');
    });

    test('ignores moderation-only built-in values when self-applied', () {
      final decision = _engine().evaluate(
        [_label(src: 'did:plc:author', val: 'dmca-violation')],
        target: ModerationTarget.content,
        subjectDid: 'did:plc:author',
        now: now,
      );

      expect(decision.causes, isEmpty);
    });

    test('uses the configured labeler policy and metadata for self-labels', () {
      final engine = _engine(
        definitions: {
          'did:plc:moderator': [
            _definition(
              'nudity',
              blurs: 'media',
              locales: const [
                LabelValueDefinitionStrings(
                  lang: 'en',
                  name: 'Labeler Nudity',
                  description: 'Labeler-authored description.',
                ),
              ],
            ),
          ],
        },
        labelPreferences: const [
          ModerationLabelPreference(
            value: 'nudity',
            labelerDid: 'did:plc:moderator',
            setting: ModerationSetting.hide,
          ),
        ],
        selfLabelerDid: 'did:plc:moderator',
      );

      final decision = engine.evaluate(
        [_label(src: 'did:plc:author', val: 'nudity')],
        target: ModerationTarget.content,
        subjectDid: 'did:plc:author',
        preferredLocales: const ['en'],
        now: now,
      );

      expect(decision.causes.single.setting, ModerationSetting.hide);
      expect(decision.causes.single.definition.definedBy, 'did:plc:moderator');
      expect(decision.causes.single.strings?.name, 'Labeler Nudity');
      expect(decision.causes.single.sourceDid, 'did:plc:author');
      expect(decision.forContext(ModerationContext.contentList).filter, isTrue);
    });

    test(
      'keeps same-valued labels from different sources as distinct causes',
      () {
        final engine = _engine(
          definitions: {
            'did:plc:alpha': [_definition('topic')],
            'did:plc:beta': [_definition('topic')],
          },
        );

        final decision = engine.evaluate(
          [
            _label(src: 'did:plc:alpha', val: 'topic'),
            _label(src: 'did:plc:beta', val: 'topic'),
          ],
          target: ModerationTarget.content,
          now: now,
        );

        expect(decision.causes.map((cause) => cause.sourceDid), {
          'did:plc:alpha',
          'did:plc:beta',
        });
      },
    );
  });

  group('imperative labels', () {
    for (final value in ['!hide', '!takedown']) {
      test('$value cannot be ignored and is non-overridable', () {
        final engine = _engine(
          labelPreferences: [
            ModerationLabelPreference(
              value: value,
              labelerDid: 'did:plc:labeler',
              setting: ModerationSetting.ignore,
            ),
          ],
        );
        final decision = engine.evaluate(
          [_label(val: value)],
          target: ModerationTarget.content,
          now: now,
        );

        expect(decision.causes.single.setting, ModerationSetting.hide);
        expect(
          decision.forContext(ModerationContext.contentList).filter,
          isTrue,
        );
        expect(decision.forContext(ModerationContext.contentView).blur, isTrue);
        expect(
          decision.forContext(ModerationContext.contentView).noOverride,
          isTrue,
        );
      });
    }

    test('!no-promote excludes promotion without changing ordinary UI', () {
      final decision = _engine().evaluate(
        [_label(val: '!no-promote')],
        target: ModerationTarget.content,
        now: now,
      );

      expect(decision.excludeFromPromotion, isTrue);
      for (final context in ModerationContext.values) {
        final ui = decision.forContext(context);
        expect(ui.filter, isFalse, reason: context.name);
        expect(ui.blur, isFalse, reason: context.name);
        expect(ui.alert, isFalse, reason: context.name);
        expect(ui.inform, isFalse, reason: context.name);
      }
    });

    test('!no-unauthenticated is ignored for signed-in viewers', () {
      final decision = _engine(authenticated: true).evaluate(
        [_label(val: '!no-unauthenticated')],
        target: ModerationTarget.content,
        now: now,
      );

      expect(decision.causes, isEmpty);
    });

    test('!no-unauthenticated hides from signed-out viewers', () {
      final decision = _engine(authenticated: false).evaluate(
        [_label(val: '!no-unauthenticated')],
        target: ModerationTarget.content,
        now: now,
      );

      expect(decision.hideFromUnauthenticated, isTrue);
      expect(decision.forContext(ModerationContext.contentList).filter, isTrue);
      expect(decision.forContext(ModerationContext.contentView).blur, isTrue);
      expect(
        decision.forContext(ModerationContext.contentView).noOverride,
        isTrue,
      );
    });
  });

  group('Spark warn policy', () {
    test('non-adult media hide still conceals a direct content view', () {
      final engine = _engine(
        definitions: {
          'did:plc:labeler': [
            _definition('media-hide', blurs: 'media', defaultSetting: 'hide'),
          ],
        },
      );
      final decision = engine.evaluate(
        [_label(val: 'media-hide')],
        target: ModerationTarget.content,
        now: now,
      );

      expect(decision.forContext(ModerationContext.contentList).filter, isTrue);
      expect(decision.forContext(ModerationContext.contentView).blur, isTrue);
      expect(decision.forContext(ModerationContext.contentMedia).blur, isTrue);
    });

    test('warn adds content blur while preserving an alert', () {
      final engine = _engine(
        definitions: {
          'did:plc:labeler': [
            _definition('alert-only', severity: 'alert', blurs: 'none'),
          ],
        },
      );
      final decision = engine.evaluate(
        [_label(val: 'alert-only')],
        target: ModerationTarget.content,
        now: now,
      );

      final ui = decision.forContext(ModerationContext.contentView);
      expect(ui.blur, isTrue);
      expect(ui.alert, isTrue);
      expect(ui.inform, isFalse);
      expect(
        decision.causes.single.definition.severity,
        ModerationSeverity.alert,
      );
    });

    test('warn keeps information badge-only without explicit blur', () {
      final engine = _engine(
        definitions: {
          'did:plc:labeler': [
            _definition('info-only', severity: 'inform', blurs: 'none'),
          ],
        },
      );
      final decision = engine.evaluate(
        [_label(val: 'info-only')],
        target: ModerationTarget.content,
        now: now,
      );

      final ui = decision.forContext(ModerationContext.contentView);
      expect(ui.blur, isFalse);
      expect(ui.inform, isTrue);
      expect(ui.alert, isFalse);
      expect(decision.forContext(ModerationContext.contentList).blur, isFalse);
      expect(decision.forContext(ModerationContext.contentMedia).blur, isFalse);
      expect(
        decision.causes.single.definition.severity,
        ModerationSeverity.inform,
      );
    });

    test('inform still applies an explicit media blur', () {
      final engine = _engine(
        definitions: {
          'did:plc:labeler': [
            _definition('info-media', severity: 'inform', blurs: 'media'),
          ],
        },
      );
      final decision = engine.evaluate(
        [_label(val: 'info-media')],
        target: ModerationTarget.content,
        now: now,
      );

      expect(decision.forContext(ModerationContext.contentView).blur, isTrue);
      expect(decision.forContext(ModerationContext.contentMedia).blur, isTrue);
    });

    test('non-inform warn blurs every content context', () {
      final engine = _engine(
        definitions: {
          'did:plc:labeler': [_definition('topic')],
        },
      );
      final decision = engine.evaluate(
        [_label(val: 'topic')],
        target: ModerationTarget.content,
        now: now,
      );

      for (final context in [
        ModerationContext.contentList,
        ModerationContext.contentView,
        ModerationContext.contentMedia,
      ]) {
        expect(decision.forContext(context).blur, isTrue, reason: context.name);
      }
      expect(decision.forContext(ModerationContext.profileView).blur, isFalse);
    });

    test('non-inform warn blurs every profile context', () {
      final engine = _engine(
        definitions: {
          'did:plc:labeler': [_definition('topic')],
        },
      );
      final decision = engine.evaluate(
        [_label(val: 'topic')],
        target: ModerationTarget.profile,
        now: now,
      );

      for (final context in [
        ModerationContext.profileList,
        ModerationContext.profileView,
        ModerationContext.avatar,
        ModerationContext.banner,
        ModerationContext.displayName,
      ]) {
        expect(decision.forContext(context).blur, isTrue, reason: context.name);
      }
      expect(decision.forContext(ModerationContext.contentView).blur, isFalse);
    });

    test('non-inform warn on an account blurs every supported context', () {
      final engine = _engine(
        definitions: {
          'did:plc:labeler': [_definition('topic')],
        },
      );
      final decision = engine.evaluate(
        [_label(val: 'topic')],
        target: ModerationTarget.account,
        now: now,
      );

      for (final context in ModerationContext.values) {
        expect(decision.forContext(context).blur, isTrue, reason: context.name);
      }
    });
  });

  group('decisions and contexts', () {
    test('partitions profile-record labels from account labels', () {
      final decision = _engine().evaluateProfileLabels(
        [
          _label(
            val: 'doxxing',
            uri: 'at://did:plc:subject/app.bsky.actor.profile/self',
          ),
          _label(val: 'doxxing', uri: 'did:plc:subject'),
        ],
        subjectDid: 'did:plc:subject',
        now: now,
      );

      expect(decision.causes, hasLength(2));
      expect(
        decision.causes
            .singleWhere(
              (cause) =>
                  cause.label.uri.endsWith('/app.bsky.actor.profile/self'),
            )
            .target,
        ModerationTarget.profile,
      );
      expect(
        decision.causes
            .singleWhere((cause) => cause.label.uri == 'did:plc:subject')
            .target,
        ModerationTarget.account,
      );
    });

    test('keeps Spark profile-record labels out of account content', () {
      final decision = _engine().evaluateProfileLabels(
        [
          _label(
            val: 'doxxing',
            uri: 'at://did:plc:subject/so.sprk.actor.profile/self',
          ),
        ],
        subjectDid: 'did:plc:subject',
        now: now,
      );

      expect(decision.causes.single.target, ModerationTarget.profile);
      expect(decision.forContext(ModerationContext.profileView).blur, isTrue);
      expect(decision.forContext(ModerationContext.contentList).blur, isFalse);
    });

    test('classifies profile-record imperatives exactly once', () {
      final decision = _engine(authenticated: false).evaluateProfileLabels(
        [
          _label(
            val: '!no-unauthenticated',
            uri: 'at://did:plc:subject/app.bsky.actor.profile/self',
          ),
        ],
        subjectDid: 'did:plc:subject',
        now: now,
      );

      expect(decision.causes, hasLength(1));
      expect(decision.causes.single.target, ModerationTarget.account);
    });

    test(
      'merges account, profile, and content decisions without losing targets',
      () {
        final engine = _engine(
          definitions: {
            'did:plc:labeler': [_definition('topic')],
          },
        );
        final merged = ModerationDecision.merge([
          engine.evaluate(
            [_label(val: 'topic')],
            target: ModerationTarget.account,
            now: now,
          ),
          engine.evaluate(
            [_label(val: 'topic')],
            target: ModerationTarget.content,
            now: now,
          ),
        ]);

        expect(merged.causes.map((cause) => cause.target), [
          ModerationTarget.account,
          ModerationTarget.content,
        ]);
        expect(
          merged.forContext(ModerationContext.contentView).blurs,
          hasLength(2),
        );
      },
    );

    test('hide filters matching list contexts only', () {
      final engine = _engine(
        definitions: {
          'did:plc:labeler': [_definition('topic', defaultSetting: 'hide')],
        },
      );

      final content = engine.evaluate(
        [_label(val: 'topic')],
        target: ModerationTarget.content,
        now: now,
      );
      expect(content.forContext(ModerationContext.contentList).filter, isTrue);
      expect(content.forContext(ModerationContext.profileList).filter, isFalse);

      final profile = engine.evaluate(
        [_label(val: 'topic')],
        target: ModerationTarget.profile,
        now: now,
      );
      expect(profile.forContext(ModerationContext.profileList).filter, isFalse);
      expect(profile.forContext(ModerationContext.contentList).filter, isFalse);
    });

    test('does not filter the current user or lock away an override', () {
      final decision = _engine(currentUserDid: 'did:plc:me').evaluate(
        [_label(val: '!hide')],
        target: ModerationTarget.account,
        subjectDid: 'did:plc:me',
        now: now,
      );

      expect(decision.isSubjectCurrentUser, isTrue);
      expect(
        decision.forContext(ModerationContext.profileList).filter,
        isFalse,
      );
      expect(decision.forContext(ModerationContext.profileView).blur, isTrue);
      expect(
        decision.forContext(ModerationContext.profileView).noOverride,
        isFalse,
      );
    });

    test('adult-disabled content is forced hidden and non-overridable', () {
      final decision =
          _engine(
            adultContentEnabled: false,
            labelPreferences: const [
              ModerationLabelPreference(
                value: 'sexual',
                setting: ModerationSetting.ignore,
              ),
            ],
          ).evaluate(
            [_label(val: 'sexual')],
            target: ModerationTarget.content,
            now: now,
          );

      expect(decision.causes.single.setting, ModerationSetting.hide);
      expect(decision.causes.single.noOverride, isTrue);
      expect(decision.forContext(ModerationContext.contentList).filter, isTrue);
      expect(decision.forContext(ModerationContext.contentView).blur, isTrue);
      expect(
        decision.forContext(ModerationContext.contentView).noOverride,
        isTrue,
      );
      expect(decision.forContext(ModerationContext.contentMedia).blur, isTrue);
      expect(
        decision.forContext(ModerationContext.contentMedia).noOverride,
        isTrue,
      );
    });

    test('source-specific ignore suppresses only that source', () {
      final engine = _engine(
        definitions: {
          'did:plc:alpha': [_definition('topic')],
          'did:plc:beta': [_definition('topic')],
        },
        labelPreferences: const [
          ModerationLabelPreference(
            value: 'topic',
            labelerDid: 'did:plc:alpha',
            setting: ModerationSetting.ignore,
          ),
          ModerationLabelPreference(
            value: 'topic',
            labelerDid: 'did:plc:beta',
            setting: ModerationSetting.warn,
          ),
        ],
      );
      final decision = engine.evaluate(
        [
          _label(src: 'did:plc:alpha', val: 'topic'),
          _label(src: 'did:plc:beta', val: 'topic'),
        ],
        target: ModerationTarget.content,
        now: now,
      );

      expect(decision.causes.single.sourceDid, 'did:plc:beta');
    });

    test('selects labeler-authored cause strings for the viewer locale', () {
      final engine = _engine(
        definitions: {
          'did:plc:labeler': [
            _definition(
              'topic',
              locales: const [
                LabelValueDefinitionStrings(
                  lang: 'en',
                  name: 'English',
                  description: 'Description',
                ),
                LabelValueDefinitionStrings(
                  lang: 'es',
                  name: 'Español',
                  description: 'Descripción',
                ),
              ],
            ),
          ],
        },
      );

      final decision = engine.evaluate(
        [_label(val: 'topic')],
        target: ModerationTarget.content,
        preferredLocales: const ['es-MX'],
        now: now,
      );

      expect(decision.causes.single.strings?.name, 'Español');
    });

    test('orders non-overridable, hide, blur, and notice causes', () {
      final engine = _engine(
        definitions: {
          'did:plc:labeler': [
            _definition('hidden', defaultSetting: 'hide'),
            _definition('media', blurs: 'media'),
            _definition('notice', severity: 'alert'),
          ],
        },
      );
      final decision = engine.evaluate(
        [
          _label(val: 'notice'),
          _label(val: 'media'),
          _label(val: 'hidden'),
          _label(val: '!hide'),
        ],
        target: ModerationTarget.content,
        now: now,
      );

      expect(decision.causes.map((cause) => cause.definition.identifier), [
        '!hide',
        'hidden',
        'media',
        'notice',
      ]);
      expect(decision.causes.map((cause) => cause.priority), [1, 2, 5, 8]);
    });
  });
}

ModerationEngine _engine({
  Map<String, Iterable<LabelValueDefinition>> definitions = const {},
  List<ModerationLabelPreference> labelPreferences = const [],
  bool adultContentEnabled = true,
  bool authenticated = true,
  String? currentUserDid,
  String? selfLabelerDid,
}) {
  return ModerationEngine(
    definitions: ModerationLabelDefinitions.fromLabelers(definitions),
    preferences: ModerationPreferences(
      labels: labelPreferences,
      adultContentEnabled: adultContentEnabled,
      authenticated: authenticated,
    ),
    currentUserDid: currentUserDid,
    selfLabelerDid: selfLabelerDid,
  );
}

LabelValueDefinition _definition(
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

Label _label({
  String src = 'did:plc:labeler',
  required String val,
  String uri = 'at://did:plc:subject/app.bsky.feed.post/1',
  bool? neg,
  DateTime? exp,
}) {
  return Label(
    src: src,
    uri: uri,
    val: val,
    neg: neg,
    cts: DateTime.utc(2026),
    exp: exp,
  );
}
