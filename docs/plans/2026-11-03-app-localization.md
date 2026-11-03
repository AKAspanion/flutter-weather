# App Localization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: the project's workflow policy names the executor (`run.executor`): ga:implement-with-subagents by default, or ga:implement. Follow the policy and this plan's Checkpoints. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Translate every in-app string into the ten most spoken languages, with a language picker in the home screen's top row.

**Architecture:** Flutter `gen_l10n` compiles `lib/l10n/app_<locale>.arb` into `AppLocalizations`. A `LocaleManager`
`ChangeNotifier` (like `ThemeManager`) holds the chosen locale and feeds `MaterialApp.locale`. Weather descriptions
come from the OpenWeatherMap condition code through `describeCondition`. The background widget refresh, which has no
`BuildContext`, looks its strings up with `lookupAppLocalizations` for the saved locale.

**Tech Stack:** Flutter 3.47 / Dart, `flutter_localizations` (sdk), `intl`, `shared_preferences`, `provider`,
`home_widget`, Kotlin for the Android widget. Android only.

**Spec:** [docs/specs/2026-11-03-app-localization.md](../specs/2026-11-03-app-localization.md)

## Global Constraints

- Languages, in this order: `en` (source and fallback), `zh`, `hi`, `es`, `ar`, `fr`, `bn`, `pt`, `ru`, `ur`.
- Spec §2: "Upper-casing stays where the views do it today (`toUpperCase()`), so the `.arb` text is in sentence case."
- Spec §2: not translated: the accent names in `lib/theme/gradients.dart`, provider names, units (`°C`, `m/s`, `%`),
  the data attribution line, and the app title "Beautiful Weather".
- Android only ([decisions/android-only](../../knowledge/decisions/android-only.md)): no iOS work or checks.
- New and changed Dart: `dart format` at page width 120, callbacks typed as function types, `package:flutterweather/...`
  imports (`knowledge/project/conventions.md`).
- Generated `lib/l10n/app_localizations*.dart` files are not committed: `.gitignore` lists them and `flutter pub get`
  regenerates them (`generate: true`). Run `flutter pub get` before running tests.
- Tests live in `test/<subject>_test.dart` with their fakes in the same file; no network.

## Checkpoints

None (`run.checkpoints: none`). The run goes from Task 1 to the end without stopping.

---

### Task 1: Localization foundation

**Files:**
- Modify: `pubspec.yaml`, `pubspec.lock`
- Create: `l10n.yaml`
- Modify: `.gitignore`
- Create: `lib/l10n/app_en.arb`
- Create: `lib/l10n/conditions.dart`
- Create: `lib/services/locale_manager.dart`
- Modify: `lib/main.dart` (the `MaterialApp` in `build` and its provider only)
- Modify: `lib/services/weather_service.dart`
- Test: `test/locale_manager_test.dart`, `test/conditions_test.dart`, `test/weather_service_test.dart`

**Interfaces:**
- Consumes: existing `ThemeManager` pattern (`lib/services/theme_manager.dart`), existing `WeatherService`.
- Produces: `AppLocalizations` (generated, `package:flutterweather/l10n/app_localizations.dart`) with the keys below;
  `describeCondition`; `LocaleManager`; `supportedLanguages`.

```dart
// lib/services/locale_manager.dart
class Language {
  final String code;       // 'en', 'zh', …
  final String nativeName; // 'English', '中文', 'हिन्दी', 'Español', 'العربية', 'Français', 'বাংলা', 'Português', 'Русский', 'اردو'
  const Language(this.code, this.nativeName);
}
const List<Language> supportedLanguages; // the ten, in the Global Constraints order

class LocaleManager extends ChangeNotifier {
  static const String preferenceKey = 'language_preference';
  Locale? get locale;                     // null = System default
  Future<void> load();                    // restores the saved choice
  Future<void> setLocale(Locale? locale); // null removes the key
  /// The locale to use without a BuildContext: the saved code if supported, else the device's language if
  /// supported, else English.
  static Locale resolve(String? savedCode, Locale device);
}

// lib/l10n/conditions.dart
String describeCondition(AppLocalizations l10n, int? code);
```

