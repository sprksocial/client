# AGENTS.md

## Project at a glance
- Root Flutter app: `spark`
- Workspace members: `widgetbook`, `fonts`, `assets`
- Stack: feature-first + Riverpod + GetIt + Freezed + AutoRoute
- Generated files in use: `*.g.dart`, `*.freezed.dart`, `*.gr.dart`

## Setup
1. Use Flutter `3.41.3` (stable, CI-aligned)
2. Ensure `.env` exists: `touch .env`
3. Install deps: `flutter pub get --enforce-lockfile`

## Common commands (repo root)
- Deps: `flutter pub get --enforce-lockfile`
- Codegen: `dart run build_runner build --delete-conflicting-outputs`
- Format: `dart format .`
- Format check: `dart format --set-exit-if-changed .`
- Analyze all: `flutter analyze .`
- Run app: `flutter run`

## Code conventions
- Prefer `package:spark/...` imports; avoid deep cross-feature relative imports
- Import order: Dart SDK, third-party, project; keep `part` after imports
- Use strong explicit types; avoid `dynamic` unless required at boundaries
- Use Freezed for immutable models and `@riverpod` for providers
- Model async state consistently with `AsyncValue`
- Naming: types `PascalCase`, members/providers `lowerCamelCase`, private `_name`
- Keep feature flow: external/API/storage -> repository -> provider -> widget
- Use GetIt (`GetIt.I` / `sl`) for DI-managed services
- Never hand-edit generated files; regenerate instead

## Reliability and logging
- Wrap fallible async work in `try/catch`
- After `await`: check `mounted` in widgets, `ref.mounted` in providers
- Prefer graceful failures over crashes (`AsyncValue.error`, typed/null fallback)
- Use `LogService` / `SparkLogger`, not `print`
- Log context + stack traces; use proper levels (`d`, `i`, `w`, `e`, `f`)

## Agent workflow
1. Read nearby feature files for local patterns
2. Edit source files; run codegen when annotations/models change
3. Format touched code (`dart format .`)
4. Analyze (`flutter analyze lib`, or `flutter analyze .` for wider impact)
5. Run targeted tests first, then broader tests
6. Keep comments minimal and only when needed

## References
- `analysis_options.yaml`
- `lib/src/features/README.md`
- `lib/src/core/utils/logging/README.md`
- `.github/workflows/flutter_lint.yml`
- `.github/workflows/flutter-test.yml`
- `.github/workflows/android.yml`

## Safety
- Never commit secrets (`.env`, platform credentials)
- Do not revert unrelated local changes
- Keep diffs scoped to the feature/task
