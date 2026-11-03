# A settings panel behind a gear: language, °C or °F, and rate on Google Play

Date: 2026-11-03. Branch: `feat/settings-menu`.

## Why

The menu's top row has a translate button for the one setting the app had. Users also need to choose Fahrenheit, and
the app has no way to ask for a rating. Adding a button per setting would crowd a row that already shrinks on narrow
phones, so settings get one home that later settings join.

## Decisions this rests on

- [decisions/settings-panel](../../knowledge/decisions/settings-panel.md): the translate button becomes a gear that
  opens a full-screen settings panel; every future setting is a row there.
- [decisions/temperature-unit-by-region](../../knowledge/decisions/temperature-unit-by-region.md): °C or °F, chosen in
  settings, defaulting to the phone's region; the app and the widget both follow it.
- [decisions/rate-via-play-store-page](../../knowledge/decisions/rate-via-play-store-page.md): Rate on Google Play
  opens the store page through `url_launcher`, not the in-app review dialog.
- [features/language-picker](../../knowledge/features/language-picker.md): the existing `LanguageOverlay` and
  `LocaleManager`, which this keeps and opens from settings.
- [decisions/android-only](../../knowledge/decisions/android-only.md): built and checked on Android only.

## What changes

### 1. The gear

- `lib/views/menu/menu_buttons.dart`: `onLanguage` becomes `onSettings`, and its button shows `Icons.settings` in the
  same slot (between the widget and location buttons), with the semantics label "Settings" from `AppLocalizations`.
  Nothing else in the row moves or resizes.
- `lib/main.dart`: `isLanguageOpen` stays; a new `isSettingsOpen` and `toggleSettings(bool)` show and hide the panel,
  as `toggleDialog` does for the city dialog.

### 2. The settings panel

`lib/views/settings/settings_overlay.dart` (`SettingsOverlay`), a new `views/settings/` area. It is built like
`LanguageOverlay`: a dimmed full-screen background, a centred card in the theme's background colour with a 12 radius
and the same shadow, the title "SETTINGS" at the top, and a close button at the bottom start. It takes `accent`,
`onClose`, `onLanguage` and `onRate`.

Rows, top to bottom (a `ListTile` each, as in `LanguageOverlay`):

| Row | Shows | Tap |
|---|---|---|
| Language | the current language's native name, or "System default" | calls `onLanguage` |
| Temperature | a two-part `°C` / `°F` toggle, the current unit filled with the accent colour | sets the unit at once |
| Rate on Google Play | an open-in-new icon | calls `onRate` |

- The panel stays open while the unit changes, so the user sees the toggle move.
- **Language:** `main.dart` opens `LanguageOverlay` above the settings panel (later in the `Stack`). Choosing a language
  or closing the picker returns to the panel, still open, now in the new language.
- `°C` and `°F` are not translated, as units weren't in the localization spec.
- The panel scrolls if the rows don't fit, as the language list does. It mirrors in Arabic and Urdu.

### 3. Temperature unit

- `lib/services/unit_manager.dart`: `enum TemperatureUnit { celsius, fahrenheit }` and a `UnitManager`
  `ChangeNotifier` built like `LocaleManager`:
  - `preferenceKey = 'temperature_unit'`, holding `celsius` or `fahrenheit`.
  - `load()` restores it; nothing saved, an unknown value or a read error means "follow the region".
  - `static TemperatureUnit resolve(String? saved, Locale device)`: the saved unit when it is valid, else
    `fahrenheit` when `device.countryCode` is one of `US`, `BS`, `BZ`, `KY`, `LR`, `PW`, `FM`, `MH`, else `celsius`.
  - `setUnit(TemperatureUnit)` applies at once, notifies, then saves; a failed save is logged with `debugPrint` and not
    thrown.
  - Provided in `main.dart` beside `ThemeManager` and `LocaleManager`.