`l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`.
`pubspec.yaml`: `flutter_localizations: {sdk: flutter}`, `intl` (the version `flutter_localizations` pins), and
`flutter: generate: true`. `.gitignore`: `lib/l10n/app_localizations*.dart`.

`app_en.arb` keys (each with an `@key` description; sentence case):

| Key | English |
|---|---|
| `greetingMorning` / `greetingAfternoon` / `greetingEvening` / `greetingNight` | Good morning / Good afternoon / Good evening / Good night |
| `sunrise` / `wind` / `humidity` | Sunrise / Wind / Humidity |
| `myLocation` | My location |
| `nextHours` / `nextHoursSubtitle` | Next hours / Forecast for the next 48 hours |
| `nextDays` | Next days |
| `nextDaysSubtitle` | `{count, plural, =1{Forecast for the next day} other{Forecast for the next {count} days}}` (`count`: int) |
| `min` / `max` | Min / Max |
| `cityName` | City name |
| `privacy` | Privacy |
| `errorFetching` | Error fetching weather details |
| `updateFailed` | Couldn't update the weather, showing the last result |
| `language` / `systemDefault` | Language / System default |
| `widgetNow` / `widgetNext24Hours` | Now / Next 24 hours |
| `widgetUpdated` | `Updated {time}` (`time`: String) |
| `widgetHighLow` | `H {high}  L {low}` (`high`, `low`: String) |
| `conditionUnknown` | Unknown |
| `conditionThunderstorm` / `conditionDrizzle` / `conditionRain` / `conditionSnow` / `conditionMist` / `conditionClouds` | Thunderstorm / Drizzle / Rain / Snow / Mist / Clouds |
| `condition<code>` for 200, 201, 202, 210, 211, 212, 221, 230, 231, 232, 300, 301, 302, 310, 311, 312, 313, 314, 321, 500, 501, 502, 503, 504, 511, 520, 521, 522, 531, 600, 601, 602, 611, 612, 613, 615, 616, 620, 621, 622, 701, 711, 721, 731, 741, 751, 761, 762, 771, 781, 800, 801, 802, 803, 804 | OpenWeatherMap's own description for that code, in sentence case (`condition500` "Light rain", `condition800` "Clear sky") |

`describeCondition` picks `condition<code>` when the code has a key; otherwise the group by hundreds (2xx
thunderstorm, 3xx drizzle, 5xx rain, 6xx snow, 7xx mist, 8xx clouds); otherwise, and for null, `conditionUnknown`.

`main.dart`: `LocaleManager` is provided beside `ThemeManager` and loaded at start; `MaterialApp` gets
`localizationsDelegates: AppLocalizations.localizationsDelegates`, `supportedLocales:
AppLocalizations.supportedLocales` and `locale: localeManager.locale`. The snackbar's text in `getLocation` uses
`updateFailed`.

`WeatherService.fetchByCoords`: when the result has no name and no geocoder names the place, the name stays `''`
(no English "My location").

**Spec:**
- §1: "`l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`"
- §4: "A code with no key falls back to its group's phrase (thunderstorm, drizzle, rain, snow, mist, clouds), and a null code to "Unknown"."
- §5: "saves the language code under the SharedPreferences key `language_preference`, removes the key for System default, and restores it at start. An unknown saved code is treated as System default."
- §5: "With System default, Flutter picks the phone's language when it is in the list, otherwise English."
- §2: "`WeatherService` … leaves the place name empty when no geocoder names the coordinates"

