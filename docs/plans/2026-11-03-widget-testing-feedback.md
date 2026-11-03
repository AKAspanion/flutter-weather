# Widget and theme fixes from internal testing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: the project's workflow policy names the executor (`run.executor`): ga:implement-with-subagents by default, or ga:implement. Follow the policy and this plan's Checkpoints. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Android widget a single resizable Now card (down to 2x2) in the app's accent, with an animated
icon, a preview that renders, and a pin flow that lands on the home screen; and make the app follow the system dark
mode.

**Architecture:** Task 1 replaces the widget's StackView with one plain `RemoteViews` layout (a wide and a small
variant, chosen by card width), adds per-accent backgrounds, and drops the hours payload from `WeatherWidget`. Task 2
renders each icon's Flare loop to frames played by an indeterminate `ProgressBar` in the card's icon slot. Task 3 adds
a `MainActivity` method channel that pins the widget with a success callback opening the home screen. Task 4, beside
the others, makes `ThemeManager` resolve the theme from the system brightness plus an override.

**Tech Stack:** Flutter (Dart), `flutter_test`, `home_widget` 0.10, `shared_preferences`; Android `RemoteViews`
in Kotlin (`WeatherWidgetProvider.kt`, `MainActivity.kt`), built with `flutter build apk`.

**Spec:** `docs/specs/2026-11-03-widget-testing-feedback.md`

## Global Constraints

- New Dart code is formatted at 120 columns with typed callbacks (`decisions/code-style-120-typed`).
- Android is the only supported platform (`decisions/android-only`).
- Platform features catch their own errors, log them with `debugPrint`, and carry on; they do nothing on platforms
  they don't support (`_supported`).
- Drawables and layouts the provider picks at runtime are mapped one by one in Kotlin (`when`), never looked up by
  name, so resource shrinking keeps them.
- The background refresh keeps using the last place viewed (`decisions/widget-uses-last-place`).

## Checkpoints

None (the fast pace).

---

### Task 1: The widget as one Now card, resizable to 2x2, in the app's accent

