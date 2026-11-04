# Edge-to-Edge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: the project's workflow policy names the executor (`run.executor`): ga:implement-with-subagents by default, or ga:implement. Follow the policy and this plan's Checkpoints. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Draw the app edge-to-edge on every Android version, with the button row and the ad banner kept clear of
the camera cutout and the gesture bar, while the system bars stay hidden.

**Architecture:** `MainActivity` turns off decor fitting with `WindowCompat`, so Android 10–14 lay out like 15+.
A small `SystemInsets` helper turns `MediaQuery` padding into the three offsets `lib/main.dart` uses: the button
row's top, the ad banner's bottom, and the `bottomInset` given to `Menu`, `Home` and `Forecast`.

**Tech Stack:** Flutter / Dart; Android in Kotlin with Gradle Kotlin DSL (`android/app/build.gradle.kts`),
`androidx.core`. Android only.

**Spec:** [docs/specs/2026-11-04-edge-to-edge.md](../specs/2026-11-04-edge-to-edge.md)

## Global Constraints

- Android only ([decisions/android-only](../../knowledge/decisions/android-only.md)): no iOS work or checks.
- The status and navigation bars stay hidden: `SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [])`
  in `lib/main.dart` is not changed.
- Nothing sets `layoutInDisplayCutoutMode` or `android:windowLayoutInDisplayCutoutMode`, and nothing calls
  `enableEdgeToEdge()`.
- New and changed Dart: `dart format` at page width 120, `package:flutterweather/...` imports, `///` comments that say
  why ([knowledge/project/conventions.md](../../knowledge/project/conventions.md)).
- Tests live in `test/<subject>_test.dart`; no network.

## Checkpoints

None: the policy stops only where the developer names a stop.

---

### Task 1: Edge-to-edge window on every Android version

**Files:**
- Modify: `android/app/src/main/kotlin/com/example/flutterweather/MainActivity.kt`
- Modify: `android/app/build.gradle.kts` (the `dependencies` block)

**Interfaces:**
- Consumes: existing `MainActivity : FlutterActivity`.
- Produces: nothing other tasks use.

```kotlin
override fun onCreate(savedInstanceState: Bundle?)
```

```kotlin
implementation("androidx.core:core-ktx:1.17.0")
```

`1.17.0` is the `androidx.core` version the release bundle already resolves through the Flutter embedding
(`META-INF/androidx.core_core.version`), so declaring it changes nothing in the build.

**Spec:**
- §1: "`MainActivity.onCreate` calls `WindowCompat.setDecorFitsSystemWindows(window, false)` after `super.onCreate`, so
  Android 10–14 lay the app out under the bars and the cutout the way Android 15+ already do."
- §1: "`androidx.core` becomes a direct dependency in `android/app/build.gradle.kts` rather than one that arrives only
  through the Flutter embedding."

**Knowledge:**
- `apps/flutterweather`: `MainActivity` draws the window edge-to-edge on every Android version with
  `WindowCompat.setDecorFitsSystemWindows(window, false)`, not `enableEdgeToEdge()`.
- `findings/deprecated-cutout-mode-in-ads-sdk` (new): Play's `LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES` warning comes
  from `com.google.android.gms.ads.internal.overlay.zzag` and `com.google.android.play.core.hsdp.service.HsdpShimActivity`
  in `play-services-ads:25.5.0`, not app code; it clears with an ads SDK release that drops the flag.

**Acceptance:**
- Given `flutter build apk --debug --dart-define-from-file=keys.json` (or without the file), when it runs, then it
  succeeds.
- Given the app on the `Pixel_9_Pro` emulator, when it opens, then the home screen draws to the top and bottom edges
  of the screen with no black band above or below.
- Given the source, when it's searched for `layoutInDisplayCutoutMode`, `windowLayoutInDisplayCutoutMode` and
  `enableEdgeToEdge`, then none appear.

There's no unit test for a window flag, and the only installed system image is Android 37, which is edge-to-edge
already. The build and the emulator check are this task's proof; the behaviour on Android 10–14 isn't checked here.

- [ ] **Step 1: Add the dependency** to `android/app/build.gradle.kts`, with a comment saying why it's declared

- [ ] **Step 2: Override `onCreate`** in `MainActivity.kt` to call `WindowCompat.setDecorFitsSystemWindows(window, false)`
  after `super.onCreate`, with a `/** */` comment saying why `enableEdgeToEdge()` isn't used

- [ ] **Step 3: Build it**

Run: `flutter build apk --debug`
Expected: `Built build/app/outputs/flutter-apk/app-debug.apk`

