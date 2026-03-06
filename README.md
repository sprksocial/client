# Spark Client

Flutter client for Spark social. This repository contains the production mobile app,
plus workspace packages used by the app (assets, fonts, and widgetbook).

## What This Repo Contains

- `spark` app package at repo root (`pubspec.yaml`)
- Flutter workspace members:
  - `widgetbook` (component/dev preview package)
  - `fonts` (shared font package)
  - `assets` (shared assets package)

The app is organized with a feature-first structure and uses Riverpod + GetIt +
Freezed + AutoRoute.

## Tech Stack

- Flutter / Dart
- Riverpod (with code generation)
- GetIt for dependency injection
- Freezed + json_serializable for immutable models
- AutoRoute for navigation
- AT Protocol client libraries (`atproto`, `bluesky`)

## Prerequisites

- Flutter SDK (CI uses stable `3.41.3`)
- Dart SDK matching Flutter toolchain
- Xcode (for iOS builds) and/or Android SDK

## Quick Start

From repository root:

```bash
touch .env
flutter pub get --enforce-lockfile
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Common Commands

### Dependencies and codegen

```bash
flutter pub get --enforce-lockfile
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs
```

### Lint and format

```bash
flutter analyze lib
flutter analyze .
dart format .
dart format --set-exit-if-changed .
```

### Tests

No tests are currently committed, but these are the standard commands:

```bash
flutter test
flutter test test/path/to/some_test.dart
flutter test test/path/to/some_test.dart --plain-name "does something specific"
```

For `widgetbook` (run inside `widgetbook/`):

```bash
flutter test
```

### Builds

```bash
flutter build appbundle
flutter build apk
flutter build ios --no-codesign
```

## Project Layout

```text
lib/
  main.dart
  src/
    core/        # shared infrastructure (network, routing, utils, theme, etc.)
    features/    # feature modules
      <feature>/
        data/
        providers/
        ui/
widgetbook/      # widgetbook workspace package
fonts/           # local font package
assets/          # local assets package
```

## Architecture Notes

- Prefer package imports (`package:spark/...`) for app code.
- Typical flow is: external/API/storage -> repository -> provider -> widget.
- Providers are generated with `@riverpod`; immutable state is typically Freezed.
- Generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`) should not be edited manually.

## CI Overview

- Lint workflow runs codegen, then `flutter analyze`.
- Android internal release workflow runs codegen, config setup, then `flutter build appbundle`.

See:

- `.github/workflows/flutter_lint.yml`
- `.github/workflows/android-internal-release.yml`

## Contributing

1. Keep changes scoped to the feature you are editing.
2. Run format, codegen (if needed), and analyze before opening a PR.
3. Do not commit secrets (`.env`, signing keys, service credentials).

## License

MIT. See `LICENSE`.