**Files:**
- Modify: `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
- Modify: `android/app/src/main/res/layout/weather_widget.xml`
- Create: `android/app/src/main/res/layout/weather_widget_small.xml`
- Modify: `android/app/src/main/res/layout/weather_widget_preview.xml`
- Delete: `android/app/src/main/res/layout/weather_widget_item.xml`
- Delete: `android/app/src/main/res/layout/weather_widget_hours.xml`
- Delete: `android/app/src/main/res/layout/weather_widget_hour.xml`
- Delete: `android/app/src/main/res/drawable/widget_dot.xml`
- Delete: `android/app/src/main/res/drawable/widget_page_background.xml`
- Delete: `android/app/src/main/res/drawable-v31/widget_page_background.xml`
- Delete: `android/app/src/main/res/drawable/widget_background.xml` (renamed to `widget_background_0.xml`)
- Create: `android/app/src/main/res/drawable/widget_background_0.xml`
- Create: `android/app/src/main/res/drawable/widget_background_1.xml`
- Create: `android/app/src/main/res/drawable/widget_background_2.xml`
- Create: `android/app/src/main/res/drawable/widget_background_3.xml`
- Create: `android/app/src/main/res/drawable/widget_background_4.xml`
- Create: `android/app/src/main/res/drawable/widget_background_5.xml`
- Create: `android/app/src/main/res/drawable/widget_background_6.xml`
- Create: `android/app/src/main/res/drawable/widget_background_7.xml`
- Create: `android/app/src/main/res/drawable/widget_background_8.xml`
- Modify: `android/app/src/main/res/xml/weather_widget_info.xml`
- Modify: `android/app/src/main/res/values/strings.xml`
- Modify: `lib/services/weather_widget.dart`
- Modify: `lib/main.dart`
- Modify: `lib/theme/gradients.dart`
- Test: `test/weather_widget_test.dart`

**Interfaces:**
- Consumes: existing `WeatherReport`, `Weather`, `GradientValues`, `HomeWidget.saveWidgetData` / `updateWidget`.
- Produces (Task 2 relies on the layouts; Task 3 on the file):

```dart
class WeatherWidget {
  static Future<void> update(WeatherReport report); // saves city, now, updated; no longer hours
  static Future<void> setAccent(int index);          // saves 'accent' (int), then updateWidget
  static Future<bool> canPin();                      // unchanged
  static Future<void> pin();                         // unchanged in this task
  static Future<void> scheduleRefresh();             // unchanged
}
```

```kotlin
// WeatherWidgetProvider
private fun backgroundFor(index: Int): Int // R.drawable.widget_background_<index>, else widget_background_0
// Both layouts: root id widget_root (background set by backgroundFor), card_icon an ImageView 64dp, widget_empty.
// Small layout chosen when the card is narrower than SMALL_WIDTH (dp, a companion const with a comment).
```

Widget data keys: `city` (String), `now` (JSON String, unchanged fields), `updated` (String), `accent` (int). `hours`
is no longer written.

**Spec:**
- §1: "`weather_widget.xml` becomes the Now card itself: a root with the accent background, clipped to its outline, holding the current layout of `weather_widget_item.xml` without the two page dots, plus the `widget_empty` view."
- §1: "New `weather_widget_small.xml` for narrow cards: city on top, the icon with the temperature, the description, and the high/low line. No sunrise/wind/humidity row and no "updated" line."
- §1: "`weather_widget_info.xml`: `minResizeWidth` and `minResizeHeight` become `110dp`. `minWidth`, `minHeight` and `targetCellWidth`/`targetCellHeight` (4x2) stay, so the picker and the pin dialog still add a 4x2."
- §1: "The whole card, and the empty view, open the app with `HomeWidgetLaunchIntent.getActivity`."
- §1: "`scaleFor` stays for both layouts."
- §2: "`weather_widget_preview.xml` gets a fixed-size root, `250dp` by `110dp` (the widget's minimum size), and no row whose height depends on a weight, so a host that measures it at wrap-content can't collapse it."
- §3: "`WeatherWidget.setAccent(int index)` saves `accent` with `HomeWidget.saveWidgetData<int>` and calls `updateWidget`. `setAccent` and `getAccent` in `lib/main.dart` both call it"
- §3: "An unknown or missing index uses index 0."
- §3: "A comment on `GradientValues._gradients` says the widget maps the same indexes, so the order must not change and new gradients are added at the end with a drawable."
- §1: "`strings.xml`: `widget_description` no longer mentions the next 24 hours or swiping, and `widget_next_24_hours` goes."

**Tags:** `failure-paths`

**Knowledge:** `features/home-screen-widget`: the widget is one Now card, resizable from 4x2 down to 2x2 with a compact
layout below `SMALL_WIDTH`, drawn in the app's accent, with its weather icon a looping frame animation played by a `ProgressBar` (planned);
`features/themes-and-accents`: the accent also colours the
widget, pushed at launch and on every change; `data/on-device-storage`: the widget's keys are `city`, `now`, `updated`
and `accent`; `project/architecture`: the widget is a single `RemoteViews` layout, no StackView.

**Acceptance:**
- Given the platform is Android and the `home_widget` method channel is mocked, when `WeatherWidget.update` runs with a
  report whose current weather is named "Lisbon", then `saveWidgetData` is called with ids `city` ("LISBON"), `now`
  and `updated`, never with `hours`, and `updateWidget` is called with `qualifiedAndroidName`
  `com.example.flutterweather.WeatherWidgetProvider`.
- Given Android, when `WeatherWidget.setAccent(3)` runs, then `saveWidgetData` is called with id `accent` and data `3`,
  then `updateWidget` with the same qualified name.
- Given the platform is iOS, when `WeatherWidget.setAccent(3)` runs, then no `home_widget` call is made.
- Given the channel throws a `PlatformException` on `saveWidgetData`, when `setAccent(3)` runs, then it completes
  without throwing.
- Given the Kotlin and XML changes, when `flutter build apk --debug` runs, then it succeeds (no remaining reference to
  a deleted layout, drawable, id or string).

- [ ] **Step 1: Write the failing tests** for the four Dart cases in `test/weather_widget_test.dart` (set
  `debugDefaultTargetPlatformOverride`, reset it in `tearDown`; mock the `home_widget` channel on the test binary
  messenger and record its calls). Add `setAccent` with its real signature and an empty body first, so the tests fail
  on behaviour.

- [ ] **Step 2: Run them to verify they fail**

Run: `flutter test test/weather_widget_test.dart`
Expected: FAIL on the `hours` and `accent` assertions.

- [ ] **Step 3: Implement the Dart side**: drop `_nextDay`, `_hourLabel`, `_isNight`, `_localTime`, `_hourColumns`
  and `_hourStep`; implement `setAccent`; call it from `setAccent` and `getAccent` in `lib/main.dart`; add the order
  comment in `lib/theme/gradients.dart`.

- [ ] **Step 4: Run the tests and verify they pass**

Run: `flutter test test/weather_widget_test.dart`
Expected: PASS

- [ ] **Step 5: Rewrite the Android side**: the two layouts, the preview, the nine backgrounds (angle `315`, the
  gradient's `from` as `startColor`, `to` as `endColor`, radius `20dp`, as `widget_background.xml` has now), the info
  file, the strings, and the provider (render one `RemoteViews` per size on Android 12+ and from `portraitSize`
  before; choose the layout by `SMALL_WIDTH`; set the root background with `backgroundFor`; open the app from
  `widget_root` and `widget_empty`; show `widget_empty` and hide the content when `city` or `now` is missing).

- [ ] **Step 6: Build to verify the Android side compiles**

Run: `flutter build apk --debug`
Expected: `Built build/app/outputs/flutter-apk/app-debug.apk`

- [ ] **Step 7: Commit**

```bash
git add lib/services/weather_widget.dart lib/main.dart lib/theme/gradients.dart test/weather_widget_test.dart \
  android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt \
  android/app/src/main/res/layout/weather_widget.xml android/app/src/main/res/layout/weather_widget_small.xml \
  android/app/src/main/res/layout/weather_widget_preview.xml android/app/src/main/res/layout/weather_widget_item.xml \
  android/app/src/main/res/layout/weather_widget_hours.xml android/app/src/main/res/layout/weather_widget_hour.xml \
  android/app/src/main/res/drawable/widget_dot.xml android/app/src/main/res/drawable/widget_page_background.xml \
  android/app/src/main/res/drawable-v31/widget_page_background.xml android/app/src/main/res/drawable/widget_background.xml \
  android/app/src/main/res/drawable/widget_background_0.xml android/app/src/main/res/drawable/widget_background_1.xml \
  android/app/src/main/res/drawable/widget_background_2.xml android/app/src/main/res/drawable/widget_background_3.xml \
  android/app/src/main/res/drawable/widget_background_4.xml android/app/src/main/res/drawable/widget_background_5.xml \
  android/app/src/main/res/drawable/widget_background_6.xml android/app/src/main/res/drawable/widget_background_7.xml \
  android/app/src/main/res/drawable/widget_background_8.xml android/app/src/main/res/xml/weather_widget_info.xml \
  android/app/src/main/res/values/strings.xml
