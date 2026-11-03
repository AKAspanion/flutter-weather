---
type: Data Model
title: What the app stores on the device
description: The SharedPreferences keys the app and the widget read and write, and what each holds.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# What the app stores on the device

## Fields

Everything is in `shared_preferences`. Nothing leaves the device except the provider requests and what the AdMob
SDK sends ([data protection](../security/data-protection.md)).

| Key | Holds | Written by | Read by |
| --- | --- | --- | --- |
| `last_report` | the last `WeatherReport`, as JSON | `WeatherCache.save` | `WeatherCache.loadReport`, at launch |
| `last_query` | the last `WeatherQuery`, as JSON | `WeatherCache.save` | `WeatherCache.loadQuery`, in the background refresh |
| `city_preference` | the searched city, or empty to use the device location | `setCity` in `lib/main.dart` | `getCity` in `lib/main.dart` |
| `theme_preference` | the index of the `AppTheme` the theme button chose, an override; absent when following the system | `ThemeManager.setTheme` | `ThemeManager` at start-up |
| `theme_preference_system` | the `Brightness` index the override was made against; the override ends when the system brightness differs | `ThemeManager.setTheme` | `ThemeManager` at start-up |
| `accent_preference` | the index of the accent gradient | `setAccent` in `lib/main.dart` | `getAccent` in `lib/main.dart` |
| `temperature_unit` | `celsius` or `fahrenheit`; absent means the phone's region decides | `UnitManager.setUnit` | `UnitManager.load` at start-up, and `WeatherWidget.temperatureUnit` in the background refresh |
| `language_preference` | the chosen language code, such as `fr`; absent means System default | `LocaleManager.setLocale` | `LocaleManager.load` at start-up, and `WeatherWidget.localizations` in the background refresh |

The keys are string literals at the places named, or `_reportKey` and `_queryKey` in
`lib/services/weather_cache.dart`.

The widget's data is written with `HomeWidget.saveWidgetData` in `lib/services/weather_widget.dart`: `city`, `now`
and `labels` by `update`, and `accent` (the accent's index, an int) by `setAccent`. `labels` holds the card title and
the update line in the app's chosen language. `WeatherWidgetProvider.kt` reads them from the `SharedPreferences` that
`home_widget` hands it ([home-screen widget](../features/home-screen-widget.md)). Keys the app no longer writes
(`hours`, `updated`) may remain on a device: `hours` is ignored, and `updated` is only the fallback for the update line.

## Rules

- `WeatherCache._read` calls `prefs.reload()` first, because the widget's background refresh may have written newer
  values from another isolate (a comment there says so).
- A cached value that no longer parses is dropped, not fixed. A comment says this is for caches written by an older
  app version.
- Changing the system brightness clears both theme keys (`ThemeManager._clearOverride`), also when the app was closed
  and notices at the next launch.
- Choosing System default removes `language_preference` rather than saving an empty value; an unknown saved code is
  read as System default ([language picker](../features/language-picker.md)).
- `temperature_unit` is absent until the user picks a unit; an unknown or unreadable value is read as absent, and the
  region's unit applies ([settings](../features/settings.md), [decision](../decisions/temperature-unit-by-region.md)).
- Refreshing from the menu button writes an empty `city_preference`, which switches back to the device location
  ([city search](../features/city-search.md)).

## History

- 2026-11-03: added `temperature_unit`, because the app can now show °F. See [temperature unit](../decisions/temperature-unit-by-region.md).
- 2026-11-03: added `language_preference` and the widget's `labels`; `updated` is no longer written, because the widget's text now follows the app's language. See [supported languages](../decisions/supported-languages.md).
- 2026-11-03: the widget keys were `city`, `now`, `hours` and `updated`, and `theme_preference` was the saved theme;
  now `hours` is gone, `accent` is added, and `theme_preference` is an override with `theme_preference_system`,
  because the widget became one Now card in the app's accent and the theme follows the system. See
  [decisions/theme-follows-system](../decisions/theme-follows-system.md) and
  [decisions/widget-one-resizable-card](../decisions/widget-one-resizable-card.md).

## Sources

* `lib/services/weather_cache.dart`
* `lib/main.dart`
* `lib/services/theme_manager.dart`
* `lib/services/locale_manager.dart`
* `lib/services/unit_manager.dart`
* `lib/services/weather_widget.dart`
* `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
