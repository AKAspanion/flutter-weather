# Translate the app into the ten most spoken languages, with an in-app language picker

Date: 2026-11-03. Branch: `feat/app-localization`.

## Why

Play Console says "Your app text is not automatically translated". Play's automatic translation only reads Android
string resources, and this app's only ones are the five widget strings in
`android/app/src/main/res/values/strings.xml`. Everything else is hard-coded English in Dart, so the app can't be
shown in any other language, by Play or by us.

## Decisions this rests on

- [decisions/app-localization-gen-l10n](../../knowledge/decisions/app-localization-gen-l10n.md): Flutter `gen_l10n`
  with `.arb` files, translations drafted by Claude and marked unreviewed, rather than routing every string through
  Android `strings.xml` so Play could translate it.
- [decisions/descriptions-by-condition-code](../../knowledge/decisions/descriptions-by-condition-code.md): the
  description shown is a translated phrase per OpenWeatherMap condition code, not the provider's English text.
- [decisions/supported-languages](../../knowledge/decisions/supported-languages.md): the ten most spoken languages by
  total speakers (Ethnologue), plus "System default".
- [decisions/android-only](../../knowledge/decisions/android-only.md): built and checked on Android only.

## Languages

| Locale | Name shown in the picker |
|---|---|
| `en` | English (source, and the fallback) |
| `zh` | 中文 (Simplified) |
| `hi` | हिन्दी |
| `es` | Español |
| `ar` | العربية (right to left) |
| `fr` | Français |
| `bn` | বাংলা |
| `pt` | Português |
| `ru` | Русский |
| `ur` | اردو (right to left) |

Each language shows in its own script, so a user who can't read the current language can still find theirs.

## What changes

### 1. Localization setup

- `pubspec.yaml`: `flutter_localizations` (sdk), `intl`, and `flutter: generate: true`.
- `l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`,
  generated into the source tree (not a synthetic package), so the background isolate can import it too.
- `lib/l10n/app_en.arb` holds every user-facing string, with an `@key` description for each. One `app_<locale>.arb`
  per language above.
- `MaterialApp` in `lib/main.dart` gets `localizationsDelegates`, `supportedLocales` and `locale` from
  `LocaleManager`. `title` stays "Beautiful Weather": it is the product name.

### 2. Strings moved to the `.arb` files

- Weather view: greetings (good morning / afternoon / evening / night), and the sunrise, wind and humidity chip
  labels.
- "My location": `WeatherService` (`lib/services/weather_service.dart`) has no locale, so it leaves the place name
  empty when no geocoder names the coordinates, and the weather view and the widget show the translated "My location"
  for an empty name. A report cached before this change still holds the English text until the next refresh.
- Forecast: "Next hours", "Forecast for the next 48 hours", "Next days", "Forecast for the next {count} days" (an ICU
  plural), "Min", "Max".
- City dialog: "City name". Menu: "Privacy". Error view: "Error fetching weather details". Snackbar: "Couldn't update
  the weather, showing the last result".
- Upper-casing stays where the views do it today (`toUpperCase()`), so the `.arb` text is in sentence case.
- Not translated: the accent names in `lib/theme/gradients.dart` (Lush, Scooter, …; brand-like names), provider
  names, units (`°C`, `m/s`, `%`), and the data attribution line, which the providers' terms ask for as written.

### 3. Dates and times

- `lib/services/calendar.dart`'s weekday and month lists are removed. Weekday names, the date line, and AM/PM come from
  `intl`'s `DateFormat` with the active locale (`DateFormat.EEEE`, `DateFormat.MMMd`, `DateFormat.jm`).
- The time zone handling doesn't change: views still shift the reading by the place's `timezone` offset before
  formatting.

### 4. Weather descriptions by condition code

- A new `describeCondition(AppLocalizations l10n, int? code)` in `lib/l10n/conditions.dart` returns the phrase for an
  OpenWeatherMap code. Every code OpenWeatherMap documents (2xx, 3xx, 5xx, 6xx, 7xx, 800 to 804) has its own key,
  `condition<code>` (for example `condition500` "light rain").
