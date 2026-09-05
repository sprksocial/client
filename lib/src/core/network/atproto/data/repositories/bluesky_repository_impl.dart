import 'package:bluesky_poptart/app/bsky/actor/get_profile.dart'
    as bsky_actor_get_profile;
import 'package:bluesky_poptart/app/bsky/actor/profile.dart';
import 'package:bluesky_poptart/app/bsky/graph/get_follows.dart'
    as bsky_graph_get_follows;
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/repo/get_record.dart'
    as repo_get_record;
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/config/app_config.dart';
import 'package:spark/src/core/network/atproto/data/repositories/bluesky_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';
import 'package:sprk_poptart/so/sprk/graph/get_follows/output.dart'
    as sprk_get_follows;

class BlueskyRepositoryImpl implements BlueskyRepository {
  BlueskyRepositoryImpl(
    this._authRepository, {
    SparkLogger? logger,
    PoptartClient Function(OAuthSession session)? oauthClient,
    PoptartClient Function(Uri appView)? anonymousClient,
  }) : _logger =
           logger ??
           GetIt.instance<LogService>().getLogger('BlueskyRepository'),
       _oauthClient = oauthClient ?? PoptartClient.fromOAuthSession,
       _anonymousClient = anonymousClient ?? _createAnonymousClient,
       _appView = Uri.parse(AppConfig.bskyAppViewUrl);

  final AuthRepository _authRepository;
  final SparkLogger _logger;
  final PoptartClient Function(OAuthSession session) _oauthClient;
  final PoptartClient Function(Uri appView) _anonymousClient;
  final Uri _appView;

  String? get _did => _authRepository.did;
  PoptartClient? get _atproto => _authRepository.atproto;

  static PoptartClient _createAnonymousClient(Uri appView) {
    return PoptartClient.anonymous(
      protocol: appView.scheme == 'http' ? Protocol.http : Protocol.https,
      service: appView.hasPort
          ? '${appView.host}:${appView.port}'
          : appView.host,
    );
  }

  @override
  Future<ActorProfileRecord?> getProfileRecord() async {
    await _authRepository.initializationComplete;

    final did = _did;
    if (did == null || did.isEmpty) return null;

    try {
      final atproto = _atproto;
      if (atproto == null) {
        _logger.w('AtProto not initialized while fetching Bluesky profile');
        return null;
      }

      final uri = AtUri.parse('at://$did/app.bsky.actor.profile/self');
      final response = await atproto.call(
        repo_get_record.comAtprotoRepoGetRecord,
        parameters: repo_get_record.RepoGetRecordInput(
          repo: uri.hostname,
          collection: uri.collection.toString(),
          rkey: uri.rkey,
        ),
      );

      return ActorProfileRecord.fromJson(response.data.value);
    } catch (error, stackTrace) {
      final message = error.toString().toLowerCase();
      if (message.contains('404') ||
          message.contains('could not locate record') ||
          message.contains('record not found')) {
        _logger.i('Bluesky profile not found', error: error);
        return null;
      }
      _logger.e(
        'Failed to fetch Bluesky profile',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<String?> getAvatarUrl() async {
    await _authRepository.initializationComplete;

    final did = _did;
    if (did == null || did.isEmpty) return null;

    try {
      final oauthSession = _atproto?.oAuthSession;
      if (oauthSession == null) {
        _logger.w('OAuth session missing while fetching Bluesky avatar URL');
        return null;
      }

      final profile = await _oauthClient(oauthSession).call(
        bsky_actor_get_profile.appBskyActorGetProfile,
        parameters: bsky_actor_get_profile.ActorGetProfileInput(actor: did),
      );
      return profile.data.avatar;
    } catch (error, stackTrace) {
      _logger.i(
        'Failed to resolve Bluesky avatar URL',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<sprk_get_follows.GraphGetFollowsOutput> getFollows({
    String? cursor,
  }) async {
    final did = _did;
    if (did == null || did.isEmpty || _atproto == null) {
      throw StateError('Not authenticated');
    }

    final response = await _anonymousClient(_appView).call(
      bsky_graph_get_follows.appBskyGraphGetFollows,
      parameters: bsky_graph_get_follows.GraphGetFollowsInput(
        actor: did,
        limit: 100,
        cursor: cursor,
      ),
    );
    final data = response.data.toJson();
    final follows = (data['follows'] as List<dynamic>)
        .map((follow) => ProfileView.fromJson(follow as Map<String, dynamic>))
        .toList();

    return sprk_get_follows.GraphGetFollowsOutput(
      subject: ProfileView.fromJson(data['subject'] as Map<String, dynamic>),
      follows: follows,
      cursor: data['cursor'] as String?,
    );
  }
}
