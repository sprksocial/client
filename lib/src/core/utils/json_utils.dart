/// Creates a deep mutable copy of a JSON-like map structure.
///
/// Use when you need to modify a JSON map without affecting the original,
/// especially when the map contains nested maps or lists that will be modified.
Map<String, dynamic> deepCopyJson(Map<String, dynamic> source) {
  return source.map((key, value) => MapEntry(key, _deepCopyValue(value)));
}

dynamic _deepCopyValue(dynamic value) {
  if (value is Map<String, dynamic>) {
    return deepCopyJson(value);
  } else if (value is List) {
    return value.map(_deepCopyValue).toList();
  }
  return value;
}
