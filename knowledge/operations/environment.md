---
type: Runbook
title: Build-time keys and signing
description: The dart-define keys in keys.example.json, where each is read, what a blank value does, and the Android signing file.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
status: draft
---

# Build-time keys and signing

The app has no runtime `.env`. Keys and IDs are passed when building, with `--dart-define-from-file=keys.json`. The
template is `keys.example.json`. `keys.json` is ignored by `./.gitignore`. `README.md` says where to get each key.

## Variables

- `OPENWEATHERMAP_KEY`: [OpenWeatherMap](../integrations/openweathermap.md). When blank, a key written in the code
  is used ([finding](../findings/committed-openweathermap-key.md)).
- `WEATHERAPI_KEY`: [WeatherAPI.com](../integrations/weatherapi.md). When blank, the provider is skipped.
- `TOMORROW_IO_KEY`: [Tomorrow.io](../integrations/tomorrow-io.md). When blank, the provider is skipped.
- `ADMOB_APP_ID`: the AdMob app ID in the Android manifest. When blank, Google's test app ID is used.
- `ADMOB_BANNER_ID`: the banner unit. When blank, Google's test banner is used.

MET Norway needs no key.

**Signing.** Release builds sign with `android/key.properties` (alias, passwords and keystore path). When the file
is absent, they fall back to the debug keys. A comment says this is so local release builds still run. The file is
ignored by `android/.gitignore`.

## Where each is read

- `OPENWEATHERMAP_KEY`, `WEATHERAPI_KEY`, `TOMORROW_IO_KEY`: `ApiKeys` in `lib/config/api_keys.dart`, with
  `String.fromEnvironment`. They are passed to the providers in `WeatherService.withDefaultProviders`
  (`lib/services/weather_service.dart`).
- `ADMOB_BANNER_ID`: `Ads.bannerUnitId` in `lib/services/ads.dart`.
- `ADMOB_APP_ID`: `dartDefines` in `android/app/build.gradle.kts`, which decodes the defines Flutter passes to
  Gradle, into `manifestPlaceholders["admobAppId"]`. The manifest uses it in
  `android/app/src/main/AndroidManifest.xml`.
- `android/key.properties`: `keystoreProperties` in `android/app/build.gradle.kts`.

## Sources

* `keys.example.json`
* `README.md`
* `lib/config/api_keys.dart`
* `lib/services/weather_service.dart`
* `lib/services/ads.dart`
* `android/app/build.gradle.kts`
* `android/app/src/main/AndroidManifest.xml`
* `./.gitignore`
* `android/.gitignore`