- [ ] **Step 4: Commit**

```bash
git add android/app/src/main/kotlin/com/example/flutterweather/MainActivity.kt android/app/build.gradle.kts
git commit -m "Draw the window edge-to-edge on every Android version, not only on 15 and later."
```

### Task 2: Keep the button row and the ad clear of the cutout and the gesture bar

**Files:**
- Create: `lib/components/system_insets.dart`
- Modify: `lib/main.dart` (the `Positioned(top: 24)` button row, the `Positioned(bottom: 0)` ad banner, and the three
  `bottomInset: adHeight` arguments to `Menu`, `Home` and `Forecast`)
- Test: `test/system_insets_test.dart`

**Interfaces:**
- Consumes: existing `MediaQuery.paddingOf(BuildContext)`.
- Produces:

```dart
/// The offsets that keep the app's fixed chrome clear of the camera cutout and the gesture bar.
class SystemInsets {
  /// Gap between the screen's top inset and the menu's button row.
  static const double buttonRowGap = 24;

  /// `buttonRowGap` plus the top system padding.
  static double buttonRowTop(BuildContext context);

  /// The bottom system padding: where the ad banner's bottom edge sits.
  static double adBottom(BuildContext context);

  /// `adHeight` plus the bottom system padding: the room `Menu`, `Home` and `Forecast` leave at the bottom.
  static double contentBottom(BuildContext context, double adHeight);
}
```

**Spec:**
- §2: "The menu's top button row (`Positioned(top: 24)` in `lib/main.dart`): `24 + MediaQuery.paddingOf(context).top`,
  so it stays below a camera cutout."
- §2: "The ad banner (`Positioned(bottom: 0)`): lifted by `MediaQuery.paddingOf(context).bottom`, so it's never under the
  gesture handle."
- §2: "The `bottomInset` given to `Menu`, `Home` and `Forecast` is `adHeight` plus that bottom padding, so the card, the
  accent picker and the forecast stop above both."

**Knowledge:**
- `design-system/components`: `SystemInsets` gives the button row's top, the ad's bottom and the content's bottom
  inset from the system padding.
- `integrations/google-admob`: the banner sits above the bottom system inset, and the `bottomInset` `Menu`, `Home` and
  `Forecast` leave is the ad's height plus that inset.

**Acceptance:**
- Given `MediaQuery` padding of top `30` and bottom `20`, then `buttonRowTop` is `54`, `adBottom` is `20`, and
  `contentBottom(context, 50)` is `70`.
- Given no padding, then `buttonRowTop` is `24`, `adBottom` is `0`, and `contentBottom(context, 50)` is `50`, as today.
- Given no ad has loaded (`adHeight` `0`) and bottom padding `20`, then `contentBottom` is `20`.
- Given the app on the `Pixel_9_Pro` emulator (camera cutout, gesture navigation), when the home screen and the open
  menu are screenshotted, then the button row sits below the cutout and the ad banner and the accent picker sit above
  the gesture handle.

- [ ] **Step 1: Create `lib/components/system_insets.dart`** with the `SystemInsets` signatures above, each returning `0`,
  so the tests fail on their values rather than on a missing class

- [ ] **Step 2: Write the failing tests** for the first three Acceptance cases in `test/system_insets_test.dart`, each
  reading the helper from a `Builder` under a `MediaQuery` with the given padding

- [ ] **Step 3: Run them to verify they fail**

Run: `flutter test test/system_insets_test.dart`
Expected: FAIL on the expected offsets

- [ ] **Step 4: Implement `SystemInsets`** to the Interfaces

- [ ] **Step 5: Run them to verify they pass**

Run: `flutter test test/system_insets_test.dart`
Expected: PASS

- [ ] **Step 6: Use `SystemInsets` in `lib/main.dart`** for the button row's `top`, the ad banner's `bottom`, and the
  `bottomInset` of `Menu`, `Home` and `Forecast`

- [ ] **Step 7: Check it on the emulator**: run the app on `Pixel_9_Pro` and screenshot the home screen and the open menu
  for the last Acceptance case

- [ ] **Step 8: Commit**

```bash
git add lib/components/system_insets.dart lib/main.dart test/system_insets_test.dart
git commit -m "Keep the menu's button row below the camera cutout and the ad above the gesture bar."
```

### Task 3: Centre the open-menu card between the button row and the accent picker

Added after Tasks 1 and 2, from spec §2a. It replaces `SystemInsets.openCardTop` (commit `d014100`, the fix for the
card overlapping the row).

