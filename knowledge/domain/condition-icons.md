---
type: Business Rule
title: Condition codes, icons and night
description: Every provider maps its conditions to OpenWeatherMap codes; Weather.getIcon turns a code into one of a fixed set of icon names, with a night variant by local hour.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
status: draft
---

# Condition codes, icons and night

## Rule

- **One code system.** Every provider converts its own conditions to OpenWeatherMap condition codes (each provider's
  `_conditionCode`). A doc comment in `lib/services/providers/met_norway.dart` says this is because the icons are
  keyed on those codes.
- **Code to icon.** `Weather.getIcon` in `lib/services/weather.dart` maps a code to one icon name: thunder, rain, snow,
  clear, sunny, foggy, broken or few. Clear, sunny and few have a `-night` variant. Codes not matched by a range
  there fall through to `few`. That includes some rain codes (511 and the 520s) and every 7xx atmosphere code except
  fog (741). See [debt](../risks/debt.md).
- **Night.** It is night when the local hour at the place is after 18 or at most 6. With no override, `getIcon` uses
  the current time at the place's `timezone`. Forecast chips and the widget's hour columns pass `overrideNight`
  computed from the reading's own time instead (`getNight` in `lib/views/forecast/hourly_detail_chip.dart`,
  `_isNight` in `lib/services/weather_widget.dart`). Daily cards always use the day icon (`overrideNight: ""` in
  `lib/views/forecast/daily_detail_card.dart`).
- **Where the names are used.** In the app, the icon name picks a Flare animation in
  `assets/animations/cloudy.flr`. On the widget, it picks a PNG through `iconFor` in `WeatherWidgetProvider.kt`
  ([home-screen widget](../features/home-screen-widget.md)). `tool/render_widget_icons_test.dart` holds the list of
  names it renders. A new icon name has to be added in all three places.

## Where it is enforced

- `lib/services/weather.dart` (`getIcon`)
- `_conditionCode` in `lib/services/providers/weather_api.dart`, `lib/services/providers/tomorrow_io.dart` and
  `lib/services/providers/met_norway.dart`. OpenWeatherMap's codes are used as they come.
- `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt` (`iconFor`)

## Sources

* `lib/services/weather.dart`
* `lib/services/providers/weather_api.dart`
* `lib/services/providers/tomorrow_io.dart`
* `lib/services/providers/met_norway.dart`
* `lib/views/forecast/hourly_detail_chip.dart`
* `lib/views/forecast/daily_detail_card.dart`
* `lib/services/weather_widget.dart`
* `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
* `tool/render_widget_icons_test.dart`
* `assets/animations/cloudy.flr`
