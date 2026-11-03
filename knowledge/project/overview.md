---
type: Project Overview
title: Beautiful Weather, an animated weather app built with Flutter
description: Shows the current weather and a 48-hour and multi-day forecast for your location or a city, with an Android home-screen widget.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# Beautiful Weather, an animated weather app built with Flutter

## Purpose

Beautiful Weather shows the weather where you are, or in any city you type, with animated weather icons, accent
gradients and a light and a dark theme. One screen shows the current conditions. A forecast panel slides up with the
next 48 hours and the next days. The 48 hours is the span the forecast screen promises ("Forecast for the next 48
hours" in `lib/views/forecast/forecast.dart`); how much each provider actually returns is in
[forecast](../features/forecast.md). On Android, a home-screen widget shows the same weather and refreshes in the
background. The app is free and shows a banner ad.

The weather comes from several services ([provider failover](../domain/provider-failover.md)), so the app keeps
working when one of them fails. It has no user accounts and no backend of its own: it calls the weather services
directly from the device.

It is published on Google Play (the link is in `README.md`). The README says it was first built to learn Flutter and
Dart.

## Applications

- [The Flutter app](../apps/flutterweather.md): everything in `lib/`, with the Android project in `android/` and the
  iOS project in `ios/`.
- [The Android home-screen widget](../features/home-screen-widget.md), written in Kotlin in
  `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt` and fed by the Flutter side.
- [flare_flutter](../packages/flare_flutter.md), a patched copy of a discontinued animation library, kept in
  `packages/flare_flutter/`.

How the parts fit together is in [architecture](architecture.md); how code is written here is in
[conventions](conventions.md).

Android is the only supported platform ([decision](../decisions/android-only.md)). `ios/` is kept but not maintained.

## Open

- [An OpenWeatherMap key is committed in the code](../findings/committed-openweathermap-key.md). It is to be rotated
  and the fallback removed ([decision](../decisions/rotate-openweathermap-key.md)).
- `privacy.md` claims analytics the app doesn't collect, and is to be reworded
  ([decision](../decisions/privacy-policy-no-analytics.md)).

## Sources

* `README.md`
* `pubspec.yaml`
* `lib/main.dart`
* `lib/views/forecast/forecast.dart`
* `privacy.md`
* `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