**Files:**
- Create: `lib/views/home/open_card_layout.dart`
- Modify: `lib/views/home/home.dart` (the `top`, `fitScale` and `factor` lines of `build`)
- Modify: `lib/views/menu/menu.dart` (`footerHeight`)
- Modify: `lib/views/menu/menu_buttons.dart` (the button-size line of `build`)
- Modify: `lib/components/system_insets.dart` (remove `openCardGap` and `openCardTop`)
- Modify: `test/system_insets_test.dart` (remove the `openCardTop` test)
- Test: `test/open_card_layout_test.dart`

**Interfaces:**
- Consumes: `SystemInsets.buttonRowTop(BuildContext)` from Task 2, and the `bottomInset` `Home` receives from Task 2.
- Produces:

```dart
/// Where the shrunken home card sits while the menu is open: centred between the button row and the accent picker.
class OpenCardLayout {
  /// The least gap kept above and below the card.
  static const double minGap = 24;

  /// The card's top edge, from the top of the screen.
  final double top;

  /// The card's scale, of the full screen height.
  final double scale;

  const OpenCardLayout({required this.top, required this.scale});

  factory OpenCardLayout.compute({
    required double screenHeight,
    required double rowBottom,
    required double pickerHeight,
    required double bottomInset,
  });
}
```

```dart
// lib/views/menu/menu.dart: the accent picker's height without the gap above it; replaces footerHeight.
static double get pickerHeight;

// lib/views/menu/menu_buttons.dart: the size of each button in a row of `count` buttons on a screen `width` wide.
static double buttonSize(double width, {required int count});
```

**Spec:**
- §2a: "The card's scale is that space less `2 × 24`, over the screen height, clamped to `0.3`–`0.65` as before."
- §2a: "The gap above and the gap below are equal: half of what the card leaves of the space. That's `24` dp when the
  card fills it, more on both sides when the `0.65` cap applies."
- §2a: "The row's bottom is `SystemInsets.buttonRowTop` plus the buttons' real size, from `MenuButtons`, for the
  4-button row."
- §2a: "`SystemInsets.openCardTop` and its `120` go: the centred layout replaces them."

**Knowledge:**
- `features/themes-and-accents`: while the menu is open, the card is centred between the button row and the accent
  picker, with equal gaps of at least `24` dp; the 24 dp gap above the picker is now `OpenCardLayout.minGap`.

**Acceptance:**
- Given a screen `952` tall, a row bottom of `132`, a picker `128` tall and a `bottomInset` of `0`, then the scale is
  `0.65` (capped) and the gap above (`top - 132`) equals the gap below (`952 - 0 - 128 - (top + 952 × 0.65)`), both
  about `36.6`.
- Given a screen `700` tall, a row bottom of `80`, a picker `128` tall and a `bottomInset` of `50`, then both gaps are
  `24` and the top is `104`.
- Given a screen `500` tall, a row bottom of `80`, a picker `128` tall and a `bottomInset` of `100`, then the scale is
  `0.3` (the floor) and the two gaps are still equal.
- Given `buttonSize(400, count: 4)` and `buttonSize(400, count: 5)`, then both are `56`; given `buttonSize(320, count: 5)`,
  then it is `(320 - 32 - 32) / 5`, `51.2`.

- [ ] **Step 1: Create `lib/views/home/open_card_layout.dart`** and `MenuButtons.buttonSize` with the signatures above,
  each returning `0`, so the tests fail on their values

- [ ] **Step 2: Write the failing tests** for the Acceptance cases in `test/open_card_layout_test.dart`

- [ ] **Step 3: Run them to verify they fail**

Run: `flutter test test/open_card_layout_test.dart`
Expected: FAIL on the expected values

- [ ] **Step 4: Implement `OpenCardLayout.compute` and `MenuButtons.buttonSize`**, and use `buttonSize` in
  `MenuButtons.build`

- [ ] **Step 5: Run them to verify they pass**

Run: `flutter test test/open_card_layout_test.dart`
Expected: PASS

- [ ] **Step 6: Use `OpenCardLayout` in `Home`**, with `Menu.pickerHeight` in place of `footerHeight`, and remove
  `SystemInsets.openCardTop`, `openCardGap` and their test

- [ ] **Step 7: Run the insets test**

Run: `flutter test test/system_insets_test.dart`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add lib/views/home/open_card_layout.dart lib/views/home/home.dart lib/views/menu/menu.dart lib/views/menu/menu_buttons.dart lib/components/system_insets.dart test/system_insets_test.dart test/open_card_layout_test.dart
git commit -m "Centre the open-menu card between the button row and the accent picker, with equal gaps above and below."
```
