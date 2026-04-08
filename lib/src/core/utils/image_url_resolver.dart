final RegExp _atUriPattern = RegExp(r'^at://([^/]+)/([^/]+)/(.+)$');

String? resolveImageUrlString(String? raw, {bool isFullsize = false}) {
  final candidate = raw?.trim();
  if (candidate == null || candidate.isEmpty || candidate == 'null') {
    return null;
  }

  if (candidate.startsWith('//')) {
    return 'https:$candidate';
  }

  final parsed = Uri.tryParse(candidate);
  final scheme = parsed?.scheme.toLowerCase();
  if (scheme == 'http' || scheme == 'https') {
    return parsed.toString();
  }

  final match = _atUriPattern.firstMatch(candidate);
  if (match == null) {
    return null;
  }

  final did = match.group(1)!;
  final collection = match.group(2)!;
  final rkey = match.group(3)!;

  if (collection != 'blob') {
    return null;
  }

  final variant = isFullsize ? 'feed_fullsize' : 'feed_thumbnail';
  return 'https://cdn.bsky.app/img/$variant/plain/$did/$rkey@jpeg';
}

String? resolveImageUrlObject(Object? raw, {bool isFullsize = false}) {
  final candidate = switch (raw) {
    null => null,
    String value => value,
    Uri value => value.toString(),
    _ => raw.toString(),
  };

  return resolveImageUrlString(candidate, isFullsize: isFullsize);
}

String resolveImageUrlOrEmpty(Object? raw, {bool isFullsize = false}) {
  return resolveImageUrlObject(raw, isFullsize: isFullsize) ?? '';
}
