---
type: Finding
title: An OpenWeatherMap API key is committed in the code
description: lib/config/api_keys.dart falls back to a hard-coded OpenWeatherMap key, in git history since 2020, though the README says keys are kept out of git.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# An OpenWeatherMap API key is committed in the code

## Finding

`ApiKeys.openWeatherMap` in `lib/config/api_keys.dart` (line 10) uses a literal OpenWeatherMap key when
`OPENWEATHERMAP_KEY` is blank. A comment there calls it "the app's existing key", and `README.md` mentions "the
bundled OpenWeatherMap key". But the same README says API keys "are passed in at build time and kept out of git", and
for this key that isn't so. The key is in the repository's history from commit `a5be54a` (2020-08-31). If the
repository is public, so is the key.

Because of the fallback, `OpenWeatherMapProvider` is always configured, and every build without `keys.json`, debug
builds included, calls OpenWeatherMap on this key.

## Evidence

- `lib/config/api_keys.dart`, line 10: the fallback literal. The value is not copied here.
- `git log -S` on that value lists `a5be54a`, `55fd909` and `01da471`.
- `README.md`, "Building a release".

## Status

Open. The fix is decided: rotate the key, pass the new one only through `keys.json`, and remove the fallback
([decisions/rotate-openweathermap-key](../decisions/rotate-openweathermap-key.md)). Removing the literal alone
doesn't help, since the key stays in history.

## Sources

* `lib/config/api_keys.dart`
* `README.md`
* `lib/services/providers/openweathermap.dart`
