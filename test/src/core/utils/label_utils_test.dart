import 'package:atproto/com_atproto_label_defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/utils/label_utils.dart';

void main() {
  group('LabelUtils', () {
    group('getLabelPreferenceFromPrefs', () {
      test('maps visibility to correct blurs/severity/setting/adultOnly', () {
        final prefs = Preferences.internal(
          preferences: [],
          contentLabelPrefs: [
            ContentLabelPref(
              labelerDid: 'did:plc:labeler',
              label: 'porn',
              visibility: 'warn',
            ),
            ContentLabelPref(
              labelerDid: 'did:plc:labeler',
              label: 'gore',
              visibility: 'hide',
            ),
            ContentLabelPref(
              labelerDid: 'did:plc:labeler',
              label: 'nudity',
              visibility: 'ignore',
            ),
          ],
        );

        final warn = LabelUtils.getLabelPreferenceFromPrefs(prefs, 'porn')!;
        expect(warn.blurs, Blurs.media);
        expect(warn.severity, Severity.alert);
        expect(warn.setting, Setting.warn);
        expect(warn.adultOnly, isTrue);

        final hide = LabelUtils.getLabelPreferenceFromPrefs(prefs, 'gore')!;
        expect(hide.blurs, Blurs.content);
        expect(hide.severity, Severity.alert);
        expect(hide.setting, Setting.hide);
        expect(hide.adultOnly, isFalse);

        final ignore = LabelUtils.getLabelPreferenceFromPrefs(prefs, 'nudity')!;
        expect(ignore.blurs, Blurs.none);
        expect(ignore.severity, Severity.none);
        expect(ignore.setting, Setting.ignore);
      });

      test('returns null when label not found', () {
        final prefs = Preferences.internal(preferences: []);
        expect(
          LabelUtils.getLabelPreferenceFromPrefs(prefs, 'unknown'),
          isNull,
        );
      });

      test('returns null when contentLabelPrefs is null', () {
        final prefs = Preferences.internal(preferences: []);
        expect(LabelUtils.getLabelPreferenceFromPrefs(prefs, 'porn'), isNull);
      });
    });

    group('shouldShowWarning', () {
      test('returns true only when severity=alert and setting=warn', () {
        final warnPrefs = Preferences.internal(
          preferences: [],
          contentLabelPrefs: [
            ContentLabelPref(
              labelerDid: 'did:plc:l',
              label: 'porn',
              visibility: 'warn',
            ),
          ],
        );
        final hidePrefs = Preferences.internal(
          preferences: [],
          contentLabelPrefs: [
            ContentLabelPref(
              labelerDid: 'did:plc:l',
              label: 'porn',
              visibility: 'hide',
            ),
          ],
        );
        final noMatchPrefs = Preferences.internal(preferences: []);

        final label = Label(
          src: 'did:plc:l',
          uri: 'at://test',
          val: 'porn',
          cts: DateTime.now(),
        );

        expect(LabelUtils.shouldShowWarning(warnPrefs, [label]), isTrue);
        expect(LabelUtils.shouldShowWarning(hidePrefs, [label]), isFalse);
        expect(LabelUtils.shouldShowWarning(noMatchPrefs, [label]), isFalse);
        expect(LabelUtils.shouldShowWarning(warnPrefs, []), isFalse);
      });
    });

    group('shouldBlurContent', () {
      test('blurs on hide (content) and warn (media)', () {
        final hidePrefs = Preferences.internal(
          preferences: [],
          contentLabelPrefs: [
            ContentLabelPref(
              labelerDid: 'did:plc:l',
              label: 'porn',
              visibility: 'hide',
            ),
          ],
        );
        final warnPrefs = Preferences.internal(
          preferences: [],
          contentLabelPrefs: [
            ContentLabelPref(
              labelerDid: 'did:plc:l',
              label: 'sexual',
              visibility: 'warn',
            ),
          ],
        );
        final ignorePrefs = Preferences.internal(
          preferences: [],
          contentLabelPrefs: [
            ContentLabelPref(
              labelerDid: 'did:plc:l',
              label: 'nudity',
              visibility: 'ignore',
            ),
          ],
        );

        final label = (String val) => Label(
          src: 'did:plc:l',
          uri: 'at://test',
          val: val,
          cts: DateTime.now(),
        );

        expect(
          LabelUtils.shouldBlurContent(hidePrefs, [label('porn')]),
          isTrue,
        );
        expect(
          LabelUtils.shouldBlurContent(warnPrefs, [label('sexual')]),
          isTrue,
        );
        expect(
          LabelUtils.shouldBlurContent(ignorePrefs, [label('nudity')]),
          isFalse,
        );
      });
    });

    group('shouldHideContent', () {
      test('hides when setting=hide or adultOnly=true', () {
        final hidePrefs = Preferences.internal(
          preferences: [],
          contentLabelPrefs: [
            ContentLabelPref(
              labelerDid: 'did:plc:l',
              label: 'gore',
              visibility: 'hide',
            ),
          ],
        );
        final warnAdultPrefs = Preferences.internal(
          preferences: [],
          contentLabelPrefs: [
            ContentLabelPref(
              labelerDid: 'did:plc:l',
              label: 'porn',
              visibility: 'warn',
            ),
          ],
        );
        final warnNonAdultPrefs = Preferences.internal(
          preferences: [],
          contentLabelPrefs: [
            ContentLabelPref(
              labelerDid: 'did:plc:l',
              label: 'gore',
              visibility: 'warn',
            ),
          ],
        );

        final label = (String val) => Label(
          src: 'did:plc:l',
          uri: 'at://test',
          val: val,
          cts: DateTime.now(),
        );

        expect(
          LabelUtils.shouldHideContent(hidePrefs, [label('gore')]),
          isTrue,
        );
        expect(
          LabelUtils.shouldHideContent(warnAdultPrefs, [label('porn')]),
          isTrue,
        );
        expect(
          LabelUtils.shouldHideContent(warnNonAdultPrefs, [label('gore')]),
          isFalse,
        );
        expect(
          LabelUtils.shouldHideContent(
            Preferences.internal(preferences: []),
            [],
          ),
          isFalse,
        );
      });
    });

    group('getWarningLabels', () {
      test('returns only labels with severity=alert and setting=warn', () {
        final prefs = Preferences.internal(
          preferences: [],
          contentLabelPrefs: [
            ContentLabelPref(
              labelerDid: 'did:plc:l',
              label: 'gore',
              visibility: 'warn',
            ),
            ContentLabelPref(
              labelerDid: 'did:plc:l',
              label: 'porn',
              visibility: 'warn',
            ),
            ContentLabelPref(
              labelerDid: 'did:plc:l',
              label: 'nudity',
              visibility: 'ignore',
            ),
          ],
        );

        final labels = ['gore', 'porn', 'nudity']
            .map(
              (v) => Label(
                src: 'did:plc:l',
                uri: 'at://test',
                val: v,
                cts: DateTime.now(),
              ),
            )
            .toList();

        final result = LabelUtils.getWarningLabels(prefs, labels);
        expect(result, containsAll(['gore', 'porn']));
        expect(result, isNot(contains('nudity')));
      });
    });
  });
}
