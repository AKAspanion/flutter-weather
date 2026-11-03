---
type: Finding
title: "Fixed: An OpenWeatherMap API key was committed in the code"
description: lib/config/api_keys.dart fell back to a hard-coded OpenWeatherMap key, still in git history since 2020; the fallback was removed, but deleting the old key in the OpenWeatherMap console was left to the developer.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# Fixed: An OpenWeatherMap API key was committed in the code

## Finding

`ApiKeys.openWeatherMap` in `lib/config/api_keys.dart` used a literal OpenWeatherMap key when
`OPENWEATHERMAP_KEY` was blank. A comment there called it "the app's existing key", and `README.md` mentioned "the
bundled OpenWeatherMap key". But the same README says API keys "are passed in at build time and kept out of git", and
for this key that wasn't so. The key is in the repository's history from commit `a5be54a` (2020-08-31). If the
repository is public, so is the key.

Because of the fallback, `OpenWeatherMapProvider` was always configured, and every build without `keys.json`, debug
builds included, called OpenWeatherMap on this key.

## Evidence

- `lib/config/api_keys.dart`: held the fallback literal until commit `e616356`. The value is not copied here.
- `git log -S` on that value lists `a5be54a`, `55fd909` and `01da471`.
- `README.md`, "Building a release".

## Status

Fixed in code on 2026-11-03 (commit `e616356`): `ApiKeys.openWeatherMap` now reads only `OPENWEATHERMAP_KEY`, so
without it OpenWeatherMap is skipped ([decisions/rotate-openweathermap-key](../decisions/rotate-openweathermap-key.md)).
`test/api_keys_test.dart` checks that the default key is empty and the provider unconfigured.

Not closed outside the code: the old key still has to be deleted (rotated) in the OpenWeatherMap console, and it
remains in git history, so removing the literal alone doesn't make it safe.

## History

- 2026-11-03: was Open, with the fallback key in `lib/config/api_keys.dart`; now fixed in code, because the fallback
  was removed. See [decisions/rotate-openweathermap-key](../decisions/rotate-openweathermap-key.md).

## Sources

* `lib/config/api_keys.dart`
* `README.md`
* `lib/services/providers/openweathermap.dart`
* `test/api_keys_test.dart`
