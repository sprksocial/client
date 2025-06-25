import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'logging.dart';

/// A ProviderObserver that logs provider changes
class SparkRiverpodLogger extends ProviderObserver {
  final LogService _logService;
  late final SparkLogger _logger;

  /// Constructor
  SparkRiverpodLogger({LogService? logService}) : _logService = logService ?? GetIt.instance<LogService>() {
    _logger = _logService.getLogger('Riverpod');
  }

  @override
  void didAddProvider(ProviderBase<Object?> provider, Object? value, ProviderContainer container) {
    _logger.d('${provider.name ?? provider.runtimeType} added: ${_truncateIfNeeded(value.toString())}');
  }

  @override
  void didDisposeProvider(ProviderBase<Object?> provider, ProviderContainer container) {
    _logger.d('${provider.name ?? provider.runtimeType} was disposed.');
  }

  @override
  void didUpdateProvider(ProviderBase<Object?> provider, Object? previousValue, Object? newValue, ProviderContainer container) {
    // Skip logging if previous and new values are identical
    if (previousValue == newValue) return;

    // Also skip if they have the same string representation
    if (previousValue.toString() == newValue.toString()) return;

    final diff = _generateDiff(previousValue, newValue);
    if (diff.isNotEmpty && diff != 'No changes') {
      _logger.d('${provider.name ?? provider.runtimeType} changed: $diff');
    }
  }

  /// Generates a diff showing what changed between two values
  String _generateDiff(Object? previous, Object? current) {
    // Handle null cases
    if (previous == null && current == null) return 'No changes';
    if (previous == null) return 'Added: ${_truncateIfNeeded(current.toString())}';
    if (current == null) return 'Removed: ${_truncateIfNeeded(previous.toString())}';

    // Handle Map types
    if (previous is Map && current is Map) {
      return _generateMapDiff(previous, current);
    }

    // Handle List types
    if (previous is List && current is List) {
      return _generateListDiff(previous, current);
    }

    // Handle custom objects with structured toString()
    final previousStr = previous.toString();
    final currentStr = current.toString();

    if (previousStr == currentStr) return 'No visible changes';

    // Try to parse structured objects (like ClassName(field1: value1, field2: value2))
    final structuredDiff = _tryParseStructuredObjectDiff(previousStr, currentStr);
    if (structuredDiff != null && structuredDiff.isNotEmpty) return structuredDiff;

    // For very long objects, try to show just the class name and indicate change
    if (previousStr.length > 1000 || currentStr.length > 1000) {
      final className = _extractClassName(previousStr);
      return className != null ? '$className fields changed' : 'Object changed (too large to diff)';
    }

    // Fallback to simple before → after for smaller objects
    return '${_truncateIfNeeded(previousStr)} → ${_truncateIfNeeded(currentStr)}';
  }

  /// Generates diff for Map objects
  String _generateMapDiff(Map previous, Map current) {
    final changes = <String>[];
    final allKeys = {...previous.keys, ...current.keys};

    for (final key in allKeys) {
      final prevValue = previous[key];
      final currValue = current[key];

      if (!previous.containsKey(key)) {
        changes.add('+ $key: ${_truncateIfNeeded(currValue.toString())}');
      } else if (!current.containsKey(key)) {
        changes.add('- $key: ${_truncateIfNeeded(prevValue.toString())}');
      } else if (prevValue != currValue) {
        changes.add('~ $key: ${_truncateIfNeeded(prevValue.toString())} → ${_truncateIfNeeded(currValue.toString())}');
      }
    }

    return changes.isEmpty ? 'No changes' : changes.join(', ');
  }

  /// Generates diff for List objects
  String _generateListDiff(List previous, List current) {
    final changes = <String>[];
    
    // Find added items (items in current but not in previous)
    final added = <dynamic>[];
    for (final item in current) {
      if (!previous.contains(item)) {
        added.add(item);
      }
    }
    
    // Find removed items (items in previous but not in current)
    final removed = <dynamic>[];
    for (final item in previous) {
      if (!current.contains(item)) {
        removed.add(item);
      }
    }
    
    // Add length change if different
    if (previous.length != current.length) {
      changes.add('length: ${previous.length} → ${current.length}');
    }
    
    // Add removed items
    if (removed.isNotEmpty) {
      if (removed.length <= 3) {
        changes.add('removed: [${removed.map((e) => _truncateIfNeeded(e.toString(), maxLength: 50)).join(', ')}]');
      } else {
        changes.add('removed: ${removed.length} items');
      }
    }
    
    // Add added items
    if (added.isNotEmpty) {
      if (added.length <= 3) {
        changes.add('added: [${added.map((e) => _truncateIfNeeded(e.toString(), maxLength: 50)).join(', ')}]');
      } else {
        changes.add('added: ${added.length} items');
      }
    }
    
    // If no adds/removes but lists are different, check for positional changes
    if (changes.isEmpty && previous.length == current.length) {
      for (int i = 0; i < previous.length; i++) {
        if (previous[i] != current[i]) {
          changes.add('[$i]: ${_truncateIfNeeded(previous[i].toString(), maxLength: 50)} → ${_truncateIfNeeded(current[i].toString(), maxLength: 50)}');
          if (changes.length >= 3) {
            changes.add('... and ${previous.length - i - 1} more changes');
            break;
          }
        }
      }
    }

    return changes.isEmpty ? 'No changes' : changes.join(', ');
  }

