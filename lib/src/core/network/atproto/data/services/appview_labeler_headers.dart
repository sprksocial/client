const String atprotoAcceptLabelersHeader = 'atproto-accept-labelers';

/// Owns the labeler subscription header shared by every appview repository.
///
/// The AT Protocol header accepts at most 20 comma-separated labeler DIDs. The
/// app's required default moderation service is always kept first so it cannot
/// be displaced by user subscriptions.
class AppViewLabelerHeaders {
  AppViewLabelerHeaders({required String defaultLabelerDid})
    : _defaultLabelerDid = _normalizeDid(defaultLabelerDid),
      _labelerDids = [_normalizeDid(defaultLabelerDid)];

  static const int maxLabelers = 20;

  final String _defaultLabelerDid;
  List<String> _labelerDids;

  List<String> get labelerDids => List.unmodifiable(_labelerDids);

  void configure(Iterable<String> labelerDids) {
    final normalized = <String>{_defaultLabelerDid};
    for (final did in labelerDids) {
      final value = _normalizeDid(did);
      if (value.isNotEmpty) {
        normalized.add(value);
      }
      if (normalized.length == maxLabelers) {
        break;
      }
    }
    _labelerDids = normalized.toList(growable: false);
  }

  Map<String, String> forAppView(
    String? proxyDid, {
    Iterable<String>? labelerDids,
  }) {
    final accepted = labelerDids == null
        ? _labelerDids
        : _normalizedWithDefault(labelerDids);
    final headers = <String, String>{
      if (accepted.isNotEmpty) atprotoAcceptLabelersHeader: accepted.join(','),
    };
    if (proxyDid != null) {
      headers['atproto-proxy'] = proxyDid;
    }
    return headers;
  }

  List<String> _normalizedWithDefault(Iterable<String> labelerDids) {
    final normalized = <String>{_defaultLabelerDid};
    for (final did in labelerDids) {
      final value = _normalizeDid(did);
      if (value.isNotEmpty) {
        normalized.add(value);
      }
      if (normalized.length == maxLabelers) {
        break;
      }
    }
    return normalized.toList(growable: false);
  }

  static String _normalizeDid(String did) => did.trim().split('#').first;
}
