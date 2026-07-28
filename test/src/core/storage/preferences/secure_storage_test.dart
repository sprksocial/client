import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/storage/preferences/secure_storage.dart';

void main() {
  late _FakeFlutterSecureStorage secureStorage;
  late SecureStorage storage;

  setUp(() {
    secureStorage = _FakeFlutterSecureStorage();
    storage = SecureStorage(secureStorage: secureStorage);
  });

  group('round trips', () {
    test('String', () async {
      await storage.setString('key', 'value');

      expect(await storage.getString('key'), 'value');
    });

    test('int', () async {
      await storage.setInt('key', 42);

      expect(await storage.getInt('key'), 42);
    });

    test('double', () async {
      await storage.setDouble('key', 3.14);

      expect(await storage.getDouble('key'), 3.14);
    });

    test('bool', () async {
      await storage.setBool('key', true);

      expect(await storage.getBool('key'), isTrue);
    });

    test('List<String>', () async {
      await storage.setStringList('key', ['alpha', 'beta']);

      expect(await storage.getStringList('key'), ['alpha', 'beta']);
    });

    test('JSON object without deadlocking', () async {
      const value = <String, Object?>{
        'name': 'Spark',
        'count': 2,
        'enabled': true,
      };

      await storage
          .setObject('key', value)
          .timeout(const Duration(milliseconds: 250));

      expect(await storage.getObject<Map<String, dynamic>>('key'), value);
    });
  });

  group('read failures', () {
    setUp(() {
      secureStorage.readError = StateError('read failed');
    });

    test('return null for typed reads', () async {
      expect(await storage.getString('key'), isNull);
      expect(await storage.getInt('key'), isNull);
      expect(await storage.getDouble('key'), isNull);
      expect(await storage.getBool('key'), isNull);
      expect(await storage.getStringList('key'), isNull);
      expect(await storage.getObject<Object>('key'), isNull);
    });

    test('containsKey returns false', () async {
      expect(await storage.containsKey('key'), isFalse);
    });
  });

  test('malformed encoded values return null', () async {
    await storage.setString('int', 'not-an-int');
    await storage.setString('double', 'not-a-double');
    await storage.setString('list', '{"not":"a-list"}');
    await storage.setString('object', 'not-json');

    expect(await storage.getInt('int'), isNull);
    expect(await storage.getDouble('double'), isNull);
    expect(await storage.getStringList('list'), isNull);
    expect(await storage.getObject<Object>('object'), isNull);
  });

  test('setObject with null removes an existing value', () async {
    await storage.setString('key', 'value');

    await storage.setObject<Object?>('key', null);

    expect(await storage.containsKey('key'), isFalse);
  });

  test('remove deletes only the requested key', () async {
    await storage.setString('removed', 'value');
    await storage.setString('preserved', 'value');

    await storage.remove('removed');

    expect(await storage.containsKey('removed'), isFalse);
    expect(await storage.containsKey('preserved'), isTrue);
  });

  test('clear deletes all values', () async {
    await storage.setString('first', 'value');
    await storage.setString('second', 'value');

    await storage.clear();

    expect(await storage.containsKey('first'), isFalse);
    expect(await storage.containsKey('second'), isFalse);
  });
}

class _FakeFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> values = <String, String>{};
  Object? readError;

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    final error = readError;
    if (error != null) {
      throw error;
    }
    return values[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    values.remove(key);
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    values.clear();
  }
}