git commit -m "Make the widget one Now card that resizes to 2x2 and uses the app's accent."
```

---

### Task 2: Animated widget icons

**Files:**
- Modify: `tool/render_widget_icons_test.dart`
- Create: `android/app/src/main/res/drawable-nodpi/widget_icon_<name>_<nn>.png` (frames, written by the tool, for
  each `<name>` in `clear`, `clear_night`, `sunny`, `sunny_night`, `few`, `few_night`, `broken`, `rain`, `snow`,
  `thunder`, `foggy`)
- Create: `android/app/src/main/res/drawable/widget_anim_<name>.xml` (11, written by the tool)
- Create: `android/app/src/main/res/layout/widget_icon_<name>.xml` (11, written by the tool)
- Modify: `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
- Modify: `android/app/src/main/res/layout/weather_widget.xml`
- Modify: `android/app/src/main/res/layout/weather_widget_small.xml`
- Test: `test/widget_icon_resources_test.dart`

**Interfaces:**
- Consumes: the two layouts and their `card_icon` ImageView, and `iconFor` in the provider (Task 1).
- Produces:

```kotlin
private fun iconLayoutFor(name: String): Int // R.layout.widget_icon_<name>, else widget_icon_few; replaces iconFor
// Both layouts: card_icon_slot, a FrameLayout where card_icon was. Each widget_icon_<name>.xml: one ProgressBar,
// id card_icon, indeterminate, indeterminateOnly, indeterminateDrawable @drawable/widget_anim_<name>.
```

