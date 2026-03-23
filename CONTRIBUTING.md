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

- Prefer `package:spark/...` imports; avoid deep relative imports
- Import order: Dart SDK, third-party, project; keep `part` after imports
- Use strong explicit types; avoid `dynamic`
- Use Freezed for immutable models and `@riverpod` for providers
- Naming: types `PascalCase`, members/providers `lowerCamelCase`, private
  `_name`
- Keep feature flow: external/API/storage -> repository -> provider -> widget
