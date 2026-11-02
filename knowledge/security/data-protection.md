---
type: Security
title: Location, keys and what leaves the device
description: The app has no accounts; its sensitive data is the user's location, the API keys built into it, and ad consent.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
status: draft
---

# Location, keys and what leaves the device

The app has no sign-in, no accounts and no backend of its own. What needs protecting is below.

## Sensitive data

- **Location.** Coordinates from `geolocator`, or a typed city name.
- **The last place viewed.** It is stored on the device as `last_query`, with coordinates when the device location
  was used ([on-device storage](../data/on-device-storage.md)).
- **API keys and AdMob IDs.** These are compiled into the app ([environment](../operations/environment.md)).
- **Ad consent and the advertising ID,** handled by Google's SDKs.

## Protections

- **Location only while the app is open.** Android asks for `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION`,
  and no background location, in `android/app/src/main/AndroidManifest.xml`. iOS has only
  `NSLocationWhenInUseUsageDescription` in `ios/Runner/Info.plist`. Permission is requested when the app needs a
  position (`Location.currentPosition`). The widget never asks for location
  ([decisions/widget-uses-last-place](../decisions/widget-uses-last-place.md)).
- **What the weather services receive.** Only the coordinates or the city name, over HTTPS (every provider builds
  `Uri.https`), plus the API key where one is needed. MET Norway also gets the app's `User-Agent`. `privacy.md`
  describes the same.
- **Keys stay out of git,** passed at build time with `--dart-define-from-file=keys.json`. `keys.json` is in
  `./.gitignore`. This doesn't hold for OpenWeatherMap: see
  [findings/committed-openweathermap-key](../findings/committed-openweathermap-key.md). Values read with
  `String.fromEnvironment` are compiled into the app, so anyone with the APK can read them. Build-time keys keep keys
  out of the repository, not away from users.
- **Ad consent.** AdMob starts only once Google's UMP consent allows ads (`Ads._startIfAllowed` in
  `lib/services/ads.dart`). The menu shows a privacy button when the user must be able to change their choice
  ([Google AdMob](../integrations/google-admob.md)).
- **Unused permissions removed.** The manifest removes the notification and foreground-service permissions that
  `workmanager` would merge in. A comment there says the app doesn't use them, and that removing them avoids Play's
  foreground-service declaration.
- **Release signing** reads `android/key.properties`, which `android/.gitignore` keeps out of the repository
  ([environment](../operations/environment.md)).

## Sources

* `android/app/src/main/AndroidManifest.xml`
* `ios/Runner/Info.plist`
* `lib/services/location.dart`
* `lib/services/ads.dart`
* `lib/config/api_keys.dart`
* `lib/services/providers/met_norway.dart`
* `./.gitignore`
* `android/.gitignore`
* `privacy.md`
* `README.md`