**Knowledge:** (written after the finish, `knowledge.update: after-finish`)
- `data/on-device-storage`: `language_preference` holds the chosen language code; absent means System default.
- `domain/condition-icons`: the shown description is `describeCondition(code)`, with the group fallback.
- `features/current-weather`: an unnamed place shows the translated "My location"; the service stores `''`.

**Acceptance:**
- Given no saved preference, when `LocaleManager.load()` runs, then `locale` is null.
- Given `setLocale(Locale('es'))`, when a new `LocaleManager` loads, then `locale` is `Locale('es')` and
  `language_preference` is `es`; listeners were notified once by `setLocale`.
- Given `es` was saved, when `setLocale(null)` runs, then `language_preference` is removed and `locale` is null.
- Given `language_preference` is `xx`, when `load()` runs, then `locale` is null.
- Given saving to SharedPreferences throws, when `setLocale(Locale('fr'))` runs, then `locale` is still `Locale('fr')`,
  listeners are notified, the error is logged with `debugPrint`, and nothing is thrown (the picker in Task 3 relies on
  this, so a failed save never leaves the overlay open).
- `LocaleManager.resolve('hi', Locale('fr'))` is `hi`; `resolve(null, Locale('fr'))` is `fr`;
  `resolve(null, Locale('de'))` is `en`; `resolve('xx', Locale('de'))` is `en`.
- `supportedLanguages` lists the ten codes in the Global Constraints order, each with its native name above.
- In English, `describeCondition(l10n, 500)` is "Light rain", `describeCondition(l10n, 800)` is "Clear sky",
  `describeCondition(l10n, 599)` is "Rain", `describeCondition(l10n, 899)` is "Clouds", `describeCondition(l10n, 999)`
  and `describeCondition(l10n, null)` are "Unknown".
