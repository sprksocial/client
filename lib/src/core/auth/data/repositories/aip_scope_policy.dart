import 'package:spark/src/core/config/app_config.dart';

class AipScopePolicy {
  AipScopePolicy._(this.scopes);

  factory AipScopePolicy.current() {
    final sprkAppViewDid = _buildServiceDid(
      AppConfig.appViewUrl,
      'sprk_appview',
    );
    final bskyAppViewDid = _buildServiceDid(
      AppConfig.bskyAppViewUrl,
      'bsky_appview',
    );

    return AipScopePolicy._(<String>[
      'atproto',
      'include:so.sprk.authFullApp?aud=$sprkAppViewDid',
      'include:chat.sprk.authFull?aud=${AppConfig.chatServiceDid}',
      'include:app.bsky.authViewAll?aud=$bskyAppViewDid',
      'include:app.bsky.authCreatePosts?aud=$bskyAppViewDid',
      'include:app.bsky.authDeleteContent?aud=$bskyAppViewDid',
      'blob:*/*',
      'repo:app.bsky.feed.like',
      'repo:app.bsky.feed.repost',
      'repo:app.bsky.graph.follow',
      'rpc:com.atproto.moderation.createReport?aud=*',
    ]);
  }

  final List<String> scopes;

  String get scope => scopes.join(' ');

  bool registrationScopeMatches(String? storedScope) {
    return storedScope == scope;
  }

  bool grantedScopesSatisfy(Iterable<String>? storedScopes) {
    if (storedScopes == null) {
      return false;
    }

    final grantedScopes = storedScopes.toSet();
    return scopes.every(grantedScopes.contains);
  }

  bool grantedScopeStringSatisfies(String? storedScope) {
    if (storedScope == null || storedScope.isEmpty) {
      return false;
    }

    return grantedScopesSatisfy(storedScope.split(RegExp(r'\s+')));
  }
}

String _buildServiceDid(String serviceUrl, String serviceId) {
  final uri = Uri.parse(serviceUrl);
  return 'did:web:${uri.host}#$serviceId';
}
