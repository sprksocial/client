# AGENTS.md

## Project at a glance
- Root Flutter app: `spark`
- Workspace members: `widgetbook`, `fonts`, `assets`
- Stack: feature-first + Riverpod + GetIt + Freezed + AutoRoute
- Generated files in use: `*.g.dart`, `*.freezed.dart`, `*.gr.dart`

## Setup
1. Flutter `3.44.0` (stable, CI-aligned)
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
- Run app: `flutter run` only when no suitable Flutter process is already running

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

## Maintainability bar
- Prefer changes that remove concepts, branches, helpers, or state rather than rearranging complexity
- Keep logic in its owning layer; do not scatter feature checks through shared widgets or repositories
- Treat ad-hoc conditionals, nullable modes, casts, `dynamic`, silent fallbacks, and pass-through wrappers as design smells unless they reflect a real external boundary
- Reuse existing shared seams and canonical helpers before adding feature-local variants; for repeated UI/loading/motion behavior, check shared templates, design-system components, and Widgetbook patterns first
- Watch file and widget growth; if a change pushes a file toward 1k lines or mixes responsibilities, split a focused helper/subcomponent before adding more flow logic

## Review guidance
- Prioritize structural regressions over style nits: duplicated owners, scattered special cases, wrong-layer logic, and abstractions that only move complexity around
- Push for simpler designs that delete branches, helpers, state, or concepts instead of polishing a messy shape
- Treat unnecessary casts, nullable modes, silent fallbacks, and pass-through wrappers as review findings when they obscure the real contract
- Flag file growth, feature logic leaking into shared paths, and bespoke helpers where an existing shared seam should be reused

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
6. If you want to run the app, first check whether a Flutter process is already running; if it is, use the Dart MCP to hot reload instead of starting a new `flutter run` process
8. Keep comments minimal and only when needed
9. Only add tests for logic that actually needs verification; avoid trivial or redundant test coverage

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