- Every `condition<code>` in the table exists in `AppLocalizations` (one lookup per code returns a non-empty string
  that isn't a group phrase).
- The existing test `names coordinate results that come back without a place name` still passes; a new case: given a
  nameless result and a geocoder that finds nothing, `fetchByCoords` returns a report whose name is `''`.

- [ ] **Step 1: Add the dependencies, `l10n.yaml`, `.gitignore` line and `app_en.arb`, and run `flutter pub get`** so `AppLocalizations` is generated

- [ ] **Step 2: Create `locale_manager.dart` and `conditions.dart` with the signatures above and bodies that return null / "Unknown"**, so tests fail on behaviour

- [ ] **Step 3: Write the failing tests** for each Acceptance case in `test/locale_manager_test.dart`, `test/conditions_test.dart` and `test/weather_service_test.dart`

- [ ] **Step 4: Run them to verify they fail**

Run: `flutter test test/locale_manager_test.dart test/conditions_test.dart test/weather_service_test.dart`
Expected: FAIL on the assertions.

- [ ] **Step 5: Implement `LocaleManager`, `describeCondition`, the `WeatherService` change and the `main.dart` wiring**

- [ ] **Step 6: Run them to verify they pass**

Run: `flutter test test/locale_manager_test.dart test/conditions_test.dart test/weather_service_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock l10n.yaml .gitignore lib/l10n/app_en.arb lib/l10n/conditions.dart lib/services/locale_manager.dart lib/main.dart lib/services/weather_service.dart test/locale_manager_test.dart test/conditions_test.dart test/weather_service_test.dart
git commit -m "Add the localization foundation: English strings, the language setting and descriptions by condition code."
```

---

### Task 2: Translations

**Files:**
- Create: `lib/l10n/app_zh.arb`, `lib/l10n/app_hi.arb`, `lib/l10n/app_es.arb`, `lib/l10n/app_ar.arb`,
  `lib/l10n/app_fr.arb`, `lib/l10n/app_bn.arb`, `lib/l10n/app_pt.arb`, `lib/l10n/app_ru.arb`, `lib/l10n/app_ur.arb`
- Create: `android/app/src/main/res/values-zh/strings.xml`
- Create: `android/app/src/main/res/values-hi/strings.xml`
- Create: `android/app/src/main/res/values-es/strings.xml`
- Create: `android/app/src/main/res/values-ar/strings.xml`
- Create: `android/app/src/main/res/values-fr/strings.xml`
- Create: `android/app/src/main/res/values-bn/strings.xml`
- Create: `android/app/src/main/res/values-pt/strings.xml`
- Create: `android/app/src/main/res/values-ru/strings.xml`
- Create: `android/app/src/main/res/values-ur/strings.xml`
- Test: `test/arb_files_test.dart`

**Interfaces:**
- Consumes: the keys and placeholders of `lib/l10n/app_en.arb`, `describeCondition` and `lookupAppLocalizations` from Task 1.
- Consumes: existing five string names in `android/app/src/main/res/values/strings.xml`.
- Produces: nothing other tasks call.

Each `app_<code>.arb` has `"@@locale": "<code>"`, `"@@x-reviewed": false`, and a translation of every non-`@` key in
`app_en.arb`, with the same placeholders and ICU plural forms that language needs (Arabic, Russian and others have
more than `one`/`other`). `zh` is Simplified Chinese. Each `values-<code>/strings.xml` translates the five widget
strings, keeping `%1$s`.

**Spec:**
- Out of scope: "they are machine-drafted and stay marked so in each `.arb` file's `@@x-reviewed` until a native speaker checks them."
- §7: "`values-<locale>/strings.xml` for each language gives the widget picker's description and the "Open the app" empty state in the device's language."

**Knowledge:** (written after the finish)
- `decisions/app-localization-gen-l10n`: the nine drafted `.arb` files carry `@@x-reviewed: false`.

**Acceptance:**
- For each of the nine `.arb` files: it parses as JSON, `@@locale` matches its file name, `@@x-reviewed` is `false`,
  and its non-`@` keys are exactly `app_en.arb`'s.
- For each key with placeholders in `app_en.arb` (`nextDaysSubtitle`, `widgetUpdated`, `widgetHighLow`), each
  translation contains every placeholder (`{count}` may appear only inside the plural's branches).
- Every translated value is non-empty, and no value except units, numbers and placeholders equals the English one.
- For each `values-<code>/strings.xml`: it has exactly the five names of `values/strings.xml`, and `widget_updated`
  keeps `%1$s`.
- `flutter pub get` regenerates without errors (gen-l10n rejects a malformed plural).
- `describeCondition(lookupAppLocalizations(Locale('es')), 500)` equals `condition500` in `app_es.arb`, and
  `describeCondition(lookupAppLocalizations(Locale('es')), 599)` equals its `conditionRain` (spec Testing: "checked in
  English and one other language").

- [ ] **Step 1: Write the failing test** `test/arb_files_test.dart` for each Acceptance case, reading the files from disk

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/arb_files_test.dart`
Expected: FAIL: the nine files are missing.

- [ ] **Step 3: Write the nine `.arb` files and the nine `strings.xml` files**

- [ ] **Step 4: Run `flutter pub get`, then the test, to verify it passes**

Run: `flutter test test/arb_files_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/app_zh.arb lib/l10n/app_hi.arb lib/l10n/app_es.arb lib/l10n/app_ar.arb lib/l10n/app_fr.arb lib/l10n/app_bn.arb lib/l10n/app_pt.arb lib/l10n/app_ru.arb lib/l10n/app_ur.arb android/app/src/main/res/values-zh/strings.xml android/app/src/main/res/values-hi/strings.xml android/app/src/main/res/values-es/strings.xml android/app/src/main/res/values-ar/strings.xml android/app/src/main/res/values-fr/strings.xml android/app/src/main/res/values-bn/strings.xml android/app/src/main/res/values-pt/strings.xml android/app/src/main/res/values-ru/strings.xml android/app/src/main/res/values-ur/strings.xml test/arb_files_test.dart
git commit -m "Draft the translations into nine languages, marked unreviewed."
```

---

### Task 3: Screens and the language picker

**Files:**
- Create: `lib/l10n/dates.dart`
- Delete: `lib/services/calendar.dart`
- Modify: `lib/views/weather/weather_view.dart`, `lib/views/weather/weather_error.dart`
- Modify: `lib/views/forecast/forecast.dart`, `lib/views/forecast/daily_detail_card.dart`,
  `lib/views/forecast/hourly_detail_chip.dart`
- Modify: `lib/views/menu/menu.dart`
- Modify: `lib/views/home/home.dart`, `lib/views/home/dialog_overlay.dart`
- Create: `lib/views/home/language_overlay.dart`
- Modify: `lib/main.dart` (overlay state and its `Stack` entry, the `Home` callback)
- Test: `test/dates_test.dart`, `test/language_overlay_test.dart`

**Interfaces:**
- Consumes: `AppLocalizations`, `describeCondition(l10n, code)`, `LocaleManager` and `supportedLanguages` from Task 1.
- Produces: nothing other tasks call.

```dart
// lib/l10n/dates.dart: zoneTime is already shifted to the place's offset, as the views do today.
String weekdayLabel(DateTime zoneTime, String locale);  // DateFormat.EEEE: "Monday", "lundi"
String dateLineLabel(DateTime zoneTime, String locale); // day and month (DateFormat.MMMd), weekday, time (DateFormat.jm)
String timeLabel(DateTime zoneTime, String locale);     // DateFormat.jm: "5:50 AM"

// lib/views/home/language_overlay.dart
class LanguageOverlay extends StatelessWidget {
  final int accent;
  final void Function() onClose;
  const LanguageOverlay({required this.accent, required this.onClose});
}

// lib/views/home/home.dart: new constructor parameter
final void Function() onLanguagePress;
```

- Every hard-coded string listed in spec §2 is replaced by its `AppLocalizations` key; views keep their
  `toUpperCase()`. The greeting picks `greetingMorning` and so on by the same hour rules as `getGreeting` today.
- The weather view and the daily card show `describeCondition(l10n, weather.condition)` instead of
  `weather.description`; the weather view shows `myLocation` when `weather.name` is empty.
- The date line, weekday names, the sunrise time and the hourly chip's time use `lib/l10n/dates.dart` with
  `Localizations.localeOf(context).toString()`. `CalendarHelper` is removed.
- `Home`'s top row: an `IconButton` with `Icons.translate`, `iconSize: 36`, tooltip `language`, between the hamburger
  and the forecast button, disabled (`onPressed: null`) while `loading || isDrawerOpen`, like the forecast button.
- `LanguageOverlay` is laid out like `DialogOverlay` (black87 scrim, `bgColor` card, radius 12): `systemDefault` first,
  then each `supportedLanguages` entry by `nativeName`; the current choice (null for System default) shows a check icon
  in the accent colour. Tapping a row calls `LocaleManager.setLocale` and then `onClose`. A close button calls
  `onClose` only.
- `main.dart` shows `LanguageOverlay` from an `isLanguageOpen` flag, as it does `DialogOverlay` with `isDialogOpen`.
- Right to left: in `Home`, the menu and the forecast panel, swap hand-placed `left`/`right` and `EdgeInsets.only(left/right)`
  for start/end forms (`PositionedDirectional`, `EdgeInsetsDirectional`) where they place things relative to the reading
  direction.

**Spec:**
- §5: "System default first, then the ten languages, the current choice marked with the accent colour. Choosing one closes the overlay and switches the app at once, with no restart. A close button dismisses it without changing anything."
- §3: "Weekday names, the date line, and AM/PM come from `intl`'s `DateFormat` with the active locale"
- §6: "Arabic and Urdu use Flutter's default mirroring."

**Tags:** `screen`

**Knowledge:** (written after the finish)
- `features/language-picker` (new): the translate button, the overlay's order and behaviour, `LocaleManager`.
- `features/current-weather`, `features/forecast`, `features/city-search`: shown text and dates follow the chosen
  language; descriptions come from the condition code.
- `design-system/components`: `LanguageOverlay` beside `DialogOverlay`.

**Acceptance:**
- With `initializeDateFormatting` for `en` and `fr`: `weekdayLabel` of 2026-11-02 (a Monday) is "Monday" in `en` and
  "lundi" in `fr`; `timeLabel` of 05:50 contains "5:50" and "AM" in `en` (intl may put a narrow space before AM) and is "05:50" in `fr`; `dateLineLabel` of
  2026-11-02 14:05 in `en` contains "Nov 2", "Monday", "2:05" and "PM".
- Given `LanguageOverlay` in English with no saved language, then it shows "System default" followed by the ten native
  names in order, and the check icon is on "System default".
- When "Español" is tapped, then `LocaleManager.locale` is `Locale('es')` and `onClose` was called once.
- Given `es` is chosen, when "System default" is tapped, then `locale` is null and `onClose` was called.
- When the close button is tapped, then `locale` is unchanged and `onClose` was called once.
- Given `locale` is `Locale('ar')`, when `LanguageOverlay` is pumped under `MaterialApp` with the localization
  delegates, then `Directionality.of` inside it is `TextDirection.rtl` and no exception is thrown.

- [ ] **Step 1: Create `dates.dart` and `language_overlay.dart` with the signatures above and empty bodies**

- [ ] **Step 2: Write the failing tests** for each Acceptance case in `test/dates_test.dart` and `test/language_overlay_test.dart`, with a `LocaleManager` backed by `SharedPreferences.setMockInitialValues`

- [ ] **Step 3: Run them to verify they fail**

Run: `flutter test test/dates_test.dart test/language_overlay_test.dart`
Expected: FAIL on the assertions.

- [ ] **Step 4: Implement `dates.dart` and `LanguageOverlay`**

- [ ] **Step 5: Run them to verify they pass**

Run: `flutter test test/dates_test.dart test/language_overlay_test.dart`
Expected: PASS

- [ ] **Step 6: Move the views' strings, dates and descriptions to `AppLocalizations`, add the top-row button and the overlay to `Home` and `main.dart`, delete `calendar.dart`, and switch hand-placed left/right to start/end**

- [ ] **Step 7: Run the task's tests again**

Run: `flutter test test/dates_test.dart test/language_overlay_test.dart`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add lib/l10n/dates.dart lib/services/calendar.dart lib/views/weather/weather_view.dart lib/views/weather/weather_error.dart lib/views/forecast/forecast.dart lib/views/forecast/daily_detail_card.dart lib/views/forecast/hourly_detail_chip.dart lib/views/menu/menu.dart lib/views/home/home.dart lib/views/home/dialog_overlay.dart lib/views/home/language_overlay.dart lib/main.dart test/dates_test.dart test/language_overlay_test.dart
git commit -m "Show the screens in the chosen language and add the language picker to the top row."
```

---

### Task 4: Home-screen widget in the chosen language

**Files:**
- Modify: `lib/services/weather_widget.dart`
- Modify: `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
- Test: `test/weather_widget_test.dart`

**Interfaces:**
- Consumes: `AppLocalizations` and `lookupAppLocalizations` from Task 1 (generated from its `app_en.arb`).
- Consumes: `describeCondition`, `LocaleManager.resolve` and `LocaleManager.preferenceKey` from Task 1.
- Produces: the widget data keys below, read by `WeatherWidgetProvider.kt`.

```dart
// lib/services/weather_widget.dart
/// What update() saves, keyed by widget data name ('city', 'now', 'hours', 'labels'), each value a String.
@visibleForTesting
static Map<String, String> payload(WeatherReport report, AppLocalizations l10n, String locale, DateTime updated);

/// The saved language, else the device's, else English (LocaleManager.resolve).
static Future<AppLocalizations> localizations();
```

| Widget data key | Value |
|---|---|
| `city` | the place name upper-cased, or `myLocation` upper-cased when the name is empty |
| `now` | JSON as today, with `description` = `describeCondition(...)` upper-cased and `detail` = `widgetHighLow` |
| `hours` | JSON as today, with `label` = the hour in the locale's short form (`DateFormat.j`) |
| `labels` | JSON `{"now": widgetNow upper-cased, "next24Hours": widgetNext24Hours upper-cased, "updated": widgetUpdated(time)}` with `time` from `DateFormat.Hm` |

`update(report)` gets its strings from `localizations()` and saves `payload(...)`. `WeatherWidgetProvider.kt` sets the
Now card's label (`card_label`), the hours card's title, and `card_updated` from `labels` when it is present, and from
`R.string.widget_now`, `R.string.widget_next_24_hours` and `R.string.widget_updated` otherwise.

**Spec:**
- §7: "The background refresh (`lib/services/weather_widget.dart`) reads `language_preference` and gets its strings with the generated `lookupAppLocalizations`, falling back to the device locale, then English."
- §7: "`WeatherWidgetProvider.kt` uses the pushed labels when they are there, and its `strings.xml` values otherwise (before the first update)."

**Tags:** `failure-paths`

**Knowledge:** (written after the finish)
- `features/home-screen-widget`: the widget's text follows the app's chosen language; its built-in strings follow the
  device's.
- `data/on-device-storage`: the widget data key `labels`.

**Acceptance:**
- Given an English `l10n`, a report named "Paris" with condition 500, today's max 290.65 K and min 280.65 K, when
  `payload` runs, then `city` is "PARIS", `now.description` is "LIGHT RAIN" and `now.detail` is "H 17°  L 7°".
- Given a report whose name is `''`, then `city` is "MY LOCATION".
- Given `updated` at 14:05, then `labels` is `{"now": "NOW", "next24Hours": "NEXT 24 HOURS", "updated": "Updated 14:05"}`.
- Given a report with condition null, then `now.description` is "UNKNOWN".
- Given `language_preference` is `hi` in mock SharedPreferences, when `localizations()` runs, then its `localeName`
  is `hi`; given no preference and a device locale outside the list, then it is `en`.
- Given `SharedPreferences` throws, when `update` runs on Android, then it logs with `debugPrint` and doesn't throw (as
  today's `catch`).

- [ ] **Step 1: Add `payload` and `localizations()` with their signatures and empty bodies**

- [ ] **Step 2: Write the failing tests** for each Acceptance case in `test/weather_widget_test.dart`

- [ ] **Step 3: Run them to verify they fail**

Run: `flutter test test/weather_widget_test.dart`
Expected: FAIL on the assertions.

- [ ] **Step 4: Implement `payload`, `localizations()`, and `update` saving the payload**

- [ ] **Step 5: Run them to verify they pass**

Run: `flutter test test/weather_widget_test.dart`
Expected: PASS

- [ ] **Step 6: Make `WeatherWidgetProvider.kt` read `labels`, with the `strings.xml` fallbacks**

- [ ] **Step 7: Commit**

```bash
git add lib/services/weather_widget.dart android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt test/weather_widget_test.dart
git commit -m "Feed the home-screen widget its text in the app's chosen language."
```

---

### Task 5: Translate button in the menu row

Added during the run at the developer's request, after Tasks 1–4 were merged: the translate button moves from the
home screen's top row to the menu's top button row.

**Files:**
- Modify: `lib/main.dart` (the menu's top button row, and the `Home(...)` call)
- Modify: `lib/views/home/home.dart`
- Modify: `lib/components/btn.dart`
- Create: `lib/views/menu/menu_buttons.dart`
- Test: `test/menu_buttons_test.dart`

**Interfaces:**
- Consumes: existing `LanguageOverlay` and `toggleLanguage` in `main.dart` (Task 3), existing `WeatherWidget.canPin()`
  and `WeatherWidget.pin`.
- Produces: nothing other tasks call.

```dart
// lib/components/btn.dart: new optional parameter, default 56
final double size;

// lib/views/menu/menu_buttons.dart
class MenuButtons extends StatelessWidget {
  final void Function() onRefresh;
  final void Function() onTheme;
  final Widget themeIcon;              // the sun or moon icon main.dart shows today
  final void Function()? onPinWidget;  // null hides the widget button
  final void Function() onLanguage;
  final void Function() onLocation;
  final void Function() onClose;
  const MenuButtons({...});
}
```

- `MenuButtons` lays out one `Row` with `MainAxisAlignment.spaceBetween` inside 16 dp horizontal padding: refresh,
  theme, widget (when `onPinWidget` isn't null), translate (`Icons.translate`), location, close. Refresh is the first
  child and close the last, so they sit in the far corners and mirror in right-to-left with the `Row`.
- Each button's size is `min(56, (width - 32 - 8 * (n - 1)) / n)` for `n` buttons, so 56 dp where they fit and evenly
  smaller on narrow screens.
- `main.dart` replaces its five hand-placed menu buttons (refresh, close, theme, location, and the centred widget
  button) with one `MenuButtons` at `top: 24`, wrapped in `_translateBuilder` as they are today. It keeps the
  `FutureBuilder` on `WeatherWidget.canPin()` to pass `onPinWidget`. Translate calls `toggleLanguage(true)`.
- `Home` loses the translate `IconButton` and its `onLanguagePress` parameter: its top row is the hamburger and the
  forecast button only, as on `master`.

**Spec:**
- §5: "The translate button (`Icons.translate`) is in the menu's top button row in `lib/main.dart`, not on the home screen."
- §5: "That row is one row: refresh in the far start corner, close in the far end corner, and theme, widget (only when the phone can pin widgets), translate and location justified evenly between them."
- §5: "The overlay opens above the menu; choosing a language closes the overlay and leaves the menu open."

**Tags:** `screen`

**Knowledge:** (written after the finish)
- `features/language-picker`: the translate button is in the menu's top button row.
- `design-system/components`: `MenuButtons`, and `Btn`'s `size`.

**Acceptance:**
- Given a 412 dp wide screen and `onPinWidget` set, then six buttons show in the order refresh, theme, widget,
  translate, location, close; refresh's left edge is 16 dp from the screen's left and close's right edge 16 dp from
  the right; each button is 56 dp; no exception.
- Given a 360 dp wide screen and `onPinWidget` set, then the six buttons fit with no exception, each the same size,
  smaller than 56 dp.
- Given `onPinWidget` is null, then five buttons show, without the widget button, refresh and close still in the far
  corners.
- Given `TextDirection.rtl`, then refresh is at the right edge and close at the left.
- When the translate button is tapped, then `onLanguage` is called once and no other callback.
- `Home` builds with no `onLanguagePress` parameter and shows no `Icons.translate`.

- [ ] **Step 1: Create `menu_buttons.dart` with the signature above and an empty `build`, and add `size` to `Btn`**

- [ ] **Step 2: Write the failing tests** for each Acceptance case in `test/menu_buttons_test.dart`

- [ ] **Step 3: Run them to verify they fail**

Run: `flutter test test/menu_buttons_test.dart`
Expected: FAIL on the assertions.

- [ ] **Step 4: Implement `MenuButtons`, use it in `main.dart`, and remove the translate button from `Home`**

- [ ] **Step 5: Run them to verify they pass**

Run: `flutter test test/menu_buttons_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/main.dart lib/views/home/home.dart lib/components/btn.dart lib/views/menu/menu_buttons.dart test/menu_buttons_test.dart
git commit -m "Move the translate button into the menu's top button row, with refresh and close in the corners."
```
