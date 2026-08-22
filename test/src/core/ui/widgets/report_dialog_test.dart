import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/admin/defs.dart';
import 'package:poptart_lex/com/atproto/moderation/create_report.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/labeler_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/ui/widgets/report_dialog.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I
      ..registerSingleton<LogService>(LogService())
      ..registerSingleton<SprkRepository>(
        _FakeSprkRepository(
          _FakeLabelerRepository({
            'did:plc:default': _service(
              'did:plc:default',
              'Default moderation',
              subjectTypes: const ['record'],
            ),
            'did:plc:community': _service(
              'did:plc:community',
              'Community moderation',
              subjectTypes: const ['record'],
              subjectCollections: const ['so.sprk.feed.post'],
            ),
            'did:plc:accounts': _service(
              'did:plc:accounts',
              'Accounts only',
              subjectTypes: const ['account'],
            ),
            'did:plc:bsky': _service(
              'did:plc:bsky',
              'Bluesky moderation',
              subjectTypes: const ['account'],
            ),
          }),
        ),
      );
  });

  tearDown(() async => GetIt.I.reset());

  testWidgets('offers only subscribed services compatible with the report', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ReportDialog(
              subject: UModerationCreateReportSubject.repoStrongRef(
                data: RepoStrongRef(
                  uri: AtUri('at://did:plc:author/so.sprk.feed.post/example'),
                  cid: 'example-cid',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Violence'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Animal Abuse'));
    await tester.pumpAndSettle();

    expect(find.text('Default moderation'), findsOneWidget);
    await tester.tap(find.text('Default moderation'));
    await tester.pumpAndSettle();
    expect(find.text('Community moderation'), findsOneWidget);
    expect(find.text('Accounts only'), findsNothing);
    expect(find.text('Moderation service'), findsOneWidget);
  });

  testWidgets('uses the supplied fallback service for account reports', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ReportDialog(
              subject: UModerationCreateReportSubject.repoRef(
                data: RepoRef(did: 'did:plc:account'),
              ),
              fallbackServiceDid: 'did:plc:bsky#atproto_labeler',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Violence'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Animal Abuse'));
    await tester.pumpAndSettle();

    expect(find.text('Bluesky moderation'), findsOneWidget);
    expect(find.text('Moderation service'), findsOneWidget);
  });

  testWidgets('renders service discovery failures without an uncaught error', (
    tester,
  ) async {
    await GetIt.I.unregister<SprkRepository>();
    GetIt.I.registerSingleton<SprkRepository>(
      _FakeSprkRepository(
        _FakeLabelerRepository(
          const {},
          compatibilityError: StateError('discovery failed'),
        ),
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ReportDialog(
              subject: UModerationCreateReportSubject.repoStrongRef(
                data: RepoStrongRef(
                  uri: AtUri('at://did:plc:author/so.sprk.feed.post/example'),
                  cid: 'example-cid',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Violence'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Animal Abuse'));
    await tester.pumpAndSettle();

    expect(find.text('Could not load moderation services.'), findsOneWidget);
  });

  testWidgets('does not expose submission exceptions to the user', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ReportDialog(
              subject: UModerationCreateReportSubject.repoRef(
                data: RepoRef(did: 'did:plc:account'),
              ),
              fallbackServiceDid: 'did:plc:bsky#atproto_labeler',
              onSubmit: (_, _, _, _) async {
                throw StateError('private transport detail');
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Violence'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Animal Abuse'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Submit'));
    await tester.pumpAndSettle();

    expect(find.text('An error occurred'), findsOneWidget);
    expect(find.textContaining('private transport detail'), findsNothing);
  });
}

class _FakeSprkRepository implements SprkRepository {
  _FakeSprkRepository(this.labelerRepository);

  final LabelerRepository labelerRepository;

  @override
  String get modDid => 'did:plc:default#atproto_labeler';

  @override
  String get bskyModDid => 'did:plc:bsky#atproto_labeler';

  @override
  List<String> get labelerDids => const [
    'did:plc:default',
    'did:plc:community',
    'did:plc:accounts',
  ];

  @override
  LabelerRepository get labeler => labelerRepository;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLabelerRepository implements LabelerRepository {
  const _FakeLabelerRepository(this.services, {this.compatibilityError});

  final Map<String, LabelerViewDetailed> services;
  final Object? compatibilityError;

  @override
  Future<List<CompatibleModerationService>> getCompatibleModerationServices(
    Iterable<String> dids,
    ModerationServiceQuery query,
  ) async {
    if (compatibilityError case final error?) throw error;
    final candidates = <String>{query.fallbackDid, ...dids};
    return [
      for (final did in candidates)
        if (services[did] case final service?)
          if ((service.subjectTypes == null ||
                  service.subjectTypes!.any(
                    (type) => type.toJson() == query.subjectType,
                  )) &&
              (query.subjectCollection == null ||
                  service.subjectCollections == null ||
                  service.subjectCollections!.contains(
                    query.subjectCollection,
                  )))
            CompatibleModerationService(
              did: did,
              displayName:
                  service.creator.displayName ?? service.creator.handle,
              isDefault: did == query.fallbackDid,
            ),
    ]..sort((left, right) => left.isDefault ? -1 : 1);
  }

  @override
  Future<LabelerViewDetailed> getServicesDetailed(List<String> dids) async {
    return services[dids.single] ??
        (throw StateError('Unknown service ${dids.single}'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LabelerViewDetailed _service(
  String did,
  String displayName, {
  required List<String> subjectTypes,
  List<String>? subjectCollections,
}) {
  return LabelerViewDetailed.fromJson({
    r'$type': 'so.sprk.labeler.defs#labelerViewDetailed',
    'uri': 'at://$did/so.sprk.labeler.service/self',
    'cid': 'service-cid',
    'creator': {
      r'$type': 'so.sprk.actor.defs#profileView',
      'did': did,
      'handle': '${did.split(':').last}.test',
      'displayName': displayName,
    },
    'policies': {
      r'$type': 'so.sprk.labeler.defs#labelerPolicies',
      'labelValues': <dynamic>[],
    },
    'indexedAt': '2026-08-08T12:00:00.000Z',
    'subjectTypes': subjectTypes,
    'subjectCollections': ?subjectCollections,
  });
}
