import 'package:atproto/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/posting/models/mention.dart';
import 'package:spark/src/features/posting/models/mention_controller.dart';
import 'package:spark/src/features/posting/ui/widgets/mention_input_field.dart';
import 'package:spark/src/features/search/providers/actor_typeahead_provider.dart';

void main() {
  final getIt = GetIt.instance;

  setUp(() async {
    await getIt.reset();
    getIt
      ..registerSingleton<LogService>(LogService())
      ..registerSingleton<ActorRepository>(_FakeActorRepository());
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets(
    'disabling the field while a mention query is active does not throw',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: _MentionInputFieldHost()),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '@spark');
      await tester.pump();

      expect(container.read(actorTypeaheadProvider).query, 'spark');

      await tester.tap(find.text('Disable'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsOneWidget);

      await tester.pump();

      expect(container.read(actorTypeaheadProvider).query, isEmpty);
    },
  );
}

class _MentionInputFieldHost extends StatefulWidget {
  const _MentionInputFieldHost();

  @override
  State<_MentionInputFieldHost> createState() => _MentionInputFieldHostState();
}

class _MentionInputFieldHostState extends State<_MentionInputFieldHost> {
  final MentionController _controller = MentionController();
  bool _enabled = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MentionInputField(
          controller: _controller,
          onMentionsChanged: _onMentionsChanged,
          hintText: 'Comment',
          enabled: _enabled,
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _enabled = false;
            });
          },
          child: const Text('Disable'),
        ),
      ],
    );
  }

  void _onMentionsChanged(List<Mention> mentions) {}
}

class _FakeActorRepository implements ActorRepository {
  @override
  Future<ProfileViewDetailed> getProfile(
    String did, {
    bool useBluesky = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<ProfileViewDetailed>> getProfiles(
    List<String> dids, {
    bool useBluesky = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isEarlySupporter(String did) async => false;

  @override
  Future<SearchActorsResponse> searchActors(
    String query, {
    String? cursor,
  }) async {
    return SearchActorsResponse(actors: const []);
  }

  @override
  Future<SearchActorsTypeaheadResponse> searchActorsTypeahead(
    String query, {
    int limit = 10,
  }) async {
    return SearchActorsTypeaheadResponse(actors: const []);
  }

  @override
  Future<void> updateProfile({
    required String displayName,
    required String description,
    Blob? avatar,
  }) async {}
}
