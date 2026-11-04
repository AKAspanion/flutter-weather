# Edge-to-edge on every Android version

Date: 2026-11-04. Branch: `feat/edge-to-edge`.

## Why

Play Console flagged release 3 (1.0.0) with two warnings:

1. **Edge-to-edge may not display for all users.** The app targets SDK 36, so Android 15 and later draw it
   edge-to-edge whether it asks or not. Older versions still stop the window at the system bars, so the app looks
   different from one phone to the next. Play asks the app to turn edge-to-edge on itself and to handle the insets.
2. **Deprecated APIs for edge-to-edge:** `LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES`, starting in `it0.j`.

The release build's R8 mapping and its dex show where the second one comes from. `it0` is an R8 outline class, and
`it0.j` sets `WindowManager.LayoutParams.layoutInDisplayCutoutMode`. Its only callers are
`com.google.android.gms.ads.internal.overlay.zzag` (the Google Mobile Ads full-screen ad overlay) and
`com.google.android.play.core.hsdp.service.HsdpShimActivity`, both inside Google's SDKs. Neither is app code.
`google_mobile_ads` is already the newest version pub resolves, and it pins `play-services-ads:25.5.0`.

Decided with the developer: **the status and navigation bars stay hidden**, as now
(`SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [])` in `lib/main.dart`).

## What changes

### 1. The window goes edge-to-edge on every version (warning 1)

`MainActivity.onCreate` calls `WindowCompat.setDecorFitsSystemWindows(window, false)` after `super.onCreate`, so
Android 10–14 lay the app out under the bars and the cutout the way Android 15+ already do.

Not `enableEdgeToEdge()`. That's an `androidx.activity.ComponentActivity` extension, and `FlutterActivity` is a plain
`Activity`. It also sets `LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES` on API 28 and 29, the flag warning 2 complains
about. The cutout mode isn't set anywhere in the app's themes, and it stays that way.

`androidx.core` becomes a direct dependency in `android/app/build.gradle.kts` rather than one that arrives only
through the Flutter embedding.

### 2. The screens keep clear of the notch and the gesture bar

Nothing reads the system insets today. The fixed offsets become the system padding plus the offset:

- The menu's top button row (`Positioned(top: 24)` in `lib/main.dart`): `24 + MediaQuery.paddingOf(context).top`,
  so it stays below a camera cutout.
- The ad banner (`Positioned(bottom: 0)`): lifted by `MediaQuery.paddingOf(context).bottom`, so it's never under the
  gesture handle. AdMob forbids placing ads where they cause accidental taps.
- The `bottomInset` given to `Menu`, `Home` and `Forecast` is `adHeight` plus that bottom padding, so the card, the
  accent picker and the forecast stop above both.

The overlays (`OverlayCard`) are centred and keep their margins, so they don't change.

### 2a. The open-menu card is centred between the button row and the accent picker

Added after the build, at the developer's request: with the row moved down, the card's fixed top (`120`) left about
40 dp above it and about 33 dp below it on the Pixel 9 Pro, and the two only matched by chance on other screens.

- The space for the card runs from the button row's bottom to the accent picker's top: the screen height, less the
  row's bottom, the picker's height without its gap, and the `bottomInset`.
- The card's scale is that space less `2 × 24`, over the screen height, clamped to `0.3`–`0.65` as before.
- The gap above and the gap below are equal: half of what the card leaves of the space. That's `24` dp when the card
  fills it, more on both sides when the `0.65` cap applies.
- The row's bottom is `SystemInsets.buttonRowTop` plus the buttons' real size, from `MenuButtons`, for the 4-button
  row. A 4-button row's buttons are never smaller than a 5-button row's, so the card can't overlap the row. Below
  `344` dp wide, where a 5-button row's buttons shrink, the gaps differ by those few dp.
- `SystemInsets.openCardTop` and its `120` go: the centred layout replaces them.

While the bars are hidden, the padding is the cutout's, or zero on a phone without one. If the user swipes the bars
in, the padding grows while they're showing and the layout moves with it. That's the standard Flutter behaviour, and
nothing else is added for it.

### 3. Warning 2 is recorded, not fixed

The app can't change code inside the ads SDK. A finding goes into the knowledge base naming the two callers, the
SDK version, and what clears it: a `google_mobile_ads` / `play-services-ads` release that drops the flag. Play shows
it as a warning, and it doesn't block a release.

## Testing

- The three offsets come from one small helper, `SystemInsets` in `lib/components/system_insets.dart`, because
  `lib/main.dart`'s state needs location and ads before it can be pumped. A widget test reads it under a `MediaQuery`
  with top and bottom padding, and checks the button row's top, the ad banner's bottom and the content's bottom inset
  each include that padding. This follows the developer's flow: test first where it fits.
- On the `Pixel_9_Pro` emulator (camera cutout, gesture navigation), a screenshot of the home screen and the open
  menu shows the button row below the cutout and nothing under the gesture handle.
- `flutter analyze`, and a release `flutter build appbundle` to confirm it still builds.

## Out of scope

- Showing the system bars (decided: they stay hidden).
- Replacing `SystemUiMode.manual`. Play didn't flag it.
- Upgrading Flutter or the ads SDK.
