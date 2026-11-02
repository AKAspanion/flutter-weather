---
type: Conventions
title: How code is written here
description: Folder layout, naming, error handling and tests as the code shows them, the analyzer config, and where the git and check settings live.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
status: draft
---

# How code is written here

## Naming

- Files are `snake_case.dart`; classes are UpperCamelCase (`lib/services/weather_cache.dart`).
- A weather provider is `<Service>Provider` in `lib/services/providers/<service>.dart`, extending `WeatherProvider`
  (`lib/services/providers/met_norway.dart`).
- Imports use the package path `package:flutterweather/...`, never relative paths (`lib/main.dart`).
- Private helpers and state start with `_`; constants are `static const` on their class (`WeatherService.cooldown`).

## Folder layout

- Screens and their parts: `lib/views/<area>/` (`home`, `menu`, `forecast`, `weather`). Widgets shared across areas:
  `lib/components/`.
- Logic, storage and platform features: `lib/services/`, one class per file (`lib/services/weather_widget.dart`).
  Weather APIs: `lib/services/providers/`.
- Theme values: `lib/theme/`. Build-time config: `lib/config/`.
- Android-native code: `android/app/src/main/kotlin/com/example/flutterweather/`.
- Unit tests: `test/`. Dev tools that need the Flutter test harness: `tool/` (`tool/render_widget_icons_test.dart`).

## Error handling

- A provider throws `ProviderException` for a bad response, and `getJson` does it for a non-200 status
  (`lib/services/providers/weather_provider.dart`). `WeatherService` catches it and moves on.
- Platform features catch their own errors, log them with `debugPrint`, and carry on. They do nothing on platforms
  they don't support (`_supported` in `lib/services/weather_widget.dart` and `lib/services/ads.dart`).
- The UI shows failures without throwing: a snackbar or `ErrorView` (`getLocation` in `lib/main.dart`).
- Comments say why, not what. They are `///` doc comments on classes and members (`lib/services/weather_service.dart`).

## Tests

- One `<subject>_test.dart` per service under test, with fakes defined in the same file
  (`test/weather_service_test.dart`).
- Test the services against fakes. Real network calls stay out of tests.

## Lint and format

- Dart analyzer, configured by `./analysis_options.yaml`. It excludes `packages/**`, the Flare copy, and the
  platform folders.
- New and changed code: `dart format` at page width 120, set in `./analysis_options.yaml`, and callbacks typed as
  function types (`lib/views/forecast/forecast.dart`). Older views still use 80 columns and untyped callbacks. See
  [decisions/code-style-120-typed](../decisions/code-style-120-typed.md).
- Changes are built and checked for Android only ([decisions/android-only](../decisions/android-only.md)).

## Git

- Commit messages are free text: 0 of the last 60 commits are conventional, and none carries a ticket (`git.message`,
  `git.ticket`).
- Work merges into `master` through GitHub pull requests: 3 of 3 merges (`git.base`). 2 of those 3 landed squashed,
  too few to set a rule (`git.squash`).
- Branch names: 5 seen, all `claude/…` from agent sessions, not enough to set a rule (`git.branch`).

## Commands

- Lint: `checks.commands.lint`, from `./analysis_options.yaml`. Tests: `checks.commands.test`, over `test/`.
- Typecheck, lint-fix, format check and e2e are `none`: the repository has no source for them.
- Read the values with `ga.mjs workflow show`.

## History

- 2026-11-03: line width and callback typing were an open question; now 120 columns and typed callbacks. See
  [New Dart code is formatted at 120 columns with typed callbacks](../decisions/code-style-120-typed.md).

## Sources

* `./analysis_options.yaml`
* `lib/main.dart`
* `lib/services/weather_cache.dart`
* `lib/services/weather_service.dart`
* `lib/services/weather_widget.dart`
* `lib/services/ads.dart`
* `lib/services/providers/weather_provider.dart`
* `lib/services/providers/met_norway.dart`
* `test/weather_service_test.dart`
* `lib/views/forecast/forecast.dart`
* `tool/render_widget_icons_test.dart`
