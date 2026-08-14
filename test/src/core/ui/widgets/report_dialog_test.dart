import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
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
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ReportDialog(
              postUri: 'at://did:plc:author/so.sprk.feed.post/example',
              postCid: 'example-cid',
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
              accountDid: 'did:plc:account',
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
  const _FakeLabelerRepository(this.services);

  final Map<String, LabelerViewDetailed> services;

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
