# AGENTS.md

## Project at a glance
- Root Flutter app: `spark`
- Workspace members: `widgetbook`, `fonts`, `assets`
- Stack: feature-first + Riverpod + GetIt + Freezed + AutoRoute
- Generated files in use: `*.g.dart`, `*.freezed.dart`, `*.gr.dart`

## Setup
1. Flutter `3.41.3` (stable, CI-aligned)
2. `touch .env` (required before `pub get`; see `.env.example` for keys)
3. `flutter pub get --enforce-lockfile`
4. `dart run build_runner build --delete-conflicting-outputs`

## Environment variables
- `.env` is loaded at startup via `flutter_dotenv`
- Typical keys: `VIDEO_SERVICE_URL`, `SPRK_APPVIEW_URL`, `MESSAGES_SERVICE_URL`, `AIP_BASE_URL`
- Never commit `.env` or platform credentials

## Common commands (repo root)
- Deps: `flutter pub get --enforce-lockfile`
- Codegen (app): `dart run build_runner build --delete-conflicting-outputs`
- Codegen (widgetbook): `cd widgetbook && dart run build_runner build --delete-conflicting-outputs`
- Format: `dart format .`
- Format check: `dart format --set-exit-if-changed .`
- Analyze app only: `flutter analyze lib`
- Analyze all (includes widgetbook): `flutter analyze .`
- Run tests: `flutter test --reporter=expanded`
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

## Localization (l10n)
- All user-facing strings must go through `intl_en.arb` (`lib/src/core/l10n/intl_en.arb`), never hardcoded in widgets
- Access: `AppLocalizations.of(context).someKey`
- Import: `package:spark/src/core/l10n/app_localizations.dart`
- Flutter regenerates l10n on build

## Reliability and logging
- Wrap fallible async work in `try/catch`
- After `await`: check `mounted` in widgets, `ref.mounted` in providers
- Prefer graceful failures over crashes (`AsyncValue.error`, typed/null fallback)
- Use `LogService` / `SparkLogger`, not `print`
- Log context + stack traces; use proper levels (`v`, `d`, `i`, `w`, `e`, `f`)

## Agent workflow
1. Read nearby feature files for local patterns
2. Edit source files; run codegen when annotations/models change
3. Format touched code (`dart format .`)
4. Analyze (`flutter analyze lib`, or `flutter analyze .` for wider impact)
5. Run targeted tests first, then broader tests (`flutter test`)
6. Keep comments minimal and only when needed
7. Only add tests for logic that actually needs verification; avoid trivial or redundant test coverage

## References
- `analysis_options.yaml` (strict-casts, strict-raw-types; excludes `**/*.g.dart`)
- `lib/src/features/README.md`
- `lib/src/core/utils/logging/README.md`
- `.github/workflows/lint.yml`
- `.github/workflows/test.yml`
- `.github/workflows/android.yml`
- `CONTRIBUTING.md`

## Safety
- Never commit secrets (`.env`, platform credentials)
- Do not revert unrelated local changes
- Keep diffs scoped to the feature/task