Tool: a frames mode (an env var, documented in the file's header comment) renders every weather icon's whole loop.
Frame size and frame rate are constants in the tool, with a comment saying they keep the total near 1.5 MB. The loop
length per icon comes from the Flare animation's duration, not a guess.

**Spec:**
- §4: "Frame size and rate are picked so all frames together are about 1.5 MB or less; the chosen values sit in the tool as constants with a comment. The loop length per icon is measured from the Flare animation, not assumed."
- §4: "The static `widget_icon_<name>.png` files stay; the preview uses one of them."
- §4: "In both widget layouts the icon becomes a `FrameLayout` slot (`card_icon_slot`). The provider calls `removeAllViews` and `addView` with `iconLayoutFor(name)`, which replaces `iconFor` and is mapped one by one. The icon is sized with `setViewLayoutWidth`/`Height` on `card_icon` on Android 12+, as today."
- §4: "The detail icons (sunrise, wind, humidity) stay static."

**Knowledge:** `operations/run-locally`: the frames mode of `tool/render_widget_icons_test.dart` regenerates them;
`domain/condition-icons`: a new icon name needs its frames, its `widget_anim_` list, its `widget_icon_` layout and an
`iconLayoutFor` entry.

**Acceptance:**
- Given the generated resources, when `test/widget_icon_resources_test.dart` reads them, then for each of the 11
  names `android/app/src/main/res/drawable/widget_anim_<name>.xml` exists, is an `animation-list` with
  `android:oneshot="false"` and at least 2 items, and every `@drawable/` it names exists as a PNG in `drawable-nodpi`.
- Given the same, then each `layout/widget_icon_<name>.xml` holds a `ProgressBar` with id `card_icon`,
  `indeterminateOnly="true"` and `indeterminateDrawable="@drawable/widget_anim_<name>"`.
- Given all frame PNGs (`widget_icon_*_[0-9][0-9].png`), when their sizes are summed, then the total is at most
  `1572864` bytes (1.5 MB).
- Given `WeatherWidgetProvider.kt`, when it is read as text, then it names `R.layout.widget_icon_<name>` for each of
  the 11 names.
- Given the changes, when `flutter build apk --debug` runs, then it succeeds.

- [ ] **Step 1: Write the failing tests** for the four resource cases in `test/widget_icon_resources_test.dart`
  (reading files relative to the project root).

- [ ] **Step 2: Run them to verify they fail**

Run: `flutter test test/widget_icon_resources_test.dart`
Expected: FAIL: the animation lists and layouts don't exist yet.

- [ ] **Step 3: Add the frames mode to the tool and run it** to write the frames, lists and layouts (the command goes
  in the tool's header comment).

- [ ] **Step 4: Change the layouts and the provider** to the icon slot and `iconLayoutFor`.

- [ ] **Step 5: Run the tests and verify they pass**

Run: `flutter test test/widget_icon_resources_test.dart`
Expected: PASS

- [ ] **Step 6: Build to verify the Android side compiles**

Run: `flutter build apk --debug`
Expected: `Built build/app/outputs/flutter-apk/app-debug.apk`

- [ ] **Step 7: Commit**

```bash
git add tool/render_widget_icons_test.dart test/widget_icon_resources_test.dart \
  android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt \
  android/app/src/main/res/layout/weather_widget.xml android/app/src/main/res/layout/weather_widget_small.xml \
  'android/app/src/main/res/drawable-nodpi/widget_icon_*_[0-9][0-9].png' \
  'android/app/src/main/res/drawable/widget_anim_*.xml' 'android/app/src/main/res/layout/widget_icon_*.xml'
git commit -m "Animate the widget's weather icon with frames rendered from the Flare loops."
```

---

### Task 3: "Add" in the pin dialog goes to the home screen

**Files:**
- Modify: `android/app/src/main/kotlin/com/example/flutterweather/MainActivity.kt`
- Modify: `lib/services/weather_widget.dart`
- Modify: `test/weather_widget_test.dart`

**Interfaces:**
- Consumes: `WeatherWidget` and `test/weather_widget_test.dart` after Task 1; existing `WeatherWidgetProvider` class.
- Produces:

```dart
// WeatherWidget
static const MethodChannel _pinChannel = MethodChannel('in.spanion.weather/widget');
static Future<void> pin(); // invokes 'pin' on _pinChannel; catches and debugPrints errors
```

```kotlin
// MainActivity: configureFlutterEngine registers 'in.spanion.weather/widget'.
// 'pin' -> Boolean: false when AppWidgetManager.isRequestPinAppWidgetSupported is false, else the result of
// requestPinAppWidget(ComponentName(this, WeatherWidgetProvider::class.java), null, homeCallback)
```

**Spec:**
- §5: "`callback` is a `PendingIntent.getActivity` for `Intent.ACTION_MAIN` with `Intent.CATEGORY_HOME` and `FLAG_ACTIVITY_NEW_TASK`, `FLAG_IMMUTABLE`. On Android 14+ it is created with `ActivityOptions.setPendingIntentCreatorBackgroundActivityStartMode(MODE_BACKGROUND_ACTIVITY_START_ALLOWED)`, since the launcher sends it."
- §5: "The method returns false when pinning isn't supported. `WeatherWidget.pin` calls the channel instead of `HomeWidget.requestPinWidget`; `canPin` stays on `home_widget`. A failed call is caught and printed, as the other `WeatherWidget` methods do."

**Tags:** `failure-paths`

**Knowledge:** `features/home-screen-widget`: the in-app widgets button pins through `MainActivity`'s
`in.spanion.weather/widget` channel, and "Add" opens the home screen.

**Acceptance:**
- Given Android and the `in.spanion.weather/widget` channel mocked, when `WeatherWidget.pin()` runs, then the channel
  receives exactly one call, method `pin`, and no `requestPinWidget` call reaches the `home_widget` channel.
- Given the pin channel throws a `PlatformException`, when `pin()` runs, then it completes without throwing.
- Given the platform is iOS, when `pin()` runs, then no channel call is made.
- Given the change, when `flutter build apk --debug` runs, then it succeeds.

- [ ] **Step 1: Write the failing tests** for the three Dart cases in `test/weather_widget_test.dart`.

- [ ] **Step 2: Run them to verify they fail**

Run: `flutter test test/weather_widget_test.dart`
Expected: FAIL: `pin` still calls `home_widget`.

- [ ] **Step 3: Implement** `pin` on the new channel and the channel handler in `MainActivity`.

- [ ] **Step 4: Run the tests and verify they pass**

Run: `flutter test test/weather_widget_test.dart`
Expected: PASS

- [ ] **Step 5: Build to verify the Android side compiles**

Run: `flutter build apk --debug`
Expected: `Built build/app/outputs/flutter-apk/app-debug.apk`

- [ ] **Step 6: Commit**

```bash
git add android/app/src/main/kotlin/com/example/flutterweather/MainActivity.kt lib/services/weather_widget.dart \
  test/weather_widget_test.dart
git commit -m "Pin the widget through MainActivity so that Add opens the home screen."
```

---

### Task 4: The theme follows the system

**Files:**
- Modify: `lib/services/theme_manager.dart`
- Test: `test/theme_manager_test.dart`

**Interfaces:**
- Consumes: existing `AppTheme`, `appThemeData`; `toggleTheme` in `lib/main.dart` is unchanged.
- Produces:

```dart
AppTheme resolveTheme(Brightness system, AppTheme? override, Brightness? overrideSystem);

class ThemeManager with ChangeNotifier, WidgetsBindingObserver {
  ThemeManager();                       // reads the system brightness, adds itself as an observer, loads prefs
  ThemeData get themeData;              // unchanged signature
  AppTheme get theme;                   // unchanged signature
  Color get bgColor;                    // unchanged
  Color get textColor;                  // unchanged
  Future<void> setTheme(AppTheme theme); // saves the override with the current system brightness
  @override void didChangePlatformBrightness(); // clears the override, notifies
  @override void dispose();             // removes the observer
}
```

Prefs: `theme_preference` (int, the override's `AppTheme` index), `theme_preference_system` (int, the `Brightness`
index the override was set against).

**Spec:**
- §6: "A pure function decides the theme: `resolveTheme(Brightness system, AppTheme? override, Brightness? overrideSystem)` returns `override` when it is set and `overrideSystem == system`, else the theme matching `system`."
- §6: "`ThemeManager` reads `WidgetsBinding.instance.platformDispatcher.platformBrightness` in its constructor, so the first frame already matches the system when there's no override."
- §6: "On a change it clears the override (memory and prefs) and notifies."
- §6: "On load, a `theme_preference` without `theme_preference_system` is treated as set against the current system brightness, and the key is written then."

**Knowledge:** `features/themes-and-accents`: the theme follows the system brightness, and the button sets an override
that holds until the system brightness changes; `data/on-device-storage`: `theme_preference_system` holds the system
brightness the override was set against.

**Acceptance:**
- `resolveTheme(Brightness.dark, null, null)` is `AppTheme.Dark`; `resolveTheme(Brightness.light, null, null)` is
  `AppTheme.White`.
- `resolveTheme(Brightness.light, AppTheme.Dark, Brightness.light)` is `AppTheme.Dark`.
- `resolveTheme(Brightness.dark, AppTheme.White, Brightness.light)` is `AppTheme.Dark` (the override was set against
  the other brightness).
- Given no prefs and the system dark (`platformBrightnessTestValue`), when a `ThemeManager` is created, then `theme` is
  `AppTheme.Dark` before prefs finish loading.
- Given prefs `{theme_preference: 1}` only and the system light, when a `ThemeManager` has loaded, then `theme` is
  `AppTheme.Dark` and `theme_preference_system` is saved as `Brightness.light.index`.
- Given that manager, when the system brightness changes to dark and then back to light, then `theme` is
  `AppTheme.Dark` and then `AppTheme.White`, and `theme_preference` is no longer in prefs.
- Given the system light and no override, when `setTheme(AppTheme.Dark)` runs, then `theme` is `AppTheme.Dark`, prefs
  hold `theme_preference: 1` and `theme_preference_system: Brightness.light.index`, and listeners are notified.

- [ ] **Step 1: Write the failing tests** for the cases in `test/theme_manager_test.dart` (use
  `SharedPreferences.setMockInitialValues` and `tester.platformDispatcher.platformBrightnessTestValue`). Add
  `resolveTheme` with its real signature returning `AppTheme.White` first, so the tests fail on behaviour.

- [ ] **Step 2: Run them to verify they fail**

Run: `flutter test test/theme_manager_test.dart`
Expected: FAIL on the dark-system and override cases.

- [ ] **Step 3: Implement** `resolveTheme` and the `ThemeManager` changes.

- [ ] **Step 4: Run the tests and verify they pass**

Run: `flutter test test/theme_manager_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/theme_manager.dart test/theme_manager_test.dart
git commit -m "Follow the system dark mode, with the theme button as an override until the system changes."
```

---

### Task 5: Compact layout below full width, with no ellipsis

Added after testing on a Galaxy (One UI): a 3-cell card got the wide layout and ellipsized.

**Files:**
- Modify: `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
- Modify: `android/app/src/main/res/layout/weather_widget_small.xml`
- Test: `test/widget_layout_resources_test.dart`

**Interfaces:**
- Consumes: the two layouts, `backgroundFor` and `scaleFor` (Task 1); `card_icon_slot` and `iconLayoutFor` (Task 2).
- Produces:

```kotlin
// WeatherWidgetProvider companion: SMALL_WIDTH is removed.
const val WIDE_WIDTH = 300f    // dp; at or above it weather_widget.xml, below it weather_widget_small.xml
const val DETAILS_WIDTH = 220f // dp; the compact layout shows card_details at or above it, hides it below
// weather_widget_small.xml gains card_details (a row with card_sunrise_icon, card_sunrise, card_wind_icon,
// card_wind, card_humidity_icon, card_humidity); it has no card_updated.
```

**Spec:**
- §1: "The wide layout (`weather_widget.xml`) is used only when the reported width is at least `WIDE_WIDTH = 300` dp (full width, 4 cells). Everything narrower uses the compact layout (`weather_widget_small.xml`)."
- §1: "The compact layout: the city / NOW header; line 1 the icon and the temperature; line 2 a subtitle, the description then the high/low. No text in it ellipsizes: the city and the subtitle wrap onto another line instead."
- §1: "The compact layout shows the sunrise / wind / humidity row while the reported width is at least `DETAILS_WIDTH = 220` dp (3 cells), and hides it below (2x2). "Updated" appears only in the wide layout."
- §1: "`SMALL_WIDTH` goes, replaced by those two constants."

**Knowledge:** `features/home-screen-widget`: the wide layout is used at `WIDE_WIDTH` and above, and narrower cards use
the compact layout, which keeps the details row from `DETAILS_WIDTH` and never ellipsizes.

**Acceptance:**
- Given `weather_widget_small.xml`, when `test/widget_layout_resources_test.dart` reads it, then no element has an
  `android:ellipsize` attribute, and it has `card_details` holding `card_sunrise`, `card_wind` and `card_humidity`,
  and no `card_updated`.
- Given `WeatherWidgetProvider.kt` read as text, then it declares `WIDE_WIDTH = 300f` and `DETAILS_WIDTH = 220f` and
  no longer names `SMALL_WIDTH`.
- Given the change, when `flutter build apk --debug` runs, then it succeeds.

- [ ] **Step 1: Write the failing tests** for the two resource cases in `test/widget_layout_resources_test.dart`.

- [ ] **Step 2: Run them to verify they fail**

Run: `flutter test test/widget_layout_resources_test.dart`
Expected: FAIL: the small layout still ellipsizes and has no `card_details`.

- [ ] **Step 3: Change the compact layout and the provider** (choose the layout by `WIDE_WIDTH`, set `card_details`
  visibility by `DETAILS_WIDTH`, fill and scale the details row in the compact layout as the wide one does).

- [ ] **Step 4: Run the tests and verify they pass**

Run: `flutter test test/widget_layout_resources_test.dart`
Expected: PASS

- [ ] **Step 5: Build to verify the Android side compiles**

Run: `flutter build apk --debug`
Expected: `Built build/app/outputs/flutter-apk/app-debug.apk`

- [ ] **Step 6: Commit**

```bash
git add android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt \
  android/app/src/main/res/layout/weather_widget_small.xml test/widget_layout_resources_test.dart
git commit -m "Use the wide widget layout only at full width, and a compact two-line layout without ellipsis below it."
```

---

### Task 6: Spacing in the compact layout, and the one-row and one-cell mini layout

Added after the Galaxy check: One UI reports 2x2 as `150.19x217.6`, 3x2 as `235.52x217.6` and 4x2 as `320.85x217.6` dp.

**Files:**
- Modify: `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
- Modify: `android/app/src/main/res/layout/weather_widget_small.xml`
- Create: `android/app/src/main/res/layout/weather_widget_mini.xml`
- Modify: `android/app/src/main/res/xml/weather_widget_info.xml`
- Modify: `test/widget_layout_resources_test.dart`

**Interfaces:**
- Consumes: `scaleFor` and `backgroundFor` (Task 1); `WIDE_WIDTH`, `DETAILS_WIDTH` and `compactScaleFor` (Task 5);
  `card_icon_slot` and `iconLayoutFor` (Task 2).
- Produces:

```kotlin
// WeatherWidgetProvider companion, added:
const val STRIP_HEIGHT = 150f // dp; a card shorter than this uses weather_widget_mini.xml
const val MINI_WIDTH = 110f   // dp; a card narrower than this uses weather_widget_mini.xml; the mini layout shows the icon from it
// weather_widget_mini.xml: widget_root, widget_content holding card_icon_slot and card_temperature, widget_empty.
// weather_widget_small.xml: a tall arrangement (icon above temperature) as well as the side-by-side one, chosen by
// the provider when height > width.
```

**Spec:**
- §1: "Compact layout, wide cards (width at least height): the icon + temperature row and the subtitle form one block, centred vertically between the header and the details row, with no band between them. The icon and temperature grow up to the `1.6`x cap, so a 3x2 reaches about `48sp` / `64dp`."
- §1: "Compact layout, tall cards (height greater than width, e.g. 2x2): the icon sits centred above the temperature, and both scale with the height, so a 2x2 temperature reaches about `43sp`."
- §1: "New mini layout (`weather_widget_mini.xml`) for a card shorter than `STRIP_HEIGHT = 150` dp (one row: 1x2, 1x3, 1x4 in the launcher's words) or narrower than `MINI_WIDTH = 110` dp (one column, 1x1): only the temperature, centred and scaled to fill the card, with the animated icon before it when the card is at least `MINI_WIDTH` wide. No city, description or details; nothing ellipsizes. The card's accent background and tap-to-open stay."
- §1: "`weather_widget_info.xml`: `minResizeWidth` and `minResizeHeight` become `40dp`, so the launcher allows one row and one cell. The default 4x2, the picker and the pin dialog stay as they are."

**Knowledge:** `features/home-screen-widget`: below `STRIP_HEIGHT` tall or `MINI_WIDTH` wide the widget shows only the
temperature (with the icon from `MINI_WIDTH`), and a tall compact card stacks the icon above the temperature.

**Acceptance:**
- Given `weather_widget_mini.xml`, when `test/widget_layout_resources_test.dart` reads it, then it has `widget_root`,
  `widget_content`, `card_icon_slot`, `card_temperature` and `widget_empty`, no `card_city`, `card_description` or
  `card_details`, and no `android:ellipsize`.
- Given `weather_widget_info.xml`, then `minResizeWidth` and `minResizeHeight` are `40dp`, and `targetCellWidth` is
  `4` and `targetCellHeight` is `2`.
- Given `WeatherWidgetProvider.kt` read as text, then it declares `STRIP_HEIGHT = 150f` and `MINI_WIDTH = 110f` and
  names `R.layout.weather_widget_mini`.
- Given `weather_widget_small.xml`, then it still has no `android:ellipsize` (the Task 5 case keeps passing).
- Given the change, when `flutter build apk --debug` runs, then it succeeds.

- [ ] **Step 1: Write the failing tests** for the three new resource cases in `test/widget_layout_resources_test.dart`.

- [ ] **Step 2: Run them to verify they fail**

Run: `flutter test test/widget_layout_resources_test.dart`
Expected: FAIL: no mini layout, the info file still says `110dp`.

- [ ] **Step 3: Build the mini layout and the compact spacing** (the layout choice by `STRIP_HEIGHT` and `MINI_WIDTH`
  before `WIDE_WIDTH`; the tall arrangement when height > width; the centred block; the scales, with named constants
  and a comment on each).

- [ ] **Step 4: Run the tests and verify they pass**

Run: `flutter test test/widget_layout_resources_test.dart`
Expected: PASS

- [ ] **Step 5: Build to verify the Android side compiles**

Run: `flutter build apk --debug`
Expected: `Built build/app/outputs/flutter-apk/app-debug.apk`

- [ ] **Step 6: Commit**

```bash
git add android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt \
  android/app/src/main/res/layout/weather_widget_small.xml android/app/src/main/res/layout/weather_widget_mini.xml \
  android/app/src/main/res/xml/weather_widget_info.xml test/widget_layout_resources_test.dart
git commit -m "Fill the compact widget without gaps, stack it on tall cards, and show only the temperature one row tall or one cell wide."
```
