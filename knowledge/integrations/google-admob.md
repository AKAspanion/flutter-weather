---
type: Integration
title: Google AdMob and consent
description: An anchored adaptive banner on Android, started only after Google UMP consent allows ads, with a privacy button where the user must be able to change their choice.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
status: draft
---

# Google AdMob and consent

## What it is used for

- **Consent first.** `Ads.initialize` in `lib/services/ads.dart` requests a UMP consent update and shows the consent
  form if one is required. MobileAds starts only when `canRequestAds` allows it (`_startIfAllowed`). It also tries
  at once, so consent given in an earlier session starts ads straight away. `Ads.initialize` is called after the
  first frame ([architecture](../project/architecture.md)).
- **Banner.** `AdBanner` in `lib/components/ad_banner.dart` loads a large anchored adaptive banner for the screen
  width once `Ads.ready` is true. Until one loads it takes no space. Then it reports its height, and `Home`, `Menu`
  and `Forecast` leave that much room at the bottom (`bottomInset`).
- **Privacy options.** When `Ads.privacyOptionsRequired` is true, the menu shows a PRIVACY button that opens Google's
  privacy options form. A comment says this is for users who must be able to revisit their consent, such as in the
  EEA.
- Android only. `_supported` is Android, and a comment says only Android has an AdMob app ID configured; the iOS SDK
  crashes without one.

## Configuration

- `ADMOB_BANNER_ID`, read in `lib/services/ads.dart`, and `ADMOB_APP_ID`, read in `android/app/build.gradle.kts`
  into the manifest's `com.google.android.gms.ads.APPLICATION_ID`. When they are blank, both fall back to Google's
  sample test IDs, which show only test ads ([environment](../operations/environment.md)).
- `ios/Runner/Info.plist` has a `GADApplicationIdentifier` set to Google's sample iOS app ID
  ([questions/ios-support](../questions/ios-support.md)).

## Failure modes

- A consent error is logged, and ads start anyway if `canRequestAds` allows it.
- A banner that fails to load is disposed, and the reserved height goes back to 0.

## Sources

* `lib/services/ads.dart`
* `lib/components/ad_banner.dart`
* `lib/views/menu/menu.dart`
* `lib/main.dart`
* `android/app/build.gradle.kts`
* `android/app/src/main/AndroidManifest.xml`
* `ios/Runner/Info.plist`
