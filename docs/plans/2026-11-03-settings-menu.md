# Settings Menu Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: the project's workflow policy names the executor (`run.executor`): ga:implement-with-subagents by default, or ga:implement. Follow the policy and this plan's Checkpoints. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the menu's translate button with a gear that opens a settings panel holding Language, a °C/°F
temperature toggle and Rate on Google Play, with every temperature (app and widget) following the chosen unit.

**Architecture:** A `UnitManager` `ChangeNotifier` (built like `LocaleManager`) holds the temperature unit, saved in
SharedPreferences under `temperature_unit` and defaulting to the phone's region; one `formatTemperature` function
turns Kelvin into the shown text everywhere. `PlayStore.openListing` opens the store page with `url_launcher`. A new
`SettingsOverlay` (built like `LanguageOverlay`) is opened from the gear in `MenuButtons` and wired in `lib/main.dart`.

**Tech Stack:** Flutter / Dart, `provider`, `shared_preferences`, `flutter_localizations` + `intl` (`gen_l10n`,
`lib/l10n/app_<code>.arb`), `home_widget`, and the new `url_launcher`. Android only.

**Spec:** [docs/specs/2026-11-03-settings-menu.md](../specs/2026-11-03-settings-menu.md)

## Global Constraints

- Android only ([decisions/android-only](../../knowledge/decisions/android-only.md)): no iOS work or checks.
- New and changed Dart: `dart format` at page width 120, callbacks typed as function types, `package:flutterweather/...`
  imports, `///` comments that say why ([knowledge/project/conventions.md](../../knowledge/project/conventions.md)).
- Tests live in `test/<subject>_test.dart` with their fakes in the same file; no network, no real URL launches.
- Generated `lib/l10n/app_localizations*.dart` files are not committed; run `flutter pub get` after changing an `.arb`
  file or `pubspec.yaml`, before running tests.
- Spec §2: "`°C` and `°F` are not translated, as units weren't in the localization spec."
- Spec §3: Fahrenheit regions are exactly `US`, `BS`, `BZ`, `KY`, `LR`, `PW`, `FM`, `MH`.
- Spec §3: rounding is `.floor()`, as today, in both units.
- The app's Play ID is `in.spanion.weather` (`android/app/build.gradle.kts`).

## Checkpoints

None (`run.checkpoints: none`). The run goes from Task 1 to the end without stopping.

---

### Task 1: Foundation: temperature unit, Play Store opener, strings, dependency

**Files:**
- Modify: `pubspec.yaml`, `pubspec.lock`
- Create: `lib/services/unit_manager.dart`
- Create: `lib/services/play_store.dart`
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_zh.arb`, `lib/l10n/app_hi.arb`, `lib/l10n/app_es.arb`,
  `lib/l10n/app_ar.arb`, `lib/l10n/app_fr.arb`, `lib/l10n/app_bn.arb`, `lib/l10n/app_pt.arb`, `lib/l10n/app_ru.arb`,
  `lib/l10n/app_ur.arb`
- Test: `test/unit_manager_test.dart`, `test/play_store_test.dart`

**Interfaces:**
- Consumes: existing `kelvinOffset` (`lib/services/providers/weather_provider.dart`).
- Consumes: existing `LocaleManager` pattern (`lib/services/locale_manager.dart`).
- Produces: `TemperatureUnit`, `UnitManager`, `formatTemperature`, `PlayStore.openListing`, and four
  `AppLocalizations` getters: `settings`, `temperature`, `rateOnGooglePlay`, `couldNotOpenPlayStore`.

```dart
// lib/services/unit_manager.dart
enum TemperatureUnit { celsius, fahrenheit }

class UnitManager extends ChangeNotifier {
  static const String preferenceKey = 'temperature_unit'; // holds 'celsius' or 'fahrenheit'
  static const Set<String> fahrenheitRegions = {'US', 'BS', 'BZ', 'KY', 'LR', 'PW', 'FM', 'MH'};

  /// [preferences] and [device] are for tests; [device] defaults to PlatformDispatcher.instance.locale.
  UnitManager({Future<SharedPreferences> Function()? preferences, Locale Function()? device});

