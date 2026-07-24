# Testing guide

Spark follows the testing model described by the official
[Dart testing documentation](https://dart.dev/tools/testing) and
[Flutter testing overview](https://docs.flutter.dev/testing/overview): keep most
tests fast and isolated, use widget tests for observable UI behavior, and reserve
integration tests for a small number of important end-to-end flows.

## What to test

- Test public behavior and contracts, not private implementation details.
- Prioritize repositories, providers, state transitions, error recovery,
  navigation, and interactions that can regress without an analyzer error.
- Cover each meaningful branch once at the lowest useful level. Do not repeat a
  repository contract in provider and widget tests unless the higher-level test
  verifies distinct wiring or user-visible behavior.
- Prefer one parameterized or table-driven test when cases share the same setup
  and assertion shape. Keep separate tests when their failure diagnoses different
  behavior.
- Do not add tests for generated code, trivial getters, framework behavior, or
  static presentation with no Spark-owned logic.

## Suite balance

Test counts are not a coverage target. New tests should first address an
unrepresented high-risk area rather than deepen an already mature area. In
particular, the video editor suite should grow only for a new gesture, timing,
race, or media-boundary regression.

The coverage summary groups results by `core/<area>` and `features/<area>` so
large imbalances remain visible. CI requires every core auth and network
repository implementation to execute at least one line; this is a floor, not a
claim that one exercised line is sufficient.

## Test quality

- Inject clocks, delays, schedulers, clients, storage, and platform boundaries.
  Never wait on wall-clock time when a deterministic seam is possible.
- Use in-memory fakes for owned boundaries and mocks only where interaction
  verification is the behavior under test.
- Assert outputs, state, requests, and visible UI. Avoid `verify`-only tests that
  merely restate the implementation.
- Keep tests order-independent and clean up provider containers, controllers,
  subscriptions, and temporary state.
- Give tests behavioral names so a failure explains the broken contract.

## Commands

Run a targeted file while iterating, then verify the complete suite:

```sh
flutter test test/path/to/example_test.dart
flutter test --test-randomize-ordering-seed=random
flutter test --coverage
dart run tool/coverage_summary.dart coverage/lcov.info --enforce-critical
```

The app integration smoke test lives under `integration_test/` and must keep its
storage and external-service boundaries isolated from real user data.
