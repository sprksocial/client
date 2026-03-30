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

String buildSparkShareUrl(String postUri) {
  final normalizedPostUri = normalizeSparkPostUri(postUri);

  return Uri.https(_sparkShareHost, '/watch', {
    'uri': normalizedPostUri,
  }).toString();
}

String? extractSparkPostUri(String url) {
  try {
    final uri = Uri.parse(url);
    final postUri = uri.queryParameters['uri'];
    final isSparkHost = uri.host == _sparkShareHost && uri.path == '/watch';
    final isLegacySparkHost = uri.host == _legacySparkShareHost;

    if ((isSparkHost || isLegacySparkHost) &&
        postUri != null &&
        postUri.isNotEmpty) {
      return normalizeSparkPostUri(postUri);
    }
  } catch (_) {
    // Ignore malformed URLs.
  }

  return null;
}
