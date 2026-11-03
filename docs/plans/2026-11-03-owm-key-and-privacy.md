# Remove the bundled OpenWeatherMap key and narrow the privacy policy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: the project's workflow policy names the executor (`run.executor`): ga:implement-with-subagents by default, or ga:implement. Follow the policy and this plan's Checkpoints. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stop shipping a hard-coded OpenWeatherMap key, and make `privacy.md` describe only what the app collects.

**Architecture:** `ApiKeys.openWeatherMap` reads `OPENWEATHERMAP_KEY` with no fallback, so the existing
`isConfigured` check skips OpenWeatherMap when it is blank. `privacy.md` loses the sections about usage, device
information and analytics. The two tasks share no file and run side by side.

**Tech Stack:** Flutter (Dart), `flutter_test`, Android build with `--dart-define-from-file=keys.json`.

**Spec:** `docs/specs/2026-11-03-owm-key-and-privacy.md`

**Status:** complete

## Global Constraints

- New Dart code is formatted at 120 columns with typed callbacks (`decisions/code-style-120-typed`).
- No key value is ever written into a file, a test, a commit message or a report.
- Android is the only supported platform (`decisions/android-only`).

## Checkpoints

None (the fast pace).

---

### Task 1: No fallback OpenWeatherMap key

**Files:**
- Modify: `lib/config/api_keys.dart`
- Modify: `README.md`
- Test: `test/api_keys_test.dart`

**Interfaces:**
- Consumes: existing `OpenWeatherMapProvider.isConfigured` (`apiKey.isNotEmpty`) and existing `WeatherService`
  filtering of unconfigured providers.
- Produces: unchanged signature.

```dart
class ApiKeys {
  static const String openWeatherMap; // String.fromEnvironment('OPENWEATHERMAP_KEY'), no fallback
  static const String weatherApi;
  static const String tomorrowIo;
}
```

**Spec:**
- What changes §1: "`ApiKeys.openWeatherMap` becomes `String.fromEnvironment('OPENWEATHERMAP_KEY')`, like `weatherApi` and `tomorrowIo`. The literal and its comment go."
- What changes §1: "`README.md` drops "the bundled OpenWeatherMap key" from what blank values fall back to."

**Tags:** `security`

**Knowledge:** `findings/committed-openweathermap-key`: the fallback key is no longer in the code, and the old key is
rotated; `operations/environment`: a blank `OPENWEATHERMAP_KEY` skips OpenWeatherMap;
`integrations/openweathermap`: the provider is configured only when `OPENWEATHERMAP_KEY` is set.

**Acceptance:**
- Given the tests run with no `--dart-define`, when `ApiKeys.openWeatherMap` is read, then it is `''`.
- Given `ApiKeys.openWeatherMap` is `''`, when an `OpenWeatherMapProvider` is built with it, then `isConfigured` is `false`.
- Given `lib/config/api_keys.dart` after the change, when it is searched for a string literal assigned to `openWeatherMap`, then there is none (checked by reading the file, not by a test that holds the key).

- [x] **Step 1: Write the failing tests** for the first two Acceptance cases, in `test/api_keys_test.dart`

- [x] **Step 2: Run them to verify they fail**

Run: `flutter test test/api_keys_test.dart`
Expected: FAIL on the first case, because the fallback makes the key non-empty

- [x] **Step 3: Remove the fallback** in `lib/config/api_keys.dart`, and drop "the bundled OpenWeatherMap key" from the README's blank-value sentence

- [x] **Step 4: Run them to verify they pass**

Run: `flutter test test/api_keys_test.dart`
Expected: PASS

- [x] **Step 5: Commit**

```bash
git add test/api_keys_test.dart lib/config/api_keys.dart README.md
git commit -m "Remove the bundled OpenWeatherMap key, so OpenWeatherMap is skipped without OPENWEATHERMAP_KEY."
```

### Task 2: Privacy policy describes only what the app collects

**Files:**
- Modify: `privacy.md`

**Interfaces:**
- Consumes: none
- Produces: none

**Spec:**
- What changes §2: "Remove *Usage Information* and *Device Information*."
- What changes §2: "*Personal Information*: only what a user sends by email when asking for support; the app has no forms or accounts."
- What changes §2: "Under *How We Use Your Information*, remove *Personalization* and *Analytics*."
- What changes §2: "*Third-Party Services*: name AdMob and the weather services instead of "analytics, advertising, or other functionalities"."
- What changes §2: "Update *Last Updated* to 03/11/2026."
- What changes §2: "Location, Advertising, Weather Services, Home Screen Widget, Data Security, Changes and Contact stay as they are."

**Tags:** not security: edits policy text only, no code or data handling changes

**Knowledge:** `security/data-protection`: `privacy.md` names only location, the weather services and AdMob.

**Acceptance:**
- Given the reworded `privacy.md`, when it is searched for "analytics", "Usage Information", "Device Information" and "Personalization", then none is found.
- Given the reworded `privacy.md`, when its *Personal Information* section is read, then it covers only details sent by email for support.
- Given the reworded `privacy.md`, when its *Third-Party Services* section is read, then it names Google AdMob, OpenWeatherMap, WeatherAPI.com, Tomorrow.io and MET Norway.
- Given the reworded `privacy.md`, when its header is read, then it says "*Last Updated: 03/11/2026*".
- Given the reworded `privacy.md`, when the Location, Advertising, Weather Services, Home Screen Widget, Data Security, Changes and Contact sections are compared with `master`, then their text is unchanged.

- [x] **Step 1: Search `privacy.md`** for the four removed terms and note each hit

Run: `grep -n -i -E "analytics|usage information|device information|personalization" privacy.md`
Expected: hits in the sections to remove

- [x] **Step 2: Edit `privacy.md`** per the Spec lines above

- [x] **Step 3: Search again to verify** the removed terms are gone

Run: `grep -n -i -E "analytics|usage information|device information|personalization" privacy.md`
Expected: no output

- [x] **Step 4: Compare the kept sections** with `master`

Run: `git diff master -- privacy.md`
Expected: changes only in the header date, Personal Information, Usage and Device Information, How We Use, and Third-Party Services

- [x] **Step 5: Commit**

```bash
git add privacy.md
git commit -m "Narrow the privacy policy to location, the weather services and AdMob, since the app collects no analytics."
```
