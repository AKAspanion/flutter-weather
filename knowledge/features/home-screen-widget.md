---
type: Feature
title: Android home-screen widget
description: A swipeable stack of two cards (now, and the next 24 hours) fed by the app and refreshed in the background for the last place viewed.
generated: { by: claude-code/claude-opus-5-5, at: 2026-11-02T19:19:02Z }
verified: human:panditankit1995@gmail.com
---

# Android home-screen widget

## What it does

A resizable home-screen widget, on Android only. It is a looping stack of two cards that the user swipes up or down
between:

- **Now:** the city, the icon, the temperature, the description, today's high and low, and when it was updated.
- **Next 24 hours:** up to `_hourColumns` columns at least `_hourStep` apart (both in `WeatherWidget`), each with a
  short hour label, an icon and the temperature.

Tapping a card opens the app. Before any data arrives, the widget shows an empty view that also opens the app.

**Updating.** Every successful fetch in the app calls `WeatherWidget.update`. `scheduleRefresh` registers a periodic
WorkManager task that needs a network. It refetches the last `WeatherQuery` in the background and updates the widget.
Its frequency and its first delay are set there. A comment says the delay is so it doesn't start a second engine
during launch. The widget itself never asks for updates (`updatePeriodMillis` is 0 in
`android/app/src/main/res/xml/weather_widget_info.xml`).

**Adding it.** If the launcher supports pinning (`WeatherWidget.canPin`), a widgets button appears at the top
centre while the menu is open. It calls `WeatherWidget.pin`.

## Screens and routes

- Flutter side: `lib/services/weather_widget.dart` (`WeatherWidget`, `widgetRefreshDispatcher`).
- Kotlin side: `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`.
- Layouts: `android/app/src/main/res/layout/weather_widget.xml`, `weather_widget_item.xml` (now),
  `weather_widget_hours.xml` and `weather_widget_hour.xml` (hours), and `weather_widget_preview.xml`, all in
  `android/app/src/main/res/layout/`. Widget info: `android/app/src/main/res/xml/weather_widget_info.xml`.
- Icons: PNGs `widget_icon_*.png` in `android/app/src/main/res/drawable-nodpi/`, rendered from the Flare animations
  by `tool/render_widget_icons_test.dart` ([run locally](../operations/run-locally.md)).

## Rules

- The background refresh uses the last place viewed in the app and never the device location. See
  [decisions/widget-uses-last-place](../decisions/widget-uses-last-place.md).
- `_androidName` names the provider by its full Kotlin class, because the Kotlin package differs from the
  application ID (a comment says so).
- `iconFor` in the Kotlin provider maps icon names to drawables one by one, instead of looking them up by name. A
  comment says this is so resource shrinking keeps them. Adding an icon name: see
  [condition icons](../domain/condition-icons.md).
- `WeatherWidget` does nothing on platforms other than Android (`_supported`).
- When the background fetch fails, the task returns false so WorkManager retries with backoff.

## Sources

* `lib/services/weather_widget.dart`
* `android/app/src/main/kotlin/com/example/flutterweather/WeatherWidgetProvider.kt`
* `android/app/src/main/res/xml/weather_widget_info.xml`
* `android/app/src/main/res/layout/weather_widget.xml`
* `android/app/src/main/res/layout/weather_widget_item.xml`
* `android/app/src/main/res/layout/weather_widget_hours.xml`
* `android/app/src/main/res/layout/weather_widget_hour.xml`
* `android/app/src/main/res/layout/weather_widget_preview.xml`
* `android/app/src/main/AndroidManifest.xml`
* `tool/render_widget_icons_test.dart`
* `lib/main.dart`
