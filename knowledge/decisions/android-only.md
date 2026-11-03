---
type: Decision
title: Android is the only supported platform
description: The app ships on Android only; changes are built and checked for Android, and ios/ is kept but not maintained.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:30:34Z }
verified: human:panditankit1995@gmail.com
---

# Android is the only supported platform

## Context

`ios/` is a full Xcode project. But ads and the home-screen widget do nothing outside Android (`_supported` in
`lib/services/ads.dart` and `lib/services/weather_widget.dart`). `ios/Runner/Info.plist` carries Google's sample
AdMob ID, and `README.md` links only a Google Play listing. See
[questions/ios-support](../questions/ios-support.md).

## Decision

The developer decided on 2026-11-03 that Android is the only platform. The iOS app isn't released. Changes are built
and checked for Android only. `ios/` stays in the repository but isn't maintained.

## Consequences

- Plans and reviews don't need an iOS build or iOS testing.
- Android-only features (the [widget](../features/home-screen-widget.md), [AdMob](../integrations/google-admob.md))
  need no iOS counterpart.
- If iOS is wanted later, `ios/` will need its own AdMob ID, a check of every `_supported` gate, and a build check.
  That would be a new decision replacing this one.

## Sources

* `ios/Runner/Info.plist`
* `lib/services/ads.dart`
* `lib/services/weather_widget.dart`
* `README.md`
