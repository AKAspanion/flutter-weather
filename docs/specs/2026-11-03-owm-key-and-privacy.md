# Remove the bundled OpenWeatherMap key and narrow the privacy policy

Date: 2026-11-03. Branch: `feat/owm-key-and-privacy`.

## Why

Both changes were decided before this release and are needed before the Play upload:

- [decisions/rotate-openweathermap-key](../../knowledge/decisions/rotate-openweathermap-key.md): the key in
  `lib/config/api_keys.dart` has been in git history since 2020
  ([finding](../../knowledge/findings/committed-openweathermap-key.md)). It is rotated in the OpenWeatherMap console
  and the new key is passed only through `keys.json`.
- [decisions/privacy-policy-no-analytics](../../knowledge/decisions/privacy-policy-no-analytics.md): the app collects
  no analytics, so `privacy.md` must not say it does. Play's Data safety answers have to match the policy.

## What changes

### 1. No fallback key

- `ApiKeys.openWeatherMap` becomes `String.fromEnvironment('OPENWEATHERMAP_KEY')`, like `weatherApi` and
  `tomorrowIo`. The literal and its comment go.
- Nothing else in the code changes: `OpenWeatherMapProvider.isConfigured` is already `apiKey.isNotEmpty`, and
  `WeatherService` already drops unconfigured providers (covered by `skips providers without an API key` in
  `test/weather_service_test.dart`).
- Behaviour: a build without `OPENWEATHERMAP_KEY` skips OpenWeatherMap. Without any key, weather comes from MET Norway
  alone and city search fails, since MET Norway has no geocoder. That is the decision's accepted consequence.
- `README.md` drops "the bundled OpenWeatherMap key" from what blank values fall back to.

### 2. Privacy policy

In `privacy.md`:

- Remove *Usage Information* and *Device Information*.
- *Personal Information*: only what a user sends by email when asking for support; the app has no forms or accounts.
- Under *How We Use Your Information*, remove *Personalization* and *Analytics*.
- *Third-Party Services*: name AdMob and the weather services instead of "analytics, advertising, or other
  functionalities".
- Update *Last Updated* to 03/11/2026.
- Location, Advertising, Weather Services, Home Screen Widget, Data Security, Changes and Contact stay as they are.

### 3. Knowledge

- The finding's `## Status` becomes `Fixed …`, its title starts "Fixed:", past tense.
- `operations/environment.md`, `operations/run-locally.md`, `integrations/openweathermap.md`,
  `security/data-protection.md` and any other concept saying a blank key falls back: a blank key now means skipped,
  each with a `## History` line.
- Log the change.

## Testing

- Test first: `ApiKeys.openWeatherMap` is empty when the test runs without a define. It fails before the change
  (the fallback) and passes after.
- `flutter analyze`, smoke, and a release build with `keys.json`.

## Out of scope

- Rotating the key in the OpenWeatherMap console: the developer does that.
- Play Console Data safety answers: filled in by the developer to match the reworded policy.
- Removing the key from git history: it is rotated instead, so the old value stops working.
