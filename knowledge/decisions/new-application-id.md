---
type: Decision
title: Publish under the new application ID in.spanion.weather
description: The app is published as a new Play listing because the original signing key was lost.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# Publish under the new application ID in.spanion.weather

## Context

A Play app can only be updated with its original signing key. A comment in `android/app/build.gradle.kts` says the
key for the original listing (`spanion.flutterweather.xyz`) was lost.

## Decision

Publish as a new app with the application ID set in `defaultConfig` in `android/app/build.gradle.kts`. This was made
in commit `4be9a85` ("Publish as a new app: in.spanion.weather"). The Play link in `README.md` points to the new
listing.

## Consequences

- The Android `namespace` and the Kotlin package are still `com.example.flutterweather`, which differs from the
  application ID. So the widget is named by its full Kotlin class (`_androidName` in
  `lib/services/weather_widget.dart`).
- Users of the old listing don't get updates from this one.

## Sources

* `android/app/build.gradle.kts`
* `lib/services/weather_widget.dart`
* `README.md`
