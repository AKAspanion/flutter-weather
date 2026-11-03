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
| `theme_preference` | the index of the `AppTheme` | `ThemeManager.setTheme` | `ThemeManager` at start-up |
| `accent_preference` | the index of the accent gradient | `setAccent` in `lib/main.dart` | `getAccent` in `lib/main.dart` |

The keys are string literals at the places named, or `_reportKey` and `_queryKey` in
`lib/services/weather_cache.dart`.

The widget's data (`city`, `now`, `hours`, `updated`) is written with `HomeWidget.saveWidgetData` in
`lib/services/weather_widget.dart`. `WeatherWidgetProvider.kt` reads it from the `SharedPreferences` that
`home_widget` hands it ([home-screen widget](../features/home-screen-widget.md)).

## Rules

- `WeatherCache._read` calls `prefs.reload()` first, because the widget's background refresh may have written newer
  values from another isolate (a comment there says so).
- A cached value that no longer parses is dropped, not fixed. A comment says this is for caches written by an older
  app version.
- Refreshing from the top button writes an empty `city_preference`, which switches back to the device location
  ([city search](../features/city-search.md)).

## Sources

* `lib/services/weather_cache.dart`
* `lib/main.dart`
* `lib/services/theme_manager.dart`
* `lib/services/weather_widget.dart`
* `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
