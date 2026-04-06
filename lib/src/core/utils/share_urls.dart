const _sparkShareHost = 'sprk.so';
const _legacySparkShareHost = 'watch.sprk.so';

String normalizeSparkPostUri(String postUri) {
  var normalizedPostUri = postUri.trim();

  if (normalizedPostUri.startsWith('at://')) {
    normalizedPostUri = normalizedPostUri.substring(5);
  }

  normalizedPostUri = normalizedPostUri.replaceAll('so.sprk.feed.post/', '');

  return normalizedPostUri;
}

String? canonicalizeSparkPostUri(String postUri) {
  final trimmedPostUri = postUri.trim();
  if (trimmedPostUri.isEmpty) {
    return null;
  }

  final canonicalMatch = _parseCanonicalSparkUri(trimmedPostUri);
  if (canonicalMatch != null) {
    return trimmedPostUri;
  }

  final shortUriMatch = RegExp(
    r'^(did:[^/]+)/([^/?#]+)$',
  ).firstMatch(normalizeSparkPostUri(trimmedPostUri));
  if (shortUriMatch == null) {
    return null;
  }

  final did = shortUriMatch.group(1)!;
  final rkey = shortUriMatch.group(2)!;
  return 'at://$did/so.sprk.feed.post/$rkey';
}

({String did, String rkey})? _parseCanonicalSparkUri(String uri) {
  final match = RegExp(
    r'^at://([^/]+)/so\.sprk\.feed\.post/([^/?#]+)$',
  ).firstMatch(uri);
  if (match == null) return null;
  return (did: match.group(1)!, rkey: match.group(2)!);
}

String buildSparkShareUrl(String postUri) {
  final normalizedPostUri = normalizeSparkPostUri(postUri);
  final parts = _parseCanonicalSparkUri(normalizedPostUri);
  if (parts == null) {
    return Uri.https(_sparkShareHost, '/watch', {
      'uri': normalizedPostUri,
    }).toString();
  }

  return Uri.https(
    _sparkShareHost,
    '/post/${parts.did}/${parts.rkey}',
  ).toString();
}

String? extractSparkPostUri(String url) {
  final canonicalPostUri = extractCanonicalSparkPostUri(url);
  if (canonicalPostUri == null) {
    return null;
  }

  return normalizeSparkPostUri(canonicalPostUri);
}

String? extractCanonicalSparkPostUri(String url) {
  try {
    final uri = Uri.parse(url);
    final isSparkHost = uri.host == _sparkShareHost;
    final isLegacySparkHost = uri.host == _legacySparkShareHost;

    if (isSparkHost || isLegacySparkHost) {
      final postPathMatch = RegExp(
        r'^/post/([^/]+)/([^/?#]+)$',
      ).firstMatch(uri.path);
      if (postPathMatch != null) {
        final identifier = postPathMatch.group(1)!;
        final rkey = postPathMatch.group(2)!;
        final did = identifier.startsWith('did:')
            ? identifier
            : 'did:plc:$identifier';
        return 'at://$did/so.sprk.feed.post/$rkey';
      }

      final postUri = uri.queryParameters['uri'];
      if ((uri.path == '/watch' || isLegacySparkHost) &&
          postUri != null &&
          postUri.isNotEmpty) {
        return canonicalizeSparkPostUri(postUri);
      }

      final shortDid = uri.queryParameters['u'];
      final rkey = uri.queryParameters['p'];
      if ((uri.path == '/watch' || isLegacySparkHost) &&
          shortDid != null &&
          shortDid.isNotEmpty &&
          rkey != null &&
          rkey.isNotEmpty) {
        final did = shortDid.startsWith('did:')
            ? shortDid
            : 'did:plc:$shortDid';
        return 'at://$did/so.sprk.feed.post/$rkey';
      }
    }
  } catch (_) {
    // Ignore malformed URLs.
  }

  return null;
}
