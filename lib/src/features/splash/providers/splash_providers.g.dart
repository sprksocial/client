// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appReadyHash() => r'5f1917b1191f13f8443fc583a66e3d21936ee05c';

/// Provider that monitors if the app is ready (active feed has finished loading)
///
/// Copied from [appReady].
@ProviderFor(appReady)
final appReadyProvider = AutoDisposeProvider<bool>.internal(
  appReady,
  name: r'appReadyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appReadyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppReadyRef = AutoDisposeProviderRef<bool>;
String _$splashNotifierHash() => r'444c2a810a5272fa5790ba9ddf230c1b3b5d07c5';

/// Provider for the simple splash screen state
///
/// Copied from [SplashNotifier].
@ProviderFor(SplashNotifier)
final splashNotifierProvider =
    AutoDisposeNotifierProvider<SplashNotifier, bool>.internal(
      SplashNotifier.new,
      name: r'splashNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$splashNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SplashNotifier = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
