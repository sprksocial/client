// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRepositoryHash() => r'41c9928f83d8cbdd88f590eb6a832ba065d0e1c8';

/// Repository provider for authentication operations
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$isAuthenticatedHash() => r'003f7e85bfa5ae774792659ce771b5b59ebf04f8';

/// Convenience provider for checking if the user is authenticated
///
/// Copied from [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$sessionHash() => r'4fef091de3b2c504647444b3f2a59a5325c22845';

/// Convenience provider for accessing the current session
///
/// Copied from [session].
@ProviderFor(session)
final sessionProvider = AutoDisposeProvider<Session?>.internal(
  session,
  name: r'sessionProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SessionRef = AutoDisposeProviderRef<Session?>;
String _$atprotoHash() => r'd823d2a2be4ef57f8d0b264c20936ba2531a25d6';

/// Convenience provider for accessing the ATProto client
///
/// Copied from [atproto].
@ProviderFor(atproto)
final atprotoProvider = AutoDisposeProvider<ATProto?>.internal(
  atproto,
  name: r'atprotoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$atprotoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AtprotoRef = AutoDisposeProviderRef<ATProto?>;
String _$authHash() => r'da78c1c526e473f230d50fc3985559273f3de0cb';

/// Authentication notifier for the application
/// Provides higher-level authentication operations and state management
///
/// Copied from [Auth].
@ProviderFor(Auth)
final authProvider = AutoDisposeNotifierProvider<Auth, AuthState>.internal(
  Auth.new,
  name: r'authProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Auth = AutoDisposeNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