  /// Before load() this is the region's unit.
  TemperatureUnit get unit;
  Future<void> load();                         // never throws; notifies
  Future<void> setUnit(TemperatureUnit unit);  // applies and notifies first, then saves; a failed save is logged
  static TemperatureUnit resolve(String? saved, Locale device);
}

/// '--' for null. symbol: true gives '°C' / '°F', false gives '°'.
String formatTemperature(double? kelvin, TemperatureUnit unit, {bool symbol = true});

// lib/services/play_store.dart
typedef UrlOpener = Future<bool> Function(Uri uri);

class PlayStore {
  static const String packageId = 'in.spanion.weather';
  /// Default opener: launchUrl(uri, mode: LaunchMode.externalApplication).
  static Future<bool> openListing({UrlOpener? open});
}
```

**Spec:**
- §3: "`preferenceKey = 'temperature_unit'`, holding `celsius` or `fahrenheit`."
- §3: "`load()` restores it; nothing saved, an unknown value or a read error means" following the region.
- §3: "the saved unit when it is valid, else `fahrenheit` when `device.countryCode` is one of `US`, `BS`, `BZ`, `KY`, `LR`, `PW`, `FM`, `MH`, else `celsius`."
- §3: "`setUnit(TemperatureUnit)` applies at once, notifies, then saves; a failed save is logged with `debugPrint` and not thrown."
- §3: "`--` for null, else `(kelvin - kelvinOffset)` for °C or `(kelvin - kelvinOffset) * 9 / 5 + 32` for °F, `.floor()`ed as today, then `°C` / `°F`, or only `°` when `symbol` is false."
- §5: "It tries `market://details?id=in.spanion.weather`, then `https://play.google.com/store/apps/details?id=in.spanion.weather`, each with `LaunchMode.externalApplication`, and returns whether one opened. It catches and logs launcher errors, and takes the launcher as an optional parameter so tests can fake it."
- §6: "Four new keys in `lib/l10n/app_en.arb`, each with an `@key` description, and drafted in the other nine `.arb` files"
- §6: "(left marked unreviewed in `@@x-reviewed`):"

**Tags:** `failure-paths`

**Knowledge:**
- `data/on-device-storage`: `temperature_unit` holds `celsius` or `fahrenheit`; absent means the phone's region decides.
- `risks/debt`: `formatTemperature` in `lib/services/unit_manager.dart` is the one place Kelvin becomes shown text.

**Acceptance:**
- `UnitManager.resolve(null, Locale('en', 'US'))` is `fahrenheit`; `resolve(null, Locale('en', 'GB'))` is `celsius`;
  `resolve(null, Locale('en'))` (no country) is `celsius`.
- `resolve('celsius', Locale('en', 'US'))` is `celsius` (a saved unit wins over the region);
  `resolve('kelvin', Locale('en', 'US'))` is `fahrenheit` (an unknown value follows the region).
- Given an empty store and a `US` device, `load()` gives `fahrenheit` and notifies listeners once.
- `setUnit(TemperatureUnit.celsius)` then a new `UnitManager` on the same store and `load()` gives `celsius`, and the
  store holds `temperature_unit = 'celsius'`.
- Given a store whose read throws, `load()` does not throw and gives the region's unit.
- Given a store whose save throws, `setUnit(TemperatureUnit.fahrenheit)` does not throw, `unit` is `fahrenheit`, and
  listeners were notified.
- `formatTemperature(273.15, celsius)` is `0°C`; `formatTemperature(273.15, fahrenheit)` is `32°F`;
  `formatTemperature(300, celsius)` is `26°C`; `formatTemperature(300, fahrenheit)` is `80°F`;
  `formatTemperature(null, celsius)` is `--`; `formatTemperature(285.15, celsius, symbol: false)` is `12°`.
- `formatTemperature(268.15, celsius)` is `-5°C` and `formatTemperature(268.15, fahrenheit)` is `23°F` (below zero
  floors toward minus infinity, as today).
- Given an opener that returns true for `market://details?id=in.spanion.weather`, `openListing` returns true and
  tried only that address.
