# Storage Utilities

This directory contains utilities for handling local storage operations in the Spark Social application.

## Components

- **LocalStorageInterface**: Abstract interface defining storage operations.
- **SharedPrefsStorage**: Implementation using SharedPreferences for non-sensitive data.
- **SecureStorage**: Implementation using FlutterSecureStorage for sensitive data.
- **StorageManager**: Provides centralized access to all storage implementations.
- **StorageKeys**: Constants for storage keys used throughout the app.
- **AppCacheManager**: Manages temporary cache files for the application.

## Usage Examples

### Basic Storage Operations

```dart
// Access the storage manager
final storageManager = StorageManager.instance;

// Store a value in preferences (non-sensitive data)
await storageManager.preferences.setString(StorageKeys.username, 'johndoe');

// Retrieve a value from preferences
final username = await storageManager.preferences.getString(StorageKeys.username);

// Store sensitive data in secure storage
await storageManager.secure.setString(StorageKeys.authToken, 'secret-token');

// Retrieve sensitive data
final token = await storageManager.secure.getString(StorageKeys.authToken);
```

### Storing Complex Objects

```dart
// Define a User class with fromJson and toJson methods
class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

// Store a user object
final user = User(id: '123', name: 'John Doe', email: 'john@example.com');
await storageManager.preferences.setObject<User>(
  StorageKeys.user, 
  user, 
  (json) => User.fromJson(json)
);

// Retrieve a user object
final retrievedUser = await storageManager.preferences.getObject<User>(
  StorageKeys.user, 
  (json) => User.fromJson(json)
);
```

### Cache Management

```dart
// Access the cache manager
final cacheManager = AppCacheManager.instance;

// Get a file (from cache if available, or download it)
final file = await cacheManager.getFile('https://example.com/image.jpg');

// Store a file in cache
final bytes = await someImage.readAsBytes();
await cacheManager.putFile('https://example.com/image.jpg', bytes);

// Get cache size
final cacheSize = await cacheManager.getCacheSize();
print('Cache size: ${cacheSize / 1024 / 1024} MB');

// Clear cache
await cacheManager.clearCache();
```
