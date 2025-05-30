// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themeModeHash() => r'd9ba82ecc3c405aabfb78864588aff91f808297f';

/// Convenience provider that exposes just the ThemeMode
///
/// Copied from [themeMode].
@ProviderFor(themeMode)
final themeModeProvider = Provider<ThemeMode>.internal(
  themeMode,
  name: r'themeModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$themeModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ThemeModeRef = ProviderRef<ThemeMode>;
String _$themeHash() => r'900b9715629a92481935e4cac549f95c895d70d9';

/// Theme notifier that manages theme state
///
/// Copied from [Theme].
@ProviderFor(Theme)
final themeProvider = NotifierProvider<Theme, ThemeState>.internal(
  Theme.new,
  name: r'themeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$themeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Theme = Notifier<ThemeState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