- Given an opener that returns false for `market://…` and true for
  `https://play.google.com/store/apps/details?id=in.spanion.weather`, `openListing` returns true after trying both, in
  that order.
- Given an opener that throws for `market://…` and returns false for the https address, `openListing` returns false
  and does not throw.
- `app_en.arb` holds `settings` = "Settings", `temperature` = "Temperature", `rateOnGooglePlay` = "Rate on Google
  Play", `couldNotOpenPlayStore` = "Couldn't open Google Play".
- `test/arb_files_test.dart` passes with the four new keys in all ten files.

- [ ] **Step 1: Add `url_launcher` to `pubspec.yaml`, the four keys to all ten `.arb` files, and run `flutter pub get`**, so `AppLocalizations` has the new getters
- [ ] **Step 2: Create `unit_manager.dart` and `play_store.dart` with the signatures above and empty bodies**, so the tests fail on behaviour, not on missing names
- [ ] **Step 3: Write the failing tests** for each Acceptance case, in `test/unit_manager_test.dart` and `test/play_store_test.dart`
- [ ] **Step 4: Run them to verify they fail**

Run: `flutter test test/unit_manager_test.dart test/play_store_test.dart`
Expected: FAIL on the assertions.

- [ ] **Step 5: Write the minimal implementation** to the Interfaces, until they pass
- [ ] **Step 6: Run them to verify they pass**

Run: `flutter test test/unit_manager_test.dart test/play_store_test.dart test/arb_files_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/services/unit_manager.dart lib/services/play_store.dart lib/l10n/app_en.arb lib/l10n/app_zh.arb lib/l10n/app_hi.arb lib/l10n/app_es.arb lib/l10n/app_ar.arb lib/l10n/app_fr.arb lib/l10n/app_bn.arb lib/l10n/app_pt.arb lib/l10n/app_ru.arb lib/l10n/app_ur.arb test/unit_manager_test.dart test/play_store_test.dart
git commit -m "Add the temperature unit setting, the Play Store opener and the settings strings."
```

---

### Task 2: Every temperature follows the unit, in the app and the widget

**Files:**
- Modify: `lib/views/weather/weather_view.dart`
- Modify: `lib/views/forecast/hourly_detail_chip.dart`
- Modify: `lib/views/forecast/daily_detail_card.dart`
- Modify: `lib/services/weather_widget.dart`
- Test: `test/hourly_detail_chip_test.dart`, `test/weather_widget_test.dart`

**Interfaces:**
- Consumes: `TemperatureUnit`, `UnitManager`, `formatTemperature` from Task 1.
- Produces: `WeatherWidget.temperatureUnit` and a `unit` parameter on `WeatherWidget.payload`.

```dart
// lib/services/weather_widget.dart
/// The saved unit, else the region's, read without a BuildContext. [device] is only for tests.
static Future<TemperatureUnit> temperatureUnit({@visibleForTesting Locale? device});

@visibleForTesting
static Map<String, String> payload(WeatherReport report, AppLocalizations l10n, String locale, DateTime updated,
    {TemperatureUnit unit = TemperatureUnit.celsius});
```

**Spec:**
- §3: "The three inline `- 273.15` conversions use it, reading the unit with `context.watch<UnitManager>()`: `lib/views/weather/weather_view.dart`, `lib/views/forecast/hourly_detail_chip.dart`, `lib/views/forecast/daily_detail_card.dart` (min and max)."
- §4: "`_degrees` uses `formatTemperature(..., symbol: false)` with the unit from a new `WeatherWidget.temperatureUnit()`, which reads `temperature_unit` from SharedPreferences and resolves it with the device locale, as `localizations()` does for the language. The background refresh therefore follows the choice."

**Tags:** `screen`

**Knowledge:**
- `features/current-weather`: the temperature shows in the chosen unit, `°C` or `°F`.
- `features/forecast`: hourly chips and daily min/max show in the chosen unit.
- `features/home-screen-widget`: the widget's temperatures follow the saved `temperature_unit`, still shown with `°` only.

