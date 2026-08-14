import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderated_content.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/moderation/moderation_provider.dart';

void main() {
  testWidgets('conceals labeled content until the engine is available', (
    tester,
  ) async {
    final completer = Completer<ModerationEngine>();
    var taps = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          moderationEngineProvider.overrideWith((ref) => completer.future),
        ],
        child: _materialApp(
          ModeratedContent(
            labels: [_label('sexual')],
            target: ModerationTarget.content,
            context: ModerationContext.contentView,
            child: GestureDetector(
              key: const Key('pending-child'),
              onTap: () => taps += 1,
              child: const ColoredBox(
                color: Colors.pink,
                child: SizedBox.square(dimension: 100),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const Key('pending-child')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(taps, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(_engine());
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('revealed compact content passes taps to its child', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      _app(
        _engine(),
        Center(
          child: ModeratedContent(
            labels: [_label('sexual')],
            target: ModerationTarget.content,
            context: ModerationContext.contentView,
            compact: true,
            child: GestureDetector(
              key: const Key('compact-child'),
              onTap: () => taps += 1,
              child: const ColoredBox(
                color: Colors.pink,
                child: SizedBox.square(dimension: 100),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('compact-child')));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('compact content can blur inside its own frame', (tester) async {
    await tester.pumpWidget(
      _app(
        _engine(),
        Center(
          child: ModeratedContent(
            labels: [_label('sexual')],
            target: ModerationTarget.content,
            context: ModerationContext.contentView,
            compact: true,
            blurredChild: const SizedBox.square(
              key: Key('internally-blurred-child'),
              dimension: 100,
            ),
            child: const SizedBox.square(
              key: Key('clear-child'),
              dimension: 100,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('internally-blurred-child')), findsOneWidget);
    expect(find.byKey(const Key('clear-child')), findsNothing);
    expect(find.byType(ImageFiltered), findsNothing);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('internally-blurred-child')), findsNothing);
    expect(find.byKey(const Key('clear-child')), findsOneWidget);
  });

  testWidgets('concealed compact content can forward taps without revealing', (
    tester,
  ) async {
    var forwardedTaps = 0;

    await tester.pumpWidget(
      _app(
        _engine(),
        Center(
          child: ModeratedContent(
            labels: [_label('sexual')],
            target: ModerationTarget.content,
            context: ModerationContext.contentList,
            compact: true,
            onConcealedTap: () => forwardedTaps += 1,
            blurredChild: const SizedBox.square(
              key: Key('still-blurred-child'),
              dimension: 100,
            ),
            child: const SizedBox.square(
              key: Key('clear-child'),
              dimension: 100,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(forwardedTaps, 1);
    expect(find.byKey(const Key('still-blurred-child')), findsOneWidget);
    expect(find.byKey(const Key('clear-child')), findsNothing);
  });

  testWidgets('warn content is concealed, revealable, and resets by label', (
    tester,
  ) async {
    final engine = _engine();
    var labels = [_label('sexual')];

    await tester.pumpWidget(
      _app(
        engine,
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              Expanded(
                child: ModeratedContent(
                  labels: labels,
                  target: ModerationTarget.content,
                  context: ModerationContext.contentView,
                  subjectDid: 'did:plc:author',
                  child: const ColoredBox(
                    color: Colors.pink,
                    child: SizedBox.expand(),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  labels = [_label('sexual', source: 'did:plc:labeler')];
                }),
                child: const Text('change label'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Content warning'), findsOneWidget);
    expect(find.text('Sexually Suggestive'), findsOneWidget);
    expect(find.text('View content'), findsOneWidget);

    await tester.tap(find.text('View content'));
    await tester.pumpAndSettle();
    expect(find.text('View content'), findsNothing);

    await tester.tap(find.text('change label'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ModeratedContent>(find.byType(ModeratedContent))
          .labels
          .single
          .src,
      'did:plc:labeler',
    );
    final updatedUi = engine
        .evaluate(
          labels,
          target: ModerationTarget.content,
          subjectDid: 'did:plc:author',
        )
        .forContext(ModerationContext.contentView);
    expect(updatedUi.blur, isTrue);
    expect(updatedUi.noOverride, isFalse);
    expect(find.text('Content warning'), findsOneWidget);
    expect(find.text('View content'), findsOneWidget);
  });

  testWidgets('built-in label details use app-localized guidance', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _engine(),
        ModeratedContent(
          labels: [_label('gore')],
          target: ModerationTarget.content,
          context: ModerationContext.contentView,
          subjectDid: 'did:plc:author',
          child: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Why am I seeing this?'));
    await tester.pumpAndSettle();

    expect(find.text('Gore'), findsWidgets);
    expect(
      find.text('Graphic depictions of severe injury, blood, or death.'),
      findsOneWidget,
    );
  });

  testWidgets('inform content stays visible with a moderation badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _engine(
          definitions: {
            'did:plc:labeler': [
              LabelValueDefinition(
                identifier: 'context',
                severity: LabelValueDefinitionSeverity.valueOf('inform')!,
                blurs: LabelValueDefinitionBlurs.valueOf('none')!,
                defaultSetting: LabelValueDefinitionDefaultSetting.valueOf(
                  'warn',
                ),
                locales: const [],
              ),
            ],
          },
        ),
        ModeratedContent(
          labels: [_label('context', source: 'did:plc:labeler')],
          target: ModerationTarget.content,
          context: ModerationContext.contentView,
          child: const SizedBox.expand(key: Key('inform-child')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('inform-child')), findsOneWidget);
    expect(find.byType(ActionChip), findsOneWidget);
    expect(find.text('Content warning'), findsNothing);
    expect(find.text('View content'), findsNothing);
  });

  testWidgets('imperative restriction cannot be revealed', (tester) async {
    await tester.pumpWidget(
      _app(
        _engine(),
        ModeratedContent(
          labels: [_label('!hide', source: 'did:plc:labeler')],
          target: ModerationTarget.content,
          context: ModerationContext.contentView,
          subjectDid: 'did:plc:author',
          child: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('View content'), findsNothing);
    expect(find.text('This restriction cannot be overridden.'), findsOneWidget);
  });

  testWidgets('a revealed item is concealed when it becomes non-overridable', (
    tester,
  ) async {
    var engine = _engine();
    final container = ProviderContainer(
      overrides: [moderationEngineProvider.overrideWith((ref) async => engine)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _materialApp(
          ModeratedContent(
            labels: [_label('sexual')],
            target: ModerationTarget.content,
            context: ModerationContext.contentView,
            subjectDid: 'did:plc:author',
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('View content'));
    await tester.pumpAndSettle();
    expect(find.text('Content warning'), findsNothing);

    engine = _engine(adultContentEnabled: false);
    container.invalidate(moderationEngineProvider);
    await tester.pumpAndSettle();

    expect(find.text('Content warning'), findsOneWidget);
    expect(find.text('View content'), findsNothing);
    expect(find.text('This restriction cannot be overridden.'), findsOneWidget);
  });
}

Widget _app(ModerationEngine engine, Widget child) {
  return ProviderScope(
    overrides: [moderationEngineProvider.overrideWith((ref) async => engine)],
    child: _materialApp(child),
  );
}

Widget _materialApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

ModerationEngine _engine({
  bool adultContentEnabled = true,
  Map<String, Iterable<LabelValueDefinition>> definitions = const {},
}) {
  return ModerationEngine(
    definitions: ModerationLabelDefinitions.fromLabelers(definitions),
    preferences: ModerationPreferences(
      labels: const [],
      adultContentEnabled: adultContentEnabled,
      authenticated: true,
    ),
  );
}

Label _label(String value, {String source = 'did:plc:author'}) {
  return Label(
    src: source,
    uri: 'at://did:plc:author/so.sprk.feed.post/example',
    val: value,
    cts: DateTime.utc(2026, 8, 8),
  );
}
