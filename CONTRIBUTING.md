# Contributing to Spark Client

Thank you for your interest in contributing to Spark!

## How to Contribute

1. **Keep changes scoped** to the feature you are editing
2. **Run format, codegen (if needed), and analyze** before opening a PR
3. **Test on a real device or simulator** and add screenshots when applicable.

## Development

### Prerequisites

- Flutter SDK 3.41+
- Dart SDK matching Flutter toolchain
- Xcode (for iOS builds) and/or Android SDK

### Setup

From repository root:

```bash
touch .env
flutter pub get --enforce-lockfile # install dependencies
dart run build_runner build --delete-conflicting-outputs # generated code
flutter run
```

### Startup timings

Debug and profile builds emit `[StartupTimings]` logs and `startup.*` events in
the DevTools timeline. Each milestone is recorded once per launch, in elapsed
milliseconds from `runSparkApp`; native process/engine startup is not included.
Use a cold launch on a physical device in profile mode for comparisons:

```bash
flutter run --profile -d <device-id>
```

- `firstFrameRasterized`: Flutter has rasterized its first frame, after the
  deferred splash is released.
- `firstFeedFrame`: the selected post's UI (including moderation UI) has built a
  frame on the active feed. This does not wait for images to decode.
- `firstVideoPlaying`: an active video's playback has advanced beyond zero with
  a non-zero frame size and its thumbnail overlay has been removed. This is a
  player/framework signal, not a measurement of GPU presentation.
- Intermediate milestones cover environment/platform setup, service registration,
  auth initialization and validation, onboarding checks, settings initialization,
  and push initialization. `*Finished` means the operation completed, not that it
  succeeded; inspect error logs separately.

Feed/video milestones are absent when no post/video is reached. Compare fresh
sessions, expired sessions, and slow networks separately. Release builds disable
these diagnostics unless built with `--dart-define=SPARK_STARTUP_TIMINGS=true`.

### Before Submitting

1. Format your code:
   ```bash
   dart format .
   ```

2. Analyze for issues:
   ```bash
   flutter analyze .
   ```

3. If you changed annotations/models, regenerate code:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### Pull Request Guidelines

1. Make your changes following the codebase conventions
2. Ensure CI passes (format check, analyze, build)
4. Use conventional commit titles. e.g. "fix: remove misshapen meatballs" or
   "feat(fruit): add strawberries"

## Code Conventions

- Use `package:material_ui/material_ui.dart` for Material UI and `appLocalizationDelegates` for localization in app and test roots.
- Prefer `package:spark/...` imports; avoid deep relative imports
- Import order: Dart SDK, third-party, project; keep `part` after imports
- Use strong explicit types; avoid `dynamic`
- Use Freezed for immutable models and `@riverpod` for providers
- Naming: types `PascalCase`, members/providers `lowerCamelCase`, private
  `_name`
- Keep feature flow: external/API/storage -> repository -> provider -> widget