**Acceptance:**
- Given `UnitManager` at `celsius`, the hourly chip for `285.15` K shows `12°C`; at `fahrenheit` it shows `53°F`
  (`test/hourly_detail_chip_test.dart` provides a `UnitManager` above `MaterialApp`).
- Given the unit changes from `celsius` to `fahrenheit` while the chip is on screen, after a pump it shows `53°F`.
- `payload(_report(), l10n, 'en', updated)` keeps today's output: `now.temperature` is `12°`, `detail` names `17°`
  and `7°`.
- `payload(_report(), l10n, 'en', updated, unit: TemperatureUnit.fahrenheit)`: `now.temperature` is `53°`, `detail`
  names `63°` and `45°`.
- Given SharedPreferences holds `temperature_unit = 'fahrenheit'`, `temperatureUnit(device: Locale('en', 'GB'))` is
  `fahrenheit`; given nothing saved, `temperatureUnit(device: Locale('en', 'US'))` is `fahrenheit` and
  `temperatureUnit(device: Locale('fr', 'FR'))` is `celsius`.
- `grep -rn "273.15" lib/views` finds nothing.

- [ ] **Step 1: Add the `unit` parameter and `temperatureUnit` with their signatures**, the parameter not yet used, so the tests fail on behaviour
- [ ] **Step 2: Write the failing tests** for each Acceptance case, in `test/hourly_detail_chip_test.dart` and `test/weather_widget_test.dart`
- [ ] **Step 3: Run them to verify they fail**

Run: `flutter test test/hourly_detail_chip_test.dart test/weather_widget_test.dart`
Expected: FAIL on the assertions.

- [ ] **Step 4: Write the minimal implementation**: the three views read `context.watch<UnitManager>().unit` and call `formatTemperature`; `_degrees` takes the unit and calls `formatTemperature(..., symbol: false)`; `update` passes `await temperatureUnit()` to `payload`
- [ ] **Step 5: Run them to verify they pass**

Run: `flutter test test/hourly_detail_chip_test.dart test/weather_widget_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/views/weather/weather_view.dart lib/views/forecast/hourly_detail_chip.dart lib/views/forecast/daily_detail_card.dart lib/services/weather_widget.dart test/hourly_detail_chip_test.dart test/weather_widget_test.dart
git commit -m "Show every temperature in the chosen unit, in the app and the widget."
```

---

### Task 3: The gear and the settings panel

**Files:**
- Create: `lib/views/settings/settings_overlay.dart`
- Modify: `lib/views/menu/menu_buttons.dart`
- Modify: `lib/main.dart`
- Test: `test/settings_overlay_test.dart`, `test/menu_buttons_test.dart`

**Interfaces:**
- Consumes from Task 1: `TemperatureUnit`, `UnitManager`, `PlayStore.openListing`, and the `AppLocalizations` getters `settings`, `temperature`, `rateOnGooglePlay`, `couldNotOpenPlayStore`.
- Consumes: existing `LocaleManager`, `supportedLanguages`, `LanguageOverlay`, `ThemeManager`, `GradientValues`.
- Consumes: existing `WeatherCache.loadReport` and the existing `update(report)` of the widget service, unchanged in signature.
- Produces: `SettingsOverlay`; `MenuButtons.onSettings` (replacing `onLanguage`).

```dart
// lib/views/settings/settings_overlay.dart
/// Reads LocaleManager, UnitManager and ThemeManager from Provider.
class SettingsOverlay extends StatelessWidget {
  const SettingsOverlay({
    required int accent,
    required void Function() onClose,
    required void Function() onLanguage,
    required void Function() onRate,
    /// Called after UnitManager.setUnit has finished saving, so the widget reads the new unit.
    required void Function() onUnitChanged,
  });
}

// lib/views/menu/menu_buttons.dart: the onLanguage parameter is renamed
final void Function() onSettings;
```

