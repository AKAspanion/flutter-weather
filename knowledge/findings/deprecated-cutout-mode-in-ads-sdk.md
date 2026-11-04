---
type: Finding
title: Play flags a deprecated display-cutout mode that comes from the ads SDK
description: Play's warning about LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES on release 1.0.0 comes from play-services-ads, not the app's code, and clears when that SDK drops the flag.
generated: { by: agent:after-finish, at: 2026-11-04T00:00:00Z }
---

# Play flags a deprecated display-cutout mode that comes from the ads SDK

## Finding

Play's pre-launch warning on release 3 (version 1.0.0) says the app uses the deprecated
`LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES`, starting in the R8 outline `it0.j`. It isn't the app's code. The release
R8 mapping and a dexdump of the bundle trace it to `com.google.android.gms.ads.internal.overlay.zzag` and
`com.google.android.play.core.hsdp.service.HsdpShimActivity` in `play-services-ads` 25.5.0, which `google_mobile_ads`
pulls in. That is already the newest version pub resolves. The app's own `MainActivity` avoids the flag on purpose
([the app](../apps/flutterweather.md)).

## Evidence

- `pubspec.yaml` and `pubspec.lock`: `google_mobile_ads` and its resolved version.
- `android/app/build.gradle.kts`: the app's own Android dependencies.
- The release R8 mapping and a dexdump of the bundle, which name the two classes above.

## Status

Open. It clears with an ads SDK release that drops the flag; until then the warning is expected and can be ignored.

## Sources

* `android/app/build.gradle.kts`
* `pubspec.yaml`
* `pubspec.lock`