- A code with no key falls back to its group's phrase (thunderstorm, drizzle, rain, snow, mist, clouds), and a null
  code to "Unknown".
- The weather view, the daily cards and the widget show `describeCondition(...)` instead of `weather.description`.
  `Weather.description` stays in the model and the cache, unused for display, so cached reports keep loading.

### 5. Language picker

- `lib/services/locale_manager.dart`: a `LocaleManager` `ChangeNotifier`, like `ThemeManager`. It holds the chosen
  `Locale?` (null means System default), saves the language code under the SharedPreferences key
  `language_preference`, removes the key for System default, and restores it at start. An unknown saved code is
  treated as System default.
- With System default, Flutter picks the phone's language when it is in the list, otherwise English.
- The translate button (`Icons.translate`) is in the menu's top button row in `lib/main.dart`, not on the home
  screen. That row is one row: refresh in the far start corner, close in the far end corner, and theme, widget (only
  when the phone can pin widgets), translate and location justified evenly between them. It mirrors in right-to-left.
  Its buttons stay 56 dp where they fit and shrink evenly on narrow screens (a 360 dp phone). `Home`'s top row is the
  hamburger and the forecast button only, as before this feature.
- Tapping translate opens `lib/views/home/language_overlay.dart`, styled like the city dialog in `dialog_overlay.dart`:
  System default first, then the ten languages, the current choice marked with the accent colour. Choosing one closes
  the overlay and switches the app at once, with no restart. A close button dismisses it without changing anything.
- `main.dart` shows and hides the overlay as it does the city dialog. The overlay opens above the menu; choosing a
  language closes the overlay and leaves the menu open.

### 6. Right to left

- Arabic and Urdu use Flutter's default mirroring. Places that position things by hand (the menu slide, the
  top-left and top-right buttons, the forecast panel) are checked on an emulator in Arabic and fixed to use
  start/end where they look wrong.

### 7. Home-screen widget

- The background refresh (`lib/services/weather_widget.dart`) reads `language_preference` and gets its strings with
  the generated `lookupAppLocalizations`, falling back to the device locale, then English. It runs without a
  `BuildContext`.
- Data pushed from Dart is in the app's language: the description (by condition code), the high and low line, the
  hour labels, and three labels the widget shows: Now, Next 24 hours, Updated.
- `WeatherWidgetProvider.kt` uses the pushed labels when they are there, and its `strings.xml` values otherwise (before
  the first update).
- `values-<locale>/strings.xml` for each language gives the widget picker's description and the "Open the app" empty
  state in the device's language. Play's automatic translation would cover these too.

### 8. Fonts

- No fonts are added. Montserrat has no Devanagari, Bengali, Arabic or Han glyphs, so Android falls back to its system
  fonts for those scripts: the text is correct, in a different typeface.

### 9. Knowledge

- New feature concept `features/language-picker`, and the three decisions above.
- `data/on-device-storage`: the `language_preference` key.
- `domain/condition-icons`: descriptions now come from the code too.
- `features/home-screen-widget`, `features/current-weather`, `features/forecast`, `features/city-search`: shown text is
  translated; a `## History` line where behaviour changed.
- Log the change.

## Testing

Test first where it's behaviour:

- `LocaleManager`: saves and restores a language; System default removes the key; an unknown saved code restores as
  System default.
- `describeCondition`: a known code gives its own phrase, an unknown code in a group gives the group's phrase, null
  gives Unknown; checked in English and one other language.
- Every `app_<locale>.arb` has exactly the keys of `app_en.arb`, and the same placeholders.
- At the end: `flutter analyze` and smoke. A run on an Android emulator in English, Hindi and Arabic to look at layout
  and right to left.

## Out of scope

- Reviewing the drafted translations: they are machine-drafted and stay marked so in each `.arb` file's `@@x-reviewed`
  until a native speaker checks them.
- Translating the Play store listing: done in Play Console's store listing translations.
- Android's system per-app language setting (Settings, App languages): the in-app picker is the way to choose.
- Bundling Noto fonts for the non-Latin scripts.