    /// Tries to parse structured objects like ClassName(field1: value1, field2: value2)
  String? _tryParseStructuredObjectDiff(String previous, String current) {
    final prevFields = _parseStructuredObject(previous);
    final currFields = _parseStructuredObject(current);
    
    if (prevFields == null || currFields == null) return null;
    
    final changes = <String>[];
    final allKeys = {...prevFields.keys, ...currFields.keys};

    for (final key in allKeys) {
      final prevValue = prevFields[key];
      final currValue = currFields[key];

      if (!prevFields.containsKey(key)) {
        changes.add('+ $key: ${_truncateIfNeeded(currValue!, maxLength: 200)}');
      } else if (!currFields.containsKey(key)) {
        changes.add('- $key: ${_truncateIfNeeded(prevValue!, maxLength: 200)}');
      } else if (prevValue != currValue) {
        // Skip logging very large nested objects - just show field name changed
        if (prevValue!.length > 500 || currValue!.length > 500) {
          changes.add('$key: <complex object changed>');
        } else {
          // Check if the field values are lists and handle them specially
          final listDiff = _tryParseFieldAsListDiff(prevValue, currValue);
          if (listDiff != null) {
            changes.add('$key: $listDiff');
          } else {
            changes.add('$key: ${_truncateIfNeeded(prevValue, maxLength: 100)} → ${_truncateIfNeeded(currValue, maxLength: 100)}');
          }
        }
      }
    }

    final result = changes.join(', ');
    return result.isEmpty ? null : result;
  }

  /// Extracts the class name from a structured object string
  String? _extractClassName(String objStr) {
    final match = RegExp(r'^([^(]+)\(').firstMatch(objStr.trim());
    return match?.group(1)?.trim();
  }

  /// Parses a structured object string like "ClassName(field1: value1, field2: value2)"
  Map<String, String>? _parseStructuredObject(String objStr) {
    // Match pattern like ClassName(...)
    final match = RegExp(r'^[^(]+\((.+)\)$').firstMatch(objStr.trim());
    if (match == null) return null;

    final content = match.group(1)!;
    final fields = <String, String>{};

    // Split by comma, but be careful about nested structures
    final parts = _splitFields(content);

    for (final part in parts) {
      final colonIndex = part.indexOf(':');
      if (colonIndex == -1) continue;

      final key = part.substring(0, colonIndex).trim();
      final value = part.substring(colonIndex + 1).trim();
      fields[key] = value;
    }

    return fields.isEmpty ? null : fields;
  }

    /// Splits field strings by comma, handling nested structures
  List<String> _splitFields(String content) {
    final parts = <String>[];
    final buffer = StringBuffer();
    int depth = 0;
    bool inString = false;
    String? currentQuote;
    
    for (int i = 0; i < content.length; i++) {
      final char = content[i];
      
      // Handle string literals
      if (!inString && (char == '"' || char == "'")) {
        inString = true;
        currentQuote = char;
      } else if (inString && char == currentQuote) {
        // Check if it's not escaped
        if (i == 0 || content[i - 1] != '\\') {
          inString = false;
          currentQuote = null;
        }
      } else if (!inString) {
        // Handle nesting
        if (char == '(' || char == '[' || char == '{') {
          depth++;
        } else if (char == ')' || char == ']' || char == '}') {
          depth--;
        } else if (char == ',' && depth == 0) {
          // Found a top-level comma separator
          final part = buffer.toString().trim();
          if (part.isNotEmpty) {
            parts.add(part);
          }
          buffer.clear();
          continue;
        }
      }
      
      buffer.write(char);
    }
    
    // Add the last part
    final lastPart = buffer.toString().trim();
    if (lastPart.isNotEmpty) {
      parts.add(lastPart);
    }
    
    return parts;
  }

  /// Tries to parse field values as lists and generate list diffs
  String? _tryParseFieldAsListDiff(String prevValue, String currValue) {
    // Check if both values look like lists [...]
    if (!prevValue.startsWith('[') || !prevValue.endsWith(']') ||
        !currValue.startsWith('[') || !currValue.endsWith(']')) {
      return null;
    }

    // Parse the list contents
    final prevList = _parseListString(prevValue);
    final currList = _parseListString(currValue);
    
    if (prevList == null || currList == null) return null;
    
    return _generateListDiff(prevList, currList);
  }

  /// Parses a list string like "[item1, item2, item3]" into a List
  List<String>? _parseListString(String listStr) {
    if (!listStr.startsWith('[') || !listStr.endsWith(']')) return null;
    
    final content = listStr.substring(1, listStr.length - 1).trim();
    if (content.isEmpty) return <String>[];
    
    // Split by comma, handling nested structures
    return _splitFields(content);
  }

  /// Truncates long strings to avoid excessive logging
  String _truncateIfNeeded(String text, {int maxLength = 700}) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}... (${text.length - maxLength} more characters)';
  }
}