**Spec:**
- §1: "`onLanguage` becomes `onSettings`, and its button shows `Icons.settings` in the same slot (between the widget and location buttons), with the semantics label"
- §1: "Nothing else in the row moves or resizes."
- §2: "a dimmed full-screen background, a centred card in the theme's background colour with a 12 radius and the same shadow, the title"
- §2: "at the top, and a close button at the bottom start."
- §2: "the current language's native name, or"
- §2: "a two-part `°C` / `°F` toggle, the current unit filled with the accent colour"
- §2: "an open-in-new icon"
- §2: "The panel stays open while the unit changes, so the user sees the toggle move."
- §2: "`main.dart` opens `LanguageOverlay` above the settings panel (later in the `Stack`). Choosing a language or closing the picker returns to the panel, still open, now in the new language."
- §2: "The panel scrolls if the rows don't fit, as the language list does. It mirrors in Arabic and Urdu."
- §3: "Provided in `main.dart` beside `ThemeManager` and `LocaleManager`."
- §4: "When the user changes the unit, `main.dart` pushes the last cached report (`WeatherCache.loadReport()`) to `WeatherWidget.update`, so the widget switches straight away rather than at its next refresh. No report cached means nothing to push."
- §5: "`main.dart`'s `onRate` shows the snackbar"

**Tags:** `screen`, `failure-paths`

**Knowledge:**
- `features/settings` (new): the gear in the menu's button row opens `SettingsOverlay` with Language, Temperature and
  Rate on Google Play rows; new settings are rows here.
- `features/language-picker`: the picker opens from the settings panel's Language row and returns to it.

**Acceptance:**
- `SettingsOverlay` (with `LocaleManager`, `UnitManager`, `ThemeManager` provided, English) shows the title "SETTINGS"
  (the `settings` string upper-cased, as `LanguageOverlay` does),
  "Language", "Temperature", "Rate on Google Play", `°C` and `°F`.
- Given no saved language, the Language row shows "System default"; given `LocaleManager` set to `Locale('hi')`, it
  shows "हिन्दी".
- Given `UnitManager` at `celsius`, tapping `°F` sets it to `fahrenheit`, the panel is still on screen, `onClose` was
  not called, and `onUnitChanged` was called once, after the store holds `temperature_unit = 'fahrenheit'`.
- Tapping `°C` while already `celsius` does not call `onUnitChanged`.
- Tapping the Language row calls `onLanguage`; tapping Rate on Google Play calls `onRate`; the close button calls
  `onClose`.
- With `Locale('ar')`, the panel's text direction is right to left.
- `MenuButtons` shows, in order, `Icons.refresh`, the theme icon, `Icons.widgets`, `Icons.settings`,
  `Icons.location_on`, `Icons.close`, and no `Icons.translate`; tapping the gear calls `onSettings`; its semantics
  label is "Settings"; the existing size and order cases in `test/menu_buttons_test.dart` still pass.
- In `lib/main.dart`, by reading: `SettingsOverlay` sits after `DialogOverlay` and before `LanguageOverlay` in the
  `Stack`; `onRate` shows `couldNotOpenPlayStore` in a snackbar when `PlayStore.openListing()` returns false;
  `onUnitChanged` pushes `WeatherCache.loadReport()` to `WeatherWidget.update` only when it is not null.

- [ ] **Step 1: Rename `onLanguage` to `onSettings` and create `SettingsOverlay` with its constructor and an empty build**, so the tests fail on behaviour
- [ ] **Step 2: Write the failing tests** for each Acceptance case, in `test/settings_overlay_test.dart` and `test/menu_buttons_test.dart`
- [ ] **Step 3: Run them to verify they fail**

Run: `flutter test test/settings_overlay_test.dart test/menu_buttons_test.dart`
Expected: FAIL on the assertions.

- [ ] **Step 4: Write the minimal implementation**: the gear and its label in `MenuButtons`; the panel's rows, toggle and close button; in `main.dart` the `UnitManager` provider, `isSettingsOpen` and `toggleSettings(bool)`, the Stack order, `onRate` and `onUnitChanged`
- [ ] **Step 5: Run them to verify they pass**

Run: `flutter test test/settings_overlay_test.dart test/menu_buttons_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/views/settings/settings_overlay.dart lib/views/menu/menu_buttons.dart lib/main.dart test/settings_overlay_test.dart test/menu_buttons_test.dart
git commit -m "Replace the translate button with a gear that opens the settings panel."
```