- `formatTemperature(double? kelvin, TemperatureUnit unit, {bool symbol = true})`, in the same file: `--` for null,
  else `(kelvin - kelvinOffset)` for °C or `(kelvin - kelvinOffset) * 9 / 5 + 32` for °F, `.floor()`ed as today, then
  `°C` / `°F`, or only `°` when `symbol` is false.
- The three inline `- 273.15` conversions use it, reading the unit with `context.watch<UnitManager>()`:
  `lib/views/weather/weather_view.dart`, `lib/views/forecast/hourly_detail_chip.dart`,
  `lib/views/forecast/daily_detail_card.dart` (min and max).

### 4. Home-screen widget

- `lib/services/weather_widget.dart`: `_degrees` uses `formatTemperature(..., symbol: false)` with the unit from a new
  `WeatherWidget.temperatureUnit()`, which reads `temperature_unit` from SharedPreferences and resolves it with the
  device locale, as `localizations()` does for the language. The background refresh therefore follows the choice.
- When the user changes the unit, `main.dart` pushes the last cached report (`WeatherCache.loadReport()`) to
  `WeatherWidget.update`, so the widget switches straight away rather than at its next refresh. No report cached means
  nothing to push.

### 5. Rate on Google Play

- `pubspec.yaml`: `url_launcher`.
- `lib/services/play_store.dart`: `PlayStore.openListing()` returns `Future<bool>`. It tries
  `market://details?id=in.spanion.weather`, then `https://play.google.com/store/apps/details?id=in.spanion.weather`,
  each with `LaunchMode.externalApplication`, and returns whether one opened. It catches and logs launcher errors, and
  takes the launcher as an optional parameter so tests can fake it.
- `main.dart`'s `onRate` shows the snackbar "Couldn't open Google Play" when it returns false.
- No `<queries>` entry is needed: the app calls `launchUrl`, not `canLaunchUrl`.

### 6. Strings

Four new keys in `lib/l10n/app_en.arb`, each with an `@key` description, and drafted in the other nine `.arb` files
(left marked unreviewed in `@@x-reviewed`):

- `settings`: "Settings"
- `temperature`: "Temperature"
- `rateOnGooglePlay`: "Rate on Google Play"
- `couldNotOpenPlayStore`: "Couldn't open Google Play"

### 7. Knowledge

- New `features/settings` concept; the three decisions above (already written).
- `features/language-picker`: opened from the settings panel; `## History` line.
- `data/on-device-storage`: the `temperature_unit` key.
- `features/home-screen-widget`, `features/current-weather`, `features/forecast`: temperatures follow the unit.
- `risks/debt`: the repeated Kelvin conversions are fixed.
- `decisions/supported-languages`: already updated with a `## History` line.
- Log the change.

## Testing

Test first where it's behaviour:

- `UnitManager`: `resolve` gives °F for a `US` locale and °C for `GB` and for a locale with no country; a saved
  unit wins over the region; an unknown saved value follows the region; `setUnit` saves and `load` restores; a store
  that fails to save still applies the unit.
- `formatTemperature`: `273.15` K is `0°C` and `32°F`; `300` K is `26°C` and `80°F` (floored); null is `--`;
  `symbol: false` gives `°`.
- `SettingsOverlay` (widget test): shows the three rows; tapping °F sets `UnitManager` to Fahrenheit; tapping Language
  calls `onLanguage`; tapping Rate calls `onRate`; the close button calls `onClose`.
- `MenuButtons`: shows the gear, and tapping it calls `onSettings` (updating `test/menu_buttons_test.dart`).
- `PlayStore.openListing`: falls back to the https address when `market://` fails, and returns false when both fail.
- The widget's degrees in °F (`test/weather_widget_test.dart`).
- `test/arb_files_test.dart` already checks that every `.arb` file has the new keys.
- At the end: `flutter analyze` and smoke.

## Out of scope

- Wind units (m/s stays); it would be another row in this panel.
- Moving the theme toggle, the accent picker or the PRIVACY button into settings.
- Re-pushing the widget when the language changes (it follows at its next refresh, as today).
- Google's in-app review dialog.
