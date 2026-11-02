---
type: Open Question
title: Is the iOS app built and shipped?
description: An iOS project exists, but ads and the widget are Android-only and iOS carries Google's sample AdMob ID.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
status: draft
---

# Is the iOS app built and shipped?

## Question

`ios/` is a full Xcode project, and `ios/Runner/Info.plist` has a location usage string. But:

- `Ads` and `WeatherWidget` do nothing outside Android (`_supported`). A comment in `lib/services/ads.dart` says the
  iOS SDK crashes without an app ID.
- `Info.plist` sets `GADApplicationIdentifier` to Google's sample ID, and nothing feeds it from `ADMOB_APP_ID`.
- `README.md` links only a Google Play listing.

Is the iOS app released, or should changes be built and checked for Android only?

## Why it matters

It decides whether a change has to be checked on iOS, whether iOS needs its own widget and ad set-up, and whether
`ios/` is worth keeping current.

## Status

Answered: Android only; iOS isn't shipped and `ios/` isn't maintained. See [Android is the only supported platform](../decisions/android-only.md).

## Sources

* `ios/Runner/Info.plist`
* `lib/services/ads.dart`
* `lib/services/weather_widget.dart`
* `README.md`
