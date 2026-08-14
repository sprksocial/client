import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/settings/providers/preferences_provider.dart';

/// The moderation engine for the current preference snapshot.
///
/// Definitions are deliberately keyed by their labeler DID. A failed labeler
/// policy request cannot make another labeler's same-named value take over.
final moderationEngineProvider = FutureProvider<ModerationEngine>((ref) async {
  final preferences = await ref.watch(userPreferencesProvider.future);
  final repository = GetIt.I<SprkRepository>();
  final logger = GetIt.I<LogService>().getLogger('ModerationEngine');
  final labelerDids = <String>{
    repository.modDid.split('#').first,
    ...?preferences.labelers?.map((labeler) => labeler.did),
  };

  final definitions = <String, Iterable<LabelValueDefinition>>{};
  await Future.wait(
    labelerDids.map((did) async {
      try {
        final service = await repository.labeler.getServicesDetailed([did]);
        definitions[did] = service.policies.labelValueDefinitions ?? const [];
      } catch (error, stackTrace) {
        logger.w(
          'Could not load label definitions for $did',
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    }),
  );

  return ModerationEngine(
    definitions: ModerationLabelDefinitions.fromLabelers(definitions),
    preferences: ModerationPreferences.fromContentLabelPrefs(
      preferences.contentLabelPrefs ?? const [],
      adultContentEnabled: preferences.adultContentEnabled,
      authenticated: repository.authRepository.isAuthenticated,
    ),
    currentUserDid: repository.authRepository.did,
    selfLabelerDid: repository.modDid.split('#').first,
  );
});
